import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_crypto.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_transaction.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_vault.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final path = Platform.environment['N42_PQ_LIBRARY'];
  if (path == null) {
    test(
      'native Falcon suite requires compiled library',
      () {},
      skip: 'Set N42_PQ_LIBRARY to libn42_pq',
    );
    return;
  }
  final crypto = FalconCrypto(DynamicLibrary.open(path));
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('real signatures reject changed message and wrong public key', () {
    final a = crypto.generate(), b = crypto.generate();
    final msg = Uint8List(32)..[0] = 1;
    final signature = crypto.sign(a.secretKey, msg);
    expect(signature.length, 666);
    expect(crypto.verify(a.publicKey, msg, signature), true);
    expect(crypto.verify(b.publicKey, msg, signature), false);
    msg[0] = 2;
    expect(crypto.verify(a.publicKey, msg, signature), false);
    a.secretKey.fillRange(0, a.secretKey.length, 0);
    b.secretKey.fillRange(0, b.secretKey.length, 0);
  });
  test('invalid imported secret key is rejected before native signing', () {
    final malformed = Uint8List(1281)..[0] = 0x59;
    expect(() => crypto.sign(malformed, Uint8List(32)), throwsA(anything));
  });
  test('transaction digest binds all fields and key ownership', () {
    final pair = crypto.generate();
    FalconTransaction tx({int chain = 94, int nonce = 0, int value = 1}) =>
        FalconTransaction(
          chainId: BigInt.from(chain),
          nonce: BigInt.from(nonce),
          recipient: '0x2222222222222222222222222222222222222222',
          value: BigInt.from(value),
          gas: BigInt.from(21000),
          tipCap: BigInt.one,
          feeCap: BigInt.two,
          publicKey: pair.publicKey,
        );
    final base = tx();
    final sig = crypto.sign(pair.secretKey, base.digest);
    expect(crypto.verify(pair.publicKey, base.digest, sig), true);
    for (final other in [tx(chain: 95), tx(nonce: 1), tx(value: 2)]) {
      expect(crypto.verify(pair.publicKey, other.digest, sig), false);
    }
    final key = base.publicKey;
    key[0] ^= 1;
    expect(base.publicKey, pair.publicKey);
    final output = Platform.environment['N42_PQ_VECTOR_OUTPUT'];
    if (output != null) {
      File(output).writeAsStringSync(
        jsonEncode({
          ...base.review(),
          'preimage': bytesToHex(base.signingPreimage, include0x: true),
          'signature': bytesToHex(sig, include0x: true),
          'rawTransaction': bytesToHex(base.encodeSigned(sig), include0x: true),
        }),
      );
    }
    pair.secretKey.fillRange(0, pair.secretKey.length, 0);
  });
  test(
    'encrypted backup survives restart; wrong password and scope do not sign',
    () async {
      final vault = FalconVault(crypto, 'account-a');
      await vault.create();
      final before = await vault.publicKey();
      expect(await vault.backupVerified(), false);
      final blob = await vault.backup('long-test-password');
      expect((jsonDecode(blob) as Map).keys, isNot(contains('secret')));
      await vault.verifyBackup(blob, 'long-test-password');
      expect(await vault.backupVerified(), true);
      final restored = FalconVault(crypto, 'account-b');
      await expectLater(
        restored.restore(blob, 'wrong-password-123'),
        throwsA(anything),
      );
      expect(await restored.publicKey(), isNull);
      await restored.restore(blob, 'long-test-password');
      expect(await restored.publicKey(), before);
      final reopened = FalconVault(crypto, 'account-b');
      final msg = Uint8List(32)..[0] = 7;
      expect(crypto.verify(before!, msg, await reopened.sign(msg)), true);
      await expectLater(restored.create(), throwsStateError);
      await expectLater(
        restored.restore(blob, 'long-test-password'),
        throwsStateError,
      );
      await expectLater(
        FalconVault(crypto, 'empty').sign(msg),
        throwsStateError,
      );
    },
  );
}
