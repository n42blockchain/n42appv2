import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/models/message_model.dart';

class XrpApi{
  //valueType: "balance"Balance;"sequence"Sequence;"checkAccount"验证是否创建了账号
  /*
  static getBalance_xrp(String address,String contract,String valueType,bool isTest)async{
    try{
      String uri=Api.getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"account_info",
        "params":[
          {
            "account":address,
            "strict":true,
            "ledger_index":"current",
            "queue":true,
          }
        ],
      };
      var data=await Api.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        if(valueType=="balance"){
          mm.data=BigInt.parse(data['result']['account_data']['Balance']);
        }else if(valueType=="sequence"){
          mm.data=data['result']['account_data']['Sequence'];
        }else{
          mm.data=data['result']['validated'];
        }
      }else{

        if(data['result']['validated']==false){
          //没有账号
          if(valueType=="balance"){
            mm.data=BigInt.zero;
          }else if(valueType=="sequence"){
            mm.data=0;
          } else{
            mm.data=false;
          }

        }else{
          mm.error=true;
          mm.data=data['result']['error'];
        }
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  */
  getAccountInfoXrp(String address,bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"account_info",
        "params":[
          {
            "account":address,
            //"strict":true,
            "ledger_index":"validated",//"current",
            //"queue":true,
          }
        ],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        Map<String,dynamic> infoMap={
          "balance":BigInt.zero,
          "sequence":0,
          "account":false,
          "ownerCount":0//持有的对象
        };
        if(data['result']['account_data'] !=null){
          infoMap['balance']=BigInt.parse(data['result']['account_data']['Balance']??"0");
          infoMap['sequence']=data['result']['account_data']['Sequence']??0;
          infoMap['account']=true;
          infoMap["ownerCount"]=data['result']['account_data']['OwnerCount']??0;
        }

        mm.data=infoMap;
      }else{
        if(data['result']['error_code']==19){
          mm.data={
            "balance":BigInt.zero,
            "sequence":0,
            "account":false,
            "ownerCount":0//持有的对象
          };
        }else{
          mm.error=true;
          mm.data=data['result']['error'];
        }
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  getGasPriceXrp(bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"fee",
        "params":[{}],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        mm.data=BigInt.parse(data['result']['drops']['minimum_level']);//minimum_level\median_fee
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  getTxInfoXrp(String txHash,bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"tx",
        "params":[{
          "transaction":txHash,
          "binary":false,
        }],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        mm.data=data['result']['meta']['TransactionResult'];
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //获取服务器信息
  getServerStateXrp({bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"server_state",
        "params":[{"ledger_index": "current"}],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        Map<String,dynamic> rData={
          "reserve_base":data['result']['state']['validated_ledger']['reserve_base'],//激活账户必须持有的最小值
          //每添加一个对象（如 trust line、挂单、payment channel）需加锁
          "reserve_inc":data['result']['state']['validated_ledger']['reserve_inc'],
          "base_fee":data['result']['state']['validated_ledger']['base_fee'],//理论最低手续费单位（网络空闲时）
          "load_base":data['result']['state']['load_base'],//固定值，表示最小负载因子基准，一般为 256（不能变）
          //当前节点对费用的整体乘数因子，用来估算“标准”费用。
          // 👉 计算：实际费用 = base_fee × (load_factor / load_base)
          "load_factor":data['result']['state']['load_factor'],
        };
        mm.data=rData;
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //获取当前账本信息
  getLedgerXrp({bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"ledger",
        "params":[{"ledger_index": "current"}],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['status']=="success"){
        mm.data=data['result']['ledger_current_index'];
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //获取全部交易记录
  /*
  * {
  "result": {
    "transactions": [
      {
        "tx": {
          "TransactionType": "Payment",
          "Account": "rUserAddress",
          "Destination": "rAnotherAddress",
          "Amount": "1000000",
          "Fee": "12"
        }
      }
    ]
  }
}*/
  /*TransactionType: 交易类型（Payment = 发送 XRP, TrustSet = 信任设置, AMMDeposit = AMM 交易）
Amount: 交易金额（单位 drops，1 XRP = 1,000,000 drops）
Fee: 交易费用（10-12 drops）*/
  getTxsXrp(String address,{int ledgerIndexMin=-1,int limit=10,bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"account_tx",
        "params":[{
          "account": "rUserAddress",
          "ledger_index_min": ledgerIndexMin,
          "ledger_index_max": -1,
          "limit": limit
        }],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        mm.data=data['result']['transactions'];
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //广播
  sendTxXrp(String signHash,bool isTest)async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"submit",
        "params":[{
          "tx_blob":signHash,
        }],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        if(data['result']['engine_result'].toString().startsWith('tes')){
          mm.data=data['result']['tx_json']['hash'];
        }else{
          mm.error=true;
          mm.data=data['result']['engine_result_message'];
        }
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //获取hook合约信息
  /*{
  "result": {
    "account_objects": [
      {
        "LedgerEntryType": "Hook",
        "HookNamespace": "0xABCDEF",
        "HookOn": "0000000000000000",
        "HookParameters": [
          {
            "HookParameter": {
              "HookParamKey": "0x74657374",
              "HookParamValue": "0x123456"
            }
          }
        ],
        "Flags": 1
      }
    ]
  }
}*/
  /*
  * HookNamespace: 合约的命名空间
HookParameters: 传递给合约的参数
Flags: 合约的状态标志*/
  getHookInfo(String address,{bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"account_objects",
        "params":[{
          "account": address,
          "type": "hook"
        }],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        mm.data=BigInt.parse(data['result']['account_objects']);
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //获取AMM合约信息
  /*{
  "result": {
    "amm": {
      "Account": "rAMMPoolAddress",
      "Amount": "100000000",
      "Amount2": {
        "currency": "USDT",
        "issuer": "rIssuerAddress",
        "value": "5000"
      },
      "TradingFee": 30
    }
  }
}*/
  /*Account: AMM 池的账户地址
Amount: XRP 储备
Amount2: USDT 储备
TradingFee: 交易费用（单位 basis points，即 30 = 0.3%）*/
  getAMMInfo(Map<String,dynamic> ammInfo,{bool isTest=false})async{
    /*Map<String,dynamic> ammInfo={
      "asset":{
        "currency":"XRP",
      },
      "asset2": { "currency": "USDT", "issuer": "rIssuerAddress" }
    };*/
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"amm_info",
        "params":[ammInfo],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        mm.data=BigInt.parse(data['result']['amm']);
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
  //获取 Trustline 代币（IOU）合约信息
  /*{
  "result": {
    "lines": [
      {
        "currency": "USDT",
        "account": "rIssuerAddress",
        "balance": "500",
        "limit": "1000",
        "limit_peer": "0",
        "quality_in": 0,
        "quality_out": 0
      }
    ]
  }
}*/
  /*currency: 代币符号
account: 代币发行者
balance: 账户持有的 USDT 数量
limit: 账户信任额度（最多持有 1000 USDT）*/
  getTrustline(String address,{bool isTest=false})async{
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"account_lines",
        "params":[
          {address}
        ],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        mm.data=BigInt.parse(data['result']['lines']);
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }

  getTxHistory(String address,{int limit=10,bool isTest=false})async{
    //tx_history
    try{
      String uri=RequestUrl().getUrl2(CoinType.XRP.name,'rpc',isTest:isTest);
      Map<String,dynamic> pData={
        "method":"account_tx",
        "params":[
          {
            "account":address,
            "limit":limit
          }
        ],
      };
      var data=await BaseApi.RequestEmpty_h.post(uri, params: {},data: pData);
      MessageModel mm=MessageModel();
      if(data['result']['status']=="success"){
        mm.data=data['result']['transactions'];
      }else{
        mm.error=true;
        mm.data=data['result']['error'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }
}
