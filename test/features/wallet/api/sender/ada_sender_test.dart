import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/ada_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends AdaApi {
  _Api({String projectId = 'fixture-project'}) : super(projectId: projectId);
  VoidCallback? onAccount;
  int broadcasts = 0;
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
          'tx_hash': 'fixture-hash',
          'output_index': 2,
          'amount': [
            {'unit': 'lovelace', 'quantity': '10000000'},
          ],
        },
      ];
  }

  @override
  Future<MessageModel> sendTransaction(
    String txXdr, {
    bool isTest = false,
  }) async {
    expect(txXdr, 'signed-cbor');
    broadcasts++;
    testnet = isTest;
    return MessageModel()..data = 'accepted-hash';
  }
}

class _Signer extends Trustdart {
  String address = 'addr_confirmed';
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
    return 'signed-cbor';
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
    'wrong address',
    'empty address',
    'address case',
    'owner during RPC',
    'owner during UTxO',
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
      final signer = _Signer();
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
        success || scenario.endsWith('during signing') ? 1 : 0,
      );
      if (success) {
        expect(result.txHash, 'accepted-hash');
        expect(signer.derivedPath, "m/1852'/1815'/0'/0/2");
        expect(
          signer.derivedMnemonic,
          privateKey == null ? 'captured mnemonic' : '',
        );
        expect(
          signer.payload!['amount'],
          scenario == 'send max' ? '9826000' : '1250000',
        );
        expect(signer.payload!['fee'], 174000);
        expect(signer.payload!['changeAddress'], 'addr_confirmed');
        expect(signer.payload!['toAddress'], 'addr_recipient');
        expect(signer.payload!['utxos'], [
          {
            'txHash': 'fixture-hash',
            'outputIndex': 2,
            'amount': [
              {'unit': 'lovelace', 'quantity': '10000000'},
            ],
          },
        ]);
        expect(result.actualAmount, scenario == 'send max' ? 9.826 : 1.25);
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
}
