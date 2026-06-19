import 'dart:convert';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class MiningWeb3 {
  MiningWeb3.init(String pk) {
    credentials = EthPrivateKey.fromHex(bytesToHex(base64Decode(pk)));
  }
  static const int _chainId = 1142;
  static const int _defaultMaxGas = 6000000;
  EthPrivateKey? credentials;
  Web3Client? web3Client;
  Web3Client? get wClient {
    web3Client ??= Web3Client(AppConfig.miningRpcUrl, Client());
    return web3Client;
  }

  Future<MessageModel> getTransactionReceipt(String hashTx) async {
    TransactionReceipt? data = await wClient?.getTransactionReceipt(hashTx);
    MessageModel mm = MessageModel();
    if (data == null) {
      mm.error = true;
      return mm;
    }

    if (data.status == false) {
      mm.error = true;
    }
    return mm;
  }

  Future<MessageModel> sendDepositTransaction(
    Map<String, dynamic> signData,
  ) async {
    final tx = await _buildTransaction(signData);
    return await sendTransaction(tx);
  }

  Future<MessageModel> sendExitDepositTransaction(
    Map<String, dynamic> signData,
  ) async {
    final tx = await _buildTransaction(signData);
    return await sendTransaction(tx);
  }

  Future<Transaction> _buildTransaction(Map<String, dynamic> signData) async {
    return Transaction(
      to: EthereumAddress.fromHex(signData['to']),
      value: EtherAmount.inWei(BigInt.parse(signData['value'])),
      data: hexToBytes(signData['data']),
      gasPrice: await wClient?.getGasPrice(),
      maxGas: _defaultMaxGas,
    );
  }

  Future<MessageModel> sendTransaction(Transaction tx) async {
    try {
      final txHash = await wClient!.sendTransaction(
        credentials!,
        tx,
        chainId: _chainId,
      );
      MessageModel rmm = MessageModel();
      rmm.data = txHash;
      return rmm;
    } catch (e) {
      MessageModel rmm = MessageModel.error();
      rmm.data = e.toString();
      return rmm;
    }
  }

  Future<MessageModel> exitDepositRowCall(String feeWeiInHexTx) async {
    try {
      final txMap = json.decode(feeWeiInHexTx);
      final to = EthereumAddress.fromHex(txMap['to']);
      // 构造 Call 请求
      final feeWeiInHex = await wClient!.callRaw(
        contract: to,
        data: hexToBytes(txMap['data']),
      );
      MessageModel mm = MessageModel();
      mm.data = feeWeiInHex;
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
