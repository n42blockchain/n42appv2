import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:n42_wallet/features/wallet/policy/restricted_signer.dart';

const account = '0x1111111111111111111111111111111111111111';
const recipient = '0x2222222222222222222222222222222222222222';
const attacker = '0x3333333333333333333333333333333333333333';
const token = '0x4444444444444444444444444444444444444444';
SigningPolicy policy({
  int expiry = 1000,
  int limit = 10,
  String asset = 'native',
}) => SigningPolicy(
  chainId: 1,
  account: account,
  asset: asset,
  recipients: {recipient},
  perTransfer: BigInt.from(limit),
  perPeriod: BigInt.from(20),
  periodSeconds: 100,
  expiresAt: expiry,
  maxFee: BigInt.from(100000),
);
RestrictedTransfer transfer({
  int chain = 1,
  String to = recipient,
  int amount = 10,
  int nonce = 0,
  String asset = 'native',
  String from = account,
  int gasPrice = 1,
}) => RestrictedTransfer(
  chainId: chain,
  account: from,
  recipient: to,
  asset: asset,
  units: BigInt.from(amount),
  nonce: BigInt.from(nonce),
  gasLimit: BigInt.from(21000),
  gasPrice: BigInt.from(gasPrice),
);
void main() {
  sqfliteFfiInit();
  late Database db;
  late SigningPolicyAdmin admin;
  late RestrictedSigner signer;
  var now = 1;
  var calls = 0;
  var approval = true;
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    now = 1;
    calls = 0;
    approval = true;
    await RestrictedSigner.initialize(db);
    admin = SigningPolicyAdmin(db, delaySeconds: 10, now: () => now);
    await admin.install('session', policy());
    signer = RestrictedSigner(
      database: db,
      scope: 'session',
      now: () => now,
      approve: (_) async => approval,
      sign: (_) async {
        calls++;
        return 'signed';
      },
    );
  });
  tearDown(() => db.close());
  test('policy denies red-team routing, asset, amount, fees and account changes before signing', () async {
    final attacks = [
      transfer(chain: 2),
      transfer(to: attacker),
      transfer(amount: 11),
      transfer(asset: token),
      transfer(from: attacker),
      transfer(gasPrice: 100),
    ];
    for (final tx in attacks) {
      await expectLater(signer.sign('attack', tx), throwsStateError);
    }
    expect(calls, 0);
  });
  test('human approval and expiry cannot be supplied by agent', () async {
    approval = false;
    await expectLater(signer.sign('a', transfer()), throwsStateError);
    approval = true;
    now = 1000;
    await expectLater(signer.sign('a', transfer()), throwsStateError);
    expect(calls, 0);
  });
  test('concurrent requests enforce rolling budget atomically', () async {
    final results = await Future.wait(
      List.generate(10, (i) async {
        try {
          await signer.sign('r$i', transfer(nonce: i));
          return true;
        } catch (_) {
          return false;
        }
      }),
    );
    expect(results.where((x) => x).length, 2);
    expect(calls, 2);
  });
  test('same request and same nonce never sign twice', () async {
    await signer.sign('a', transfer());
    await expectLater(signer.sign('a', transfer(nonce: 1)), throwsStateError);
    await expectLater(signer.sign('b', transfer()), throwsStateError);
    expect(calls, 1);
  });
  test('timeout remains reserved across facade restart', () async {
    final failing = RestrictedSigner(
      database: db,
      scope: 'session',
      now: () => now,
      approve: (_) async => true,
      sign: (_) async => throw TimeoutException('unknown'),
    );
    await expectLater(
      failing.sign('a', transfer()),
      throwsA(isA<TimeoutException>()),
    );
    await expectLater(signer.sign('a', transfer()), throwsStateError);
    await signer.sign('b', transfer(nonce: 1));
    await expectLater(signer.sign('c', transfer(nonce: 2)), throwsStateError);
    expect(calls, 1);
  });
  test('policy re-read after delayed human approval', () async {
    final gate = Completer<bool>();
    final delayed = RestrictedSigner(
      database: db,
      scope: 'session',
      now: () => now,
      approve: (_) => gate.future,
      sign: (_) async {
        calls++;
        return 'signed';
      },
    );
    final future = delayed.sign('a', transfer());
    await admin.freeze('session');
    gate.complete(true);
    await expectLater(future, throwsStateError);
    expect(calls, 0);
  });
  test('owner change requires timelock and preserves usage', () async {
    await signer.sign('a', transfer());
    await admin.propose('session', policy(limit: 20));
    await expectLater(admin.activate('session'), throwsStateError);
    now = 11;
    await admin.activate('session');
    await expectLater(
      signer.sign('b', transfer(amount: 20, nonce: 1)),
      throwsStateError,
    );
    await signer.sign('c', transfer(nonce: 2));
    expect(calls, 2);
  });
  test(
    'freeze cancels pending relaxation and requires new delayed recovery',
    () async {
      await admin.propose('session', policy());
      await admin.freeze('session');
      now = 12;
      await expectLater(admin.activate('session'), throwsStateError);
      await expectLater(signer.sign('a', transfer()), throwsStateError);
      await admin.propose('session', policy());
      now = 22;
      await admin.activate('session');
      await signer.sign('a', transfer());
    },
  );
  test(
    'clock rollback fails closed and scope identity cannot change',
    () async {
      now = 50;
      await signer.sign('a', transfer());
      now = 49;
      await expectLater(signer.sign('b', transfer(nonce: 1)), throwsStateError);
      await expectLater(
        admin.propose('session', policy(asset: token)),
        throwsStateError,
      );
    },
  );
  test('ERC20 payload binds recipient and exact integer to selector', () {
    final tx = transfer(asset: token);
    expect(tx.payload['to'], token);
    expect(tx.payload['value'], '0');
    expect(
      tx.data,
      '0xa9059cbb${recipient.substring(2).padLeft(64, '0')}${'a'.padLeft(64, '0')}',
    );
    expect(() => tx.payload['to'] = attacker, throwsUnsupportedError);
    expect(tx.digest, isNot(transfer(asset: token, to: attacker).digest));
  });
}
