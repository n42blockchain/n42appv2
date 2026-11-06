import 'package:flutter/widgets.dart';

import '../../../../native/aptos_reference_vectors.dart';

import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/apt_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends AptApi {
  BigInt price = BigInt.from(7);
  BigInt balance = BigInt.from(10000000);
  dynamic chainId = 1;
  int? expectedChain;
  dynamic sequence = BigInt.zero;
  dynamic timestamp = BigInt.from(2000000000000000);
  int priceReads = 0;
  int submits = 0;
  void Function()? onLedger;
  void Function()? onPrice;
  @override
  Future<MessageModel> getBalance(
    String address, {
    String contract = '',
    String tokenName = '',
  }) async => MessageModel()..data = balance;
  @override
  Future<MessageModel> getGasPrice() async {
    priceReads++;
    onPrice?.call();
    return MessageModel()..data = price;
  }

  @override
  Future<MessageModel> getAccountInfo(String address) async =>
      MessageModel()..data = sequence;
  @override
  Future<MessageModel> getServiceInfo({int? expectedChainId}) async {
    onLedger?.call();
    expectedChain = expectedChainId;
    return AptApi(
      read: (_) async => {'chain_id': chainId, 'ledger_timestamp': timestamp},
    ).getServiceInfo(expectedChainId: expectedChainId);
  }

  @override
  Future<MessageModel> sendTxHash(String signedHex) async {
    submits++;
    return MessageModel()..data = 'accepted';
  }
}

class _Signer extends Trustdart {
  Map? received;
  void Function()? onSign;
  String signed = '';
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
    onSign?.call();
    // No broadcast: stop at the native boundary to inspect the approved fields.
    return signed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('en')));
  test('RPC maximum sequence and microseconds reach signer exactly', () async {
    final max = (BigInt.one << 64) - BigInt.one;
    final api = _Api()
      ..sequence = max
      ..timestamp = max;
    final signer = _Signer();
    await AptSender(
      ownerIdentity: () => 'test-owner',
      trustdart: signer,
      apiFactory: (_) => api,
    ).send(
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
    expect(signer.received!['SequenceNumber'], max.toString());
    expect(signer.received!['expirationTimestampSecs'], '18446744073769');
    expect(api.submits, 0);
  });
  for (final defaultConfig in [false, true]) {
    for (final nodeFollowsMutation in [false, true]) {
      test(
        'network snapshot default=$defaultConfig nodeChanges=$nodeFollowsMutation',
        () async {
          final config = <String, dynamic>{'chainId': 1};
          final api = _Api();
          api.onPrice = () {
            config['chainId'] = 2;
            if (nodeFollowsMutation) api.chainId = 2;
          };
          final signer = _Signer();
          await AptSender(
            ownerIdentity: () => 'owner',
            chainConfig: defaultConfig ? config : null,
            trustdart: signer,
            apiFactory: (_) => api,
          ).send(
            SendParams(
              coinType: 'APT',
              fromAddress: 'owner',
              toAddress: 'recipient',
              amount: 1,
              decimals: 0,
              path: '',
              privateKey: 'public-test-only',
              chainConfig: defaultConfig ? null : config,
            ),
          );
          expect(config['chainId'], 2);
          expect(api.expectedChain, 1);
          if (nodeFollowsMutation) {
            expect(signer.received, isNull);
          } else {
            expect(signer.received!['chainId'], 1);
          }
          expect(api.submits, 0);
        },
      );
    }
  }
  for (final phase in ['unchanged', 'ledger', 'signer']) {
    test('owner binding across $phase await', () async {
      Object? owner = 'original';
      final api = _Api();
      final signer = _Signer()
        ..signed = aptosReferenceVectors.first['signed'] as String;
      if (phase == 'ledger') api.onLedger = () => owner = 'replacement';
      if (phase == 'signer') signer.onSign = () => owner = 'replacement';
      final result =
          await AptSender(
            ownerIdentity: () => owner,
            trustdart: signer,
            apiFactory: (_) => api,
          ).send(
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
      expect(result.success, phase == 'unchanged');
      expect(api.submits, phase == 'unchanged' ? 1 : 0);
      expect(signer.received == null, phase == 'ledger');
    });
  }
  test('missing owner stops before network and signing', () async {
    final api = _Api();
    final signer = _Signer();
    final result =
        await AptSender(
          ownerIdentity: () => null,
          trustdart: signer,
          apiFactory: (_) => api,
        ).send(
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
    expect(api.priceReads, 0);
    expect(signer.received, isNull);
    expect(api.submits, 0);
  });
  for (final field in ['sequence', 'timestamp']) {
    for (final value in [null, -1, 1.5, '18446744073709551616']) {
      test('invalid $field stops native dispatch: $value', () async {
        final api = _Api();
        if (field == 'sequence') {
          api.sequence = value;
        } else {
          api.timestamp = value;
        }
        final signer = _Signer();
        final result =
            await AptSender(
              ownerIdentity: () => 'test-owner',
              trustdart: signer,
              apiFactory: (_) => api,
            ).send(
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
  }
  for (final reported in [null, 2, 0, 256, '1', true, 1.5]) {
    test('wrong or malformed RPC chain blocks signing: $reported', () async {
      final api = _Api()..chainId = reported;
      final signer = _Signer();
      final result =
          await AptSender(
            ownerIdentity: () => 'test-owner',
            trustdart: signer,
            apiFactory: (_) => api,
          ).send(
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
      expect(api.expectedChain, 1);
      expect(signer.received, isNull);
      expect(api.submits, 0);
    });
  }
  for (final token in [false, true]) {
    for (final exact in [
      BigInt.parse('9007199254740993'),
      (BigInt.one << 64) - BigInt.one,
      BigInt.one << 64,
      BigInt.zero,
      -BigInt.one,
    ]) {
      test(
        'exact amount takes precedence token=$token amount=$exact',
        () async {
          final api = _Api()..balance = BigInt.one << 65;
          final signer = _Signer();
          await AptSender(
            ownerIdentity: () => 'test-owner',
            trustdart: signer,
            apiFactory: (_) => api,
          ).send(
            SendParams(
              coinType: 'APT',
              fromAddress: 'owner',
              toAddress: 'recipient',
              amount: 1,
              decimals: 8,
              tokenDecimals: 6,
              path: '',
              privateKey: 'public-test-only',
              contractAddress: token ? '0x1' : '',
              valueWeiOverride: token ? BigInt.from(123) : exact,
              tokenValueWeiOverride: token ? exact : BigInt.from(123),
            ),
          );
          if (exact > BigInt.zero && exact < (BigInt.one << 64)) {
            expect(signer.received!['amount'], exact.toString());
          } else {
            expect(signer.received, isNull);
          }
          expect(api.submits, 0);
        },
      );
    }
    test('decimal text uses asset decimals token=$token', () async {
      final api = _Api()..balance = BigInt.from(1000000000);
      final signer = _Signer();
      await AptSender(
        ownerIdentity: () => 'test-owner',
        trustdart: signer,
        apiFactory: (_) => api,
      ).send(
        SendParams(
          coinType: 'APT',
          fromAddress: 'owner',
          toAddress: 'recipient',
          amount: 9,
          decimalAmountOverride: '1.234567',
          decimals: 8,
          tokenDecimals: 6,
          path: '',
          privateKey: 'public-test-only',
          contractAddress: token ? '0x1' : '',
        ),
      );
      expect(signer.received!['amount'], token ? '1234567' : '123456700');
      expect(api.submits, 0);
    });
  }
  for (final price in [BigInt.zero, -BigInt.one, BigInt.one << 64]) {
    test('invalid gas price stops before signing: $price', () async {
      final api = _Api()..price = price;
      final signer = _Signer();
      final result =
          await AptSender(
            ownerIdentity: () => 'test-owner',
            trustdart: signer,
            apiFactory: (_) => api,
          ).send(
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
          final api = _Api()
            ..price = BigInt.from(price)
            ..chainId = isTest ? 2 : 1;
          final signer = _Signer();
          final sender = AptSender(
            ownerIdentity: () => 'test-owner',
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
          expect(signer.received!['gasUnitPrice'], price.toString());
          expect(signer.received!['maxGasAmount'], 10000);
          expect(
            signer.received!['amount'],
            (10000000 - price * 10000).toString(),
          );
          expect(signer.received!['chainId'], isTest ? 2 : 1);
          expect(api.expectedChain, isTest ? 2 : 1);
          expect(api.submits, 0);
        },
      );
    }
  }
}
