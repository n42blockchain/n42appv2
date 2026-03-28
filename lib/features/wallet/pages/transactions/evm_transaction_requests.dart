import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';

Future<MessageModel> fetchEvmTransactionByHash(
  EthAPI ethApi, {
  required String txHash,
  required String coinType,
  required bool isTest,
}) {
  return ethApi.getTransactionByHash(
    txHash,
    coinType: coinType,
    isTest: isTest,
  );
}

Future<MessageModel> fetchEvmTransactionReceipt(
  EthAPI ethApi, {
  required String txHash,
  required String coinType,
  required bool isTest,
}) {
  return ethApi.getTransactionReceipt(
    txHash,
    coinType: coinType,
    isTest: isTest,
  );
}

Future<MessageModel> fetchEvmGasPrice(
  TokenViewApi tokenViewApi, {
  required String coinType,
  required bool isTest,
  String? rpc,
}) async {
  return await tokenViewApi.getGasPrice(
        'Ethereum',
        coinType,
        isTest: isTest,
        rpc: rpc,
      ) ??
      MessageModel.error();
}
