import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;

import '../../../helpers/wallet_connect_client_fake.dart';

const _chains = [
  (
    ns: 'tron',
    chain: 'tron:0x2b6653dc',
    type: 'TRX',
    blockchain: 'Tron',
    address: 'TJRabPrwbZy45sbavfcjinPJC18kjpRTv8',
    field: 'address',
    methods: ['tron_signMessage', 'tron_signTransaction'],
  ),
  (
    ns: 'solana',
    chain: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
    type: 'SOL',
    blockchain: 'Solana',
    address: 'So11111111111111111111111111111111111111112',
    field: 'pubkey',
    methods: [
      'solana_signMessage',
      'solana_signTransaction',
      'solana_signAndSendTransaction',
    ],
  ),
  (
    ns: 'aptos',
    chain: 'aptos:1',
    type: 'APT',
    blockchain: 'Aptos',
    address: '0xabc123',
    field: 'address',
    methods: [
      'aptos_signMessage',
      'aptos_signTransaction',
      'aptos_signAndSubmitTransaction',
    ],
  ),
  (
    ns: 'sui',
    chain: 'sui:mainnet',
    type: 'SUI',
    blockchain: 'Sui',
    address: '0xdef456',
    field: 'account',
    methods: [
      'sui_signMessage',
      'sui_signTransaction',
      'sui_signAndExecuteTransaction',
    ],
  ),
  (
    ns: 'near',
    chain: 'near:mainnet',
    type: 'NEAR',
    blockchain: 'Near',
    address: 'alice.near',
    field: 'signerId',
    methods: ['near_signTransaction', 'near_signAndSendTransaction'],
  ),
];

class _Signer extends WalletConnectProvider {
  @override
  Future<({String mnemonic, String privateKey})>
  getCurrentWalletCredentials() async =>
      (mnemonic: 'fixture mnemonic', privateKey: 'fixture private key');
}

wc.SessionData _session(
  String namespace,
  String chain,
  String address,
  List<String> methods, {
  int expiry = 4102444800,
  List<String>? chains,
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
        accounts: ['$chain:$address'],
        methods: methods,
        events: [],
        chains: chains,
      ),
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WalletConnectProvider provider;
  late WalletKitFake client;
  setUp(() {
    client = WalletKitFake();
    provider = _Signer()..signClient = client;
  });
  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });
  for (final c in _chains) {
    for (final method in c.methods) {
      void configure() {
        provider.coinModels = [
          sessionCoin(
            type: c.type,
            blockchain: c.blockchain,
            address: c.address,
          ),
        ];
        provider.coinModelsIndex = 0;
        client.activeSessions['request-topic'] = _session(
          c.ns,
          c.chain,
          c.address,
          c.methods,
        );
      }

      test(
        '$method permits an approved configured account with or without explicit signer',
        () {
          configure();
          for (final params in [
            {},
            {c.field: c.address},
          ]) {
            expect(
              provider.isSessionRequestAuthorized(
                sessionRequest(method, params, chain: c.chain),
              ),
              isTrue,
            );
          }
        },
      );
      test('$method preserves chain-keyed namespaces', () {
        configure();
        client.activeSessions['request-topic'] = _session(
          c.chain,
          c.chain,
          c.address,
          c.methods,
        );
        expect(
          provider.isSessionRequestAuthorized(
            sessionRequest(method, {}, chain: c.chain),
          ),
          isTrue,
        );
      });
      for (final scenario in [
        'missing',
        'expired',
        'method',
        'chain',
        'namespace',
        'account',
        'requested-account',
        'unconfigured',
        'params',
        'wrong-namespace',
      ]) {
        test('$method denies $scenario', () {
          configure();
          if (scenario == 'missing') client.activeSessions.clear();
          if (scenario == 'expired') {
            client.activeSessions['request-topic'] = _session(
              c.ns,
              c.chain,
              c.address,
              c.methods,
              expiry: 1,
            );
          }
          if (scenario == 'method') {
            client.activeSessions['request-topic'] = _session(
              c.ns,
              c.chain,
              c.address,
              [],
            );
          }
          if (scenario == 'chain') {
            client.activeSessions['request-topic'] = _session(
              c.ns,
              c.chain,
              c.address,
              c.methods,
              chains: ['${c.ns}:other'],
            );
          }
          if (scenario == 'namespace') {
            client.activeSessions['request-topic'] = _session(
              'other',
              c.chain,
              c.address,
              c.methods,
            );
          }
          if (scenario == 'account') {
            client.activeSessions['request-topic'] = _session(
              c.ns,
              c.chain,
              'different-account',
              c.methods,
            );
          }
          if (scenario == 'unconfigured') provider.coinModels = [];
          final params = scenario == 'params'
              ? []
              : scenario == 'requested-account'
              ? {c.field: 'different-account'}
              : <String, dynamic>{};
          expect(
            provider.isSessionRequestAuthorized(
              sessionRequest(
                method,
                params,
                chain: scenario == 'wrong-namespace' ? 'eip155:1' : c.chain,
              ),
            ),
            isFalse,
          );
        });
      }
    }
  }
  for (final c in _chains) {
    for (final method in c.methods.where((m) => !m.contains('And'))) {
      test(
        '$method reaches the native signer under a real approved session',
        () async {
          final calls = <MethodCall>[];
          const channel = MethodChannel('trustdart');
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (call) async {
                calls.add(call);
                return 'fixture-signature';
              });
          addTearDown(
            () => TestDefaultBinaryMessengerBinding
                .instance
                .defaultBinaryMessenger
                .setMockMethodCallHandler(channel, null),
          );
          provider.coinModels = [
            sessionCoin(
              type: c.type,
              blockchain: c.blockchain,
              address: c.address,
            )..coin['path'] = {'legacy': "m/44'/0'/0'"},
          ];
          provider.coinModelsIndex = 0;
          client.activeSessions['request-topic'] = _session(
            c.ns,
            c.chain,
            c.address,
            c.methods,
          );
          provider.actionData = sessionRequest(method, {
            c.field: c.address,
            'message': method == 'tron_signTransaction'
                ? <String, dynamic>{'transaction': <String, dynamic>{}}
                : 'Zml4dHVyZQ==',
            'transaction': 'cmF3',
            'encodedTransaction': 'cmF3',
            'transactionBlock': 'cmF3',
            'transactions': ['cmF3'],
          }, chain: c.chain);
          if (method.endsWith('Message')) {
            await provider.messageSignTap();
          } else {
            await provider.transactionSignTap();
          }
          expect(provider.errorMessage, isEmpty);
          expect(calls, hasLength(1));
          expect(calls.single.arguments['coin'], c.type);
          expect(client.responses.single.$2.error, isNull);
          expect(provider.walletConnectState, WalletConnectState.connect);
        },
      );
    }
    test('${c.ns} account comparison preserves address encoding rules', () {
      provider.coinModels = [
        sessionCoin(type: c.type, blockchain: c.blockchain, address: c.address),
      ];
      final hex = c.ns == 'aptos' || c.ns == 'sui';
      final alias = hex
          ? '0x000${c.address.substring(2).toUpperCase()}'
          : c.address.toUpperCase();
      client.activeSessions['request-topic'] = _session(
        c.ns,
        c.chain,
        alias,
        c.methods,
      );
      expect(
        provider.isSessionRequestAuthorized(
          sessionRequest(c.methods.first, {}, chain: c.chain),
        ),
        hex,
      );
    });
  }

  test('unapproved non-EVM request preserves an existing preview and responds 4100', () async {
    final current = sessionRequest('personal_sign', ['current', 'fixture']);
    provider.actionData = current;
    provider.walletConnectState = WalletConnectState.messageSignOK;
    await provider.setActionDataMap(
      sessionRequest('solana_signMessage', {
        'message': 'fixture',
      }, chain: _chains[1].chain),
    );
    expect(provider.actionData, same(current));
    expect(provider.walletConnectState, WalletConnectState.messageSignOK);
    expect(client.responses.single.$2.error?.code, 4100);
  });
}
