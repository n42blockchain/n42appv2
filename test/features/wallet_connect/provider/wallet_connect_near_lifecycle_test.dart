import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;

import '../../../helpers/wallet_connect_client_fake.dart';

class _Signer extends WalletConnectProvider {
  int walletIndex = 0;
  String owner = 'fixture-owner';
  int credentialReads = 0;
  bool disposed = false;
  @override
  int get signingWalletIndex => walletIndex;
  @override
  String get signingWalletOwner => owner;
  @override
  Future<({String mnemonic, String privateKey})>
  getCurrentWalletCredentials() async {
    credentialReads++;
    return (mnemonic: 'fixture mnemonic', privateKey: 'fixture private key');
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

wc.SessionData _session() {
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
      'near': wc.Namespace(
        accounts: ['near:mainnet:alice.near'],
        methods: ['near_signTransaction'],
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
  late List<MethodCall> calls;
  Future<String> Function(int)? sign;
  setUp(() {
    calls = [];
    sign = null;
    client = WalletKitFake()..activeSessions['request-topic'] = _session();
    provider = _Signer()
      ..signClient = client
      ..coinModels = [
        sessionCoin(type: 'NEAR', blockchain: 'Near', address: 'alice.near')
          ..coin['path'] = {'legacy': "m/44'/397'/0'"},
      ]
      ..coinModelsIndex = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return sign == null
              ? 'signed-${calls.length}'
              : await sign!(calls.length);
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    provider.signClient = null;
    if (!provider.disposed) provider.dispose();
  });
  Future<void> execute(Map<String, dynamic> params) {
    provider.actionData = sessionRequest(
      'near_signTransaction',
      params,
      chain: 'near:mainnet',
    );
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
  ]) {
    test(
      'NEAR does not sign the next item after $mutation changes during native work',
      () async {
        final started = Completer<void>();
        final first = Completer<String>();
        sign = (count) async {
          if (count == 1) {
            started.complete();
            return first.future;
          }
          return 'signed-$count';
        };
        final operation = execute({
          'transactions': ['Zmlyc3Q=', 'c2Vjb25k'],
        });
        await started.future;
        if (mutation == 'revoked') client.activeSessions.clear();
        if (mutation == 'wallet') provider.walletIndex++;
        if (mutation == 'owner') provider.owner = 'other-owner';
        if (mutation == 'address') {
          provider.coinModels.single.address = 'bob.near';
        }
        if (mutation == 'path') provider.coinModels.single.pathIndex++;
        if (mutation == 'network') provider.coinModels.single.isTest = true;
        if (mutation == 'request') {
          provider.actionData = sessionRequest('personal_sign', [
            'new',
            'fixture',
          ]);
          provider.walletConnectState = WalletConnectState.messageSignOK;
        }
        if (mutation == 'disconnect') {
          provider.walletConnectState = WalletConnectState.disconnect;
        }
        if (mutation == 'dispose') provider.dispose();
        first.complete('signed-1');
        await operation;
        expect(calls, hasLength(1));
        expect(client.responses, isEmpty);
        if (mutation == 'request') {
          expect(provider.walletConnectState, WalletConnectState.messageSignOK);
        }
        if (mutation == 'disconnect') {
          expect(provider.walletConnectState, WalletConnectState.disconnect);
        }
      },
    );
  }
  test(
    'a stale empty native result cannot replace a new preview with an error',
    () async {
      final started = Completer<void>();
      final first = Completer<String>();
      sign = (_) {
        started.complete();
        return first.future;
      };
      final operation = execute({
        'transactions': ['Zmlyc3Q='],
      });
      await started.future;
      provider.actionData = sessionRequest('personal_sign', ['new', 'fixture']);
      provider.walletConnectState = WalletConnectState.messageSignOK;
      first.complete('');
      await operation;
      expect(provider.walletConnectState, WalletConnectState.messageSignOK);
      expect(provider.errorMessage, isEmpty);
      expect(client.responses, isEmpty);
    },
  );
  for (final invalid in [
    null,
    42,
    <String, dynamic>{'raw': 'data'},
    '',
  ]) {
    test(
      'NEAR rejects an invalid batch entry ($invalid) before credentials or partial signing',
      () async {
        await execute({
          'transactions': ['Zmlyc3Q=', invalid],
        });
        expect(calls, isEmpty);
        expect(provider.credentialReads, 0);
        expect(client.responses, isEmpty);
        expect(provider.walletConnectState, WalletConnectState.error);
      },
    );
  }
  test('NEAR single-transaction alias retains its signed result', () async {
    await execute({'transaction': 'Zmlyc3Q='});
    expect(calls, hasLength(1));
    expect(client.responses.single.$2.result, 'signed-1');
  });
  test(
    'NEAR signs a stable batch snapshot in order and returns every result',
    () async {
      final source = ['Zmlyc3Q=', 'c2Vjb25k', 'dGhpcmQ='];
      sign = (count) async {
        if (count == 1) source[1] = 'changed';
        return 'signed-$count';
      };
      await execute({'transactions': source});
      expect(calls.map((c) => c.arguments['txData']['transaction']), [
        'Zmlyc3Q=',
        'c2Vjb25k',
        'dGhpcmQ=',
      ]);
      expect(client.responses.single.$2.result, [
        'signed-1',
        'signed-2',
        'signed-3',
      ]);
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );
}
