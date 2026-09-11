import 'dart:async';
import 'dart:convert';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sol_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sol_transaction_message.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

final message = [1, 0, 0, 1, ...List.filled(32, 2), ...List.filled(32, 3), 0];
final signed = Base58Encode([1, ...List.filled(64, 4), ...message]);
MessageModel ok(dynamic value) => MessageModel()..data = value;
MessageModel fail() => MessageModel.error()..data = 'RPC unavailable';

class FakeSol extends SolApi {
  final calls = <(String, bool)>[];
  BigInt balance = BigInt.from(1000000000);
  BigInt nativeBalance = BigInt.from(1000000000);
  BigInt fee = BigInt.from(5000);
  String? failAt;
  String? hash = 'confirmed-signature';
  Object? account = ['data', 'base64'];
  Completer<void>? gate;
  int sends = 0;
  String? feeMessage;
  @override
  Future<MessageModel> getBalance(
    String address,
    String contract, {
    bool isTest = false,
  }) async {
    calls.add(('balance:$contract', isTest));
    if (gate != null) await gate!.future;
    return failAt == 'balance'
        ? fail()
        : ok(contract.isEmpty ? nativeBalance : balance);
  }

  @override
  Future<MessageModel> getTokenAccountBalance(
    String address, {
    bool isTest = false,
  }) async {
    calls.add(('tokenBalance:$address', isTest));
    return failAt == 'balance' ? fail() : ok(balance);
  }

  @override
  Future<MessageModel> getTokenAccountRent({bool isTest = false}) async {
    calls.add(('rent', isTest));
    return failAt == 'rent' ? fail() : ok(BigInt.from(2039280));
  }

  @override
  Future<MessageModel> getLatestBlockhash({bool isTest = false}) async {
    calls.add(('blockhash', isTest));
    return failAt == 'blockhash' ? fail() : ok('recent-blockhash');
  }

  @override
  Future<MessageModel> getAccountInfo(
    String address, {
    bool isTest = false,
  }) async {
    calls.add(('account', isTest));
    return failAt == 'account' ? fail() : ok(account);
  }

  @override
  Future<MessageModel> getFeeForMessage(
    String signMessage, {
    bool isTest = false,
  }) async {
    calls.add(('fee', isTest));
    feeMessage = signMessage;
    return failAt == 'fee' ? fail() : ok(fee);
  }

  @override
  Future<MessageModel> sendTransaction(
    String signMessage, {
    bool isTest = false,
  }) async {
    calls.add(('send', isTest));
    sends++;
    if (failAt == 'throw') throw StateError('RPC unavailable');
    return failAt == 'send' ? fail() : ok(hash);
  }
}

class FakeSigner extends Trustdart {
  final payloads = <Map<String, dynamic>>[];
  String output = signed;
  String tokenAccount = 'associated-token-account';
  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    expect(coin, 'SOL');
    expect(pk, 'fixture-key');
    payloads.add(jsonDecode(jsonEncode(txData)) as Map<String, dynamic>);
    return output;
  }

  @override
  Future<String> getPubKeySOL(String address, String mintAddress) async =>
      tokenAccount;
}

SendParams params({
  bool testnet = true,
  bool max = false,
  double amount = .1,
  String contract = '',
  BigInt? exact,
  BigInt? exactToken,
}) => SendParams(
  coinType: 'SOL',
  fromAddress: 'sender',
  toAddress: 'recipient',
  amount: amount,
  decimals: 9,
  path: "m/44'/501'/0'/0'",
  isTest: testnet,
  sendMax: max,
  contractAddress: contract,
  tokenDecimals: 6,
  privateKey: 'fixture-key',
  valueWeiOverride: exact,
  tokenValueWeiOverride: exactToken,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSol api;
  late FakeSigner signer;
  late SolSender sender;
  setUp(() async {
    await S.load(const Locale('en'));
    api = FakeSol();
    signer = FakeSigner();
    sender = SolSender(api: api, trustdart: signer);
  });
  for (final testnet in [true, false]) {
    test('native transfer keeps every RPC on network $testnet', () async {
      final result = await sender.send(params(testnet: testnet));
      expect(result.success, isTrue);
      expect(result.txHash, api.hash);
      expect(api.calls.map((c) => c.$2), everyElement(testnet));
      expect(api.calls.map((c) => c.$1), [
        'balance:',
        'blockhash',
        'fee',
        'send',
      ]);
      expect(api.feeMessage, base64Encode(message));
      expect(
        signer.payloads.single['transferTransaction']['value'],
        '100000000',
      );
    });
  }
  test('MAX reserves fee and signs the reduced exact amount again', () async {
    final r = await sender.send(params(amount: 1, max: true));
    expect(r.success, isTrue);
    expect(r.actualAmount, .999995);
    expect(signer.payloads, hasLength(2));
    expect(signer.payloads.last['transferTransaction']['value'], '999995000');
    expect(api.sends, 1);
  });
  test('exact amount overrides floating point representation', () async {
    final r = await sender.send(params(exact: BigInt.from(123456789)));
    expect(r.success, isTrue);
    expect(signer.payloads.single['transferTransaction']['value'], '123456789');
  });
  test('SPL balance and native fee both use testnet', () async {
    final r = await sender.send(
      params(contract: 'mint', exactToken: BigInt.from(999)),
    );
    expect(r.success, isTrue);
    expect(api.calls.map((c) => c.$2), everyElement(isTrue));
    expect(
      api.calls.map((c) => c.$1),
      containsAll([
        'tokenBalance:associated-token-account',
        'balance:',
        'account',
      ]),
    );
    expect(signer.payloads.single['tokenTransferTransaction']['amount'], '999');
  });
  test('missing recipient token account selects account creation', () async {
    api.account = null;
    expect((await sender.send(params(contract: 'mint'))).success, isTrue);
    expect(
      signer
          .payloads
          .single['tokenTransferTransaction']['recipientTokenAddress'],
      '',
    );
  });
  test(
    'new token account reserves rent in addition to signature fee',
    () async {
      api.account = null;
      api.nativeBalance = BigInt.from(5000);
      expect((await sender.send(params(contract: 'mint'))).success, isFalse);
      expect(api.calls, contains(('rent', true)));
      expect(api.sends, 0);
    },
  );
  test('rent lookup failure cannot broadcast', () async {
    api.account = null;
    api.failAt = 'rent';
    expect((await sender.send(params(contract: 'mint'))).success, isFalse);
    expect(api.sends, 0);
  });
  for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
    test('rejects invalid amount $amount before RPC', () async {
      expect((await sender.send(params(amount: amount))).success, isFalse);
      expect(api.calls, isEmpty);
      expect(signer.payloads, isEmpty);
    });
  }
  for (final exact in [BigInt.zero, -BigInt.one, BigInt.one << 64]) {
    test('rejects out-of-range exact value $exact', () async {
      expect((await sender.send(params(exact: exact))).success, isFalse);
      expect(api.calls, isEmpty);
    });
  }
  test('insufficient principal stops before signing', () async {
    expect((await sender.send(params(amount: 2))).success, isFalse);
    expect(signer.payloads, isEmpty);
    expect(api.sends, 0);
  });
  test('full balance without MAX cannot spend gas reserve', () async {
    expect((await sender.send(params(amount: 1))).success, isFalse);
    expect(api.sends, 0);
  });
  test('MAX rejects when fee consumes full balance', () async {
    api.fee = api.nativeBalance;
    expect((await sender.send(params(amount: 1, max: true))).success, isFalse);
    expect(api.sends, 0);
  });
  test('SPL transfer cannot spend without native gas', () async {
    api.nativeBalance = BigInt.zero;
    expect((await sender.send(params(contract: 'mint'))).success, isFalse);
    expect(api.sends, 0);
  });
  for (final stage in [
    'balance',
    'blockhash',
    'fee',
    'account',
    'send',
    'throw',
  ]) {
    test('failure at $stage is reported without retry', () async {
      api.failAt = stage;
      expect(
        (await sender.send(
          params(contract: stage == 'account' ? 'mint' : ''),
        )).success,
        isFalse,
      );
      expect(api.sends, stage == 'send' || stage == 'throw' ? 1 : 0);
      api.failAt = null;
      expect((await sender.send(params())).success, isTrue);
    });
  }
  for (final value in ['', 'not-a-valid-signature']) {
    test('malformed signing output never broadcasts: $value', () async {
      signer.output = value;
      expect((await sender.send(params())).success, isFalse);
      expect(api.sends, 0);
    });
  }
  for (final hash in [null, '', '  ']) {
    test('missing hash $hash is not reported as success', () async {
      api.hash = hash;
      expect((await sender.send(params())).success, isFalse);
      expect(api.sends, 1);
    });
  }
  test(
    'duplicate submission while preparing signs and broadcasts once',
    () async {
      api.gate = Completer<void>();
      final first = sender.send(params());
      expect((await sender.send(params())).success, isFalse);
      api.gate!.complete();
      expect((await first).success, isTrue);
      expect(api.sends, 1);
    },
  );
  test('associated account derivation failure stops before signing', () async {
    signer.tokenAccount = '';
    expect((await sender.send(params(contract: 'mint'))).success, isFalse);
    expect(signer.payloads, isEmpty);
  });
  group('serialized message extraction', () {
    test('legacy transaction strips signatures without changing message', () {
      expect(solTransactionMessage(signed), base64Encode(message));
    });
    test('versioned transaction preserves version prefix', () {
      expect(
        solTransactionMessage(
          Base58Encode([1, ...List.filled(64, 4), 128, ...message]),
        ),
        base64Encode([128, ...message]),
      );
    });
    for (final bytes in <List<int>>[
      [],
      [128],
      [128, 128, 128],
      [129, 0],
      [0, 1, 0, 0],
      [1, 2, 3],
      [1, ...List.filled(64, 4), 2, 0, 0],
    ]) {
      test('rejects truncated or mismatched wire data $bytes', () {
        expect(
          () => solTransactionMessage(Base58Encode(bytes)),
          throwsA(anything),
        );
      });
    }
  });
}
