import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/algo_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

MessageModel ok(dynamic data) => MessageModel()..data = data;

class Api extends TokenViewApi {
  final networks = <bool>[];
  int sends = 0;
  BigInt balance = BigInt.from(1000000);
  BigInt reserve = BigInt.from(100000);
  BigInt assetBalance = BigInt.from(500);
  String? hash = 'transaction-id';
  VoidCallback? onBalance;
  Completer<void>? gate;
  final assets = <String>[];
  @override
  Future<MessageModel?> getBalance(
    String blockchain,
    String coinType,
    String address, {
    String contract = '',
    bool returnDouble = false,
    bool isTest = false,
    String? rpc,
  }) async {
    networks.add(isTest);
    assets.add(contract);
    onBalance?.call();
    if (gate != null) await gate!.future;
    return ok(
      contract.isEmpty
          ? {'balance': balance, 'minBalance': reserve}
          : {'balance': assetBalance, 'code': 200},
    );
  }

  @override
  Future<MessageModel?> sendTx(
    String blockchain,
    String coinType,
    dynamic signHash, {
    String netMode = 'main',
    String? rpc,
  }) async {
    sends++;
    networks.add(netMode == 'test');
    return ok(hash);
  }
}

class ParamsApi extends AlgoApi {
  final networks = <bool>[];
  Object fee = 1000;
  String genesisHash = base64Encode(List.filled(32, 1));
  VoidCallback? onParams;
  @override
  Future<MessageModel> getTransactionsParams({bool isTest = false}) async {
    networks.add(isTest);
    onParams?.call();
    return ok({
      'min-fee': fee,
      'genesis-id': 'fixture',
      'genesis-hash': genesisHash,
      'last-round': 100,
    });
  }
}

class Signer extends Trustdart {
  int signs = 0;
  String address = 'sender';
  String signed = '0102';
  Map? payload;
  VoidCallback? onDerive;
  VoidCallback? onSign;
  final mnemonics = <String>[];
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
    expect(coin, 'ALGO');
    expect(addressType, 'legacy');
    mnemonics.add(mnemonic);
    onDerive?.call();
    return {addressType: address};
  }

  @override
  Future<Map> signTransactionByteArray(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    signs++;
    payload = Map.of(txData);
    mnemonics.add(mnemonic);
    onSign?.call();
    return {'result': true, 'signHash': signed};
  }
}

SendParams params({
  bool testnet = true,
  bool max = false,
  String asset = '',
  BigInt? exact,
  double amount = .1,
  String? key = 'fixture-key',
}) => SendParams(
  coinType: 'ALGO',
  fromAddress: 'sender',
  toAddress: 'recipient',
  amount: amount,
  decimals: 6,
  tokenDecimals: 2,
  contractAddress: asset,
  sendMax: max,
  valueWeiOverride: asset.isEmpty ? exact : null,
  tokenValueWeiOverride: asset.isNotEmpty ? exact : null,
  path: "m/44'/283'/0'/0'/0'",
  privateKey: key,
  isTest: testnet,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    await S.load(const Locale('en'));
  });
  test(
    'native transfer consumes account balance object on selected testnet',
    () async {
      final api = Api();
      final signer = Signer();
      final sender = AlgoSender(
        tokenViewApi: api,
        trustdart: signer,
        algoApi: ParamsApi(),
      );
      expect((await sender.send(params())).success, isTrue);
      expect(api.networks, everyElement(isTrue));
      expect(api.sends, 1);
    },
  );
  for (final testnet in [false, true]) {
    test(
      'ASA transfer uses asset balance, native fee and native Asset dispatch on $testnet',
      () async {
        final api = Api();
        final signer = Signer();
        final chain = ParamsApi();
        final sender = AlgoSender(
          tokenViewApi: api,
          trustdart: signer,
          algoApi: chain,
        );
        expect(
          (await sender.send(
            params(testnet: testnet, asset: '42', exact: BigInt.from(499)),
          )).success,
          isTrue,
        );
        expect(api.assets, ['', '42']);
        expect(api.networks, everyElement(testnet));
        expect(chain.networks, [testnet]);
        expect(signer.payload!['type'], 'Asset');
        expect(signer.payload!['assetId'], '42');
        expect(signer.payload!['amount'], '499');
      },
    );
  }
  for (final amount in [1.0, .9]) {
    test('MAX retains minimum account reserve for input $amount', () async {
      final api = Api();
      final signer = Signer();
      final sender = AlgoSender(
        tokenViewApi: api,
        trustdart: signer,
        algoApi: ParamsApi(),
      );
      final result = await sender.send(params(amount: amount, max: true));
      expect(result.success, isTrue);
      expect(result.actualAmount, .899);
      expect(signer.payload!['amount'], '899000');
      expect(api.sends, 1);
    });
  }
  for (final scenario in [
    'wrong key',
    'native reserve',
    'asset shortfall',
    'fee reserve',
    'negative fee',
    'invalid hash',
    'empty signature',
    'invalid signature',
    'missing receipt',
  ]) {
    test('rejects $scenario without an unsafe transaction', () async {
      final api = Api();
      final signer = Signer();
      final chain = ParamsApi();
      if (scenario == 'wrong key') signer.address = 'other';
      if (scenario == 'native reserve') api.balance = BigInt.from(200000);
      if (scenario == 'asset shortfall') api.assetBalance = BigInt.zero;
      if (scenario == 'fee reserve') api.balance = api.reserve;
      if (scenario == 'negative fee') chain.fee = -1;
      if (scenario == 'invalid hash') chain.genesisHash = 'bad';
      if (scenario == 'empty signature') signer.signed = '';
      if (scenario == 'invalid signature') signer.signed = 'abc';
      if (scenario == 'missing receipt') api.hash = null;
      final sender = AlgoSender(
        tokenViewApi: api,
        trustdart: signer,
        algoApi: chain,
      );
      expect(
        (await sender.send(
          params(asset: scenario == 'asset shortfall' ? '42' : ''),
        )).success,
        isFalse,
      );
      expect(api.sends, scenario == 'missing receipt' ? 1 : 0);
    });
  }
  for (final phase in ['derive', 'balance', 'params', 'sign']) {
    for (final useMnemonic in [true, false]) {
      test(
        'account change during $phase blocks broadcast, mnemonic=$useMnemonic',
        () async {
          final api = Api();
          final signer = Signer();
          final chain = ParamsApi();
          Object owner = Object();
          var mnemonic = 'captured';
          void change() {
            owner = Object();
            mnemonic = 'replacement';
          }

          if (phase == 'derive') signer.onDerive = change;
          if (phase == 'balance') api.onBalance = change;
          if (phase == 'params') chain.onParams = change;
          if (phase == 'sign') signer.onSign = change;
          final sender = AlgoSender(
            tokenViewApi: api,
            trustdart: signer,
            algoApi: chain,
            ownerIdentity: () => owner,
            readMnemonic: () => mnemonic,
          );
          expect(
            (await sender.send(params(key: useMnemonic ? null : 'fixture-key')))
                .success,
            isFalse,
          );
          expect(api.sends, 0);
          expect(signer.mnemonics, isNot(contains('replacement')));
          expect(signer.signs, phase == 'sign' ? 1 : 0);
        },
      );
    }
  }
  test(
    'pending send rejects duplicates and accepts a new send after completion',
    () async {
      final api = Api()..gate = Completer<void>();
      final signer = Signer();
      final sender = AlgoSender(
        tokenViewApi: api,
        trustdart: signer,
        algoApi: ParamsApi(),
      );
      final first = sender.send(params());
      expect((await sender.send(params())).success, isFalse);
      api.gate!.complete();
      expect((await first).success, isTrue);
      api.gate = null;
      expect((await sender.send(params())).success, isTrue);
      expect(api.sends, 2);
    },
  );
  test(
    'stable mnemonic signer supports exact amounts without double rounding',
    () async {
      final api = Api();
      final signer = Signer();
      final owner = Object();
      final sender = AlgoSender(
        tokenViewApi: api,
        trustdart: signer,
        algoApi: ParamsApi(),
        ownerIdentity: () => owner,
        readMnemonic: () => 'captured fixture',
      );
      final result = await sender.send(
        params(key: null, exact: BigInt.from(123456), amount: double.nan),
      );
      expect(result.success, isTrue);
      expect(signer.payload!['amount'], '123456');
      expect(result.actualAmount, .123456);
      expect(signer.mnemonics, ['captured fixture', 'captured fixture']);
    },
  );
  test('same-owner mnemonic replacement stops signing', () async {
    final api = Api();
    final signer = Signer();
    final owner = Object();
    var mnemonic = 'original';
    api.onBalance = () {
      mnemonic = 'replacement';
    };
    final sender = AlgoSender(
      tokenViewApi: api,
      trustdart: signer,
      algoApi: ParamsApi(),
      ownerIdentity: () => owner,
      readMnemonic: () => mnemonic,
    );
    expect((await sender.send(params(key: null))).success, isFalse);
    expect(signer.signs, 0);
    expect(api.sends, 0);
  });
  test('Android 0x-prefixed signature is accepted as bytes', () async {
    final api = Api();
    final signer = Signer()..signed = '0x0102';
    final sender = AlgoSender(
      tokenViewApi: api,
      trustdart: signer,
      algoApi: ParamsApi(),
    );
    expect((await sender.send(params())).success, isTrue);
    expect(api.sends, 1);
  });
  for (final asset in ['0x2a', '+42', ' 42']) {
    test(
      'non-decimal native asset ID $asset is rejected before signing',
      () async {
        final api = Api();
        final signer = Signer();
        final sender = AlgoSender(
          tokenViewApi: api,
          trustdart: signer,
          algoApi: ParamsApi(),
        );
        expect((await sender.send(params(asset: asset))).success, isFalse);
        expect(signer.signs, 0);
        expect(api.sends, 0);
      },
    );
  }
}
