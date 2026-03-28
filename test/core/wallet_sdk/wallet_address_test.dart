import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/error/exceptions.dart';
import 'package:n42_wallet/core/wallet_sdk/wallet_address.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('trustdart');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('WalletAddress.generateAddress', () {
    test(
      'falls back to the first non-empty address when legacy is empty',
      () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'generateAddress') {
            return {'legacy': ' ', 'segwit': 'bc1qexampleaddress'};
          }
          return null;
        });

        final account = await WalletAddress(Trustdart()).generateAddress(
          coin: 'BTC',
          path: "m/84'/0'/0'/0/0",
          addressType: 'legacy',
        );

        expect(account.address, 'bc1qexampleaddress');
        expect(account.addresses, {'segwit': 'bc1qexampleaddress'});
      },
    );

    test('throws when native returns only empty addresses', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'generateAddress') {
          return {'legacy': '', 'segwit': '  '};
        }
        return null;
      });

      await expectLater(
        WalletAddress(Trustdart()).generateAddress(
          coin: 'BTC',
          path: "m/84'/0'/0'/0/0",
          addressType: 'legacy',
        ),
        throwsA(
          isA<WalletException>().having(
            (e) => e.code,
            'code',
            'ADDRESS_GENERATION_FAILED',
          ),
        ),
      );
    });
  });
}
