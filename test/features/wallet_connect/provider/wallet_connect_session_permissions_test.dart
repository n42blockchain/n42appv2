import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;
import 'package:web3dart/web3dart.dart' as web3;

import '../../../helpers/wallet_connect_client_fake.dart';

final _key = web3.EthPrivateKey.fromInt(BigInt.one);
final _address = _key.address.with0x;

class _Signer extends WalletConnectProvider {
  Completer<bool>? initializing;
  int keyReads = 0;
  @override
  Future<bool> web3clientInitFromChainId(String chain) =>
      initializing?.future ?? Future.value(true);
  @override
  web3.EthPrivateKey get privateKey {
    keyReads++;
    return _key;
  }
}

wc.SessionData _session({
  int expiry = 4102444800,
  String namespace = 'eip155',
  List<String>? methods,
}) {
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
    expiry: expiry,
    acknowledged: true,
    controller: 'fixture',
    self: metadata,
    peer: metadata,
    namespaces: {
      namespace: wc.Namespace(
        accounts: ['eip155:1:$_address', 'eip155:94:$_address'],
        methods:
            methods ??
            ['personal_sign', 'eth_signTypedData_v4', 'eth_sendTransaction'],
        events: [],
      ),
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WalletKitFake client;
  late _Signer provider;
  setUp(() {
    client = WalletKitFake()..activeSessions['request-topic'] = _session();
    provider = _Signer()..signClient = client;
  });
  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });
  test('approved personal_sign reaches the actual signing handler', () async {
    provider.actionData = sessionRequest('personal_sign', [
      'fixture',
      _address,
    ]);
    await provider.messageSignTap();
    expect(
      client.responses.single.$2.result,
      matches(RegExp(r'^0x[0-9a-f]{130}$')),
    );
    expect(provider.walletConnectState, WalletConnectState.connect);
  });
  test('approved multi-chain and chain-keyed namespaces remain usable', () {
    expect(
      provider.isSessionRequestAuthorized(
        sessionRequest('personal_sign', ['text', _address], chain: 'eip155:94'),
      ),
      isTrue,
    );
    client.activeSessions['request-topic'] = _session(namespace: 'eip155:1');
    expect(
      provider.isSessionRequestAuthorized(
        sessionRequest('personal_sign', ['text', _address]),
      ),
      isTrue,
    );
  });
  test(
    'unauthorized incoming request cannot replace another active preview',
    () async {
      final current = sessionRequest('personal_sign', ['current', _address]);
      provider.actionData = current;
      provider.walletConnectState = WalletConnectState.messageSignOK;
      await provider.setActionDataMap(
        sessionRequest('personal_sign', [
          'invalid',
          _address,
        ], topic: 'unknown-topic'),
      );
      expect(provider.actionData, same(current));
      expect(provider.walletConnectState, WalletConnectState.messageSignOK);
      expect(client.responses.single.$2.error?.code, 4100);
      expect(provider.keyReads, 0);
    },
  );
  for (final scenario in ['missing', 'expired', 'method', 'chain', 'account']) {
    test(
      '$scenario permission is rejected before a signature response',
      () async {
        if (scenario == 'missing') client.activeSessions.clear();
        if (scenario == 'expired') {
          client.activeSessions['request-topic'] = _session(expiry: 1);
        }
        if (scenario == 'method') {
          client.activeSessions['request-topic'] = _session(methods: []);
        }
        provider.actionData = sessionRequest('personal_sign', [
          'fixture',
          scenario == 'account' ? '0x${'11' * 20}' : _address,
        ], chain: scenario == 'chain' ? 'eip155:2' : 'eip155:1');
        await provider.messageSignTap();
        expect(client.responses, isEmpty);
        expect(provider.errorMessage, contains('approved session permissions'));
      },
    );
  }
  test(
    'revocation during initialization stops before key use or send',
    () async {
      provider.initializing = Completer<bool>();
      provider.actionData = sessionRequest('eth_sendTransaction', [
        {'from': _address},
      ]);
      final sending = provider.transactionSignTap();
      client.activeSessions.clear();
      provider.initializing!.complete(true);
      await sending;
      expect(provider.keyReads, 0);
      expect(client.responses, isEmpty);
      expect(provider.errorMessage, contains('permissions changed'));
    },
  );
  test('transaction sender must appear in approved session accounts', () {
    expect(
      provider.isSessionRequestAuthorized(
        sessionRequest('eth_sendTransaction', [
          {'from': _address},
        ]),
      ),
      isTrue,
    );
    expect(
      provider.isSessionRequestAuthorized(
        sessionRequest('eth_sendTransaction', [
          {'from': '0x${'11' * 20}'},
        ]),
      ),
      isFalse,
    );
  });
  test('stateless connection probes keep their existing path', () {
    client.activeSessions.clear();
    expect(
      provider.isSessionRequestAuthorized(sessionRequest('eth_accounts', [])),
      isTrue,
    );
  });
}
