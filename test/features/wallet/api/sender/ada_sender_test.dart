import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/ada_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends AdaApi {
  _Api({super.projectId = 'fixture-project'});
  VoidCallback? onAccount;
  int broadcasts = 0;
  bool errorResult = false;
  bool throwsOnSend = false;
  String hash = 'ab' * 32;
  VoidCallback? onSend;
  int reads = 0;
  bool? testnet;
  @override
  Future<MessageModel> getAddressInfo(
    String address, {
    bool isTest = false,
  }) async {
    reads++;
    onAccount?.call();
    return MessageModel()
      ..data = {
        'amount': [
          {'unit': 'lovelace', 'quantity': '10000000'},
        ],
      };
  }

  bool tokenOnly = false;
  bool wrongInputOwner = false;
  dynamic slot = 100000;
  VoidCallback? onUtxos;
  @override
  Future<MessageModel> getAddressUtxos(
    String address, {
    bool isTest = false,
  }) async {
    onUtxos?.call();
    return MessageModel()
      ..data = [
        {
          'tx_hash': 'ab' * 32,
          'address': wrongInputOwner ? 'addr_other' : 'addr_confirmed',
          'output_index': 2,
          'amount': [
            {'unit': 'lovelace', 'quantity': '10000000'},
            if (tokenOnly) {'unit': 'ab' * 28, 'quantity': '1'},
          ],
        },
      ];
  }

  VoidCallback? onBlock;
  @override
  Future<MessageModel> getLatestBlock({bool isTest = false}) async {
    onBlock?.call();
    return MessageModel()..data = {'slot': slot};
  }

  @override
  Future<MessageModel> sendTransaction(
    String txXdr, {
    bool isTest = false,
  }) async {
    expect(txXdr, '0x00ff');
    broadcasts++;
    onSend?.call();
    if (throwsOnSend) throw StateError('lost response');
    if (errorResult) return MessageModel.error()..data = 'offline';
    testnet = isTest;
    return MessageModel()..data = hash;
  }
}

class _Signer extends Trustdart {
  String address = 'addr_confirmed';
  VoidCallback? onDerive;
  VoidCallback? onSign;
  int signatures = 0;
  String quoteFee = '200000';
  VoidCallback? onPlan;
  bool brokenQuote = false;
  @override
  Future<Map<String, dynamic>> planCardanoTransaction(
    Map<String, dynamic> txData,
  ) async {
    onPlan?.call();
    if (brokenQuote) return {};
    final maximum = txData['useMaxAmount'] == true;
    final fee = BigInt.parse(quoteFee);
    final amount = maximum
        ? BigInt.from(10000000) - fee
        : BigInt.parse(txData['amount'] as String);
    return {
      'amount': amount.toString(),
      'fee': quoteFee,
      'change': (BigInt.from(10000000) - amount - fee).toString(),
      'available': '10000000',
    };
  }

  bool invalidPlan = false;
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
    expect(coin, 'ADA');
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
    expect(coin, 'ADA');
    expect(path, derivedPath);
    expect(mnemonic, derivedMnemonic);
    expect(pk, derivedKey);
    signatures++;
    payload = txData;
    onSign?.call();
    final amount = txData['useMaxAmount'] == true
        ? BigInt.from(9800000)
        : BigInt.parse(txData['amount'] as String);
    return jsonEncode({
      'encoded': '0x00ff',
      'txHash': 'ab' * 32,
      'amount': invalidPlan ? '1' : amount.toString(),
      'fee': '200000',
      'change': (BigInt.from(9800000) - amount).toString(),
      'available': '10000000',
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await S.load(const Locale('en'));
  });
  for (final (amount, quoted, expectMax, ok) in [
    (10.0, true, true, true),
    (9.0, true, false, false),
    (9.0, false, false, true),
  ]) {
    test('sendMax amount=$amount quoted=$quoted', () async {
      final signer = _Signer();
      final result =
          await AdaSender(
            api: _Api(),
            trustdart: signer,
            ownerIdentity: () => 'owner',
            readMnemonic: () => 'fixture mnemonic',
          ).send(
            SendParams(
              coinType: 'ADA',
              fromAddress: 'addr_confirmed',
              toAddress: 'addr_recipient',
              amount: amount,
              decimals: 6,
              path: "m/1852'/1815'/0'/0/2",
              sendMax: true,
              expectedFeeBaseUnits: quoted ? BigInt.from(200000) : null,
            ),
          );
      if (!ok) {
        // A reviewed maximum whose balance moved is never sent as an exact
        // transfer of the old balance.
        expect(result.success, isFalse);
        expect(result.txHash, isNull);
        expect(signer.signatures, 0);
        return;
      }
      expect(signer.signatures, 1);
      expect(signer.payload!['useMaxAmount'], expectMax);
      if (expectMax) expect(result.actualAmount, 9.8);
    });
  }
  for (final scenario in [
    'same fee',
    'new fee',
    'malformed',
    'signed fee differs',
    'owner changes',
  ]) {
    test('reviewed fee: $scenario', () async {
      Object owner = Object();
      final signer = _Signer();
      final api = _Api();
      final expected = scenario == 'signed fee differs' ? 100000 : 200000;
      if (scenario == 'new fee') signer.quoteFee = '300000';
      if (scenario == 'signed fee differs') signer.quoteFee = '100000';
      if (scenario == 'malformed') signer.brokenQuote = true;
      if (scenario == 'owner changes') signer.onPlan = () => owner = Object();
      final sender = AdaSender(
        api: api,
        trustdart: signer,
        ownerIdentity: () => owner,
        readMnemonic: () => 'fixture mnemonic',
      );
      final result = await sender.send(
        SendParams(
          coinType: 'ADA',
          fromAddress: 'addr_confirmed',
          toAddress: 'addr_recipient',
          amount: 1.25,
          decimals: 6,
          path: "m/1852'/1815'/0'/0/2",
          expectedFeeBaseUnits: BigInt.from(expected),
        ),
      );
      expect(result.success, scenario == 'same fee');
      expect(api.broadcasts, scenario == 'same fee' ? 1 : 0);
      expect(
        signer.signatures,
        ['same fee', 'signed fee differs'].contains(scenario) ? 1 : 0,
      );
    });
  }
  for (final scenario in [
    'mnemonic',
    'private key',
    'testnet',
    'send max',
    'wrong address',
    'empty address',
    'address case',
    'owner during RPC',
    'owner during UTxO',
    'owner during block',
    'invalid slot',
    'token-only inputs',
    'wrong input owner',
    'invalid native plan',
    'missing project',
    'key during RPC',
    'owner during derivation',
    'key during derivation',
    'owner during signing',
    'key during signing',
    'no owner',
    'empty key',
    'owner reader failure',
  ]) {
    test(scenario, () async {
      Object? owner = Object();
      var mnemonic = 'captured mnemonic';
      final api = _Api(
        projectId: scenario == 'missing project' ? '' : 'fixture-project',
      );
      api.slot = scenario == 'invalid slot' ? null : 100000;
      api.tokenOnly = scenario == 'token-only inputs';
      api.wrongInputOwner = scenario == 'wrong input owner';
      final signer = _Signer()..invalidPlan = scenario == 'invalid native plan';
      void changeOwner() {
        owner = Object();
      }

      void changeKey() {
        mnemonic = 'replacement mnemonic';
      }

      switch (scenario) {
        case 'wrong address':
          signer.address = 'addr_other';
        case 'empty address':
          signer.address = '';
        case 'address case':
          signer.address = 'ADDR_CONFIRMED';
        case 'owner during RPC':
          api.onAccount = changeOwner;
        case 'owner during block':
          api.onBlock = changeOwner;
        case 'owner during UTxO':
          api.onUtxos = changeOwner;
        case 'key during RPC':
          api.onAccount = changeKey;
        case 'owner during derivation':
          signer.onDerive = changeOwner;
        case 'key during derivation':
          signer.onDerive = changeKey;
        case 'owner during signing':
          signer.onSign = changeOwner;
        case 'key during signing':
          signer.onSign = changeKey;
        case 'no owner':
          owner = null;
        case 'empty key':
          mnemonic = '';
      }
      final privateKey = scenario == 'private key' ? 'explicit key' : null;
      final sender = AdaSender(
        api: api,
        trustdart: signer,
        ownerIdentity: () {
          if (scenario == 'owner reader failure') {
            throw StateError('unavailable');
          }
          return owner;
        },
        readMnemonic: () {
          if (privateKey != null) {
            fail('Private-key send must not read mnemonic');
          }
          return mnemonic;
        },
      );
      final result = await sender.send(
        SendParams(
          coinType: 'ADA',
          fromAddress: 'addr_confirmed',
          toAddress: 'addr_recipient',
          amount: scenario == 'send max' ? 10 : 1.25,
          decimals: 6,
          path: "m/1852'/1815'/0'/0/2",
          privateKey: privateKey,
          memo: 'invoice 42',
          isTest: scenario == 'testnet',
          sendMax: scenario == 'send max',
        ),
      );
      final success = [
        'mnemonic',
        'private key',
        'testnet',
        'send max',
      ].contains(scenario);
      expect(result.success, success);
      expect(api.broadcasts, success ? 1 : 0);
      expect(
        signer.signatures,
        success ||
                scenario.endsWith('during signing') ||
                scenario == 'invalid native plan'
            ? 1
            : 0,
      );
      if (success) {
        expect(result.txHash, 'ab' * 32);
        expect(signer.derivedPath, "m/1852'/1815'/0'/0/2");
        expect(
          signer.derivedMnemonic,
          privateKey == null ? 'captured mnemonic' : '',
        );
        expect(
          signer.payload!['amount'],
          scenario == 'send max' ? '10000000' : '1250000',
        );
        expect(signer.payload!['returnMetadata'], isTrue);
        expect(signer.payload!['useMaxAmount'], scenario == 'send max');
        expect(signer.payload!['ttl'], '103600');
        expect(signer.payload!['changeAddress'], 'addr_confirmed');
        expect(signer.payload!['toAddress'], 'addr_recipient');
        expect(signer.payload!['utxos'], [
          {
            'txHash': 'ab' * 32,
            'address': 'addr_confirmed',
            'outputIndex': 2,
            'amount': '10000000',
          },
        ]);
        expect(result.actualAmount, scenario == 'send max' ? 9.8 : 1.25);
        expect(api.testnet, scenario == 'testnet');
      }
      if ([
        'no owner',
        'missing project',
        'empty key',
        'owner reader failure',
      ].contains(scenario)) {
        expect(api.reads, 0);
      }
    });
  }
  for (final scenario in [
    'accepted',
    'dispatch failure',
    'owner during dispatch',
    'persist failure',
    'owner during persist',
    'transport error',
    'transport throw',
    'foreign hash',
  ]) {
    test('submission recovery: $scenario', () async {
      Object owner = Object();
      var dispatchRecorded = false;
      final api = _Api()
        ..errorResult = scenario == 'transport error'
        ..throwsOnSend = scenario == 'transport throw'
        ..hash = scenario == 'foreign hash' ? 'cd' * 32 : 'ab' * 32;
      final saved = <String>[];
      api.onSend = () {
        expect(saved, ['ab' * 32]);
        expect(dispatchRecorded, isTrue);
      };
      final sender = AdaSender(
        api: api,
        trustdart: _Signer(),
        ownerIdentity: () => owner,
        readMnemonic: () => 'fixture mnemonic',
      );
      final result = await sender.send(
        SendParams(
          coinType: 'ADA',
          fromAddress: 'addr_confirmed',
          toAddress: 'addr_recipient',
          amount: 1.25,
          decimals: 6,
          path: "m/1852'/1815'/0'/0/2",
          onBroadcastStarting: (hash) async {
            expect(hash, 'ab' * 32);
            expect(saved, ['ab' * 32]);
            if (scenario == 'dispatch failure') {
              throw StateError('dispatch storage failed');
            }
            if (scenario == 'owner during dispatch') owner = Object();
            dispatchRecorded = true;
          },
          beforeBroadcast: (hash) async {
            saved.add(hash);
            if (scenario == 'persist failure') {
              throw StateError('storage failed');
            }
            if (scenario == 'owner during persist') owner = Object();
          },
        ),
      );
      final aborted = [
        'dispatch failure',
        'owner during dispatch',
        'persist failure',
        'owner during persist',
      ].contains(scenario);
      expect(saved, ['ab' * 32]);
      expect(api.broadcasts, aborted ? 0 : 1);
      expect(result.success, scenario == 'accepted');
      expect(result.txHash, 'ab' * 32);
      expect(result.definitelyNotSubmitted, aborted);
      if (!aborted) expect(result.actualAmount, 1.25);
    });
  }
}
