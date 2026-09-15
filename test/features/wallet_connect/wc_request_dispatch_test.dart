import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';

import '../../helpers/wallet_connect_client_fake.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WalletKitFake client;
  late SessionPreviewProvider provider;
  setUp(() {
    client = WalletKitFake();
    provider = SessionPreviewProvider()
      ..signClient = client
      ..coinModels = [sessionCoin()]
      ..coinModelsIndex = 0;
  });
  tearDown(() => provider.dispose());

  for (final isTest in [false, true]) {
    test(
      'chain introspection reports the selected ${isTest ? 'test' : 'main'} network',
      () async {
        provider.coinModels = [sessionCoin(chainId: 137, isTest: isTest)];
        await provider.setActionDataMap(sessionRequest('eth_chainId', null));
        await provider.setActionDataMap(
          sessionRequest('net_version', null, id: 43),
        );
        expect(client.responses.map((r) => r.$1), [
          'request-topic',
          'request-topic',
        ]);
        expect(client.responses.map((r) => r.$2.id), [42, 43]);
        expect(
          client.responses.map((r) => r.$2.result),
          isTest ? ['0xaa36a7', '11155111'] : ['0x89', '137'],
        );
        expect(provider.initializedChains, isEmpty);
        expect(provider.actionData, isNull);
      },
    );
  }

  test('chain introspection has a mainnet fallback before selection', () async {
    provider.coinModelsIndex = -1;
    await provider.setActionDataMap(sessionRequest('eth_chainId', null));
    await provider.setActionDataMap(sessionRequest('net_version', null));
    expect(client.responses.map((r) => r.$2.result), ['0x1', '1']);
  });

  for (final method in ['eth_accounts', 'eth_requestAccounts']) {
    test(
      '$method excludes non-EVM and absent addresses without loading keys',
      () async {
        provider.coinModels = [
          sessionCoin(address: null),
          sessionCoin(address: ''),
          sessionCoin(address: 'null'),
          sessionCoin(),
          sessionCoin(
            type: 'SOL',
            blockchain: 'Solana',
            address: 'solana-account',
          ),
        ];
        await provider.setActionDataMap(sessionRequest(method, null));
        expect(client.responses.single.$2.result, [
          '0x1111111111111111111111111111111111111111',
        ]);
        expect(provider.initializedChains, isEmpty);
      },
    );
  }

  for (final requested in ['0x89', '137']) {
    test(
      'chain switching accepts supported ID $requested and notifies once',
      () async {
        provider.coinModels.addAll([
          sessionCoin(type: 'APT', blockchain: 'Aptos', chainId: 137),
          sessionCoin(type: 'MATIC', chainId: 137),
        ]);
        var changes = 0;
        provider.addListener(() => changes++);
        await provider.setActionDataMap(
          sessionRequest('wallet_switchEthereumChain', [
            {'chainId': requested},
          ]),
        );
        expect(provider.coinModelsIndex, 2);
        expect(changes, 1);
        expect(client.responses.single.$2.error, isNull);
        expect(client.responses.single.$2.result, isNull);
        expect(provider.initializedChains, isEmpty);
      },
    );
  }

  for (final params in [
    null,
    [],
    [<String, dynamic>{}],
    [
      {'chainId': 'bad'},
    ],
    [
      {'chainId': '0x9999'},
    ],
  ]) {
    test('unsupported chain params $params leave selection intact', () async {
      await provider.setActionDataMap(
        sessionRequest('wallet_switchEthereumChain', params),
      );
      expect(provider.coinModelsIndex, 0);
      expect(client.responses.single.$2.error?.code, 4902);
      expect(provider.states, isEmpty);
    });
  }

  test(
    'add-chain acknowledgement does not insert a new configured wallet',
    () async {
      await provider.setActionDataMap(
        sessionRequest('wallet_addEthereumChain', [
          {'chainId': '0x9999'},
        ]),
      );
      expect(provider.coinModels, hasLength(1));
      expect(client.responses.single.$2.error, isNull);
      expect(provider.initializedChains, isEmpty);
    },
  );

  test(
    'null signing params stop before key initialization or preview',
    () async {
      await provider.setActionDataMap(sessionRequest('personal_sign', null));
      expect(provider.errorMessage, contains('params is null'));
      expect(provider.states, [WalletConnectState.error]);
      expect(provider.initializedChains, isEmpty);
      expect(provider.actionDataMap, isNull);
    },
  );

  for (final index in [-1, 1]) {
    test('invalid selected index $index stops signing dispatch', () async {
      provider.coinModelsIndex = index;
      await provider.setActionDataMap(
        sessionRequest('personal_sign', ['hello', 'address']),
      );
      expect(provider.errorMessage, 'No valid chain selected');
      expect(provider.initializedChains, isEmpty);
      expect(provider.actionDataMap, isNull);
    });
  }

  test(
    'failed chain initialization does not expose a signing preview',
    () async {
      provider.canInitialize = false;
      await provider.setActionDataMap(
        sessionRequest('personal_sign', ['hello', 'address']),
      );
      expect(provider.initializedChains, ['eip155:1']);
      expect(provider.actionDataMap, isNull);
      expect(provider.states, isEmpty);
    },
  );

  for (final method in [
    'personal_sign',
    'eth_sign',
    'eth_signTypedData',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
  ]) {
    test(
      '$method preserves message/address order and waits for confirmation',
      () async {
        final request = sessionRequest(
          method,
          method == 'personal_sign'
              ? ['payload', 'address']
              : ['address', 'payload'],
        );
        await provider.setActionDataMap(request);
        expect(provider.actionData, same(request));
        expect(provider.actionDataMap, {
          'network': 'ETH',
          'from': 'address',
          'data': 'payload',
          'signType': 'message',
        });
        expect(provider.states, [WalletConnectState.messageSignOK]);
        expect(
          client.responses,
          isEmpty,
          reason: 'Preview must not sign or approve a request',
        );
      },
    );
    test('$method rejects a missing message/address pair', () async {
      await provider.setActionDataMap(sessionRequest(method, ['only-one']));
      expect(provider.states, [WalletConnectState.error]);
      expect(provider.errorMessage, contains('expected 2, got 1'));
      expect(provider.actionDataMap, isNull);
    });
  }

  for (final (method, chain, params)
      in <(String, String, Map<String, dynamic>)>[
        (
          'tron_signMessage',
          'tron:0x2b6653dc',
          {'address': 'address', 'message': 'payload'},
        ),
        (
          'solana_signMessage',
          'solana:mainnet',
          {'pubkey': 'address', 'message': 'payload'},
        ),
        (
          'aptos_signMessage',
          'aptos:1',
          {'address': 'address', 'message': 'payload'},
        ),
        (
          'aptos_signMessage',
          'aptos:1',
          {'address': 'address', 'fullMessage': 'payload'},
        ),
        (
          'sui_signMessage',
          'sui:mainnet',
          {'account': 'address', 'message': 'payload'},
        ),
      ]) {
    test(
      '$method maps $params to the confirmation without responding',
      () async {
        await provider.setActionDataMap(
          sessionRequest(method, params, chain: chain),
        );
        expect(provider.initializedChains, [chain]);
        expect(provider.actionDataMap, {
          'network': 'ETH',
          'from': 'address',
          'data': 'payload',
          'signType': 'message',
        });
        expect(provider.states, [WalletConnectState.messageSignOK]);
        expect(client.responses, isEmpty);
      },
    );
  }

  for (final (method, type, params, expected)
      in <(String, String, Map<String, dynamic>, String)>[
        (
          'solana_signTransaction',
          'SOL',
          {'transaction': 'serialized', 'feePayer': 'payer'},
          'serialized',
        ),
        (
          'solana_signAndSendTransaction',
          'SOL',
          {'transaction': 'serialized'},
          'serialized',
        ),
        (
          'aptos_signTransaction',
          'APT',
          {'encodedTransaction': 'encoded', 'transaction': 'fallback'},
          'encoded',
        ),
        (
          'aptos_signAndSubmitTransaction',
          'APT',
          {'transaction': 'fallback'},
          'fallback',
        ),
        (
          'sui_signTransaction',
          'SUI',
          {'transactionBlock': 'block', 'transaction': 'fallback'},
          'block',
        ),
        (
          'sui_signAndExecuteTransaction',
          'SUI',
          {'transaction': 'fallback'},
          'fallback',
        ),
        ('near_signTransaction', 'NEAR', {'transaction': 'single'}, 'single'),
        (
          'near_signAndSendTransaction',
          'NEAR',
          {
            'transactions': ['first', 'second'],
          },
          'first',
        ),
        ('near_signTransaction', 'NEAR', {'transactions': []}, ''),
      ]) {
    test('$method preserves encoded transaction in preview', () async {
      await provider.setActionDataMap(sessionRequest(method, params));
      expect(provider.actionDataMap, {
        'network': 'ETH',
        'coinType': type,
        'data': expected,
        'from': params['feePayer'] ?? '',
        'to': '',
        'value': '0',
        'gas': '0',
        'signType': 'transaction',
      });
      expect(provider.states, [WalletConnectState.transactionOK]);
      expect(client.responses, isEmpty);
    });
  }

  test('unknown signing method returns a topic-correlated rejection', () async {
    await provider.setActionDataMap(sessionRequest('unknown_sign', {}));
    expect(client.responses.single.$1, 'request-topic');
    expect(client.responses.single.$2.id, 42);
    expect(client.responses.single.$2.error?.code, 4200);
    expect(client.responses.single.$2.error?.message, contains('unknown_sign'));
    expect(provider.states, isEmpty);
  });
}
