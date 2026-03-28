import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/error/exceptions.dart';
import 'package:n42_wallet/core/wallet_sdk/wallet_key_manager.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('trustdart');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('WalletKeyManager', () {
    test(
      'importFromKeystore falls back to first non-empty address variant',
      () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getWalletInfoWithKeyStore') {
            return {
              'address': {'legacy': '', 'segwit': ' bc1qkeystoreaddress '},
              'privateKey': 'private-key',
            };
          }
          return null;
        });

        final info = await WalletKeyManager(Trustdart()).importFromKeystore(
          keyStore: '{"crypto":{}}',
          coin: 'BTC',
          passphrase: 'password',
        );

        expect(info.address, 'bc1qkeystoreaddress');
        expect(info.privateKey, 'private-key');
      },
    );

    test('getKeyPair rejects malformed native payloads', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getPrivateKeyAndPublicKey') {
          return 'private-only';
        }
        return null;
      });

      await expectLater(
        WalletKeyManager(
          Trustdart(),
        ).getKeyPair(coin: 'ETH', path: "m/44'/60'/0'/0/0"),
        throwsA(
          isA<WalletException>().having(
            (e) => e.code,
            'code',
            'KEY_PAIR_DERIVATION_FAILED',
          ),
        ),
      );
    });
  });
}
