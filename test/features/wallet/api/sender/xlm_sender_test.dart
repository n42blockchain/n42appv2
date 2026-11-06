import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xlm_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/xlm_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends XlmApi {
  VoidCallback? onAccount;
  VoidCallback? onLedger;
  bool ledgerError = false;
  bool malformedLedger = false;
  int fee = 100;
  bool submissionError = false;
  bool submissionThrows = false;
  String hash = 'ab' * 32;
  VoidCallback? onSend;
  int broadcasts = 0;
  int reads = 0;
  bool? testnet;
  @override
  Future<MessageModel> getAccount(String address, {bool isTest = false}) async {
    reads++;
    onAccount?.call();
    return MessageModel()
      ..data = {
        'sequence': '7',
        'subentry_count': 0,
        'num_sponsoring': 0,
        'num_sponsored': 0,
        'balances': [
          {'asset_type': 'native', 'balance': '10', 'selling_liabilities': '0'},
        ],
      };
  }

  @override
  Future<MessageModel> getLatestLedger({bool isTest = false}) async {
    onLedger?.call();
    if (ledgerError) return MessageModel.error();
    if (malformedLedger) return MessageModel()..data = {};
    return MessageModel()
      ..data = {
        '_embedded': {
          'records': [
            {'base_reserve_in_stroops': 5000000, 'base_fee_in_stroops': fee},
          ],
        },
      };
  }

  @override
  Future<MessageModel> sendTransaction(
    String txXdr, {
    bool isTest = false,
  }) async {
    expect(txXdr, '+/8=');
    broadcasts++;
    testnet = isTest;
    onSend?.call();
    if (submissionThrows) throw StateError('Lost response');
    if (submissionError) return MessageModel.error();
    return MessageModel()..data = {'hash': hash};
  }
}

class _Signer extends Trustdart {
  String address = 'GCONFIRMED';
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
    expect(coin, 'XLM');
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
    expect(coin, 'XLM');
    expect(path, derivedPath);
    expect(mnemonic, derivedMnemonic);
    expect(pk, derivedKey);
    signatures++;
    payload = txData;
    onSign?.call();
    return jsonEncode({'encoded': '+/8=', 'txHash': 'ab' * 32});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await S.load(const Locale('en'));
  });
  for (final scenario in [
    'mnemonic',
    'private key',
    'testnet',
    'send max',
    'reserve overdraw',
    'ledger error',
    'malformed ledger',
    'owner during ledger',
    'one stroop',
    'current base fee',
    'wrong address',
    'empty address',
    'address case',
    'owner during RPC',
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
      final api = _Api();
      final signer = _Signer();
      void changeOwner() {
        owner = Object();
      }

      void changeKey() {
        mnemonic = 'replacement mnemonic';
      }

      switch (scenario) {
        case 'current base fee':
          api.fee = 300;
        case 'reserve overdraw':
          break;
        case 'ledger error':
          api.ledgerError = true;
        case 'malformed ledger':
          api.malformedLedger = true;
        case 'owner during ledger':
          api.onLedger = changeOwner;
        case 'wrong address':
          signer.address = 'GOTHER';
        case 'empty address':
          signer.address = '';
        case 'address case':
          signer.address = 'gconfirmed';
        case 'owner during RPC':
          api.onAccount = changeOwner;
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
      final sender = XlmSender(
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
          coinType: 'XLM',
          fromAddress: 'GCONFIRMED',
          toAddress: 'GRECIPIENT',
          amount: scenario == 'send max'
              ? 10
              : scenario == 'reserve overdraw'
              ? 9.5
              : scenario == 'one stroop'
              ? 0.0000001
              : 1.25,
          decimals: 7,
          path: "m/44'/148'/2'",
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
        'one stroop',
        'current base fee',
      ].contains(scenario);
      expect(result.success, success);
      expect(api.broadcasts, success ? 1 : 0);
      expect(
        signer.signatures,
        success || scenario.endsWith('during signing') ? 1 : 0,
      );
      if (success) {
        expect(result.txHash, 'ab' * 32);
        expect(
          result.actualAmount,
          scenario == 'send max'
              ? 8.99999
              : scenario == 'one stroop'
              ? 0.0000001
              : 1.25,
        );
        expect(signer.derivedPath, "m/44'/148'/2'");
        expect(
          signer.derivedMnemonic,
          privateKey == null ? 'captured mnemonic' : '',
        );
        expect(signer.payload, {
          'toAddress': 'GRECIPIENT',
          'amount': scenario == 'send max'
              ? '89999900'
              : scenario == 'one stroop'
              ? '1'
              : '12500000',
          'sequence': '8',
          'memo': 'invoice 42',
          'returnMetadata': true,
          'fee': scenario == 'current base fee' ? '300' : '100',
          'passphrase': scenario == 'testnet'
              ? 'Test SDF Network ; September 2015'
              : 'Public Global Stellar Network ; September 2015',
        });
        expect(api.testnet, scenario == 'testnet');
      }
      if ([
        'no owner',
        'empty key',
        'owner reader failure',
      ].contains(scenario)) {
        expect(api.reads, 0);
      }
    });
  }
  for (final scenario in [
    'accepted',
    'persist failure',
    'owner change',
    'timeout',
    'error',
    'foreign hash',
  ]) {
    test('submission recovery $scenario', () async {
      Object owner = Object();
      final saved = <String>[];
      final api = _Api()
        ..submissionThrows = scenario == 'timeout'
        ..submissionError = scenario == 'error'
        ..hash = scenario == 'foreign hash' ? 'cd' * 32 : 'ab' * 32
        ..onSend = () => expect(saved, ['ab' * 32]);
      final sender = XlmSender(
        api: api,
        trustdart: _Signer(),
        ownerIdentity: () => owner,
        readMnemonic: () => 'fixture mnemonic',
      );
      final result = await sender.send(
        SendParams(
          coinType: 'XLM',
          fromAddress: 'GCONFIRMED',
          toAddress: 'GRECIPIENT',
          amount: 1.25,
          decimals: 7,
          path: "m/44'/148'/2'",
          beforeBroadcast: (hash) async {
            saved.add(hash);
            if (scenario == 'persist failure') {
              throw StateError('Storage failed');
            }
            if (scenario == 'owner change') owner = Object();
          },
        ),
      );
      final aborted = ['persist failure', 'owner change'].contains(scenario);
      expect(saved, ['ab' * 32]);
      expect(api.broadcasts, aborted ? 0 : 1);
      expect(result.success, scenario == 'accepted');
      expect(result.txHash, 'ab' * 32);
      expect(result.definitelyNotSubmitted, aborted);
      if (!aborted) expect(result.actualAmount, 1.25);
    });
  }
}
