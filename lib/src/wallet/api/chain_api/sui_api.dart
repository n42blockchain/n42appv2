import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class SuiApi{
  String url="";
  SuiApi({bool isTest=false}){
    url=RequestUrl().getUrl2(CoinType.SUI.name, "rpc",isTest: isTest);
  }
  Future<MessageModel> getBalanceSui(String address)async{
    MessageModel rmm=await baseRPCSui(
      "suix_getBalance",
      [
        address,
        "0x2::sui::SUI"  // 查询 SUI 代币余额
      ],
    );
    if(rmm.error==false){
      rmm.data=BigInt.parse(rmm.data['totalBalance']);
    }
    return rmm;
  }
  Future<MessageModel> getGasPriceSui()async{
    MessageModel rmm= await baseRPCSui(
      "suix_getReferenceGasPrice",
      [],
    );
    if(rmm.error==false){
      rmm.data=BigInt.parse(rmm.data);
    }
    return rmm;
  }
  //用户所有的对象，NFT，合约等
  Future<void> getOwnedObjects(String address)async{
    MessageModel rmm= await baseRPCSui(
      "suix_getOwnedObjects",
      [address, {
        "filter": {
          "MatchAll": [
            {
              "StructType": "0x2::coin::Coin<0x2::sui::SUI>"
            },
            {
              "AddressOwner": address
            },
          ]
        },
        "options": {
          "showType": true,
          "showOwner": true,
          "showPreviousTransaction": true,
          "showContent": false,
        }
      }],
    );
    if(rmm.error==false){
      rmm.data=rmm.data['data'];
    }
  }
  //模拟交易
  Future<MessageModel> dryRunTransactionBlock(String signStr)async{
    MessageModel rmm= await baseRPCSui(
      "sui_dryRunTransactionBlock",
      [signStr],
    );
    if(rmm.error==false){
      if(rmm.data['effects']['status']=='success'){
        //computationCost + storageCost - storageRebate
        int computationCost=int.parse(rmm.data['effects']['gasUsed']['computationCost']);
        int storageCost=int.parse(rmm.data['effects']['gasUsed']['storageCost']);
        int storageRebate=int.parse(rmm.data['effects']['gasUsed']['storageRebate']);
        rmm.data=BigInt.from(computationCost+storageCost-storageRebate);
      }
    }
    return rmm;
  }
  //交易商链
  Future<MessageModel> submit(String transactionBlock,String signStr)async{
    return await baseRPCSui("sui_executeTransactionBlock", [
      transactionBlock,
      [signStr],
      "WaitForEffectsCert",
      {
        "showEffects": true,
        "showEvents": true
      }
    ]);
  }
  //查询交易信息
  Future<MessageModel> getTransactionBlock(String txHash)async{
    return await baseRPCSui("sui_getTransactionBlock", [
      txHash,
      {
        "showInput": false,
        "showRawInput": false,
        "showEffects": true,
        "showEvents": false,
        "showObjectChanges": false,
        "showBalanceChanges": false,
        "showRawEffects": false
      },
    ]);
  }
  Future<MessageModel> baseRPCSui(String method,var value)async{
    try{
      MessageModel mm=MessageModel();
      Map<String,dynamic> postData={"jsonrpc":"2.0","method":method,"params":value,"id":AppGlobals.currentId++};

      final data=await BaseApi.requestEmptyH.post(url, params: {},data: postData);
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
