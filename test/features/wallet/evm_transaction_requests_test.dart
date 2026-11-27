import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
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
}
