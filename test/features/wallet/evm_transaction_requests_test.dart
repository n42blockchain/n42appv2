import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/evm_transaction_requests.dart';

class _FakeEthApi extends EthAPI {
  String? lastTxHash;
  String? lastCoinType;
  bool? lastIsTest;
  String? lastMethod;

  @override
  Future<MessageModel> getTransactionByHash(
    String txHash, {
    String? coinType,
    bool isTest = false,
  }) async {
    lastMethod = 'tx';
    lastTxHash = txHash;
    lastCoinType = coinType;
    lastIsTest = isTest;
    return MessageModel()..data = <String, dynamic>{'hash': txHash};
  }

  @override
  Future<MessageModel> getTransactionReceipt(
    String txHash, {
    String? coinType,
    bool isTest = false,
  }) async {
    lastMethod = 'receipt';
    lastTxHash = txHash;
    lastCoinType = coinType;
    lastIsTest = isTest;
    return MessageModel()..data = <String, dynamic>{'status': '0x1'};
  }
}

class _FakeTokenViewApi extends TokenViewApi {
  String? lastBlockchain;
  String? lastCoinType;
  bool? lastIsTest;
  String? lastRpc;

  @override
  Future<MessageModel?> getGasPrice(
    String blockchain,
    String coinType, {
    bool isTest = false,
    String? rpc,
    String signMessage = '',
  }) async {
    lastBlockchain = blockchain;
    lastCoinType = coinType;
    lastIsTest = isTest;
    lastRpc = rpc;
    return MessageModel()..data = BigInt.from(1);
  }
}

void main() {
  group('fetchEvmTransactionByHash', () {
    test('forwards testnet flag to EthAPI', () async {
      final api = _FakeEthApi();

      await fetchEvmTransactionByHash(
        api,
        txHash: '0xtesthash',
        coinType: 'N',
        isTest: true,
      );

      expect(api.lastMethod, 'tx');
      expect(api.lastTxHash, '0xtesthash');
      expect(api.lastCoinType, 'N');
      expect(api.lastIsTest, isTrue);
    });
  });

  group('fetchEvmTransactionReceipt', () {
    test('forwards testnet flag to EthAPI', () async {
      final api = _FakeEthApi();

      await fetchEvmTransactionReceipt(
        api,
        txHash: '0xtesthash',
        coinType: 'N',
        isTest: true,
      );

      expect(api.lastMethod, 'receipt');
      expect(api.lastTxHash, '0xtesthash');
      expect(api.lastCoinType, 'N');
      expect(api.lastIsTest, isTrue);
    });
  });

  group('fetchEvmGasPrice', () {
    test('forwards testnet flag and rpc override to TokenViewApi', () async {
      final api = _FakeTokenViewApi();

      await fetchEvmGasPrice(
        api,
        coinType: 'N',
        isTest: true,
        rpc: 'https://testrpc.n42.world',
      );

      expect(api.lastBlockchain, 'Ethereum');
      expect(api.lastCoinType, 'N');
      expect(api.lastIsTest, isTrue);
      expect(api.lastRpc, 'https://testrpc.n42.world');
    });
  });
}
