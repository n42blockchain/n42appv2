import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;
import 'package:web3dart/web3dart.dart' as web3;

class _Rpc extends Fake implements web3.Web3Client {
  web3.Transaction? transaction;
  int? broadcastChainId;

  @override
  Future<Uint8List> signTransaction(
    web3.Credentials credentials,
    web3.Transaction transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  }) async {
    this.transaction = transaction;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<String> sendTransaction(
    web3.Credentials credentials,
    web3.Transaction transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  }) async {
    this.transaction = transaction;
    broadcastChainId = chainId;
    return '0xfixture-transaction-hash';
  }

  @override
  Future<void> dispose() async {}
}

class _Client extends Fake implements wc.ReownWalletKit {
  final responses = <wc.JsonRpcResponse>[];
  @override
  Future<void> respondSessionRequest({
    required String topic,
    required wc.JsonRpcResponse response,
  }) async {
    responses.add(response);
  }

  @override
  Map<String, wc.SessionData> getActiveSessions() => {};
}

class _Provider extends WalletConnectProvider {
  var keyReads = 0;
  @override
  web3.EthPrivateKey get privateKey {
    keyReads++;
    // Public scalar used only with the fake RPC above.
    return web3.EthPrivateKey.fromInt(BigInt.one);
  }

  @override
  Future<bool> web3clientInitFromChainId(String chain) async => true;
}

class _PreviewProvider extends _Provider {
  @override
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params}) async {
    walletConnectState = state;
  }
}

Map<String, dynamic> _transaction(Map<String, dynamic> gas) => {
  'from': '0x0000000000000000000000000000000000000001',
  'to': '0x0000000000000000000000000000000000000002',
  'value': '0x1',
  'gasPrice': '0x3b9aca00',
  'nonce': '0x0',
  ...gas,
};

wc.SessionRequestEvent _request(
  Map<String, dynamic> gas, {
  String method = 'eth_signTransaction',
}) => wc.SessionRequestEvent(1, 'test-topic', method, 'eip155:1', [
  _transaction(gas),
], wc.TransportType.relay);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Rpc rpc;
  late _Client client;
  late _Provider provider;
  setUp(() {
    rpc = _Rpc();
    client = _Client();
    provider = _Provider()
      ..signClient = client
      ..web3client = rpc;
    provider.coinModels.add(
      CoinModel()
        ..coin = {
          'coinType': 'ETH',
          'name': 'Ethereum',
          'unit': 'ETH',
          'blockchainType': 'Ethereum',
          'chainId': 1,
        },
    );
    provider.coinModelsIndex = 0;
  });
  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });

  for (final fields in <Map<String, dynamic>>[
    {'gas': '0x5208'},
    {'gas': '21000'},
    {'gas': '0X5208'},
    {'gasLimit': '0x5208'},
    {'gasLimit': '21000'},
    {'gas': '0x5208', 'gasLimit': '90000'},
  ]) {
    for (final method in ['eth_signTransaction', 'eth_sendTransaction']) {
      test('$method preserves the explicit gas cap $fields', () async {
        provider.actionData = _request(fields, method: method);
        await provider.transactionSignTap();
        expect(rpc.transaction, isNotNull);
        expect(rpc.transaction!.maxGas, 21000);
        expect(rpc.transaction!.gasPrice!.getInWei, BigInt.from(1000000000));
        expect(rpc.transaction!.value!.getInWei, BigInt.one);
        expect(rpc.transaction!.nonce, 0);
        expect(client.responses.single.error, isNull);
        if (method == 'eth_sendTransaction') expect(rpc.broadcastChainId, 1);
      });
    }
    test('confirmation preview uses the same cap $fields', () async {
      final preview = _PreviewProvider()
        ..signClient = client
        ..coinModelsIndex = 0;
      preview.coinModels.add(provider.coinModels.single);
      addTearDown(() {
        preview.signClient = null;
        preview.dispose();
      });
      await preview.setActionDataMap(_request(fields));
      expect(preview.actionDataMap?['gas'], '21000');
      expect(preview.walletConnectState, WalletConnectState.transactionOK);
    });
  }

  for (final cap in <Object>[
    '',
    '0x',
    '0xgg',
    '-1',
    '1.5',
    '1e6',
    ' 21000',
    '9007199254740992',
    '0x20000000000000',
    21000,
  ]) {
    test(
      'invalid gas cap $cap never falls back to estimation or a signing key',
      () async {
        provider.actionData = _request({'gas': cap, 'gasLimit': '21000'});
        await provider.transactionSignTap();
        expect(rpc.transaction, isNull);
        expect(provider.keyReads, 0);
        expect(client.responses, isEmpty);
        expect(provider.walletConnectState, WalletConnectState.error);
      },
    );
  }

  test(
    'omitted gas remains available for estimation with wei-denominated EIP-1559 fees',
    () async {
      final request = _request({});
      final fields = (request.params as List).single as Map<String, dynamic>;
      fields.remove('gasPrice');
      fields['maxFeePerGas'] = '0x77359400';
      fields['maxPriorityFeePerGas'] = '1000000000';
      provider.actionData = request;
      await provider.transactionSignTap();
      expect(rpc.transaction!.maxGas, isNull);
      expect(rpc.transaction!.gasPrice, isNull);
      expect(rpc.transaction!.maxFeePerGas!.getInWei, BigInt.from(2000000000));
      expect(
        rpc.transaction!.maxPriorityFeePerGas!.getInWei,
        BigInt.from(1000000000),
      );
    },
  );

  test('the maximum exactly representable cap stays exact', () async {
    provider.actionData = _request({'gas': '0x1fffffffffffff'});
    await provider.transactionSignTap();
    expect(rpc.transaction!.maxGas, 9007199254740991);
  });
}
