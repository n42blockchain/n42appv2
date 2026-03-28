import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/error/exceptions.dart';
import 'package:n42_wallet/core/wallet_sdk/wallet_signer.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('trustdart');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('WalletSigner', () {
    test('signTransaction throws when native returns empty data', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'signTransaction') {
          return '';
        }
        return null;
      });

      await expectLater(
        WalletSigner(Trustdart()).signTransaction(
          coin: 'ETH',
          path: "m/44'/60'/0'/0/0",
          txData: const {'to': '0x1'},
        ),
        throwsA(
          isA<TransactionException>().having(
            (e) => e.code,
            'code',
            'SIGNING_FAILED',
          ),
        ),
      );
    });

    test(
      'signTransactionWithGas throws when native returns empty data',
      () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'signTransaction_g') {
            return '';
          }
          return null;
        });

        await expectLater(
          WalletSigner(Trustdart()).signTransactionWithGas(
            coin: 'ETH',
            path: "m/44'/60'/0'/0/0",
            txData: const {'to': '0x1'},
          ),
          throwsA(isA<TransactionException>()),
        );
      },
    );

    test('signBtcP2wsh throws when native returns empty data', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'signTransaction_btc_p2wsh') {
          return '';
        }
        return null;
      });

      await expectLater(
        WalletSigner(
          Trustdart(),
        ).signBtcP2wsh(path: "m/84'/0'/0'/0/0", txData: const {'inputs': []}),
        throwsA(isA<TransactionException>()),
      );
    });

    test('signTransactionByteArray throws on invalid payload', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'signTransaction_byteArray') {
          return '{"result": true, "signHash": ""}';
        }
        return null;
      });

      await expectLater(
        WalletSigner(Trustdart()).signTransactionByteArray(
          coin: 'SOL',
          path: "m/44'/501'/0'/0'",
          txData: const {'message': 'abc'},
        ),
        throwsA(
          isA<TransactionException>().having(
            (e) => e.code,
            'code',
            'SIGNING_FAILED',
          ),
        ),
      );
    });

    test(
      'getMaxTransactionValue throws when native returns empty data',
      () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getTransactionMaxValue') {
            return '';
          }
          return null;
        });

        await expectLater(
          WalletSigner(Trustdart()).getMaxTransactionValue(
            coin: 'ETH',
            path: "m/44'/60'/0'/0/0",
            txData: const {'gasLimit': '21000'},
          ),
          throwsA(
            isA<TransactionException>().having(
              (e) => e.code,
              'code',
              'MAX_VALUE_FAILED',
            ),
          ),
        );
      },
    );
  });
}
