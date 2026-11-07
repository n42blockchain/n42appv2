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
  VoidCallback? onBalance;
  VoidCallback? onFee;
  @override
  Future<MessageModel> getBalance(
    String address,
    String contract, {
    bool isTest = false,
  }) async {
    calls.add(('balance:$contract', isTest));
    onBalance?.call();
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
    onFee?.call();
    feeMessage = signMessage;
    return failAt == 'fee' ? fail() : ok(fee);
  }

  @override
  Future<MessageModel> sendTransaction(
    String signMessage, {
    bool isTest = false,
    String encoding = 'base58',
    String? walletConnectChainId,
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
  String address = 'sender';
  VoidCallback? onDerive;
  VoidCallback? onSign;
  String expectedKey = 'fixture-key';
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
    expect(coin, 'SOL');
    expect(addressType, 'legacy');
    expect(pk, expectedKey);
    mnemonics.add(mnemonic);
    onDerive?.call();
    return {addressType: address};
  }

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
    expect(pk, expectedKey);
    mnemonics.add(mnemonic);
    onSign?.call();
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
  String? privateKey = 'fixture-key',
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
  privateKey: privateKey,
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
  test('rejects a signing key belonging to another sender', () async {
    signer.address = 'another-sender';
    final result = await sender.send(params());
    expect(result.success, isFalse);
    expect(signer.payloads, isEmpty);
    expect(api.sends, 0);
  });
  for (final phase in ['derive', 'balance', 'sign', 'fee']) {
    for (final useMnemonic in [false, true]) {
      test(
        'account switch during $phase rejects submission (mnemonic=$useMnemonic)',
        () async {
          Object? owner = Object();
          var mnemonic = 'captured fixture mnemonic';
          void changeAccount() {
            owner = Object();
            mnemonic = 'replacement fixture mnemonic';
          }

          if (useMnemonic) signer.expectedKey = '';
          sender = SolSender(
            api: api,
            trustdart: signer,
            ownerIdentity: () => owner,
            readMnemonic: () => mnemonic,
          );
          switch (phase) {
            case 'derive':
              signer.onDerive = changeAccount;
            case 'balance':
              api.onBalance = changeAccount;
            case 'sign':
              signer.onSign = changeAccount;
            case 'fee':
              api.onFee = changeAccount;
          }
          final result = await sender.send(
            params(privateKey: useMnemonic ? null : 'fixture-key'),
          );
          expect(result.success, isFalse);
          expect(api.sends, 0);
          expect(
            signer.mnemonics,
            isNot(contains('replacement fixture mnemonic')),
          );
          if (phase == 'derive' || phase == 'balance') {
            expect(signer.payloads, isEmpty);
          }
        },
      );
    }
  }
  test(
    'mnemonic transfer retains captured signer through MAX resign',
    () async {
      final owner = Object();
      signer.expectedKey = '';
      sender = SolSender(
        api: api,
        trustdart: signer,
        ownerIdentity: () => owner,
        readMnemonic: () => 'captured fixture mnemonic',
      );
      final result = await sender.send(
        params(amount: 1, max: true, privateKey: null),
      );
      expect(result.success, isTrue);
      expect(signer.payloads, hasLength(2));
      expect(signer.mnemonics, everyElement('captured fixture mnemonic'));
      expect(api.sends, 1);
    },
  );
  test(
    'MAX fee lookup account switch cannot trigger a second signature',
    () async {
      Object owner = Object();
      sender = SolSender(
        api: api,
        trustdart: signer,
        ownerIdentity: () => owner,
      );
      api.onFee = () {
        owner = Object();
      };
      expect(
        (await sender.send(params(amount: 1, max: true))).success,
        isFalse,
      );
      expect(signer.payloads, hasLength(1));
      expect(api.sends, 0);
    },
  );
  test('mnemonic changes within the same owner reject submission', () async {
    final owner = Object();
    var mnemonic = 'captured fixture mnemonic';
    signer.expectedKey = '';
    sender = SolSender(
      api: api,
      trustdart: signer,
      ownerIdentity: () => owner,
      readMnemonic: () => mnemonic,
    );
    api.onBalance = () {
      mnemonic = 'replacement fixture mnemonic';
    };
    expect((await sender.send(params(privateKey: null))).success, isFalse);
    expect(signer.payloads, isEmpty);
    expect(api.sends, 0);
  });
  test('unavailable mnemonic account fails before network calls', () async {
    sender = SolSender(
      api: api,
      trustdart: signer,
      ownerIdentity: () => null,
      readMnemonic: () => 'fixture mnemonic',
    );
    expect((await sender.send(params(privateKey: null))).success, isFalse);
    expect(api.calls, isEmpty);
    expect(signer.payloads, isEmpty);
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
        (await sender.send(params(contract: stage == 'account' ? 'mint' : '')))
            .success,
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
