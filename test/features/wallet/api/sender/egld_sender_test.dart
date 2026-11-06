import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/egld_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _Signer extends Trustdart {
  String address = 'erd1sender';
  VoidCallback? onDerive;
  VoidCallback? onSign;
  int signatures = 0;
  String? derivedMnemonic;
  String? derivedKey;
  String? derivedPath;
  Map? payload;
  @override
  Future<Map> generateAddress(
    String coin,
    String path,
    String addressType, {
    String mnemonic = '',
    String passphrase = '',
    String pk = '',
    bool isImport = false,
    bool isTest = false,
  }) async {
    expect(coin, 'EGLD');
    expect(addressType, 'legacy');
    derivedMnemonic = mnemonic;
    derivedKey = pk;
    derivedPath = path;
    onDerive?.call();
    return {'legacy': address};
  }

  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    expect(coin, 'EGLD');
    expect(path, derivedPath);
    expect(mnemonic, derivedMnemonic);
    expect(pk, derivedKey);
    signatures++;
    payload = txData;
    onSign?.call();
    return 'signed-json';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => S.load(const Locale('en')));
  test(
    'real Trustdart channel carries the native MultiversX contract',
    () async {
      const channel = MethodChannel('trustdart');
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call.method);
            final args = call.arguments as Map;
            expect(args['coin'], 'EGLD');
            expect(args['path'], "m/44'/508'/0'/0'/2'");
            expect(args['pk'], 'fixture key');
            if (call.method == 'generateAddress') {
              return {'legacy': 'erd1sender'};
            }
            expect(call.method, 'signTransaction');
            expect(args['txData'], {
              'toAddress': 'erd1recipient',
              'amount': '1000000000000000000',
              'nonce': '7',
              'gasPrice': '1000000000',
              'gasLimit': '50000',
              'chainId': 'T',
              'version': '1',
              'data': '',
            });
            return 'signed-json';
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final sender = EgldSender(
        ownerIdentity: () => 'fixture owner',
        getAccount: (_) async => {
          'nonce': 7,
          'balance': '10000000000000000000',
        },
        broadcast: (_, signed) async {
          expect(signed, 'signed-json');
          return {'txHash': 'accepted-hash'};
        },
      );
      final result = await sender.send(
        const SendParams(
          coinType: 'EGLD',
          fromAddress: 'erd1sender',
          toAddress: 'erd1recipient',
          amount: 1,
          decimals: 18,
          path: "m/44'/508'/0'/0'/2'",
          privateKey: 'fixture key',
          isTest: true,
        ),
      );
      expect(result.success, isTrue);
      expect(calls, ['generateAddress', 'signTransaction']);
    },
  );
  for (final scenario in [
    'mnemonic',
    'private key',
    'testnet',
    'max',
    'exact amount',
    'wrong address',
    'empty address',
    'no owner',
    'empty mnemonic',
    'owner during RPC',
    'key during RPC',
    'owner during derivation',
    'key during derivation',
    'owner during signing',
    'key during signing',
    'invalid account',
    'missing nonce',
    'negative nonce',
    'invalid balance',
    'derive fails',
    'sign fails',
    'insufficient balance',
  ]) {
    test(scenario, () async {
      Object? owner = scenario == 'no owner' ? null : Object();
      var mnemonic = scenario == 'empty mnemonic' ? '' : 'captured mnemonic';
      final signer = _Signer();
      var broadcasts = 0;
      void mutate(String stage) {
        if (scenario == 'owner during $stage') owner = Object();
        if (scenario == 'key during $stage') mnemonic = 'changed mnemonic';
      }

      signer.onDerive = () {
        mutate('derivation');
        if (scenario == 'derive fails') throw StateError('native failure');
      };
      signer.onSign = () {
        mutate('signing');
        if (scenario == 'sign fails') throw StateError('native failure');
      };
      if (scenario == 'wrong address') signer.address = 'erd1other';
      if (scenario == 'empty address') signer.address = '';
      final key = scenario == 'private key' ? 'explicit key' : null;
      final base = scenario == 'testnet'
          ? 'https://testnet-api.multiversx.com'
          : 'https://api.multiversx.com';
      final sender = EgldSender(
        trustdart: signer,
        ownerIdentity: () => owner,
        readMnemonic: () {
          if (key != null) fail('Explicit key must not load a mnemonic');
          return mnemonic;
        },
        getAccount: (url) async {
          expect(url, '$base/accounts/erd1sender');
          mutate('RPC');
          if (scenario == 'invalid account') return [];
          if (scenario == 'missing nonce') {
            return {'balance': '10000000000000000000'};
          }
          return <String, dynamic>{
            'nonce': scenario == 'negative nonce' ? -1 : 7,
            'balance': scenario == 'invalid balance'
                ? 'not a number'
                : '10000000000000000000',
          };
        },
        broadcast: (url, signed) async {
          expect(url, '$base/transactions');
          expect(signed, 'signed-json');
          broadcasts++;
          return {'txHash': 'accepted-hash'};
        },
      );
      final result = await sender.send(
        SendParams(
          coinType: 'EGLD',
          fromAddress: 'erd1sender',
          toAddress: 'erd1recipient',
          amount: scenario == 'max'
              ? 10
              : scenario == 'insufficient balance'
              ? 20
              : 1.25,
          decimals: 18,
          path: "m/44'/508'/0'/0'/2'",
          privateKey: key,
          decimalAmountOverride: scenario == 'exact amount'
              ? '1.250000000000000001'
              : null,
          memo: 'invoice 42',
          isTest: scenario == 'testnet',
          sendMax: scenario == 'max',
        ),
      );
      final success = [
        'mnemonic',
        'private key',
        'testnet',
        'max',
        'exact amount',
      ].contains(scenario);
      expect(result.success, success);
      expect(broadcasts, success ? 1 : 0);
      expect(
        signer.signatures,
        success ||
                scenario.endsWith('during signing') ||
                scenario == 'sign fails'
            ? 1
            : 0,
      );
      if (success) {
        expect(result.txHash, 'accepted-hash');
        expect(signer.derivedMnemonic, key == null ? 'captured mnemonic' : '');
        expect(signer.derivedKey, key ?? '');
        expect(signer.payload!['nonce'], '7');
        expect(signer.payload!['toAddress'], 'erd1recipient');
        expect(signer.payload!['gasLimit'], '50000');
        expect(signer.payload!['gasPrice'], '1000000000');
        expect(signer.payload!['version'], '1');
        expect(signer.payload!.keys.toSet(), {
          'nonce',
          'amount',
          'toAddress',
          'gasLimit',
          'gasPrice',
          'chainId',
          'version',
          'data',
        });
        expect(signer.payload!['chainId'], scenario == 'testnet' ? 'T' : '1');
        expect(signer.payload!['data'], 'invoice 42');
        expect(
          signer.payload!['amount'],
          scenario == 'max'
              ? '9999950000000000000'
              : scenario == 'exact amount'
              ? '1250000000000000001'
              : '1250000000000000000',
        );
      }
    });
  }
}
