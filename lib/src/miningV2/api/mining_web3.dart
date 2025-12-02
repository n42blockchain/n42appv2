import 'dart:convert';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class MiningWeb3{
  MiningWeb3.init(String pk){
    credentials=EthPrivateKey.fromHex(bytesToHex(base64Decode(pk)));
  }
  EthAPI? ethAPI=null;
  EthAPI? get EAPI{
    if(ethAPI==null){
      ethAPI=EthAPI.init(null,'http://5.161.252.59:8545/',null);
    }
    return ethAPI;
  }
  EthPrivateKey? credentials=null;
  Web3Client? web3Client=null;
  Web3Client? get WClient{
    if(web3Client==null){
      web3Client = Web3Client('http://5.161.252.59:8545', Client());
    }
    return web3Client;
  }

  Future getTransactionReceipt(String hashTx) async {
    TransactionReceipt? data= await WClient?.getTransactionReceipt(hashTx);
    MessageModel mm=MessageModel();
    if(data==null){
      mm.error=true;
      return mm;
    }

    if(data?.status==false){
      mm.error=true;
    }
    return mm;
  }

  Future getBlockNumber() async {
    return await WClient?.getBlockNumber();
  }
  sendDepositTransaction(Map<String,dynamic> signData)async{
    final tx = Transaction(
      to: EthereumAddress.fromHex(
          signData['to']), // 目标合约
      value: EtherAmount.inWei(BigInt.parse(signData['value'])), // 交易金额
      data: hexToBytes(signData['data']),
      gasPrice: await WClient?.getGasPrice(),
      maxGas: 6000000, // 预估一个合理的 gas 上限
    );
    return await sendTransaction(tx);
  }
  sendExitDepositTransaction(Map<String,dynamic> signData)async{
    final tx = Transaction(
      to: EthereumAddress.fromHex(
          signData['to']), // 目标合约
      value: EtherAmount.inWei(BigInt.parse(signData['value'])), // 交易金额
      data: hexToBytes(signData['data']),
      gasPrice: await WClient?.getGasPrice(),
      maxGas: 6000000, // 预估一个合理的 gas 上限
    );
    return await sendTransaction(tx);
  }
  sendTransaction(Transaction tx)async{
    try{
      // 4. 发送交易
      final txHash = await WClient!.sendTransaction(
        credentials!,
        tx,
        chainId: 1142,
      );
      MessageModel rmm=MessageModel();
      rmm.data=txHash;
      return rmm;
    }catch(e){
      MessageModel rmm=MessageModel.error();
      rmm.data=e.toString();
      return rmm;
    }

  }

  exitDepositRowCall(String feeWeiInHexTx)async{
    try{
      final txMap= json.decode(feeWeiInHexTx);
      final to = EthereumAddress.fromHex(txMap['to']);
      // 构造 Call 请求
      final feeWeiInHex = await WClient!.callRaw(
        contract: to,
        data: hexToBytes(txMap['data']),
      );
      MessageModel mm=MessageModel();
      mm.data=feeWeiInHex;
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
}