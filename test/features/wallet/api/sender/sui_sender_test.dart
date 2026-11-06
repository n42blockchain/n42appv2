import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sui_sender.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class FakeApi extends SuiApi {
  int submits = 0;
  int reads = 0;
  BigInt balance = BigInt.parse('10000000000000000');
  @override
  Future<MessageModel> getBalanceSui(String address) async {
    reads++;
    return MessageModel()..data = balance;
  }

  @override
  Future<MessageModel> getGasPriceSui() async =>
      MessageModel()..data = BigInt.from(1000);
  @override
  Future<List<dynamic>> getOwnedObjects(String address) async => [
    {
      'data': {'objectId': 'coin', 'version': '7', 'digest': 'digest'},
    },
  ];
  @override
  Future<MessageModel> submit(String tx, String sig) async {
    submits++;
    expect(tx, 'AQID');
    expect(base64Decode(sig).length, 97);
    return MessageModel()..data = {'digest': 'confirmed'};
  }
}

class Signer extends Trustdart {
  Map? received;
  String output = 'AQID|${base64Encode(List.filled(97, 0))}';
  Completer<String>? pending;
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
    return pending == null ? output : pending!.future;
  }
}

SendParams params({
  BigInt? exact,
  String contract = '',
  int decimals = 9,
  bool max = false,
}) => SendParams(
  coinType: 'SUI',
  fromAddress: 'owner',
  toAddress: 'recipient',
  amount: 1,
  decimals: decimals,
  path: 'path',
  privateKey: 'test-only',
  isTest: true,
  valueWeiOverride: exact,
  contractAddress: contract,
  sendMax: max,
);
void main() {
  test('exact amount and full coin references reach signer without fee multiplication', () async {
    final api = FakeApi();
    final signer = Signer();
    final sender = SuiSender(
      trustdart: signer,
      apiFactory: (testnet) {
        expect(testnet, true);
        return api;
      },
    );
    final result = await sender.send(
      params(exact: BigInt.parse('9007199254740993')),
    );
    expect(result.success, true);
    expect(signer.received, {
      'type': 'SUI_TRANSFER',
      'amount': '9007199254740993',
      'toAddress': 'recipient',
      'fromAddress': 'owner',
      'gasBudget': '2000000',
      'referenceGasPrice': '1000',
      'utxo': [
        {'objectId': 'coin', 'version': '7', 'objectDigest': 'digest'},
      ],
    });
    expect(api.submits, 1);
  });
  for (final output in ['AQID', 'AQID|AQID', '|', 'AQID|!']) {
    test(
      'unsigned or malformed native output is never submitted: $output',
      () async {
        final api = FakeApi();
        final signer = Signer()..output = output;
        final result = await SuiSender(
          trustdart: signer,
          apiFactory: (_) => api,
        ).send(params());
        expect(result.success, false);
        expect(api.submits, 0);
      },
    );
  }
  test('invalid asset or integer range fails before accessing RPC', () async {
    final api = FakeApi();
    final sender = SuiSender(apiFactory: (_) => api);
    for (final request in [
      params(contract: 'token'),
      params(decimals: 18),
      params(exact: BigInt.zero),
      params(exact: BigInt.one << 64),
    ]) {
      expect((await sender.send(request)).success, false);
    }
    expect(api.reads, 0);
  });
  test(
    'pending signing blocks a second transfer and releases after completion',
    () async {
      final api = FakeApi();
      final signer = Signer()..pending = Completer<String>();
      final sender = SuiSender(trustdart: signer, apiFactory: (_) => api);
      final first = sender.send(params());
      await Future<void>.delayed(Duration.zero);
      expect((await sender.send(params())).success, false);
      signer.pending!.complete(signer.output);
      expect((await first).success, true);
      signer.pending = null;
      expect((await sender.send(params())).success, true);
      expect(api.submits, 2);
    },
  );
  test('max reserves a MIST budget exactly once', () async {
    final api = FakeApi()..balance = BigInt.from(1000000000);
    final signer = Signer();
    final result = await SuiSender(
      trustdart: signer,
      apiFactory: (_) => api,
    ).send(params(exact: api.balance, max: true));
    expect(result.success, true);
    expect(signer.received!['amount'], '998000000');
  });
}
