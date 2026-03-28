import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/mining_v2/models/mining_withdrawals_daily.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/mining/services/mining_channel.dart';

class MiningApi{
  MiningApi.init(){
    mining=MiningChannel();
  }
  late MiningChannel mining;
  String get wsUrl => AppConfig.miningWebSocketUrl;
  static const String _explorerApiBase = String.fromEnvironment(
    'MINING_EXPLORER_URL',
    defaultValue: 'https://testnet2.n42.world',
  );
  static const String _depositContractAddress='0x0dcAE65dDB5df8f1817D35286beAC32b8994962B';
  Future<Map<String,String>?> generateBls12381Keypair()async{
    try{
      String? res=await mining.generateBls12381Keypair();
      if(res !=null){
        List<dynamic> dynamicArray= json.decode(res);
        return {
          'privateKey':dynamicArray[0],
          'publicKey':dynamicArray[1],
        };
      }
      return null;
    }catch(e){
      return null;
    }
  }
  Future<String?> createDepositUnsignedTx(String validatorPrivateKey,String withdrawalAddress,String depositValueWeiInHex)async{
    try{
      return await mining.createDepositUnsignedTx({
        "depositContractAddress": _depositContractAddress,
        "validatorPrivateKey": validatorPrivateKey,
        "withdrawalAddress": withdrawalAddress,
        "depositValueWeiInHex": depositValueWeiInHex,
      });
    }catch(e){
      return null;
    }
  }
  Future<String?> runClient(String validatorPrivateKey)async{
    try{
      return await mining.runClient({
        "wsUrl": wsUrl, "validatorPrivateKey": validatorPrivateKey
      });
    }catch(e){
      return null;
    }
  }
  Future<String?> stopClient()async{
    try{
      return await mining.stopClient();
    }catch(e){
      return null;
    }
  }
  Future<String?> miningCreateGetExitFeeUnsignedTx()async{
    try{
      return await mining.createGetExitFeeUnsignedTx();
    }catch(e){
      return null;
    }
  }
  Future<String?> miningCreateExitUnsignedTx(String feeWeiInHex,String validatorPublicKey)async{
    try{
      return await mining.createExitUnsignedTx({
        "feeWeiInHex": feeWeiInHex,
        "validatorPublicKey": validatorPublicKey,
      });
    }catch(e){
      return null;
    }
  }

  Future<MessageModel> getMiningWithdrawalsDaily(String dayStr,String address)async{
    try {
      //https://testnet2.n42.world/api/v2/addresses/0x8157AC6F0C0eb1F465D14f62917e151637Ee47cC/withdrawals-daily?day=2025-11-12
      var data = await BaseApi.requestEmptyH.get("$_explorerApiBase/api/v2/addresses/$address/withdrawals-daily?day=$dayStr", params: {});
      MessageModel mm=MessageModel();
      List<dynamic>? items=data['items'];
      if(items != null){
        final List<MiningWithdrawalsDaily> withdrawalsList = items
            .map((item) => MiningWithdrawalsDaily.fromJson(item as Map<String, dynamic>))
            .toList();
        mm.data = withdrawalsList;
        return mm;
      }
      mm.error=true;
      return mm;

    } catch (e) {
      return MessageModel.error();
    }
  }
  //获取总收益
  Future<MessageModel> getMiningWithdrawalsDailySummary(String address)async{
    try {
      var data = await BaseApi.requestEmptyH.get("$_explorerApiBase/api/v2/addresses/$address/withdrawals-daily/summary", params: {});
      if(data != null){
        final mm = MessageModel();
        mm.data = data['total_amount'];
        return mm;
      }
      final mm = MessageModel();
      mm.error=true;
      return mm;
    } catch (e) {
      return MessageModel.error();
    }
  }
  Future<MessageModel> getBeaconValidator(String pubKey)async{
    return await _postBeacon('consensusBeaconExt_get_beacon_validator_by_pubkey', [pubKey]);
  }
  ///consensusBeaconExt_get_total_effective_balance
  Future<MessageModel> getTotalEffectiveBalance()async{
    return await _postBeacon('consensusBeaconExt_get_total_effective_balance', []);
  }

  Future<MessageModel> _postBeacon(String method,List<dynamic> params)async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":params,"id":AppGlobals.nextId};

      final data=await BaseApi.requestEmptyH.post(AppConfig.miningRpcUrl, params: {},data: postData);
      if(data.containsKey('error')){
        mm.error=true;
        mm.data=data['error'];
      }else{
        mm.data=data['result'];
      }
      return mm;
    }catch(e){
      return MessageModel.error()..data=e.toString();
    }
  }
}