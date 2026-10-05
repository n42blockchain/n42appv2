import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;
import 'package:web3dart/web3dart.dart' as web3;

import '../../../helpers/wallet_connect_client_fake.dart';

class _Client extends Fake implements wc.ReownWalletKit {
  final responses = <(String, wc.JsonRpcResponse)>[];

  @override
  Future<void> respondSessionRequest({
    required String topic,
    required wc.JsonRpcResponse response,
  }) async {
    responses.add((topic, response));
  }
}

class _RpcClient extends Fake implements web3.Web3Client {
  web3.Transaction? signedTransaction;
  web3.Transaction? sentTransaction;
  int? sendChainId;

  @override
  Future<Uint8List> signTransaction(
    web3.Credentials cred,
    web3.Transaction transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  }) async {
    signedTransaction = transaction;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<String> sendTransaction(
    web3.Credentials cred,
    web3.Transaction transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  }) async {
    sentTransaction = transaction;
    sendChainId = chainId;
    return '0xfixture-hash';
  }

  @override
  Future<void> dispose() async {}
}

class _Provider extends WalletConnectProvider {
  static final _key = web3.EthPrivateKey.fromInt(BigInt.one);
  int keyReads = 0;
  int chainInitializations = 0;

  @override
  web3.EthPrivateKey get privateKey {
    keyReads++;
    return _key;
  }

  @override
  Future<bool> web3clientInitFromChainId(String chainStr) async {
    chainInitializations++;
    return true;
  }

  @override
  Future<({String mnemonic, String privateKey})>
  getCurrentWalletCredentials() async =>
      (mnemonic: 'fixture mnemonic', privateKey: 'fixture private key');
}

const _trustdartChannel = MethodChannel('trustdart');

wc.SessionRequestEvent _request(String method, dynamic params) =>
    wc.SessionRequestEvent(
      84,
      'evm-request-topic',
      method,
      'eip155:1',
      params,
      wc.TransportType.relay,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Client client;
  late _RpcClient rpc;
  late _Provider provider;

  setUp(() {
    client = _Client();
    rpc = _RpcClient();
    provider = _Provider()
      ..signClient = client
      ..web3client = rpc
      ..coinModels = [sessionCoin(isTest: true)]
      ..coinModelsIndex = 0;
  });

  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });

  test(
    'signTransaction maps JSON quantities to exact wei and transaction fields',
    () async {
      provider.actionData = _request('eth_signTransaction', [
        {
          'from': '0x1111111111111111111111111111111111111111',
          'to': '0x2222222222222222222222222222222222222222',
          'value': '0xde0b6b3a7640000',
          'gasPrice': '0x2540be400',
          'gas': '0x5208',
          'nonce': '0x3',
          'data': '0xdeadbeef',
        },
      ]);

      await provider.transactionSignTap();

      final transaction = rpc.signedTransaction!;
      expect(
        transaction.from!.without0x,
        '1111111111111111111111111111111111111111',
      );
      expect(
        transaction.to!.without0x,
        '2222222222222222222222222222222222222222',
      );
      expect(transaction.value!.getInWei, BigInt.from(1000000000000000000));
      expect(transaction.gasPrice!.getInWei, BigInt.from(10000000000));
      expect(transaction.maxGas, 21000);
      expect(transaction.nonce, 3);
      expect(transaction.data, [0xde, 0xad, 0xbe, 0xef]);
      expect(provider.keyReads, 1);
      expect(client.responses.single.$1, 'evm-request-topic');
      expect(client.responses.single.$2.id, 84);
      expect(client.responses.single.$2.result, '0x010203');
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );

  test('EIP-1559 fee fields are preserved as wei quantities', () async {
    provider.actionData = _request('eth_signTransaction', [
      {
        'from': '0x1111111111111111111111111111111111111111',
        'maxFeePerGas': '0x59682f00',
        'maxPriorityFeePerGas': '0x3b9aca00',
        'data': '0x60006000',
      },
    ]);

    await provider.transactionSignTap();

    expect(provider.errorMessage, isEmpty);
    expect(rpc.signedTransaction, isNotNull);
    final transaction = rpc.signedTransaction!;
    expect(transaction.to, isNull);
    expect(transaction.data, [0x60, 0x00, 0x60, 0x00]);
    expect(transaction.maxFeePerGas!.getInWei, BigInt.from(1500000000));
    expect(transaction.maxPriorityFeePerGas!.getInWei, BigInt.from(1000000000));
    expect(transaction.gasPrice, isNull);
    expect(client.responses.single.$2.error, isNull);
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  test(
    'sendTransaction returns the mocked hash on the selected test chain',
    () async {
      provider.actionData = _request('eth_sendTransaction', [
        {
          'from': '0x1111111111111111111111111111111111111111',
          'to': '0x2222222222222222222222222222222222222222',
          'gas': '21000',
        },
      ]);

      await provider.transactionSignTap();

      expect(rpc.sentTransaction, isNotNull);
      expect(rpc.sendChainId, 11155111);
      expect(client.responses.single.$2.result, '0xfixture-hash');
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );

  test('malformed gas cap stops before the signer is called', () async {
    provider.actionData = _request('eth_signTransaction', [
      {'from': '0x1111111111111111111111111111111111111111', 'gas': '0xZZ'},
    ]);

    await provider.transactionSignTap();

    expect(rpc.signedTransaction, isNull);
    expect(provider.keyReads, 0);
    expect(client.responses, isEmpty);
    expect(provider.walletConnectState, WalletConnectState.error);
    expect(provider.errorMessage, contains('Invalid gas limit'));
  });

  test('personal_sign signs plain UTF-8 message bytes', () async {
    const message = 'Sign this WalletConnect message';
    provider.actionData = _request('personal_sign', [
      message,
      '0x1111111111111111111111111111111111111111',
    ]);

    await provider.messageSignTap();

    final expected = web3.bytesToHex(
      _Provider._key.signPersonalMessageToUint8List(
        Uint8List.fromList(message.codeUnits),
      ),
      include0x: true,
    );
    expect(client.responses.single.$2.result, expected);
    expect(client.responses.single.$2.error, isNull);
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  test('personal_sign decodes hex message bytes before signing', () async {
    provider.actionData = _request('personal_sign', [
      '0x48656c6c6f',
      '0x1111111111111111111111111111111111111111',
    ]);

    await provider.messageSignTap();

    final expected = web3.bytesToHex(
      _Provider._key.signPersonalMessageToUint8List(
        Uint8List.fromList('Hello'.codeUnits),
      ),
      include0x: true,
    );
    expect(client.responses.single.$2.result, expected);
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  test(
    'eth_sign is rejected without reading or using the private key',
    () async {
      provider.actionData = _request('eth_sign', [
        '0x1111111111111111111111111111111111111111',
        '0xdeadbeef',
      ]);

      await provider.messageSignTap();

      expect(provider.keyReads, 0);
      expect(client.responses.single.$2.error?.code, 4200);
      expect(client.responses.single.$2.result, isNull);
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );

  test('typed-data requests sign a 65-byte EIP-712 signature', () async {
    provider.actionData = _request('eth_signTypedData_v4', [
      '0x1111111111111111111111111111111111111111',
      '{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"}],"Mail":[{"name":"contents","type":"string"}]},"primaryType":"Mail","domain":{"name":"N42","version":"1","chainId":1},"message":{"contents":"hello"}}',
    ]);

    await provider.messageSignTap();

    final signature = client.responses.single.$2.result as String;
    expect(signature, matches(RegExp(r'^0x[0-9a-f]{130}$')));
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  for (final (method, expectedError) in [
    ('tron_signMessage', 'TRON chain not supported'),
    ('aptos_signMessage', 'Aptos chain not configured'),
    ('sui_signMessage', 'Sui chain not configured'),
    ('solana_signMessage', 'Solana chain not configured'),
  ]) {
    test('$method refuses to sign when its chain is not configured', () async {
      provider.actionData = _request(method, {
        'message': method == 'solana_signMessage' ? 'Zml4dHVyZQ==' : 'fixture',
      });

      await provider.messageSignTap();

      expect(provider.errorMessage, expectedError);
      expect(provider.keyReads, 0);
      expect(client.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.error);
    });
  }

  for (final (method, params, expectedError) in [
    (
      'tron_signTransaction',
      {'message': 'fixture'},
      'TRON chain not supported',
    ),
    (
      'solana_signTransaction',
      {'transaction': 'fixture'},
      'Solana chain not configured',
    ),
    (
      'aptos_signTransaction',
      {'encodedTransaction': 'fixture'},
      'Aptos chain not configured',
    ),
    (
      'sui_signTransaction',
      {'transactionBlock': 'fixture'},
      'Sui chain not configured',
    ),
    (
      'near_signTransaction',
      {'transaction': 'fixture'},
      'NEAR chain not configured',
    ),
  ]) {
    test('$method refuses to sign when its chain is not configured', () async {
      provider.actionData = _request(method, params);

      await provider.transactionSignTap();

      expect(provider.errorMessage, expectedError);
      expect(provider.keyReads, 0);
      expect(client.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.error);
    });
  }

  test(
    'NEAR rejects a request with no transaction before chain lookup',
    () async {
      provider.actionData = _request('near_signTransaction', {
        'transactions': [],
      });

      await provider.transactionSignTap();

      expect(provider.errorMessage, 'NEAR: no transaction provided');
      expect(provider.keyReads, 0);
      expect(client.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.error);
    },
  );

  test(
    'duplicate message-sign taps are ignored while a request is active',
    () async {
      provider.walletConnectState = WalletConnectState.messageSign;
      provider.actionData = _request('personal_sign', ['ignored', '0x00']);

      await provider.messageSignTap();

      expect(provider.keyReads, 0);
      expect(client.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.messageSign);
    },
  );

  test(
    'duplicate transaction-sign taps are ignored while a request is active',
    () async {
      provider.walletConnectState = WalletConnectState.transaction;
      provider.actionData = _request('eth_signTransaction', [{}]);

      await provider.transactionSignTap();

      expect(provider.chainInitializations, 0);
      expect(provider.keyReads, 0);
      expect(client.responses, isEmpty);
      expect(provider.walletConnectState, WalletConnectState.transaction);
    },
  );

  test('Solana transaction signing returns the signed transaction', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, (call) async {
          calls.add(call);
          return 'c2lnbmVkLXRyYW5zYWN0aW9u';
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_trustdartChannel, null),
    );
    final solanaCoin = sessionCoin(type: 'SOL', blockchain: 'Solana')
      ..coin['path'] = {'legacy': "m/44'/501'/0'/0'"};
    provider
      ..coinModels = [solanaCoin]
      ..coinModelsIndex = 0
      ..actionData = _request('solana_signTransaction', {
        'transaction': 'cmF3LXRyYW5zYWN0aW9u',
      });

    await provider.transactionSignTap();

    expect(calls.single.method, 'signTransaction');
    expect(calls.single.arguments['coin'], 'SOL');
    expect(calls.single.arguments['mnemonic'], 'fixture mnemonic');
    expect(client.responses.single.$2.result, {
      'transaction': 'c2lnbmVkLXRyYW5zYWN0aW9u',
    });
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  test('Aptos signing returns the native signed transaction', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _trustdartChannel,
          (_) async => '0xsigned-aptos-transaction',
        );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_trustdartChannel, null),
    );
    final aptosCoin = sessionCoin(type: 'APT', blockchain: 'Aptos')
      ..coin['path'] = {'legacy': "m/44'/637'/0'/0'"};
    provider
      ..coinModels = [aptosCoin]
      ..coinModelsIndex = 0
      ..actionData = _request('aptos_signTransaction', {
        'transaction': 'encoded-aptos-transaction',
      });

    await provider.transactionSignTap();

    expect(client.responses.single.$2.result, {
      'signedTransaction': '0xsigned-aptos-transaction',
    });
    expect(provider.walletConnectState, WalletConnectState.connect);
  });

  test(
    'Sui signing returns the signature with its transaction block',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            _trustdartChannel,
            (_) async => 'base64-sui-signature',
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_trustdartChannel, null),
      );
      final suiCoin = sessionCoin(type: 'SUI', blockchain: 'Sui')
        ..coin['path'] = {'legacy': "m/44'/784'/0'/0'"};
      provider
        ..coinModels = [suiCoin]
        ..coinModelsIndex = 0
        ..actionData = _request('sui_signTransaction', {
          'transactionBlock': 'original-sui-block',
        });

      await provider.transactionSignTap();

      expect(client.responses.single.$2.result, {
        'signature': 'base64-sui-signature',
        'transactionBlock': 'original-sui-block',
      });
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );
}
