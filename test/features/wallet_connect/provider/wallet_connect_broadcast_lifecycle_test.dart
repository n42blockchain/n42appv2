import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;

import '../../../helpers/wallet_connect_client_fake.dart';

const _chains = [
  (
    ns: 'solana',
    chain: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
    type: 'SOL',
    blockchain: 'Solana',
    address: 'So11111111111111111111111111111111111111112',
    method: 'solana_signAndSendTransaction',
    result: <String, String>{'signature': 'submitted-hash'},
  ),
  (
    ns: 'aptos',
    chain: 'aptos:1',
    type: 'APT',
    blockchain: 'Aptos',
    address: '0xabc123',
    method: 'aptos_signAndSubmitTransaction',
    result: <String, String>{'hash': 'submitted-hash'},
  ),
  (
    ns: 'near',
    chain: 'near:mainnet',
    type: 'NEAR',
    blockchain: 'Near',
    address: 'alice.near',
    method: 'near_signAndSendTransaction',
    result: 'submitted-hash',
  ),
  (
    ns: 'sui',
    chain: 'sui:mainnet',
    type: 'SUI',
    blockchain: 'Sui',
    address: '0xdef456',
    method: 'sui_signAndExecuteTransaction',
    result: <String, dynamic>{
      'digest': 'submitted-hash',
      'effects': {
        'status': {'status': 'success'},
      },
    },
  ),
];

class _Signer extends WalletConnectProvider {
  int walletIndex = 0;
  String owner = 'fixture-owner';
  bool disposed = false;
  final submissions = <(CoinType, String, bool)>[];
  String? submittedChain;
  Completer<MessageModel>? rpc;
  final rpcStarted = Completer<void>();
  @override
  int get signingWalletIndex => walletIndex;
  @override
  String get signingWalletOwner => owner;
  @override
  Future<({String mnemonic, String privateKey})>
  getCurrentWalletCredentials() async =>
      (mnemonic: 'fixture mnemonic', privateKey: 'fixture private key');
  @override
  Future<MessageModel> broadcastNonEvmTransaction(
    CoinType type,
    String signedTransaction, {
    required bool isTest,
    String? sessionChainId,
  }) {
    submittedChain = sessionChainId;
    submissions.add((type, signedTransaction, isTest));
    if (!rpcStarted.isCompleted) {
      rpcStarted.complete();
    }
    return rpc?.future ?? Future.value(MessageModel()..data = 'submitted-hash');
  }

  @override
  Future<MessageModel> broadcastSuiTransaction(
    String transactionBlock,
    String signature, {
    required bool isTest,
  }) {
    expect(transactionBlock, 'cmF3');
    submissions.add((CoinType.SUI, signature, isTest));
    if (!rpcStarted.isCompleted) rpcStarted.complete();
    return rpc?.future ??
        Future.value(MessageModel()..data = _chains.last.result);
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

wc.SessionData _session(
  String ns,
  String chain,
  String address,
  String method,
) {
  const metadata = wc.ConnectionMetadata(
    publicKey: 'fixture',
    metadata: wc.PairingMetadata(
      name: 'fixture',
      description: '',
      url: 'https://example.test',
      icons: [],
    ),
  );
  return wc.SessionData(
    topic: 'request-topic',
    pairingTopic: 'pairing',
    relay: wc.Relay('irn'),
    expiry: 4102444800,
    acknowledged: true,
    controller: 'fixture',
    self: metadata,
    peer: metadata,
    namespaces: {
      ns: wc.Namespace(
        accounts: ['$chain:$address'],
        methods: [method],
        events: [],
      ),
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('trustdart');
  late _Signer provider;
  late WalletKitFake client;
  late Completer<String> native;
  late Completer<void> nativeStarted;
  int nativeCalls = 0;
  setUp(() {
    native = Completer<String>();
    nativeStarted = Completer<void>();
    nativeCalls = 0;
    client = WalletKitFake();
    provider = _Signer()..signClient = client;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'generateAddress') {
            return {'legacy': provider.coinModels.single.address};
          }
          nativeCalls++;
          if (!nativeStarted.isCompleted) {
            nativeStarted.complete();
          }
          return native.future;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    provider.signClient = null;
    if (!provider.disposed) {
      provider.dispose();
    }
  });
  void supersede() {
    provider.actionData = sessionRequest('personal_sign', [
      'new request',
      'fixture',
    ]);
    provider.walletConnectState = WalletConnectState.messageSignOK;
  }

  test('unsupported Solana chain is rejected before native signing', () async {
    final c = _chains.first;
    const chain = 'solana:unknown';
    provider.coinModels = [
      sessionCoin(type: c.type, blockchain: c.blockchain, address: c.address)
        ..coin['path'] = {'legacy': "m/44'/0'/0'"},
    ];
    provider.coinModelsIndex = 0;
    client.activeSessions['request-topic'] = _session(
      c.ns,
      chain,
      c.address,
      c.method,
    );
    provider.actionData = sessionRequest(c.method, {
      'transaction': 'cmF3',
    }, chain: chain);
    await provider.transactionSignTap();
    expect(nativeCalls, 0);
    expect(provider.submissions, isEmpty);
    expect(provider.walletConnectState, WalletConnectState.error);
  });

  for (final invalid in [
    'bad encoding',
    'wrong sender',
    'wrong chain',
    'trailing data',
  ]) {
    test('Aptos $invalid cannot reach native signing', () async {
      final c = _chains[1];
      var raw = aptosRawFixture(c.address);
      if (invalid == 'bad encoding') raw = '!!!';
      if (invalid == 'wrong sender') raw = aptosRawFixture('0x2');
      if (invalid == 'wrong chain') raw = aptosRawFixture(c.address, chain: 2);
      if (invalid == 'trailing data') {
        raw = base64Encode([...base64Decode(raw), 0]);
      }
      provider.coinModels = [
        sessionCoin(type: c.type, blockchain: c.blockchain, address: c.address)
          ..coin['path'] = {'legacy': "m/44'/0'/0'"},
      ];
      provider.coinModelsIndex = 0;
      client.activeSessions['request-topic'] = _session(
        c.ns,
        c.chain,
        c.address,
        c.method,
      );
      provider.actionData = sessionRequest(c.method, {
        'encodedTransaction': raw,
      }, chain: c.chain);
      await provider.transactionSignTap();
      expect(nativeCalls, 0);
      expect(provider.submissions, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.error);
    });
  }

  for (final chain in [
    'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
    'solana:8E9rvCKLFQia2Y35HXjjpWzj8weVo44K',
  ]) {
    test('Solana submits the approved request chain $chain', () async {
      final c = _chains.first;
      provider.coinModels = [
        sessionCoin(type: c.type, blockchain: c.blockchain, address: c.address)
          ..coin['path'] = {'legacy': "m/44'/0'/0'"},
      ];
      provider.coinModelsIndex = 0;
      client.activeSessions['request-topic'] = _session(
        c.ns,
        chain,
        c.address,
        c.method,
      );
      provider.actionData = sessionRequest(c.method, {
        'transaction': 'cmF3',
      }, chain: chain);
      final operation = provider.transactionSignTap();
      await nativeStarted.future;
      native.complete('signed');
      await operation;
      expect(provider.submittedChain, chain);
      expect(provider.submissions, hasLength(1));
    });
  }

  for (final c in _chains.skip(1)) {
    for (final requestIsTest in [false, true]) {
      for (final walletIsTest in [false, true]) {
        test(
          '${c.ns} request network $requestIsTest overrides wallet mode $walletIsTest',
          () async {
            final chain = c.ns == 'aptos'
                ? (requestIsTest ? 'aptos:2' : 'aptos:1')
                : '${c.ns}:${requestIsTest ? 'testnet' : 'mainnet'}';
            provider.coinModels = [
              sessionCoin(
                  type: c.type,
                  blockchain: c.blockchain,
                  address: c.address,
                )
                ..coin['path'] = {'legacy': "m/44'/0'/0'"}
                ..isTest = walletIsTest,
            ];
            provider.coinModelsIndex = 0;
            client.activeSessions['request-topic'] = _session(
              c.ns,
              chain,
              c.address,
              c.method,
            );
            provider.actionData = sessionRequest(c.method, {
              'transaction': c.ns == 'aptos'
                  ? aptosRawFixture(c.address, chain: requestIsTest ? 2 : 1)
                  : 'cmF3',
            }, chain: chain);
            final operation = provider.transactionSignTap();
            await nativeStarted.future;
            native.complete('signed');
            await operation;
            expect(provider.submissions.single.$3, requestIsTest);
            expect(client.responses.single.$2.result, c.result);
          },
        );
      }
    }
    test('${c.ns} unknown approved chain cannot reach native signer', () async {
      final chain = '${c.ns}:unknown';
      provider.coinModels = [
        sessionCoin(type: c.type, blockchain: c.blockchain, address: c.address)
          ..coin['path'] = {'legacy': "m/44'/0'/0'"},
      ];
      provider.coinModelsIndex = 0;
      client.activeSessions['request-topic'] = _session(
        c.ns,
        chain,
        c.address,
        c.method,
      );
      provider.actionData = sessionRequest(c.method, {
        'transaction': 'cmF3',
      }, chain: chain);
      await provider.transactionSignTap();
      expect(nativeCalls, 0);
      expect(provider.submissions, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.error);
    });
  }

  for (final c in _chains) {
    Future<void> execute() {
      provider.coinModels = [
        sessionCoin(type: c.type, blockchain: c.blockchain, address: c.address)
          ..coin['path'] = {'legacy': "m/44'/0'/0'"},
      ];
      provider.coinModelsIndex = 0;
      client.activeSessions['request-topic'] = _session(
        c.ns,
        c.chain,
        c.address,
        c.method,
      );
      provider.actionData = sessionRequest(c.method, {
        'transaction': c.ns == 'aptos' ? aptosRawFixture(c.address) : 'cmF3',
      }, chain: c.chain);
      return provider.transactionSignTap();
    }

    for (final mutation in [
      'revoked',
      'wallet',
      'owner',
      'address',
      'path',
      'network',
      'request',
      'disconnect',
      'dispose',
      'client',
    ]) {
      test(
        '${c.method} does not submit after $mutation changes during native signing',
        () async {
          final operation = execute();
          await nativeStarted.future;
          if (mutation == 'revoked') {
            client.activeSessions.clear();
          }
          if (mutation == 'wallet') {
            provider.walletIndex++;
          }
          if (mutation == 'owner') {
            provider.owner = 'other-owner';
          }
          if (mutation == 'address') {
            provider.coinModels.single.address = 'different-account';
          }
          if (mutation == 'path') {
            provider.coinModels.single.pathIndex++;
          }
          if (mutation == 'network') {
            provider.coinModels.single.isTest = true;
          }
          if (mutation == 'request') {
            supersede();
          }
          if (mutation == 'disconnect') {
            provider.walletConnectState = WalletConnectState.disconnect;
          }
          if (mutation == 'dispose') {
            provider.dispose();
          }
          if (mutation == 'client') {
            provider.signClient = WalletKitFake();
          }
          native.complete('signed-native');
          await operation;
          expect(provider.submissions, isEmpty);
          expect(client.responses, isEmpty);
          if (mutation == 'request') {
            expect(
              provider.walletConnectState,
              WalletConnectState.messageSignOK,
            );
          }
          if (mutation == 'disconnect') {
            expect(provider.walletConnectState, WalletConnectState.disconnect);
          }
        },
      );
    }
    test(
      '${c.method} still submits once and returns the original response shape',
      () async {
        native.complete('signed-native');
        await execute();
        expect(nativeCalls, 1);
        expect(provider.submissions, hasLength(1));
        expect(provider.submissions.single.$1.name, c.type);
        expect(provider.submissions.single.$2, 'signed-native');
        expect(client.responses.single.$2.result, c.result);
        expect(provider.walletConnectState, WalletConnectState.connect);
      },
    );
    test(
      '${c.method} stale native empty output preserves the new preview',
      () async {
        final operation = execute();
        await nativeStarted.future;
        supersede();
        native.complete('');
        await operation;
        expect(provider.submissions, isEmpty);
        expect(client.responses, isEmpty);
        expect(provider.walletConnectState, WalletConnectState.messageSignOK);
        expect(provider.errorMessage, isEmpty);
      },
    );
    test('${c.method} stale RPC error preserves the new preview', () async {
      provider.rpc = Completer<MessageModel>();
      native.complete('signed-native');
      final operation = execute();
      await provider.rpcStarted.future;
      supersede();
      provider.rpc!.complete(
        MessageModel()
          ..error = true
          ..data = 'old RPC failure',
      );
      await operation;
      expect(provider.submissions, hasLength(1));
      expect(client.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.messageSignOK);
      expect(provider.errorMessage, isEmpty);
    });
    test(
      '${c.method} current RPC errors remain visible and do not report success',
      () async {
        provider.rpc = Completer<MessageModel>();
        native.complete('signed-native');
        final operation = execute();
        await provider.rpcStarted.future;
        provider.rpc!.complete(
          MessageModel()
            ..error = true
            ..data = 'current RPC failure',
        );
        await operation;
        expect(provider.walletConnectState, WalletConnectState.error);
        expect(provider.errorMessage, 'current RPC failure');
        expect(client.responses, isEmpty);
        expect(provider.submissions, hasLength(1));
      },
    );
    for (final failed in [false, true]) {
      test(
        '${c.method} RPC ${failed ? 'error' : 'success'} cannot reset a changed wallet context',
        () async {
          provider.rpc = Completer<MessageModel>();
          native.complete('signed-native');
          final operation = execute();
          await provider.rpcStarted.future;
          provider.walletIndex++;
          provider.walletConnectState = WalletConnectState.transactionOK;
          provider.rpc!.complete(
            MessageModel()
              ..error = failed
              ..data = failed
                  ? 'old RPC failure'
                  : (c.ns == 'sui' ? c.result : 'submitted-hash'),
          );
          await operation;
          expect(provider.walletConnectState, WalletConnectState.transactionOK);
          expect(provider.errorMessage, isEmpty);
          if (failed) {
            expect(client.responses, isEmpty);
          } else {
            expect(client.responses.single.$2.result, c.result);
          }
          expect(provider.submissions, hasLength(1));
        },
      );
    }
    test(
      '${c.method} submitted success returns to its original SDK client',
      () async {
        provider.rpc = Completer<MessageModel>();
        native.complete('signed-native');
        final operation = execute();
        await provider.rpcStarted.future;
        final replacement = WalletKitFake();
        provider.signClient = replacement;
        supersede();
        provider.rpc!.complete(
          MessageModel()..data = c.ns == 'sui' ? c.result : 'submitted-hash',
        );
        await operation;
        expect(client.responses.single.$2.result, c.result);
        expect(replacement.responses, isEmpty);
        expect(provider.walletConnectState, WalletConnectState.messageSignOK);
      },
    );
  }
}
