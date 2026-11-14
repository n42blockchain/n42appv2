import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sui_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sui_transaction_message.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class FakeApi extends SuiApi {
  int submits = 0;
  void Function()? onBalance;
  Object? submitError;
  MessageModel? reply;
  int reads = 0;
  BigInt balance = BigInt.parse('10000000000000000');
  @override
  Future<MessageModel> getBalanceSui(String address) async {
    reads++;
    onBalance?.call();
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
    if (submitError != null) throw submitError!;
    return reply ??
        (MessageModel()..data = {'digest': suiTransactionDigest(tx)});
  }
}

class Signer extends Trustdart {
  Map? received;
  String? mnemonic;
  void Function()? onSign;
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
    this.mnemonic = mnemonic;
    onSign?.call();
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

/// Mnemonic signing requires a mounted app context.
Future<void> mountContext(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  AppGlobals.appContext = tester.element(find.byType(SizedBox));
}

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
  test('transaction digest follows the TransactionData intent hash', () {
    // Blake2b-256(b"TransactionData::" + bytes), Base58: computed
    // independently with Python hashlib for the fixture bytes 01 02 03.
    expect(
      suiTransactionDigest('AQID'),
      '45BcYgib9Z6jfxixeAWNGjH8JfAx8NzrDnhRAnn7FnpG',
    );
  });
  for (final scenario in [
    'timeout',
    'transport error',
    'rpc error',
    'unconfirmed reply',
    'foreign digest',
  ]) {
    test(
      '$scenario after submission is unknown with the local digest',
      () async {
        final api = FakeApi();
        switch (scenario) {
          case 'timeout':
            api.submitError = TimeoutException('no reply');
          case 'transport error':
            api.submitError = StateError('socket closed');
          case 'rpc error':
            api.reply = MessageModel.error()..data = 'quorum not reached';
          case 'unconfirmed reply':
            api.reply = MessageModel()..data = {'effects': {}};
          case 'foreign digest':
            api.reply = MessageModel()
              ..data = {'digest': '11111111111111111111111111111111'};
        }
        final result = await SuiSender(
          trustdart: Signer(),
          apiFactory: (_) => api,
        ).send(params());
        expect(api.submits, 1);
        expect(result.success, isFalse);
        expect(result.definitelyNotSubmitted, isFalse);
        expect(result.definitelyRejected, isFalse);
        expect(result.txHash, suiTransactionDigest('AQID'));
        expect(result.error, contains(suiTransactionDigest('AQID')));
      },
    );
  }
  for (final change in ['owner', 'mnemonic', 'owner after signing']) {
    testWidgets('wallet $change change never signs or submits', (tester) async {
      await mountContext(tester);
      Object owner = Object();
      var mnemonic = 'first account words';
      final api = FakeApi();
      final signer = Signer();
      if (change == 'owner after signing') {
        signer.onSign = () => owner = Object();
      } else {
        api.onBalance = () => change == 'owner'
            ? owner = Object()
            : mnemonic = 'replacement account words';
      }
      final request = SendParams(
        coinType: 'SUI',
        fromAddress: 'owner',
        toAddress: 'recipient',
        amount: 1,
        decimals: 9,
        path: 'path',
        isTest: true,
      );
      final result = await SuiSender(
        trustdart: signer,
        apiFactory: (_) => api,
        ownerIdentity: () => owner,
        readMnemonic: () => mnemonic,
      ).send(request);
      expect(result.success, isFalse);
      expect(result.txHash, isNull);
      expect(api.submits, 0);
      if (change == 'owner after signing') {
        expect(signer.mnemonic, 'first account words');
      } else {
        expect(signer.received, isNull);
      }
    });
  }
  testWidgets('mnemonic signing uses the account captured at entry', (
    tester,
  ) async {
    await mountContext(tester);
    final api = FakeApi();
    final signer = Signer();
    final result =
        await SuiSender(
          trustdart: signer,
          apiFactory: (_) => api,
          ownerIdentity: () => 'owner',
          readMnemonic: () => 'first account words',
        ).send(
          SendParams(
            coinType: 'SUI',
            fromAddress: 'owner',
            toAddress: 'recipient',
            amount: 1,
            decimals: 9,
            path: 'path',
            isTest: true,
          ),
        );
    expect(result.success, isTrue);
    expect(signer.mnemonic, 'first account words');
  });
  test('missing wallet fails before any RPC', () async {
    final api = FakeApi();
    final result =
        await SuiSender(
          trustdart: Signer(),
          apiFactory: (_) => api,
          ownerIdentity: () => null,
          readMnemonic: () => null,
        ).send(
          SendParams(
            coinType: 'SUI',
            fromAddress: 'owner',
            toAddress: 'recipient',
            amount: 1,
            decimals: 9,
            path: 'path',
          ),
        );
    expect(result.success, isFalse);
    expect(api.reads, 0);
  });
  test('failures before submission stay plain failures', () async {
    final api = FakeApi()..balance = BigInt.zero;
    final result = await SuiSender(
      trustdart: Signer(),
      apiFactory: (_) => api,
    ).send(params());
    expect(result.success, isFalse);
    expect(result.txHash, isNull);
    expect(api.submits, 0);
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
