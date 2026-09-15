import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;

import '../../helpers/wallet_connect_client_fake.dart';
import '../../helpers/wallet_connect_session_fixture.dart';

wc.RequiredNamespace _namespace(
  List<String>? chains, {
  List<String> methods = const [],
  List<String> events = const [],
}) => wc.RequiredNamespace(chains: chains, methods: methods, events: events);

wc.SessionProposalEvent _proposal({
  Map<String, wc.RequiredNamespace> optional = const {},
  Map<String, wc.RequiredNamespace> required = const {},
}) => wc.SessionProposalEvent(
  42,
  wc.ProposalData(
    id: 42,
    expiry: 2200000000,
    relays: [wc.Relay('irn')],
    proposer: session('proposal-dapp').peer,
    requiredNamespaces: required,
    optionalNamespaces: optional,
    pairingTopic: 'pairing-topic',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WalletKitFake client;
  late SessionPreviewProvider provider;
  setUp(() {
    client = WalletKitFake();
    provider = SessionPreviewProvider()..signClient = client;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (_) async => true,
        );
  });
  tearDown(() {
    provider.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          null,
        );
  });

  test('subscription can start after the SDK client becomes available', () {
    provider.signClient = null;
    provider.setChainInfo();
    provider.signClient = client;
    provider.setChainInfo();
    client.onSessionProposal.broadcast(_proposal());
    expect(provider.states, [WalletConnectState.selectChain]);
  });

  test(
    'repeated setup registers one listener and one set of chain handlers',
    () {
      provider.availableChains['eip155:1'] = sessionCoin();
      provider.setChainInfo();
      provider.setChainInfo();
      final proposal = _proposal(
        required: {
          'eip155': _namespace(['eip155:1']),
        },
      );
      client.onSessionProposal.broadcast(proposal);
      expect(provider.states, [WalletConnectState.selectChain]);
      expect(provider.actionData, same(proposal));
      expect(provider.metadata?.name, 'proposal-dapp');
      expect(client.accounts, [
        ('eip155:1', '0x1111111111111111111111111111111111111111'),
      ]);
      expect(client.handlers.toSet(), hasLength(client.handlers.length));
      expect(
        client.handlers,
        containsAll([
          ('eip155:1', 'personal_sign'),
          ('eip155:1', 'eth_sendTransaction'),
        ]),
      );
      expect(provider.namespace?['eip155']?.chains, ['eip155:1']);
      expect(provider.namespace?['eip155']?.events, [
        'chainChanged',
        'accountsChanged',
      ]);
    },
  );

  test('same account on Ethereum and Polygon retains both EVM permissions', () {
    provider.availableChains.addAll({
      'eip155:1': sessionCoin(),
      'eip155:137': sessionCoin(type: 'MATIC', chainId: 137),
    });
    provider.setChainInfo();
    client.onSessionProposal.broadcast(
      _proposal(
        optional: {
          'eip155': _namespace(['eip155:1', 'eip155:137']),
        },
        required: {
          'eip155': _namespace(['eip155:1']),
        },
      ),
    );
    expect(provider.coinModels, hasLength(2));
    expect(
      provider.namespace?['eip155']?.chains,
      unorderedEquals(['eip155:1', 'eip155:137']),
    );
    expect(
      client.accounts,
      unorderedEquals([
        ('eip155:1', '0x1111111111111111111111111111111111111111'),
        ('eip155:137', '0x1111111111111111111111111111111111111111'),
      ]),
    );
  });

  test(
    'required chains are retained and unknown optional chains are skipped',
    () {
      provider.availableChains.addAll({
        'eip155:1': sessionCoin(),
        'eip155:137': sessionCoin(type: 'MATIC', chainId: 137),
      });
      provider.setChainInfo();
      client.onSessionProposal.broadcast(
        _proposal(
          optional: {
            'eip155': _namespace(['eip155:1', 'eip155:9999']),
            'unknown': _namespace(null),
          },
          required: {
            'eip155': _namespace(['eip155:137']),
            'other': _namespace(null),
          },
        ),
      );
      expect(provider.coinModels.map((c) => c.coin['chainId']), [137, 1]);
      expect(provider.namespace?.keys, ['eip155']);
    },
  );

  for (final address in [null, '', 'null']) {
    test('EVM account $address is not advertised as a signable account', () {
      provider.availableChains['eip155:1'] = sessionCoin(address: address);
      provider.setChainInfo();
      client.onSessionProposal.broadcast(
        _proposal(
          required: {
            'eip155': _namespace(['eip155:1']),
          },
        ),
      );
      expect(client.accounts, isEmpty);
      expect(client.handlers, isEmpty);
      expect(provider.namespace, isEmpty);
    });
  }

  test('testnet proposal registers the test chain ID rather than mainnet', () {
    provider.availableChains['eip155:11155111'] = sessionCoin(isTest: true);
    provider.setChainInfo();
    client.onSessionProposal.broadcast(
      _proposal(
        required: {
          'eip155': _namespace(['eip155:11155111']),
        },
      ),
    );
    expect(provider.namespace?['eip155']?.chains, ['eip155:11155111']);
    expect(client.accounts.single.$1, 'eip155:11155111');
  });

  for (final (ns, chain, type, blockchain, methods) in [
    (
      'tron',
      'tron:0x2b6653dc',
      'TRX',
      'Tron',
      ['tron_signTransaction', 'tron_signMessage'],
    ),
    (
      'solana',
      'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
      'SOL',
      'Solana',
      [
        'solana_signTransaction',
        'solana_signMessage',
        'solana_signAndSendTransaction',
      ],
    ),
    (
      'aptos',
      'aptos:1',
      'APT',
      'Aptos',
      [
        'aptos_signTransaction',
        'aptos_signMessage',
        'aptos_signAndSubmitTransaction',
      ],
    ),
    (
      'sui',
      'sui:mainnet',
      'SUI',
      'Sui',
      [
        'sui_signTransaction',
        'sui_signAndExecuteTransaction',
        'sui_signMessage',
      ],
    ),
    (
      'near',
      'near:mainnet',
      'NEAR',
      'Near',
      ['near_signTransaction', 'near_signAndSendTransaction'],
    ),
  ]) {
    test(
      '$ns proposal advertises supported methods with no unsolicited EVM events',
      () {
        provider.availableChains[chain] = sessionCoin(
          type: type,
          blockchain: blockchain,
          address: 'fixture-account',
        );
        provider.setChainInfo();
        client.onSessionProposal.broadcast(
          _proposal(
            required: {
              ns: _namespace([chain]),
            },
          ),
        );
        expect(provider.namespace?.keys, [ns]);
        expect(provider.namespace?[ns]?.accounts, ['$chain:fixture-account']);
        expect(provider.namespace?[ns]?.chains, [chain]);
        expect(provider.namespace?[ns]?.events, isEmpty);
        expect(provider.namespace?[ns]?.methods, methods);
        expect(client.handlers.map((h) => h.$2), methods);
        expect(client.accounts, [(chain, 'fixture-account')]);
      },
    );
    test(
      '$ns merges overlapping requested permissions without duplicate registration',
      () {
        provider.availableChains[chain] = sessionCoin(
          type: type,
          blockchain: blockchain,
          address: 'fixture-account',
        );
        provider.setChainInfo();
        client.onSessionProposal.broadcast(
          _proposal(
            optional: {
              ns: _namespace(
                [chain],
                methods: [methods.first],
                events: ['accountsChanged'],
              ),
            },
            required: {
              ns: _namespace(
                [chain],
                methods: methods,
                events: ['accountsChanged', 'chainChanged'],
              ),
            },
          ),
        );
        expect(provider.namespace?[ns]?.methods, methods);
        expect(provider.namespace?[ns]?.events, [
          'accountsChanged',
          'chainChanged',
        ]);
        expect(client.accounts, hasLength(1));
      },
    );
  }

  test('a new proposal replaces the previous proposal namespace', () {
    provider.availableChains['eip155:1'] = sessionCoin();
    provider.setChainInfo();
    client.onSessionProposal.broadcast(
      _proposal(
        required: {
          'eip155': _namespace(['eip155:1']),
        },
      ),
    );
    client.onSessionProposal.broadcast(
      _proposal(
        required: {
          'unsupported': _namespace(['unsupported:1']),
        },
      ),
    );
    expect(provider.namespace, isEmpty);
    expect(provider.coinModels, isEmpty);
    expect(provider.coinModelsIndex, -1);
  });

  test('a request event reaches the production dispatcher', () async {
    provider.coinModels = [sessionCoin(chainId: 137)];
    provider.coinModelsIndex = 0;
    provider.setChainInfo();
    client.onSessionRequest.broadcast(sessionRequest('eth_chainId', null));
    expect(client.responses.single.$2.result, '0x89');
  });

  test(
    'expiring a different session preserves the currently selected session',
    () {
      provider.dAppTopic = 'selected';
      provider.setChainInfo();
      client.onSessionExpire.broadcast(wc.SessionExpire('other'));
      expect(provider.states, isEmpty);
      expect(provider.dAppTopic, 'selected');
    },
  );

  test('expiration of the selected session requests a disconnect', () async {
    provider.dAppTopic = 'selected';
    provider.setChainInfo();
    client.onSessionExpire.broadcast(wc.SessionExpire('selected'));
    expect(provider.states, [WalletConnectState.disconnect]);
  });

  test(
    'remote deletion of another session refreshes the list without disconnecting',
    () {
      provider.dAppTopic = 'selected';
      var changes = 0;
      provider.addListener(() => changes++);
      provider.setChainInfo();
      client.onSessionDelete.broadcast(wc.SessionDelete('other'));
      expect(changes, 1);
      expect(provider.states, isEmpty);
    },
  );

  test(
    'user-initiated deletion suppresses duplicate remote disconnect handling',
    () {
      provider.dAppTopic = 'selected';
      provider.disconnectingByUser = true;
      provider.setChainInfo();
      client.onSessionDelete.broadcast(wc.SessionDelete('selected'));
      expect(provider.states, isEmpty);
    },
  );

  test('proposal error is exposed with the SDK error message', () {
    provider.setChainInfo();
    client.onSessionProposalError.broadcast(
      wc.SessionProposalErrorEvent(
        42,
        {},
        {},
        const wc.ReownSignError(code: 5100, message: 'Unsupported chain'),
      ),
    );
    expect(provider.states, [WalletConnectState.error]);
    expect(provider.errorMessage, 'Unsupported chain');
  });

  test('proposal timeout is exposed as a retryable error', () {
    provider.setChainInfo();
    client.onProposalExpire.broadcast(_proposal());
    expect(provider.states, [WalletConnectState.error]);
    expect(provider.errorMessage, contains('timed out'));
  });
}
