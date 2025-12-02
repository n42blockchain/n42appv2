import 'dart:convert';

import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/miningV2/models/miningWithdrawalsDaily.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';

class MiningApi{
  late Trustdart mining;
  String wsUrl='ws://5.161.252.59:8546/';
  MiningApi.init(){
    mining=Trustdart();
  }
  Future<Map<String,String>?> generateBls12381Keypair()async{
    try{
      String? res=await mining.miningGenerateBls12381Keypair();
      if(res !=null){
        List<dynamic> dynamicArray= json.decode(res);
        return {
          'privateKey':dynamicArray[0],
          'publicKey':dynamicArray[1],
        };
      }else{
        return null;
      }
    }catch(e){
      return null;
    }
  }
  Future<String?> createDepositUnsignedTx(String validatorPrivateKey,String withdrawalAddress,String depositValueWeiInHex)async{
    try{
      String? res=await mining.miningCreateDepositUnsignedTx({
        "depositContractAddress": "0x0dcAE65dDB5df8f1817D35286beAC32b8994962B",
        "validatorPrivateKey": validatorPrivateKey,
        "withdrawalAddress": withdrawalAddress,
        "depositValueWeiInHex": depositValueWeiInHex,
      });
      if(res !=null){
        return res;
      }else{
        return null;
      }
    }catch(e){
      return null;
    }
  }
  runClent(String validatorPrivateKey)async{
    try{
      String? res=await mining.miningRunClient({
        "wsUrl": wsUrl, "validatorPrivateKey": validatorPrivateKey
      });
      if(res != null){
        return res;
      }else{
        return null;
      }
    }catch(e){
      return null;
    }

  }
  Future<String?> miningCreateGetExitFeeUnsignedTx()async{
    try{
      String? res=await mining.miningCreateGetExitFeeUnsignedTx();
      if(res !=null){
        return res;
      }else{
        return null;
      }
    }catch(e){
      return null;
    }
  }
  Future<String?> miningCreateExitUnsignedTx(String feeWeiInHex,String validatorPublicKey)async{
    try{
      String? res=await mining.miningCreateExitUnsignedTx({
        "feeWeiInHex": feeWeiInHex,
        "validatorPublicKey": validatorPublicKey,
      });
      if(res !=null){
        return res;
      }else{
        return null;
      }
    }catch(e){
      return null;
    }
  }

  Future<MessageModel> getMiningWithdrawalsDaily(String dayStr,String address)async{
    try {
      //https://testnet2.n42.world/api/v2/addresses/0x8157AC6F0C0eb1F465D14f62917e151637Ee47cC/withdrawals-daily?day=2025-11-12
      var data = await BaseApi.RequestEmpty_h.get("https://testnet2.n42.world/api/v2/addresses/${address}/withdrawals-daily?day=${dayStr}", params: {});
      MessageModel mm=MessageModel();
      List<dynamic>? items=data['items'];
      if(items != null){
        final List<MiningWithdrawalsDaily> withdrawalsList = items
            .map((item) => MiningWithdrawalsDaily.fronJson(item as Map<String, dynamic>))
            .toList();
        mm.data = withdrawalsList;
        return mm;
      }
      mm.error=true;
      return mm;

    } catch (e) {
      MessageModel mm=MessageModel.error();
      return mm;
    }
  }
  //获取总收益
  Future<MessageModel> getMiningWithdrawalsDailySummary(String address)async{
    try {
      //https://testnet2.n42.world/api/v2/addresses/0xCC5BC02C7cD8E7bda6D17128f3B20949040c5131/withdrawals-daily/summary
      var data = await BaseApi.RequestEmpty_h.get("https://testnet2.n42.world/api/v2/addresses/${address}/withdrawals-daily/summary", params: {});
      MessageModel mm=MessageModel();
      if(data != null){
        mm.data = data['total_amount'];
        return mm;
      }
      mm.error=true;
      return mm;

    } catch (e) {
      MessageModel mm=MessageModel.error();
      return mm;
    }
  }
  getBeaconValidator(String pubKey)async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":"consensusBeaconExt_get_beacon_validator_by_pubkey","params":[pubKey],"id":Application.currentId++};

      final data=await BaseApi.RequestEmpty_h.post('http://5.161.252.59:8545', params: {},data: postData);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['error'];
      }else{
        mm.data=data['result'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  ///consensusBeaconExt_get_total_effective_balance
  getTotalEffectiveBalance()async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":"consensusBeaconExt_get_total_effective_balance","params":[],"id":Application.currentId++};

      final data=await BaseApi.RequestEmpty_h.post('http://5.161.252.59:8545', params: {},data: postData);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['error'];
      }else{
        mm.data=data['result'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
}