import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/atom_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/dot_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/fil_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ton_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xtz_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/zil_api.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/generated/l10n.dart';

class TokenViewApi{
  late String url;
  late Map<String,String> header;
  TokenViewApi(){
    url=AppConfig.getApiUrlOnline('tokenViewUri');
    header={'content-type': 'application/json'};
  }
  //public
  ///获取币列表，主链加代币
  ///chains 返回特定的主链 主链币全名 solna,bitcoin,
  ///coins 返回特定的代币 代币的symbol eth,bnb,ast
  Future<MessageModel> getChainListAll({String chains="",String coins=""})async{
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
      final a=await BaseApi.requestEmptyH.get(path, params: {},header:header,);
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
  //获取某个主链币的所有代币
  Future<MessageModel> getTokenListFullname(String fullname)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/chains/coins?chains=$fullname', params: {},header:header,);
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
  //获取某笔交易的确认数
  Future<MessageModel> getTxConfirmation(String coinType,String txHash)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/vipapi/tx/confirmation?coin=${coinType.toLowerCase()}&tx_hash=$txHash', params: {},header:header,);
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
  //获取币的 余额
  Future<MessageModel?> getBalance(String blockchain,String coinType,String address,{String contract="",bool returnDouble=false,bool isTest=false,String? rpc})async{
    switch(blockchain){
      case "Bitcoin":
        if(isTest){
          return await BtcApi(test: isTest).getBalance(address);
        }else{
          return await getBalanceBtc(coinType,address,returnDouble: returnDouble);
        }
      case "Ethereum":
        return await getBalanceEth(coinType, address, contract,returnDouble: returnDouble,isTest: isTest,rpc: rpc);
      case "Solana":
        return await getBalanceSolana(coinType, address, contract,returnDouble: returnDouble,isTest: isTest);
    /*if(contract==""){
          //return await SolApi.getBalance_rpc(address,isTest: isTest);
          return await getBalanceSolana(coinType, address, contract,returnDouble: returnDouble,isTest: isTest);
        }else{
          //return await SolApi.getTokenAccountsByOwner_rpc(address, contract,isTest: isTest);
          //return await SolApi.getBalance_tokens_sol(address,isTest);
          return await getTokenAccountsByOwner_solana(address,contract,isTest: isTest);
        }*/
      case "Tron":
        TrxApi trxApi=TrxApi();
        return //await getBalance_trx(coinType,address);
          await trxApi.getBalanceTrx(address, contract,isTest:isTest);
      case "Algorand":
        AlgoApi algoApi=AlgoApi();
        return await algoApi.getBalance(address,assetId:contract,isTest: isTest);
      case "Tezos":
        XtzApi xtzApi=XtzApi();
        return await xtzApi.getBalanceXtz(address, contract,"balance", isTest);
      case "Ripple":
        XrpApi xrpApi=XrpApi();
        return await xrpApi.getAccountInfoXrp(address, isTest);
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
        return await suiApi.getBalanceSui(address);
      case "TheOpenNetwork":
        TonApi tonApi=TonApi(isTest: isTest);
        return await tonApi.getBalanceTon(address);
      case "Zilliqa":
        ZilApi zilApi=ZilApi(isTest: isTest);
        return await zilApi.getBalance(address);
      case "Near":
        NearApi nearApi=NearApi(isTest: isTest);
        return await nearApi.getBalance(address);
    }
    return null;
  }
  //发送交易
  Future<MessageModel?> sendTx(String blockchain,String coinType,dynamic signHash,{String netMode="main",String? rpc})async{
    switch(blockchain){
      case "Bitcoin":
        return await sendTxBtc(coinType,signHash,isTest: netMode=="main"?false:true);
      case "Ethereum":
        return await sendTxEth(coinType, signHash,netMode,rpc: rpc);
      case "Solana":
        return await sendTxSolana(signHash,netMode);
      case "Tron":
        return await sendTxTrx( signHash,netMode);
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
  Future<MessageModel?> getGasPrice(String blockchain,String coinType,{bool isTest=false,String? rpc,String signMessage=""})async{
    switch(blockchain){
      case "Bitcoin":
      //return await getBalanceBtc(coinType,address,returnDouble: returnDouble);
      case "Ethereum":
        return await getGasPriceEth(coinType,isTest: isTest,rpc: rpc);
      case "Solana":
        return await SolApi().getFeeForMessage(signMessage);
        //return await getGasPrice_solana(isTest: isTest);
      case "Tron":
        return await getGasPriceTrx(isTest: isTest);
      case "Algorand":
        AlgoApi algoApi=AlgoApi();
        return await algoApi.getTransactionsParams(isTest: isTest);
      case "Tezos":
        MessageModel mm=MessageModel();
        mm.data=BigInt.from(500);
        return mm;
      case "Ripple":
        XrpApi xrpApi=XrpApi();
        return await xrpApi.getGasPriceXrp(isTest);
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
        return await suiApi.getGasPriceSui();
      case "Zilliqa":
        ZilApi zilApi=ZilApi(isTest: isTest);
        return await zilApi.getMinimumGasPrice();
    }
    return null;
  }
  //获取比特币的gasfee 等级数据，只是比特币的
  Future<MessageModel> getGasFeeBtc({bool isTest=false})async{
    try{
      if(isTest){
        return await BtcApi(test: isTest).getGasfee();
      }else{
        final a=await BaseApi.requestEmptyH.get('${url}v1/blockchain/fee/byte', params: {},header:header,);
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
  Future<MessageModel> getBalanceBtc(String coinType,String address,{bool returnDouble=false})async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/vipapi/account/balance?coin=${coinType.toLowerCase()}&addr=$address', params: {},header:header,);
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
  Future<MessageModel> getUTXOBtc(String coinType,String address,{int pageSize=100,int pageNum=1,bool isTest=false})async{
    try{
      if(isTest){
        return await BtcApi(test: isTest).getUtxos(address);
      }else{
        final a=await BaseApi.requestEmptyH.get('${url}v1/vipapi/utxo/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize', params: {},header:header,);
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
  Future<MessageModel> getTxListBtc(String coinType,String address,{int pageSize=20,int pageNum=1})async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/vipapi/address/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize', params: {},header:header,);
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
  Future<MessageModel> sendTxBtc(String coinType,String signHash,{bool isTest=false})async{
    try{
      if(isTest){
        return await BtcApi(test: isTest).sendTxHttp(signHash);
      }else{
        Map<String,dynamic> params={
          "coin":coinType.toLowerCase(),
          "tx_hash":signHash,
        };
        final a=await BaseApi.requestEmptyH.post('${url}v1/vipapi/onchainwallet/rawtransaction', params: params,data: params,header:header,);
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
  Future<MessageModel> getBalanceEth(String coinType,String address,String contract,{bool returnDouble=false,bool isTest=false,String? rpc})async{
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
          a=await BaseApi.requestEmptyH.post(pUrl, params: params,data: params,header:header,);
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
          a=await BaseApi.requestEmptyH.post(pUrl, params: params,data: params,header:header,);
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
  //获取eth 类 某个地址的所有代币余额
  Future<MessageModel> getAllTokenBalanceEth(String coinType,String address)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/vipapi/eth-class/address/balance?coin=${coinType.toLowerCase()}&address=${address.toLowerCase()}', params: {},header:header,);
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
  Future<MessageModel> getGasEstimateEth(Map<String,dynamic> params)async{
    try{
      final a=await BaseApi.requestEmptyH.post('${url}v2/eth/estimate/gas', params: params,data: params,header:header,);
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
  Future<MessageModel> getGasEstimateEthV2(String from,String to,BigInt gasPrice,BigInt value,BigInt gas,String coinType,{String contract="",String data="",bool isTest=false})async{
    if(coinType==CoinType.TRX.name){
      TrxApi trxApi=TrxApi();
      return await trxApi.getGasEstimateTrx(from, to, gasPrice, value, gas,contract:contract,isTest:isTest);
    }
    if(contract==""){
      Map<String,dynamic> params = {"from": from,
        "to": to,
        "gas":"0x${gas.toRadixString(16)}",
        "coin":coinType,
        "net_mode":isTest?"test":"main",
        "id":AppGlobals.nextId,
      };
      if(get1559WithChainSymbol(coinType)){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      if(data !=""){
        params['data']=data;
      }
      return await getGasEstimateEth(params);
    }
    else{
      String toAddress=strip0x(to);
      String aaa=bytesToHex(keccakAscii("transfer(address,uint256)"));
      aaa=aaa.substring(0,8).toLowerCase();
      Uint8List valueList=padUint8ListTo32(unsignedIntToBytes(value));
      String valueHex=bytesToHex(valueList);
      Map<String,dynamic> params = {"from": from,
        "to": contract,
        "gas":"0x${gas.toRadixString(16)}",
        "data": "0x${aaa}000000000000000000000000$toAddress$valueHex",
        "coin":coinType,
        "net_mode":isTest?"test":"main",
        "id":AppGlobals.nextId,
      };
      if(get1559WithChainSymbol(coinType)){
        params["maxFeePerGas"]='0x${gasPrice.toRadixString(16)}';
      }else{
        params["gasPrice"]='0x${gasPrice.toRadixString(16)}';
      }
      return await getGasEstimateEth(params);
    }
  }
  //返回交易数量 nonic值
  //netMode= main,test
  Future<MessageModel> getTransactionCountEth(String coinType,String address,{String netMode="main",String? rpc})async{
    try{
      if(rpc==null){
        Map<String,dynamic> params={
          "coin":coinType.toLowerCase(),
          "hex_address":address,
          "net_mode":netMode,
          "tag":"pending"//"latest"
        };
        final a=await BaseApi.requestEmptyH.post('${url}v2/eth/transaction/count', params: params,data: params,header:header,);
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
  Future<MessageModel> sendTxEth(String coinType,String signHash,String netMode,{String? rpc})async{
    try{
      if(rpc==null){
        Map<String,dynamic> params={
          "coin":coinType,
          "signed_tx":signHash,
          "net_mode":netMode,
        };
        final a=await BaseApi.requestEmptyH.post('${url}v2/eth/raw/transaction', params: params,data: params,header:header,);
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
  Future<MessageModel> getTransactionReceiptEth(String coinType,String txHash,{bool isTest=false,String? rpc})async{
    try{
      if(rpc==null){
        Map<String,dynamic> params={
          "tx_hash":txHash,
          "coin":coinType,
          "net_mode":isTest?"test":"main",
        };
        final a=await BaseApi.requestEmptyH.post('${url}v2/eth/transaction/receipt', params: params,data: params,header:header,);
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
  Future<MessageModel> getGasPriceEth(String coinType,{bool isTest=false,String? rpc})async{
    try{
      if(rpc ==null){
        Map<String,dynamic> params={
          "coin":coinType,
          "net_mode":isTest?"test":"main",
        };
        final a=await BaseApi.requestEmptyH.post('${url}v2/eth/gas/price', params: params,data: params,header:header,);
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
  Future<MessageModel> getEnsResolve(String domain)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/ens/resolve?domain=$domain', params: {},header:header,);
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

  /// N42 链专用的 ENS 解析
  /// N42 Name Service - 支持 .n42 后缀的域名
  Future<MessageModel> getN42EnsResolve(String domain)async{
    try{
      // N42 链使用专门的解析端点
      final a=await BaseApi.requestEmptyH.get('${url}v1/n42/ens/resolve?domain=$domain', params: {},header:header,);
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

  /// ENS 反向解析 - 将地址解析为 ENS 名称
  Future<MessageModel> getEnsReverseResolve(String address)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/ens/reverse?address=$address', params: {},header:header,);
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

  /// N42 ENS 反向解析
  Future<MessageModel> getN42ReverseResolve(String address)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/n42/ens/reverse?address=$address', params: {},header:header,);
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

  /// 获取 ENS 头像
  Future<MessageModel> getEnsAvatar(String domain)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/ens/avatar?domain=$domain', params: {},header:header,);
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

  /// 获取 ENS 文本记录 (email, twitter, github 等)
  Future<MessageModel> getEnsTextRecords(String domain)async{
    try{
      final a=await BaseApi.requestEmptyH.get('${url}v1/ens/text-records?domain=$domain', params: {},header:header,);
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

  // ── Unstoppable Domains ────────────────────────────────────────────────────

  /// Unstoppable Domains 正向解析
  ///
  /// [domain] — 域名（如 alice.crypto）
  /// [ticker] — 目标链代币符号（ETH / BNB / MATIC / BTC / SOL 等）
  ///            不传则由后端返回默认 EVM 地址
  ///
  /// 后端代理调用 UD Resolve API：
  ///   GET /domains/{domain}
  ///   取 records['crypto.{TICKER}.address']
  Future<MessageModel> getUdResolve(String domain, {String? ticker}) async {
    try {
      final tickerParam = ticker != null ? '&ticker=$ticker' : '';
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ud/resolve?domain=$domain$tickerParam',
        params: {},
        header: header,
      );
      MessageModel mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// Unstoppable Domains 反向解析
  ///
  /// [address] — 链地址
  /// [ticker]  — 地址所属链的代币符号
  ///
  /// 后端调用 UD Reverse API：
  ///   GET /reverse/{address}
  Future<MessageModel> getUdReverseResolve(String address,
      {String? ticker}) async {
    try {
      final tickerParam = ticker != null ? '&ticker=$ticker' : '';
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/ud/reverse?address=$address$tickerParam',
        params: {},
        header: header,
      );
      MessageModel mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  // ── Solana Name Service (SNS / Bonfida) ────────────────────────────────────

  /// SNS 正向解析：.sol 域名 → Solana 地址
  ///
  /// [domain] — 域名（如 alice.sol）
  ///
  /// 后端代理调用：
  ///   GET https://sns-sdk-proxy.bonfida.workers.dev/resolve/{domain}
  Future<MessageModel> getSnsResolve(String domain) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/sns/resolve?domain=$domain',
        params: {},
        header: header,
      );
      MessageModel mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// SNS 反向解析：Solana 地址 → .sol 域名
  ///
  /// [address] — Solana base58 地址
  Future<MessageModel> getSnsReverseResolve(String address) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/sns/reverse?address=$address',
        params: {},
        header: header,
      );
      MessageModel mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['msg']);
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  ////////////////////////////
  //solana
  //获取余额
  Future<MessageModel> getBalanceSolana(String coinType,String address,String contract,{bool returnDouble=false,bool isTest=false})async{
    try{
      dynamic a;
      if(contract==""){
        Map<String,dynamic> params={
          "pubkey":address,
          "net_mode":isTest?"test":"main",
        };
        a=await BaseApi.requestEmptyH.post('${url}v1/sol/balance', params: params,data: params,header:header,);
      }else{
        String pubKey=await Trustdart().getPubKeySOL(address,contract);
        Map<String,dynamic> params={
          "pubkey":pubKey,
          "net_mode":isTest?"test":"main",
        };
        a=await BaseApi.requestEmptyH.post('${url}v1/sol/token/account/balance', params: params,data: params,header:header,);
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
  Future<MessageModel> getTokenAccountsByOwnerSolana(String address,String contract,{bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "mint":contract,
        "net_mode":isTest?"test":"main",
        "pubkey":address,
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/sol/token/accounts/by/owner', params: params,data: params,header:header,);
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
  Future<MessageModel> getAccountInfoSolana(String address,{bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
        "pubkey":address,
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/sol/account/info', params: params,data: params,header:header,);
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
  Future<MessageModel> getRecentBlockhashSolana({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/sol/recent/block/hash', params: params,data: params,header:header,);
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
  Future<MessageModel> sendTxSolana(String signHash,String netMode)async{
    try{
      Map<String,dynamic> params={
        "net_mode":netMode,
        "tx_hash":signHash,
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/sol/tx/send', params: params,data: params,header:header,);
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
  Future<MessageModel> getGasPriceSolana({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/sol/fees', params: params,data: params,header:header,);
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
  Future<MessageModel> getTransactionSolana(String txHash,String netMode)async{
    try{
      Map<String,dynamic> params={
        "net_mode":netMode,
        "tx_sign":txHash,
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/sol/transaction', params: params,data: params,header:header,);
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
  //获取gas费
  Future<MessageModel> getGasPriceTrx({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/trx/gas/price', params: params,data: params,header:header,);
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
  Future<MessageModel> getTransactionReceiptTrx(String txHash,{bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "tx_hash":txHash,
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/trx/transaction/receipt', params: params,data: params,header:header,);
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
  Future<MessageModel> getLatestBlockNumberTrx({bool isTest=false})async{
    try{
      Map<String,dynamic> params={
        "net_mode":isTest?"test":"main",
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/trx/latest/block', params: params,data: params,header:header,);
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
  Future<MessageModel> createTxTrx(String sendAddress,String toAddress,int amount, dynamic netMode)async{
    try{
      Map<String,dynamic> params={
        "coin":"trx",
        "owner_address":sendAddress,
        "to_address":toAddress,
        "visible":false,
        "amount":amount,
      };
      final a=await BaseApi.requestEmptyH.post('${url}v1/vipapi/onchainwallet/transaction', params: params,data: params,header:header,);
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
  Future<MessageModel> sendTxTrx(String signHash,String netMode)async{
    try{
      Map<String,dynamic> sign=json.decode(signHash);
      sign["visible"]=false;
      sign['net_mode']="main";
      final a=await BaseApi.requestEmptyH.post('${url}v1/trx/broadcast/transaction', params: sign,data: sign,header:header,);
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
