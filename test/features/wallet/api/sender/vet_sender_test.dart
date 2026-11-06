import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/vet_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/vet_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class _Api extends VetApi {
  VoidCallback? onAccount;
  int broadcasts = 0;
  int reads = 0;
  bool? testnet;
  @override
  Future<MessageModel> getAccount(String address, {bool isTest = false}) async {
    reads++;
    onAccount?.call();
    return MessageModel()..data = {'balance': '0x8ac7230489e80000'};
  }

  VoidCallback? onBlock;
  @override
  Future<MessageModel> getBestBlock({bool isTest = false}) async {
    onBlock?.call();
    return MessageModel()..data = {'id': '0x1122334455667788aabbccdd'};
  }

  @override
  Future<MessageModel> sendTransaction(
    String txXdr, {
    bool isTest = false,
  }) async {
    expect(txXdr, 'signed-rlp');
    broadcasts++;
    testnet = isTest;
    return MessageModel()..data = {'id': 'accepted-hash'};
  }
}

class _Signer extends Trustdart {
  String address = "0x${'ab' * 20}";
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
    expect(coin, 'VET');
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
    expect(coin, 'VET');
    expect(path, derivedPath);
    expect(mnemonic, derivedMnemonic);
    expect(pk, derivedKey);
    signatures++;
    payload = txData;
    onSign?.call();
    return 'signed-rlp';
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
    'malformed address',
    'address case',
    'owner during RPC',
    'owner during block',
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
        case 'wrong address':
          signer.address = "0x${'ef' * 20}";
        case 'empty address':
          signer.address = '';
        case 'malformed address':
          signer.address = 'not-an-address';
        case 'address case':
          signer.address = "0x${'AB' * 20}";
        case 'owner during RPC':
          api.onAccount = changeOwner;
        case 'owner during block':
          api.onBlock = changeOwner;
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
      final sender = VetSender(
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
          coinType: 'VET',
          fromAddress: "0x${'ab' * 20}",
          toAddress: "0x${'cd' * 20}",
          amount: scenario == 'send max' ? 10 : 1.25,
          decimals: 18,
          path: "m/44'/818'/0'/0/2",
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
        'address case',
      ].contains(scenario);
      expect(result.success, success);
      expect(api.broadcasts, success ? 1 : 0);
      expect(
        signer.signatures,
        success || scenario.endsWith('during signing') ? 1 : 0,
      );
      if (success) {
        expect(result.txHash, 'accepted-hash');
        expect(signer.derivedPath, "m/44'/818'/0'/0/2");
        expect(
          signer.derivedMnemonic,
          privateKey == null ? 'captured mnemonic' : '',
        );
        final value = scenario == 'send max'
            ? '0x8ac7230489e80000'
            : '0x1158e460913d0000';
        expect(signer.payload!['amount'], value);
        expect(signer.payload!['gas'], 21000);
        expect(signer.payload!['gasPriceCoef'], 0);
        expect(
          signer.payload!['chainTag'],
          scenario == 'testnet' ? 0x27 : 0x4a,
        );
        expect(signer.payload!['blockRef'], '0x1122334455667788');
        expect(signer.payload!['expiration'], 32);
        expect(signer.payload!['clauses'], [
          {'to': "0x${'cd' * 20}", 'value': value, 'data': '0x'},
        ]);
        expect(signer.payload!['nonce'], isNonNegative);
        expect(result.actualAmount, scenario == 'send max' ? 10 : 1.25);
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
}
