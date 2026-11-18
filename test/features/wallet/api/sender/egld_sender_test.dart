import 'dart:convert';
import 'dart:io';

import 'package:n42_wallet/features/wallet/utils/chain/memo_expiry_proof.dart';
import 'package:n42_wallet/features/wallet/services/egld_transaction_hash.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/egld_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';

String signedFixture(Map payload) => jsonEncode({
  'sender': 'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
  'receiver': payload['toAddress'],
  'value': payload['amount'],
  'nonce': int.parse(payload['nonce'] as String),
  'gasPrice': int.parse(payload['gasPrice'] as String),
  'gasLimit': int.parse(payload['gasLimit'] as String),
  'chainID': payload['chainId'],
  'version': int.parse(payload['version'] as String),
  'data': base64Encode(utf8.encode(payload['data'] as String)),
  'signature': '03' * 64,
});

class _Signer extends Trustdart {
  String address =
      'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7';
  VoidCallback? onDerive;
  VoidCallback? onSign;
  int signatures = 0;
  String? derivedMnemonic;
  String? derivedKey;
  String? derivedPath;
  Map? payload;
  String Function(String)? alterSigned;
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
    final signed = signedFixture(txData);
    return alterSigned?.call(signed) ?? signed;
  }
}

Map<String, dynamic> networkConfig({
  bool testnet = false,
  Map<String, dynamic> overrides = const {},
}) => {
  'code': 'successful',
  'data': {
    'config': {
      'erd_chain_id': testnet ? 'T' : '1',
      'erd_denomination': 18,
      'erd_min_gas_limit': 50000,
      'erd_gas_per_data_byte': 1500,
      'erd_min_gas_price': 1000000000,
      'erd_max_gas_per_transaction': 600000000,
      'erd_min_transaction_version': 1,
      ...overrides,
    },
  },
};

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
              return {
                'legacy': 'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
              };
            }
            expect(call.method, 'signTransaction');
            expect(args['txData'], {
              'toAddress': 'erd1qgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqjv7g5k',
              'amount': '1000000000000000000',
              'nonce': '7',
              'gasPrice': '1000000000',
              'gasLimit': '50000',
              'chainId': 'T',
              'version': '1',
              'data': '',
            });
            return signedFixture(args['txData'] as Map);
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final sender = EgldSender(
        ownerIdentity: () => 'fixture owner',
        getNetworkConfig: (url) async {
          expect(url, 'https://testnet-api.multiversx.com/network/config');
          return networkConfig(testnet: true);
        },
        getAccount: (_) async => {
          'nonce': 7,
          'balance': '10000000000000000000',
        },
        broadcast: (_, signed) async {
          return {'txHash': EgldTransactionHash.compute(signed)};
        },
      );
      final result = await sender.send(
        const SendParams(
          coinType: 'EGLD',
          fromAddress:
              'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
          toAddress:
              'erd1qgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqjv7g5k',
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
  final nativeRows =
      (jsonDecode(
            File('test/fixtures/multiversx/transaction_hashes.json')
                .readAsStringSync(),
          ) as Map)['vectors']
          as List;
  for (final row in nativeRows.where(
    (row) =>
        row['name'] == 'walletcore-native-1' ||
        row['name'] == 'walletcore-native-T',
  )) {
    test(
      'real WalletCore output survives sender checks: ${row['name']}',
      () async {
        final tx = row['transaction'] as Map;
        final signer = _Signer()
          ..address = tx['sender'] as String
          ..alterSigned = (_) => jsonEncode(tx);
        var broadcasts = 0;
        final sender = EgldSender(
          trustdart: signer,
          ownerIdentity: () => 'owner',
          readMnemonic: () => 'fixture',
          getAccount: (_) async => {
            'nonce': 0,
            'balance': '20000000000000000000',
          },
          getNetworkConfig: (_) async =>
              networkConfig(testnet: tx['chainID'] == 'T'),
          broadcast: (_, signed) async {
            broadcasts++;
            expect(EgldTransactionHash.compute(signed), row['hash']);
            return {'txHash': row['hash']};
          },
        );
        final result = await sender.send(
          SendParams(
            coinType: 'EGLD',
            fromAddress: tx['sender'] as String,
            toAddress: tx['receiver'] as String,
            amount: 10,
            decimals: 18,
            path: "m/44'/508'/0'/0'/2'",
            memo: '你好🙂',
            isTest: tx['chainID'] == 'T',
          ),
        );
        expect(result.success, isTrue);
        expect(result.txHash, row['hash']);
        expect(broadcasts, 1);
      },
    );
  }
  for (final scenario in [
    'accepted',
    'rejected',
    'gateway error',
    'timeout',
    'missing hash',
    'wrong hash',
    'malformed response',
    'save fails',
    'dispatch fails',
    'owner after save',
    'key after save',
    'owner after dispatch',
    'key after dispatch',
    'owner during broadcast',
  ]) {
    test('submission boundary: $scenario', () async {
      Object owner = Object();
      var mnemonic = 'fixture mnemonic';
      final stages = <String>[];
      String? original;
      final proofs = <String>[];
      final sender = EgldSender(
        trustdart: _Signer(),
        ownerIdentity: () => owner,
        readMnemonic: () => mnemonic,
        getAccount: (_) async => {
          'nonce': 7,
          'balance': '10000000000000000000',
        },
        getNetworkConfig: (_) async => networkConfig(),
        broadcast: (_, signed) async {
          stages.add('broadcast');
          expect(EgldTransactionHash.compute(signed), original);
          if (scenario == 'timeout') throw StateError('timeout');
          if (scenario == 'owner during broadcast') owner = Object();
          if (scenario == 'missing hash') return <String, dynamic>{};
          if (scenario == 'wrong hash') return {'txHash': '00' * 32};
          if (scenario == 'malformed response') return [];
          if (scenario == 'rejected') {
            return HttpStatusResult(400, {
              'message': 'lowerNonceInTx: true',
              'error': 'Bad Request',
              'statusCode': 400,
            });
          }
          if (scenario == 'gateway error') {
            return const HttpStatusResult(502, '<html>Bad gateway</html>');
          }
          return {'txHash': original!.toUpperCase()};
        },
      );
      final result = await sender.send(
        SendParams(
          coinType: 'EGLD',
          fromAddress:
              'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
          toAddress:
              'erd1qgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqjv7g5k',
          amount: 1,
          decimals: 18,
          path: "m/44'/508'/0'/0'/0'",
          onExpiryProof: (proof) {
            expect(original, isNull, reason: 'proof precedes the save');
            proofs.add(proof);
          },
          beforeBroadcast: (hash) async {
            original = hash;
            stages.add('save');
            if (scenario == 'save fails') throw StateError('disk full');
            if (scenario == 'owner after save') owner = Object();
            if (scenario == 'key after save') mnemonic = 'other';
          },
          onBroadcastStarting: (hash) async {
            expect(hash, original);
            stages.add('dispatch');
            if (scenario == 'dispatch fails') throw StateError('disk full');
            if (scenario == 'owner after dispatch') owner = Object();
            if (scenario == 'key after dispatch') mnemonic = 'other';
          },
        ),
      );
      final notSubmitted =
          scenario.contains('fails') || scenario.contains('after');
      expect(result.txHash, original);
      expect(result.definitelyNotSubmitted, notSubmitted);
      expect(result.definitelyRejected, scenario == 'rejected');
      expect(
        stages.where((s) => s == 'broadcast').length,
        notSubmitted ? 0 : 1,
      );
      expect(
        result.success,
        scenario == 'accepted' || scenario == 'owner during broadcast',
      );
      if (!notSubmitted) expect(stages, ['save', 'dispatch', 'broadcast']);
      // The signed nonce lets the poller prove a later nonce consumption.
      expect(proofs, [MemoExpiryProof.multiversx(nonce: BigInt.from(7))]);
    });
  }
  for (final field in [
    'sender',
    'receiver',
    'value',
    'nonce',
    'gasPrice',
    'gasLimit',
    'chainID',
    'version',
    'data',
  ]) {
    test('native output mismatch in $field never saves or broadcasts', () async {
      final signer = _Signer()
        ..alterSigned = (signed) {
          final tx = jsonDecode(signed) as Map<String, dynamic>;
          tx[field] = switch (field) {
            'sender' =>
              'erd1qgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqjv7g5k',
            'receiver' =>
              'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
            'value' => '2',
            'nonce' => 8,
            'gasPrice' => 2,
            'gasLimit' => 60000,
            'chainID' => 'T',
            'version' => 2,
            _ => base64Encode(utf8.encode('other')),
          };
          return jsonEncode(tx);
        };
      final sender = EgldSender(
        trustdart: signer,
        ownerIdentity: () => 'owner',
        readMnemonic: () => 'fixture',
        getAccount: (_) async => {
          'nonce': 7,
          'balance': '10000000000000000000',
        },
        getNetworkConfig: (_) async => networkConfig(),
        broadcast: (_, _) async => fail('must not broadcast'),
      );
      final result = await sender.send(
        SendParams(
          coinType: 'EGLD',
          fromAddress:
              'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
          toAddress:
              'erd1qgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqjv7g5k',
          amount: 1,
          decimals: 18,
          path: "m/44'/508'/0'/0'/0'",
          beforeBroadcast: (_) async =>
              fail('must not save mismatched transaction'),
        ),
      );
      expect(result.success, isFalse);
      expect(result.txHash, isNull);
      expect(result.error, contains('differs'));
    });
  }
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
    'unicode memo',
    'repriced fees',
    'owner during fees',
    'key during fees',
    'wrong network',
    'bad config',
    'fee RPC failure',
    'gas exceeds limit',
    'invalid gas price',
    'reviewed fee changed',
    'reviewed fee matches',
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
        getNetworkConfig: (url) async {
          expect(url, '$base/network/config');
          mutate('fees');
          if (scenario == 'fee RPC failure') throw StateError('offline');
          if (scenario == 'bad config') return {'code': 'successful'};
          return networkConfig(
            testnet: scenario == 'testnet',
            overrides: {
              if (scenario == 'wrong network') 'erd_chain_id': 'D',
              if (scenario == 'gas exceeds limit')
                'erd_max_gas_per_transaction': 50000,
              if (scenario == 'invalid gas price')
                'erd_min_gas_price': '1000000000',
              if (scenario == 'repriced fees') 'erd_min_gas_limit': 60000,
              if (scenario == 'repriced fees') 'erd_min_gas_price': 2000000000,
              if (scenario == 'repriced fees') 'erd_gas_per_data_byte': 2000,
            },
          );
        },
        getAccount: (url) async {
          expect(
            url,
            '$base/accounts/erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
          );
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
          expect(jsonDecode(signed)['sender'], signer.address);
          broadcasts++;
          return {'txHash': EgldTransactionHash.compute(signed)};
        },
      );
      final result = await sender.send(
        SendParams(
          coinType: 'EGLD',
          fromAddress:
              'erd1qyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqsl6e0p7',
          toAddress:
              'erd1qgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqjv7g5k',
          amount: scenario == 'max'
              ? 10
              : scenario == 'insufficient balance'
              ? 20
              : 1.25,
          decimals: 18,
          path: "m/44'/508'/0'/0'/2'",
          privateKey: key,
          expectedFeeBaseUnits: scenario == 'reviewed fee changed'
              ? BigInt.one
              : scenario == 'reviewed fee matches'
              ? BigInt.from(65000000000000)
              : null,
          decimalAmountOverride: scenario == 'exact amount'
              ? '1.250000000000000001'
              : null,
          memo: scenario == 'unicode memo' ? '你好🙂' : 'invoice 42',
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
        'unicode memo',
        'repriced fees',
        'reviewed fee matches',
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
        expect(
          result.txHash,
          EgldTransactionHash.compute(signedFixture(signer.payload!)),
        );
        expect(signer.derivedMnemonic, key == null ? 'captured mnemonic' : '');
        expect(signer.derivedKey, key ?? '');
        expect(signer.payload!['nonce'], '7');
        expect(
          signer.payload!['toAddress'],
          'erd1qgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqyqszqgpqjv7g5k',
        );
        expect(
          signer.payload!['gasLimit'],
          scenario == 'repriced fees' ? '80000' : '65000',
        );
        expect(
          signer.payload!['gasPrice'],
          scenario == 'repriced fees' ? '2000000000' : '1000000000',
        );
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
        expect(
          signer.payload!['data'],
          scenario == 'unicode memo' ? '你好🙂' : 'invoice 42',
        );
        expect(
          signer.payload!['amount'],
          scenario == 'max'
              ? '9999935000000000000'
              : scenario == 'exact amount'
              ? '1250000000000000001'
              : '1250000000000000000',
        );
      }
    });
  }
}
