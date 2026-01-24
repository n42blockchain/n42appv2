import 'dart:convert';
import 'dart:typed_data';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/api/chain_api/algo_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/apt_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/atom_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/btc_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/dot_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/fil_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/sol_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/sui_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/ton_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/trx_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xrp_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xtz_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/zil_api.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_1559.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:eth_sig_util/util/bigint.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:n42appv2/generated/l10n.dart';

class TokenViewApi{
  late String url;
  late Map<String,String> header;
  TokenViewApi(){
    url=AppConfig.getApiUrl_online('tokenViewUri');
    header={'content-type': 'application/json'};
  }
  //获取nft主页的banner 列表
  Future getBannerData()async{
    try {
      final res = await BaseApi.RequestEmpty_h.get(
        '${url}v1/image/url',
        params: {},header:header,
      );
      MessageModel mm=MessageModel.error();
      if (res['code'] == 200) {
        mm.error=false;
        mm.data= res["data"]['image_link'];
      }else{
        mm.data="error";
      }
      return mm;
    } catch (err) {
      MessageModel mm=MessageModel.error();
      mm.data=err.toString();
      return mm;
    }
  }
  //static String tokenViewUri="https://192.168.0.196:18214/v1/";//"https://198.200.30.38:18214/v1/";//
  // "https://services.tokenview.com/vipapi/";//
  //static String tokenViewUri_net="https://services.tokenview.com/vipapi";
  //static String apikey="rjWMOBGRJbbGvhCcKzQu";
  //public
  ///获取币列表，主链加代币
  ///chains 返回特定的主链 主链币全名 solna,bitcoin,
  ///coins 返回特定的代币 代币的symbol eth,bnb,ast
  getChainList_all({String chains="",String coins=""})async{
    try{
      //chains="Amaze Chain";
      String condition="";
      if(chains!=""){
        condition="?chains=$chains";
      }
      if(coins!=""){
        if(condition==""){
          condition="?";
        }else{
          condition+="&";
        }
        condition+="coins=$coins";
      }
      String path='${url}v2/chains/coins/v2$condition';
      final a=await BaseApi.RequestEmpty_h.get(path, params: {},header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  /*
  //获取主链币的列表
  static getChainList()async{
    try{
      final a=await Api.tokenViewHelp.get('chain/list', params: {});
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  */
  //获取某个主链币的所有代币
  getTokenList_fullname(String fullname)async{
    try{
      final a=await BaseApi.RequestEmpty_h.get('${url}v1/chains/coins?chains=$fullname', params: {},header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        List<dynamic> rData=a['data'];
        mm.error=false;
        if(rData.isEmpty){
          mm.data=[];
        }else{
          mm.data=rData[0]['coins'];
        }
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  /*
  //某笔交易详情
  static getTxInfo(String coinType,String txHash)async{
    try{
      final a=await Api.tokenViewHelp.get('vipapi/tx?coin=${coinType.toLowerCase()}&tx_hash=${txHash}', params: {});
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      } else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
   */
  //获取某笔交易的确认数
  getTxConfirmation(String coinType,String txHash)async{
    try{
      final a=await BaseApi.RequestEmpty_h.get('${url}v1/vipapi/tx/confirmation?coin=${coinType.toLowerCase()}&tx_hash=$txHash', params: {},header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==1){
        mm.error=false;
        mm.data=a['data']['confirmation'];
      } else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  /*
  //判断交易是否确认
  static getTx_pending(String coinType,String txHash)async{
    try{
      final a=await Api.tokenViewHelp.get('vipapi/pending/tx?coin=${coinType.toLowerCase()}&tx_hash=${txHash}', params: {});
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      } else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  */
  //获取币的 余额
  getBalance(String blockchain,String coinType,String address,{String contract="",bool returnDouble=false,bool isTest=false,String? rpc})async{
    switch(blockchain){
      case "Bitcoin":
        if(isTest){
          return await BtcApi(test: isTest).getBalance(address);
        }else{
          return await getBalance_btc(coinType,address,returnDouble: returnDouble);
        }
      case "Ethereum":
        return await getBalance_eth(coinType, address, contract,returnDouble: returnDouble,isTest: isTest,rpc: rpc);
      case "Solana":
        return await getBalance_solana(coinType, address, contract,returnDouble: returnDouble,isTest: isTest);
    /*if(contract==""){
          //return await SolApi.getBalance_rpc(address,isTest: isTest);
          return await getBalance_solana(coinType, address, contract,returnDouble: returnDouble,isTest: isTest);
        }else{
          //return await SolApi.getTokenAccountsByOwner_rpc(address, contract,isTest: isTest);
          //return await SolApi.getBalance_tokens_sol(address,isTest);
          return await getTokenAccountsByOwner_solana(address,contract,isTest: isTest);
        }*/
      case "Tron":
        TrxApi trxApi=TrxApi();
        return //await getBalance_trx(coinType,address);
          await trxApi.getBalance_trx(address, contract,isTest:isTest);
      case "Algorand":
        AlgoApi algoApi=AlgoApi();
        return await algoApi.getBalance(address,assetId:contract,isTest: isTest);
      case "Tezos":
        XtzApi xtzApi=XtzApi();
        return await xtzApi.getBalance_xtz(address, contract,"balance", isTest);
      case "Ripple":
        XrpApi xrpApi=XrpApi();
        return await xrpApi.getAccountInfo_xrp(address, isTest);
      case "Cosmos":
        AtomApi atomApi=AtomApi();
        return await atomApi.getBalance(address,contract);
      case "Filecoin":
        FilApi filApi=FilApi();
        return await filApi.getBalance(address,isTest:isTest);
      case "Polkadot":
        DotApi dotApi=DotApi();
        return await dotApi.getTokens(address,coinType,isTest: isTest);
      case "Aptos":
        AptApi aptApi=AptApi(isTest: isTest);
        return await aptApi.getBalance(address,contract: contract);
      case "Sui":
        SuiApi suiApi=SuiApi(isTest: isTest);
        return await suiApi.getBalance_sui(address);
      case "TheOpenNetwork":
        TonApi tonApi=TonApi(isTest: isTest);
        return await tonApi.getBalance_ton(address);
      case "Zilliqa":
        ZilApi zilApi=ZilApi(isTest: isTest);
        return await zilApi.getBalance(address);
    }
    return null;
  }
  //发送交易
  sendTx(String blockchain,String coinType,dynamic signHash,{String netMode="main",String? rpc})async{
    switch(blockchain){
      case "Bitcoin":
        return await sendTx_btc(coinType,signHash,isTest: netMode=="main"?false:true);
      case "Ethereum":
        return await sendTx_eth(coinType, signHash,netMode,rpc: rpc);
      case "Solana":
        return await sendTx_solana(signHash,netMode);
      case "Tron":
        return await sendTx_trx( signHash,netMode);
      case "Cosmos":
        AtomApi atomApi=AtomApi();
        return await atomApi.sendTxs( signHash);
      case "Algorand":
        AlgoApi algoApi=AlgoApi();
        return await algoApi.sendTx(signHash,isTest: netMode=="main"?false:true);
      case "Zilliqa":
        ZilApi zilApi=ZilApi(isTest: netMode=="main"?false:true);
        return await zilApi.createTransaction(signHash);
    }
    return null;
  }
  //获取gasprice
  getGasPrice(String blockchain,String coinType,{bool isTest=false,String? rpc,String signMessage=""})async{
    switch(blockchain){
      case "Bitcoin":
      //return await getBalance_btc(coinType,address,returnDouble: returnDouble);
      case "Ethereum":
        return await getGasPrice_eth(coinType,isTest: isTest,rpc: rpc);
      case "Solana":
        return await SolApi().getFeeForMessage(signMessage);
        //return await getGasPrice_solana(isTest: isTest);
      case "Tron":
        return await getGasPrice_trx(isTest: isTest);
      case "Algorand":
        AlgoApi algoApi=AlgoApi();
        return await algoApi.getTransactionsParams(isTest: isTest);
      case "Tezos":
        MessageModel mm=MessageModel();
        mm.data=BigInt.from(500);
        return mm;
      case "Ripple":
        XrpApi xrpApi=XrpApi();
        return await xrpApi.getGasPrice_xrp(isTest);
      case "Cosmos":
        MessageModel mm=MessageModel();
        mm.data=BigInt.from(20000);
        return mm;
      case "Filecoin":
        FilApi filApi=FilApi();
        return await filApi.getGasPrice(isTest:isTest);
      case "Aptos":
        AptApi aptApi=AptApi(isTest: isTest);
        return await aptApi.getGasPrice();
      case "Sui":
        SuiApi suiApi=SuiApi(isTest: isTest);
        return await suiApi.getGasPrice_sui();
      case "Zilliqa":
        ZilApi zilApi=ZilApi(isTest: isTest);
        return await zilApi.getMinimumGasPrice();
    }
    return null;
  }
  //
  //获取btc类的余额
  /*static getBalance_btc(String coinType,String address)async{
    try{
      final a=await Api.RequestEmpty_h.get('${tokenViewUri}addr/b/${coinType.toLowerCase()}/${address}?apikey=lsqvqucOU0H0J9LfJQBX', params: {});
      if(a['code']==1){
        return ethToWeiString(a['data'].toString(), 9);
      }else{
        return Future.error("Error");
      }
    }catch(e){
      return Future.error(e);
    }
  }*/
  //获取比特币的gasfee 等级数据，只是比特币的
  getGasFee_btc({bool isTest=false})async{
    try{
      if(isTest){
        return await BtcApi(test: isTest).getGasfee();
      }else{
        final a=await BaseApi.RequestEmpty_h.get('${url}v1/blockchain/fee/byte', params: {},header:header,);
        MessageModel mm=MessageModel();
        if(a['code']==200){
          mm.data=a['data'];
        }else{
          mm.error=true;
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //获取btc类的余额
  getBalance_btc(String coinType,String address,{bool returnDouble=false})async{
    try{
      final a=await BaseApi.RequestEmpty_h.get('${url}v1/vipapi/account/balance?coin=${coinType.toLowerCase()}&addr=$address', params: {},header:header,);
      MessageModel mm=MessageModel();
      if(a['code']==200){
        if(returnDouble){
          mm.data= double.parse(a['data'].toString());
        }else{
          mm.data= ethToWeiString(a['data'].toString(), 8);
        }
      }else{
        mm.error=true;
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //获取btc类的utxo
  getUTXO_btc(String coinType,String address,{int pageSize=100,int pageNum=1,bool isTest=false})async{
    try{
      if(isTest){
        return await BtcApi(test: isTest).getUtxos(address);
      }else{
        final a=await BaseApi.RequestEmpty_h.get('${url}v1/vipapi/utxo/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize', params: {},header:header,);
        MessageModel mm=MessageModel.error();
        if(a['code']==200){
          mm.error=false;
          mm.data=a['data'];
        }else if(a['code']==404){
          mm.error=false;
          mm.data=[];
        }else{
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //获取btc类的交易记录
  getTxList_btc(String coinType,String address,{int pageSize=20,int pageNum=1})async{
    try{
      final a=await BaseApi.RequestEmpty_h.get('${url}v1/vipapi/address/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize', params: {},header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else if(a['code']==404){
        mm.error=false;
        mm.data=[];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }




  //广播交易，比特币类、以太坊类和
  //btc、eth、etc
  sendTx_btc(String coinType,String signHash,{bool isTest=false})async{
    try{
      if(isTest){
        return await BtcApi(test: isTest).sendTx_http(signHash);
      }else{
        Map<String,dynamic> params={
          "coin":coinType.toLowerCase(),
          "tx_hash":signHash,
        };
        final a=await BaseApi.RequestEmpty_h.post('${url}v1/vipapi/onchainwallet/rawtransaction', params: params,data: params,header:header,);
        MessageModel mm=MessageModel.error();
        if(a['code']==200){
          mm.error=false;
          mm.data=a['data'];
        }else{
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }


  ////////////////////////////eth
  getBalance_eth(String coinType,String address,String contract,{bool returnDouble=false,bool isTest=false,String? rpc})async{
    try{
      if(rpc==null){
        dynamic a;
        if(contract==""){
          Map<String,dynamic> params={
            "address":address,
            "coin":coinType.toLowerCase(),
            "net_mode":isTest?"test":"main",
            "tag":"latest",
          };
          String pUrl;
          if(rpc !=null){
            pUrl=rpc;
          }else{
            pUrl='${url}v2/eth/balance';
          }
          a=await BaseApi.RequestEmpty_h.post(pUrl, params: params,data: params,header:header,);
        }else{
          Map<String,dynamic> params={
            "from":address,
            "to":contract,
            "coin":coinType.toLowerCase(),
            "net_mode":isTest?"test":"main",
            "tag":"latest",
          };
          String pUrl;
          if(rpc !=null){
            pUrl=rpc;
          }else{
            pUrl='${url}v2/eth/call';
          }
          a=await BaseApi.RequestEmpty_h.post(pUrl, params: params,data: params,header:header,);
        }
        MessageModel mm=MessageModel.error();
        if(a['code']==200){
          mm.error=false;
          String result=a['data']['result'];
          if(result=="0x"){
            result="0x0";
          }
          BigInt value=hexToInt(result);
          mm.data=value;
          /*if(returnDouble){
          mm.data= double.parse(a['data']['result'].toString());
        }else{
          mm.data= ethToWeiString(a['data']['result'].toString(), 18);
        }*/
        }else{
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }else{
        return await EthAPI.init(null, rpc, null).getBalance(address, contract);
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  /*
  //获取eth类的交易记录
  static getTxList_eth(String coinType,String address,{int pageSize=20,int pageNum=1})async{
    try{
      final a=await Api.tokenViewHelp.get('vipapi/address/normal/tx/list?coin=${coinType.toLowerCase()}&addr=${address}&page=${pageNum}&page_size=${pageSize}', params: {});
      MessageModel mm=MessageModel.error();
      if(a['code']==0){
        mm.error=false;
        mm.data=a['data'];
      }else if(a['code']==404){
        mm.error=false;
        mm.data=[];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
*/
  //获取eth 类 某个地址的所有代币余额
  getAllTokenBalance_eth(String coinType,String address)async{
    try{
      final a=await BaseApi.RequestEmpty_h.get('${url}v1/vipapi/eth-class/address/balance?coin=${coinType.toLowerCase()}&address=${address.toLowerCase()}', params: {},header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==1){
        mm.error=false;
        mm.data=a['data'];
      }else if(a['code']==0){
        mm.error=false;
        mm.data=a['data'];
      }else if(a['code']==404){
        mm.error=false;
        mm.data=[];
      }else if(a['code']==400){
        mm.error=false;
        mm.data=[];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }

  //eth、etc 预估gas花费
  getGasEstimate_eth(Map<String,dynamic> params)async{
    try{
      final a=await BaseApi.RequestEmpty_h.post('${url}v2/eth/estimate/gas', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        if(a['data']['error']['code']!=0){
          mm.data=a['data']['error']['message'];
        }else{
          mm.error=false;
          mm.data=hexToInt(a['data']['result']);
        }

      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  getGasEstimate_eth_v2(String from,String to,BigInt gasPrice,BigInt value,BigInt gas,String coinType,{String contract="",String data="",bool isTest=false})async{
    if(coinType==CoinType.TRX.name){
      TrxApi trxApi=TrxApi();
      return await trxApi.getGasEstimate_trx(from, to, gasPrice, value, gas,contract:contract,isTest:isTest);
    }
    if(contract==""){
      Map<String,dynamic> params = {"from": from,
        "to": to,
        //"gas_price":'0x${gasPrice.toRadixString(16)}',
        //"gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        //"price":"0x${value.toRadixString(16)}",
        //"value":"0x${value.toRadixString(16)}",
        "coin":coinType,
        "net_mode":isTest?"test":"main",
        "id":AppGlobals.currentId++,
      };
      if(get1559WithChainSymbol(coinType)){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      if(data !=""){
        params['data']=data;
      }
      return await getGasEstimate_eth(params);
    }
    else{
      String toAddress=strip0x(to);
      String aaa=hex(keccakAscii("transfer(address,uint256)"));
      aaa=aaa.substring(0,8).toLowerCase();
      Uint8List valueList=encodeBigInt(value,length: 32);
      String valueHex=hex(valueList).toLowerCase();
      Map<String,dynamic> params = {"from": from,
        "to": contract,
        //"gas_price":'0x${gasPrice.toRadixString(16)}',
        //"gasPrice":'0x${gasPrice.toRadixString(16)}',
        "gas":"0x${gas.toRadixString(16)}",
        "data": "0x${aaa}000000000000000000000000$toAddress$valueHex",
        "coin":coinType,
        "net_mode":isTest?"test":"main",
        "id":AppGlobals.currentId++,
      };
      if(get1559WithChainSymbol(coinType)){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      return await getGasEstimate_eth(params);
    }
  }
  //返回交易数量 nonic值
  //netMode= main,test
  getTransactionCount_eth(String coinType,String address,{String netMode="main",String? rpc})async{
    try{
      if(rpc==null){
        Map<String,dynamic> params={
          "coin":coinType.toLowerCase(),
          "hex_address":address,
          "net_mode":netMode,
          "tag":"pending"//"latest"
        };
        final a=await BaseApi.RequestEmpty_h.post('${url}v2/eth/transaction/count', params: params,data: params,header:header,);
        MessageModel mm=MessageModel.error();
        if(a['code']==200){
          String result=a['data']['result'].toString();
          if(a['data']['error']['code']!=0){
            mm.data=a['data']['error']['message'];
          }else{
            mm.error=false;
            BigInt value=hexToInt(result);
            value=value;
            mm.data=value;
          }
        }else{
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }else{
        return await EthAPI.init(null, rpc, null).getTransactionCount(address);
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //发送交易
  sendTx_eth(String coinType,String signHash,String netMode,{String? rpc})async{
    try{
      if(rpc==null){
        Map<String,dynamic> params={
          "coin":coinType,
          "signed_tx":signHash,
          "net_mode":netMode,
        };
        final a=await BaseApi.RequestEmpty_h.post('${url}v2/eth/raw/transaction', params: params,data: params,header:header,);
        MessageModel mm=MessageModel.error();
        if(a['code']==200){
          String result=a['data']['result'].toString();
          if(a['data']['error']['code']!=0){
            mm.data=a['data']['error']['message'];
          }else{
            mm.error=false;
            mm.data=result;
          }
        }else{
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }else{
        return await EthAPI.init(null, rpc, null).sendTransaction(signHash);
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //获取交易的收据
  getTransactionReceipt_eth(String coinType,String txHash,{bool isTest=false,String? rpc})async{
    try{
      if(rpc==null){
        Map<String,dynamic> params={
          "tx_hash":txHash,
          "coin":coinType,
          "net_mode":isTest?"test":"main",
        };
        final a=await BaseApi.RequestEmpty_h.post('${url}v2/eth/transaction/receipt', params: params,data: params,header:header,);
        MessageModel mm=MessageModel.error();
        if(a['code']==200){
          mm.error=false;
          mm.data=a['data'];
        }else{
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }else{
        return await EthAPI.init(null, rpc, null).getTransactionReceipt(txHash);
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  getGasPrice_eth(String coinType,{bool isTest=false,String? rpc})async{
    try{
      if(rpc ==null){
        Map<String,dynamic> params={
          "coin":coinType,
          "net_mode":isTest?"test":"main",
        };
        final a=await BaseApi.RequestEmpty_h.post('${url}v2/eth/gas/price', params: params,data: params,header:header,);
        MessageModel mm=MessageModel.error();
        if(a['code']==200){
          if(a['data']['error']['code']!=0){
            mm.data=a['data']['error']['message'];
          }else{
            mm.error=false;
            BigInt value=hexToInt(a['data']['result'].toString());
            mm.data=value;
          }
        }else{
          mm.data=errorMessage(a['code']);
        }
        return mm;
      }else{
        return await EthAPI.init(null, rpc, null).getGasPrice();
      }
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  getEnsResolve(String domain)async{
    try{
      final a=await BaseApi.RequestEmpty_h.get('${url}v1/ens/resolve?domain=$domain', params: {},header:header,);
      MessageModel mm=MessageModel();
      if(a['code']==200){
        mm.data=a['data'];
      }else{
        mm.error=true;
        mm.data=errorMessage(a['msg']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }



  ////////////////////////////
  //solana
  //获取余额
  getBalance_solana(String coinType,String address,String contract,{bool returnDouble=false,bool isTest=false})async{
    try{
      dynamic a;
      if(contract==""){
        Map<String,dynamic> params={
          "pubkey":address,
          "net_mode":isTest?"test":"main",
        };
        a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/balance', params: params,data: params,header:header,);
      }else{
        String pubKey=await Trustdart().getPubKeySOL(address,contract);
        Map<String,dynamic> params={
          "pubkey":pubKey,
          "net_mode":isTest?"test":"main",
        };
        a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/token/account/balance', params: params,data: params,header:header,);
      }

      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        if(contract==""){
          mm.error=false;
          BigInt value=BigInt.from(a['data']);
          mm.data=value;
        }else{
          if(a['data']['error']['code']!=0){
            mm.data=a['data']['error']['message'];
          }else{
            mm.error=false;
            mm.data=BigInt.parse(a['data']['result']['value']['amount']??"0".toString());
          }
        }
      }else{
        if(contract !=""){
          if(a['code']==500){
            mm.error=false;
            mm.data=BigInt.zero;
          }
        }else{
          mm.data=errorMessage(a['code']);
        }
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //获取当前用户 某个合约的全部账号
  getTokenAccountsByOwner_solana(String address,String contract,{bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "mint":contract,
        "net_mode":isTest?"test":"main",
        "pubkey":address,
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/token/accounts/by/owner', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        if(a['data']['error']['code']!=0){
          mm.data=a['data']['error']['message'];
        }else{
          mm.error=false;
          mm.data=a['data']['result']['value'];
        }
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //获取指定 地址的 账户信息
  getAccountInfo_solana(String address,{bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
        "pubkey":address,
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/account/info', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data']['result']['value']['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //获取最新块hash
  getRecentBlockhash_solana({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/recent/block/hash', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data']['result']['value']['blockhash'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //发送交易
  sendTx_solana(String signHash,String netMode)async{
    try{
      Map<String,dynamic> params={
        "net_mode":netMode,
        "tx_hash":signHash,
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/tx/send', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        if(a['data']['error']['code']!=0){
          mm.data=a['data']['error']['message'];
        }else{
          mm.error=false;
          mm.data=a['data']['result'];
        }
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //获取gasfee
  getGasPrice_solana({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/fees', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=BigInt.from(a['data']['result']['value']['feeCalculator']['lamportsPerSignature']);
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //根据交易hash 返回交易信息
  getTransaction_solana(String txHash,String netMode)async{
    try{
      Map<String,dynamic> params={
        "net_mode":netMode,
        "tx_sign":txHash,
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/sol/transaction', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==0){
        if(a['data']['error']['code']!=0){
          mm.data=a['data']['error']['message'];
        }else{
          mm.error=false;
          mm.data=a['data']['result']['meta']['status'];
        }
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }


  ////////////////////////////trx tron
  /*
  static getBalance_trx(String coinType,String address,{bool returnDouble=false})async{
    try{
      final a=await Api.tokenViewHelp.get('v1/vipapi/account/balance?coin=${coinType.toLowerCase()}&addr=${address}', params: {});
      MessageModel mm=MessageModel();
      if(a['code']==200){
        if(returnDouble){
          mm.data= double.parse(a['data'].toString());
        }else{
          mm.data= ethToWeiString(a['data'].toString(), 6);
        }
      }else{
        mm.error=true;
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  static getBalance1_trx(String address,String contract,{bool returnDouble=false,bool isTest=false})async{
    try{
      var a;
      if(contract==""){
        Map<String,dynamic> params={
          "address":address,
          "net_mode":isTest?"test":"main",
          "tag":"latest",
        };
        a=await Api.tokenViewHelp.post('v1/trx/balance', params: params,data: params);
      }else{
        Map<String,dynamic> params={
          "from":address,
          "to":contract,
          "net_mode":isTest?"test":"main",
          "tag":"latest",
        };
        a=await Api.tokenViewHelp.post('v1/trx/call', params: params,data: params);
      }

      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        BigInt value=DataUtils.hexToInt(a['data']['result'].toString());
        mm.data=value;
        /*if(returnDouble){
          mm.data= double.parse(a['data']['result'].toString());
        }else{
          mm.data= ethToWeiString(a['data']['result'].toString(), 18);
        }*/
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  */
  //获取gas费
  getGasPrice_trx({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/trx/gas/price', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        if(a['data']['error']['code']!=0){
          mm.data=a['data']['error']['message'];
        }else{
          mm.error=false;
          BigInt value=hexToInt(a['data']['result'].toString());
          mm.data=value;
        }
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //获取交易的收据
  getTransactionReceipt_trx(String txHash,{bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "tx_hash":txHash,
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/trx/transaction/receipt', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //获取最新块信息
  getLatestBlockNumber_trx({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/trx/latest/block', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  //创建交易
  createTx_trx(String sendAddress,String toAddress,int amount, netMode)async{
    try{
      Map<String,dynamic> params={
        "coin":"trx",
        "owner_address":sendAddress,
        "to_address":toAddress,
        "visible":false,
        "amount":amount,
      };
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/vipapi/onchainwallet/transaction', params: params,data: params,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data']['raw_data_hex'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  /*
  //发送交易
  static sendTx1_trx(String signHash,String netMode)async{
    try{
      Map<String,dynamic> sign=json.decode(signHash);
      MessageModel cmm=await createTx_trx(
          sign['raw_data']['contract'][0]['parameter']['value']["owner_address"],
          sign['raw_data']['contract'][0]['parameter']['value']["to_address"],
          sign['raw_data']['contract'][0]['parameter']['value']["amount"],
          'main');
      String rawDataHex="";
      if(cmm.error==true){
        return cmm;
      }else{
        rawDataHex=cmm.data;
      }
      Map<String,dynamic> params={
        "net_mode":"main",
        "transaction":rawDataHex,
      };
      params['net_mode']="main";
      final a=await Api.tokenViewHelp.post('v1/trx/broadcast/hex', params: params,data: params);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  static sendTx2_trx(String signHash,String netMode)async{
    try{
      Map<String,dynamic> params=json.decode(signHash);
      params['net_mode']="main";
      final a=await Api.tokenViewHelp.post('v1/trx/broadcast/transaction', params: params,data: params);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  */
  sendTx_trx(String signHash,String netMode)async{
    try{
      Map<String,dynamic> sign=json.decode(signHash);
      /*MessageModel cmm=await createTx_trx(
          sign['raw_data']['contract'][0]['parameter']['value']["owner_address"],
          sign['raw_data']['contract'][0]['parameter']['value']["to_address"],
          sign['raw_data']['contract'][0]['parameter']['value']["amount"],
          'main');
      String rawDataHex="";
      if(cmm.error==true){
        return cmm;
      }else{
        rawDataHex=cmm.data;
      }
      sign['raw_data_hex']=rawDataHex;
      sign['coin']='trx';
      sign["method"]= "broadcasttransaction";*/
      sign["visible"]=false;
      sign['net_mode']="main";
      //MessageModel mmmm=await TrxApi.sendTx_trx(sign);
      final a=await BaseApi.RequestEmpty_h.post('${url}v1/trx/broadcast/transaction', params: sign,data: sign,header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data= e.toString();
      return mm;
    }
  }
  /*
  getGasEstimate_trx(
      String from,
      String to,
      String contract,
      String method,
      List<Map<String,dynamic>> attributes,
      {
        BigInt? gasPrice,
        BigInt? gas,
        bool isTest=false}
      )async{
    if(gasPrice==null){
      MessageModel gmm=await getGasPrice_trx(isTest:isTest);
      if(gmm.error){
        return gmm;
      }else{
        gasPrice=gmm.data;
      }
    }
    if(gas==null){
      gas=BigInt.from(GetCoinGas("TRX",contract:true));
    }
    String aaa=hex(keccakAscii(method));
    aaa=aaa.substring(0,8).toLowerCase();
    String dataStr="0x${aaa}";
    for(Map<String,dynamic> attribute in attributes){
      if(attribute['type']=="address"){
        String addr=DataUtils.strip0x(attribute['value']);
        dataStr="${dataStr}00000000000000000000000041${addr}";
      }else if(attribute['type']=="uint256"){
        Uint8List valueList=encodeBigInt(attribute['value'],length: 32);
        String valueHex=hex(valueList).toLowerCase();
        dataStr="${dataStr}${valueHex}";
      }
    }
    TrxApi trxApi=TrxApi();
    return await trxApi.sendCall(
        {"from": from,
          "to": contract,
          "gas_price":'0x${gasPrice!.toRadixString(16)}',
          "gas":"0x${gas.toRadixString(16)}",
          "data": dataStr,
        },
      isTest:isTest,
      id:AppGlobals.currentId++,);
  }
*/
  getBrowserPreviewUrl()async{
    try{
      final rData=await BaseApi.RequestEmpty_h.get('${url}v1/preview/url', params: {},header: header);
      MessageModel mm=MessageModel.error();
      if(rData['code']==200){
        mm.error=false;
        mm.data=rData['data']['preview_url'];
      }else{
        mm.data=rData['err'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  String errorMessage(int errorcode){
    if(errorcode==404){
      return S.current.g_key_error_14;
    }else if(errorcode==429){
      return S.current.g_key_error_24;
    }else if(errorcode==500){
      return S.current.g_key_error_5;
    }else if(errorcode==40001){
      return S.current.g_key_error_23;//系统繁忙
    }else if(errorcode==10001){
      return S.current.g_key_error_25;
    }else if(errorcode==10002){
      return S.current.g_key_error_26;
    }else{
      return S.current.g_key_error_3;//未知错误
    }
  }
}
