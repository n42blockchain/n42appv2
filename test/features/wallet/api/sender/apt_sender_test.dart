import 'package:flutter/widgets.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/apt_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends AptApi {
  BigInt price = BigInt.from(7);
  int priceReads = 0;
  int submits = 0;
  @override
  Future<MessageModel> getBalance(
    String address, {
    String contract = '',
    String tokenName = '',
  }) async => MessageModel()..data = BigInt.from(10000000);
  @override
  Future<MessageModel> getGasPrice() async {
    priceReads++;
    return MessageModel()..data = price;
  }

  @override
  Future<MessageModel> getAccountInfo(String address) async =>
      MessageModel()..data = 0;
  @override
  Future<MessageModel> getServiceInfo() async =>
      MessageModel()..data = 2000000000000000;
  @override
  Future<MessageModel> sendTxHash(String signedHex) async {
    submits++;
    return MessageModel()..data = 'accepted';
  }
}

class _Signer extends Trustdart {
  Map? received;
  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    received = txData;
    // No broadcast: stop at the native boundary to inspect the approved fields.
    return '';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('en')));
  for (final price in [BigInt.zero, -BigInt.one, BigInt.one << 63]) {
    test('invalid gas price stops before signing: $price', () async {
      final api = _Api()..price = price;
      final signer = _Signer();
      final result = await AptSender(trustdart: signer, apiFactory: (_) => api)
          .send(
            const SendParams(
              coinType: 'APT',
              fromAddress: 'owner',
              toAddress: 'recipient',
              amount: 1,
              decimals: 0,
              path: '',
              privateKey: 'public-test-only',
            ),
          );
      expect(result.success, false);
      expect(signer.received, isNull);
      expect(api.submits, 0);
    });
  }
  for (final isTest in [false, true]) {
    for (final price in [7, 123]) {
      test(
        'Aptos price and gas units stay distinct on testnet=$isTest price=$price',
        () async {
          final api = _Api()..price = BigInt.from(price);
          final signer = _Signer();
          final sender = AptSender(
            trustdart: signer,
            apiFactory: (selectedTestnet) {
              expect(selectedTestnet, isTest);
              return api;
            },
          );
          // The current chain registry uses network-specific config fields.
          final result = await sender.send(
            SendParams(
              coinType: 'APT',
              fromAddress: 'owner',
              toAddress: 'recipient',
              amount: 10000000,
              decimals: 0,
              path: '',
              privateKey: 'public-test-only',
              sendMax: true,
              isTest: isTest,
              chainConfig: {'chainId': 1, 'chainId_test': 2},
            ),
          );
          expect(result.success, false);
          expect(signer.received, isNotNull);
          expect(api.priceReads, 1);
          expect(signer.received!['gasUnitPrice'], price);
          expect(signer.received!['maxGasAmount'], 10000);
          expect(signer.received!['amount'], 10000000 - price * 10000);
          expect(signer.received!['chainId'], isTest ? 2 : 1);
          expect(api.submits, 0);
        },
      );
    }
  }
}
