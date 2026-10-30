import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/features/wallet/policy/restricted_signer.dart';
import 'package:n42_wallet/features/wallet/policy/evm_policy_signer.dart';

void main() {
  sqfliteFfiInit();
  test('offline signer binds approved integer amount, address and chain to signed bytes', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    // Public deterministic fixture, never funded.
    final key = EthPrivateKey.fromInt(BigInt.one);
    const recipient = '0x2222222222222222222222222222222222222222';
    const token = '0x4444444444444444444444444444444444444444';
    final units = BigInt.parse('900719925474099312345678');
    await RestrictedSigner.initialize(db);
    await SigningPolicyAdmin(db, delaySeconds: 10, now: () => 1).install(
      'fixture',
      SigningPolicy(
        chainId: 31337,
        account: key.address.with0x,
        asset: token,
        recipients: {recipient},
        perTransfer: units,
        perPeriod: units,
        periodSeconds: 100,
        expiresAt: 100,
        maxFee: BigInt.from(100000),
      ),
    );
    RestrictedTransfer? approved;
    final signer = createEvmPolicySigner(
      database: db,
      scope: 'fixture',
      credentials: key,
      approve: (tx) async {
        approved = tx;
        return true;
      },
      now: () => 1,
    );
    final intent = RestrictedTransfer(
      chainId: 31337,
      account: key.address.with0x,
      recipient: recipient,
      asset: token,
      units: units,
      nonce: BigInt.zero,
      gasLimit: BigInt.from(60000),
      gasPrice: BigInt.one,
    );
    final signed = await signer.sign('one', intent);
    expect(identical(approved, intent), true);
    final decoded = decodeFields(hexToBytes(signed));
    expect(bytesToHex(decoded[3] as List<int>, include0x: true), token);
    expect(decoded[4], isEmpty); // zero native value
    expect(bytesToHex(decoded[5] as List<int>, include0x: true), intent.data);
    final v = bytesToUnsignedInt(Uint8List.fromList(decoded[6]));
    expect((v - BigInt.from(35)) ~/ BigInt.two, BigInt.from(31337));
    await expectLater(signer.sign('one', intent), throwsStateError);
  });
}

// Independent minimal RLP decoder for a flat legacy transaction fixture.
List<Uint8List> decodeFields(Uint8List bytes) {
  var cursor = bytes[0] <= 247 ? 1 : 1 + bytes[0] - 247;
  final result = <Uint8List>[];
  while (cursor < bytes.length) {
    final prefix = bytes[cursor++];
    if (prefix < 128) {
      result.add(Uint8List.fromList([prefix]));
      continue;
    }
    var length = prefix - 128;
    if (prefix > 183) {
      final count = prefix - 183;
      length = 0;
      for (var i = 0; i < count; i++) {
        length = length * 256 + bytes[cursor++];
      }
    }
    result.add(bytes.sublist(cursor, cursor + length));
    cursor += length;
  }
  return result;
}
