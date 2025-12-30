import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/https/activity_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/algo_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/apt_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/atom_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/btc_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/dot_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/fil_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/sol_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/ton_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/trx_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xrp_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xtz_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_1559.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/coin_gas.dart';
import 'package:decimal/decimal.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:provider/provider.dart';

class TransferApi {
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    if(_tokenViewApi==null){
      _tokenViewApi=TokenViewApi();
    }
    return _tokenViewApi!;
  }
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils=DataUtils();
    }
    return _dataUtils!;
  }
  Trustdart? _trustdart;
  Trustdart get trustdart{
    if(_trustdart==null){
      _trustdart=Trustdart();
    }
    return _trustdart!;
  }
  //地址处理
  addressDealWith(String address,String chainSymbol){
    if(chainSymbol==CoinType.BCH.name){
      List<String> addrs=address.split(':');
      if(addrs.length==2){
        return addrs[1];
      }
    }
    return address;
  }
  //Symbol处理
  symbolDealWith(String symbol){
    if(symbol == "BSC"){
      symbol = "BNB";
      return symbol;
    }
    if(symbol == "AVAXC"){
      symbol = "AVAX";
      return symbol;
    }
    if(symbol == "OPTIMISM"){
      symbol = "OP";
      return symbol;
    }
    return symbol;
  }

  ///转账方法
  /// chainSymbol 链缩写 例如：Bitcoin:btc或BTC都可以
  /// fromAddress 转出地址
  /// toAddress 转入地址
  /// value 转账金额 double类型
  /// maxValue 是否是最大转账金额，默认 是最大转账金额
  /// contractAddeess 合约地址 ，如果是合约币转账，传入合约地址
  transfer(
      String chainSymbol ,String toAddress, double value,
      {String contractAddress = "", String fromAddress = "",bool isTest=false,bool maxValue=true,String? message}) async {
    WalletActionProvider wap = Provider.of(AppGlobals.appContext,listen: false);
    chainSymbol=symbolDealWith(chainSymbol);
    Map<String, dynamic>? txChainMap =
    wap.walletMap[chainSymbol.toString().toUpperCase()];
    if (txChainMap == null) {
      MessageModel mm = MessageModel.error();
      mm.data = S.current.g_key_wallet_m1(chainSymbol);
      return mm;
    }
    Map<String, dynamic>? token = null;
    if (contractAddress != "") {
      if(isTest){
        if (txChainMap['testnets']['testnetContract'].length != 0) {
          token = txChainMap['testnets']['testnetContract'][contractAddress.toString().toUpperCase()];
        }
      }else{
        if (txChainMap['mainnets'].length != 0) {
          token = txChainMap['mainnets'][contractAddress.toString().toUpperCase()];
        }
      }

      if (token == null) {
        MessageModel mm = MessageModel.error();
        mm.data = S.current.g_key_wallet_m2;
        return mm;
      }
    }

    if (fromAddress == "") {
      String? fAddress = wap.getAddress(txChainMap['baseInfo']['coinType'],
          addrType: txChainMap['addrType']);
      if (fAddress == null) {
        MessageModel mm = MessageModel.error();
        mm.data = S.current.g_key_wallet_m3(txChainMap['baseInfo']['coinType']);
        return mm;
      } else {
        fromAddress = fAddress;
      }
    }
    String blockchain = txChainMap['baseInfo']['blockchainType'];
    String path=txChainMap['baseInfo']['path'][txChainMap['addrType']];
    int pathIndex=txChainMap["pathIndex"]??0;
    path=getPathWithIndex(path, pathIndex);
    String coinType=txChainMap['baseInfo']['coinType'];
    MessageModel txmm=MessageModel();
    switch (blockchain) {
      case "Bitcoin":
        txmm= await transfer_btc(
            txChainMap['baseInfo']['coinType'],
            fromAddress,
            toAddress,
            value,
            path,
            maxValue: maxValue,
            isTest:isTest?"test":"main",
          //txChainMap['baseInfo']['path'][txChainMap['addrType']]
        );
        break;
      case "Ethereum":
        txmm= await transfer_eth(
          isTest?txChainMap['baseInfo']['chainId_test']:txChainMap['baseInfo']['chainId'],
          txChainMap['baseInfo']['coinType'],
          fromAddress,
          toAddress,
          value,
          txChainMap['baseInfo']['decimals'],
          path,
          //txChainMap['baseInfo']['path'][pathType],
          contractAddress: contractAddress,
          tokenDecimals: token==null?0:token['decimals'],
          isTest:isTest,
          maxValue: maxValue,
          message: message,
        );
        break;
      case "Solana":
        txmm= await transfer_sol(
            txChainMap,
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,
            //txChainMap['baseInfo']['path'][pathType],
            contractAddress: contractAddress,tokenDecimals: token==null?0:token['decimals'],
            maxValue: maxValue
        );
        break;
      case "Tron":
        txmm= await transfer_trx(
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,
            //txChainMap['baseInfo']['path'][pathType],
            contractAddress: contractAddress,tokenDecimals: token==null?0:token['decimals'],
            maxValue: maxValue
        );
        break;
      case "Algorand":
        return await transfer_algo(
          fromAddress,
          toAddress,
          value,
          txChainMap['baseInfo']['decimals'],
          path,
          //txChainMap['baseInfo']['path'][pathType],
          maxValue: maxValue,
        );
      case "Tezos":
        return await transfer_xtz(
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,
            //txChainMap['baseInfo']['path'][pathType],
            maxValue: maxValue
        );
      case "Ripple":
        return await transfer_xrp(
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,
            //txChainMap['baseInfo']['path'][pathType],
            maxValue: maxValue
        );
      case "Cosmos":
        return await transfer_atom(
          fromAddress,
          toAddress,
          value,
          txChainMap['baseInfo']['decimals'],
          path,
          maxValue: maxValue,
        );
    }
    if (txmm.error == false) {
      Map<String, dynamic> pushMap = {
        "uuid": AppGlobals.userInfo?.uuid??"",
        "coin": coinType,
        "tx": txmm.data['txHash'],
        "network":isTest?"test":"main",
      };
      ActivityApi activityApi=ActivityApi();
      activityApi.collectDelayPush(json.encode(pushMap), event: "transaction");
    }
    return txmm;
  }

  //钱包转账使用，此方法无需检测币是否存在，也无需检测转账是否无误
  transfer_wallet({TransationRecordModel? trModel,BtcTransactionRecodeModel? trModel_btc,String? privateKey,int pathIndex=0})async{
    String blockchain = "";
    if(trModel==null){
      blockchain=trModel_btc!.coin['blockchainType'];
    }else{
      blockchain=trModel.coin['blockchainType'];
    }
    MessageModel txmm=MessageModel();
    String coinType="";
    String network="main";
    switch (blockchain) {
      case "Bitcoin":
        List<Map<String,dynamic>> utxo=[];
        for(InputModel im in trModel_btc!.InputModels){
          utxo.add(im.toMap());
        }
        coinType=trModel_btc.coin['coinType'];
        network=trModel_btc.isTest==0?"main":"test";
        txmm= await transfer_btc_send(
          trModel_btc.coin['coinType'],
          trModel_btc.address,
          trModel_btc.to1,
          trModel_btc.price,
          getPathWithIndex(trModel_btc.coin['path'][trModel_btc.addrType], pathIndex),
          trModel_btc.gas,
          trModel_btc.gasPrice,
          trModel_btc.inputModels_map(),
          max: trModel_btc.max,
          privateKey: privateKey,
          isTest: trModel_btc.isTest==0?"main":"test",
        );
        break;
      case "Ethereum":
        coinType=trModel!.coin['coinType'];
        network=trModel.isTest==0?"main":"test";
        double gasPrice2Double=toEther(trModel.gasPriceValue.toString(), trModel.coin['decimals']).toDouble();
        gasPrice2Double=gasPrice2Double/2;
        Decimal rValue=Decimal.parse(gasPrice2Double.toString());
        BigInt gasPrice2=ethToWeiString(rValue.toString(), trModel.coin['decimals']);
        String? rpc;
        if(trModel.isTest==0){
          rpc=trModel.coin['service'];
        }else{
          rpc=trModel.coin['service_test'];
        }
        txmm= await transfer_eth_send(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPriceValue,
          gasPrice2,
          trModel.gas,//gas
          trModel.coin['coinType'],
          trModel.isTest==0?trModel.coin['chainId']:trModel.coin['chainId_test'],
          contractAddress: trModel.contract,
          isTest: trModel.isTest==0?"main":"test",
          privateKey: privateKey,
          nonce: trModel.nonce,
          message: trModel.message,
          erc721Or1155:trModel.erc721Or1155,
          returnSignHash:trModel.returnSignHash,
          rpc: rpc,
        );
        break;
      case "Solana":
        coinType=CoinType.SOL.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transfer_sol_send(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          tokenDecimals: trModel.coin['decimals'],
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
        );
        break;
      case "Tron":
        coinType=CoinType.TRX.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transfer_trx_send(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
        );
        break;
      case "Algorand":
        coinType=CoinType.ALGO.name;
        network=trModel!.isTest==0?"main":"test";
        String type="ALGO";
        if(trModel.contract !=""){
          type="Asset";
        }
        if(trModel.other !=null){
          type=trModel.other.type;
        }
        txmm= await transfer_algo_send(trModel.from1,
          trModel.to1,
          trModel.price.toString(),
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          isTest: trModel.isTest==0?"main":"test",
          privateKey: privateKey,
          contractAddress: trModel.contract,
          type: type,
        );
        break;
      case "Tezos":
        coinType=CoinType.XTZ.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transfer_xtz_send(
          trModel.from1,
          trModel.to1,
          trModel.price.toInt(),
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          isTest: trModel.isTest==0?false:true,
          privateKey: privateKey,
        );
        break;
      case "Ripple":
        coinType=CoinType.XRP.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transfer_xrp_send(trModel.from1,
          trModel.to1,
          trModel.price,
          trModel.gasPrice,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.other.sequence,
          isTest: trModel.isTest==0?false:true,
          privateKey: privateKey,
        );
        break;
      case "Filecoin":
        coinType=CoinType.FIL.name;
        network=trModel!.isTest==0?"main":"test";
        txmm=await transfer_fil_send(
            trModel.from1,
            trModel.to1,
            trModel.price,
            trModel.gasPrice,
            getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
            trModel.nonce??"0",
            trModel.gas.toString(),
            trModel.other.gasFeeCap,
            trModel.other.gasPremium,isTest:trModel.isTest==0?false:true);
        break;
      case "Cosmos":
        coinType=CoinType.ATOM.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transfer_atom_send(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
        );
        break;
      case "Polkadot":
        coinType=trModel!.coin['coinType'];
        network=trModel!.isTest==0?"main":"test";
        txmm= await transfer_dot_send(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          coinType,
          contractAddress: trModel.contract,
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
          returnSignHash:trModel.returnSignHash,
        );
        break;
      case "Aptos":
        coinType=trModel!.coin['coinType'];
        network=trModel!.isTest==0?"main":"test";
        txmm=await transfer_apt_send(
            trModel.from1,
            trModel.to1,
            trModel.price,
            getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
            trModel.gas,
            trModel.gasPrice,
            coinType, trModel.coinId);
        break;
      case "TheOpenNetwork":
        coinType=trModel!.coin['coinType'];
        network=trModel!.isTest==0?"main":"test";
        txmm=await transfer_ton_send(
            trModel.from1,
            trModel.to1,
            trModel.price,
            getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
            trModel.gas,
            trModel.gasPrice,
            coinType,
          isTest: trModel.isTest==0?"main":"test",
        );
        break;
    }
    if (txmm.error == false) {
      Map<String, dynamic> pushMap = {
        "uuid": AppGlobals.userInfo?.uuid??"",
        "coin": coinType,
        "tx": txmm.data,
        "network":network,
      };
      ActivityApi activityApi=ActivityApi();
      activityApi.collectDelayPush(json.encode(pushMap), event: "transaction");
    }
    return txmm;
  }

  //最大交易金额
  transactionMaxValue(String blockchain,String coinType,Map<String,dynamic> signData,String path,{String? privateKey})async{
    String rStr="";
    switch (blockchain) {
      case "Bitcoin":
        if(privateKey ==null){
          rStr = await trustdart.signTransaction_maxValue(
            coinType.toUpperCase(),
            path,
            signData,
            mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
          );
        }else{
          rStr = await trustdart.signTransaction_maxValue(coinType.toUpperCase(), "", signData, pk: privateKey??"",);
        }
        break;

    }
    return rStr;
  }
  //Aptos
  transfer_apt(String fromAddress, String toAddress, double value,
      int decimals, String path,String coinType,int chainId,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true,String? privateKey})async{
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas(coinType,
        contract: contractAddress == "" ? false : true);
    DotApi dotApi=DotApi();
    MessageModel mm = await dotApi.getTokens(fromAddress, coinType,isTest: false);

    //获取余额
    BigInt chainBalance = BigInt.zero;
    if (mm.error == true) {
      return mm;
    } else {
      chainBalance = mm.data;
    }
    /*BigInt balance = BigInt.zero;
    if (contractAddress != "") {
      MessageModel mmToken = await getBalanceAll_trx(fromAddress, contractAddress: contractAddress);
      if (mmToken.error == true) {
        return mmToken;
      } else {
        balance = mmToken.data;
      }
      if (balance == BigInt.zero) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;//"TRC20 余额不足";
        return mme;
      }
    }*/
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5(coinType);//"TRX 余额不足";
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Cosmos.name, CoinType.ATOM.name,
        isTest: false);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice = mmg.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice=ethToWeiString(value.toString(), decimals);
      //如果是全部转账
      if(valuePrice==chainBalance && maxValue){
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(CoinType.ATOM.name);
        return mme;
      }
    } /*else {
      valuePrice=ethToWeiString(value.toString(), tokenDecimals);
      if (valuePrice > balance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;
        return mme;
      }
      if (totalGasPrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(CoinType.ATOM.name);
        return mme;
      }
    }*/
    MessageModel mmtx=await transfer_atom_send(fromAddress, toAddress, valuePrice, path, totalGasPrice,contractAddress: contractAddress);
    if(mmtx.error==false){
      MessageModel mmr = MessageModel();
      mmr.data = {
        "txHash":mmtx.data,
        "value":value,
      };
      return mmr;
    }else{
      return mmtx;
    }
  }
  transfer_apt_send(String fromAddress, String toAddress, BigInt valuePrice, String path,int gas,BigInt totalGasPrice,String coinType,int chainId,
      {String contractAddress = "",String contractModule="",String contractName="",String isTest="main",String? privateKey})async{
    AptApi aptApi=AptApi(isTest: isTest=="main"?false:true);
    MessageModel sequenceNumber=await aptApi.getAccountInfo(fromAddress);
    if(sequenceNumber.error){
      return sequenceNumber;
    }
    MessageModel ledgerTimestamp=await aptApi.getServiceInfo();
    if(ledgerTimestamp.error){
      return ledgerTimestamp;
    }
    int lt=ledgerTimestamp.data/1000000+60;
    Map<String,dynamic> signMap={
      "amount":valuePrice,
      "toAddress":toAddress,
      "sequenceNumber":sequenceNumber,
      "fromAddress":fromAddress,
      "contractAddress":"contractAddress",
      "contractModule":contractModule,
      "contractName":contractName,
      "gasUnitPrice":gas,
      "maxGasAmount":totalGasPrice,
      "expirationTimestampSecs":lt,
      "chainId":chainId,
    };
    String signStr;
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk:privateKey??"",);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }//发起交易
    MessageModel mmtx=await aptApi.sendTxHash(signStr);
    return mmtx;
  }
  //TheOpenNetwork
  transfer_ton_send(String fromAddress, String toAddress, BigInt valuePrice, String path,int gas,BigInt totalGasPrice,String coinType,
      {String contractAddress = "",String isTest="main",String? privateKey})async{
    TonApi tonApi=TonApi(isTest: isTest=="main"?false:true);
    MessageModel sequenceNumber=await tonApi.getSeqno_ton(fromAddress);
    if(sequenceNumber.error){
      return sequenceNumber;
    }
    int expireAt=DateTime.now().add(Duration(seconds: 60)).millisecondsSinceEpoch~/1000;
    Map<String,dynamic> signMap={
      "amount":valuePrice.toString(),
      "toAddress":toAddress,
      "sequenceNumber":sequenceNumber.data,
      "fromAddress":fromAddress,
      "contractAddress":contractAddress,
      "maxGasAmount":totalGasPrice.toString(),
      "expireAt":expireAt,
    };
    String signStr;
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk:privateKey??"",);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }//发起交易
    MessageModel mmtx=await tonApi.submit_ton(signStr);
    return mmtx;
  }

  //Polkadot
  transfer_dot(String fromAddress, String toAddress, double value,
      int decimals, String path,String coinType,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true,String? privateKey})async{
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas(coinType,
        contract: contractAddress == "" ? false : true);
    DotApi dotApi=DotApi();
    MessageModel mm = await dotApi.getTokens(fromAddress, coinType,isTest: false);

    //获取余额
    BigInt chainBalance = BigInt.zero;
    if (mm.error == true) {
      return mm;
    } else {
      chainBalance = mm.data;
    }
    /*BigInt balance = BigInt.zero;
    if (contractAddress != "") {
      MessageModel mmToken = await getBalanceAll_trx(fromAddress, contractAddress: contractAddress);
      if (mmToken.error == true) {
        return mmToken;
      } else {
        balance = mmToken.data;
      }
      if (balance == BigInt.zero) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;//"TRC20 余额不足";
        return mme;
      }
    }*/
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5(coinType);//"TRX 余额不足";
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Cosmos.name, CoinType.ATOM.name,
        isTest: false);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice = mmg.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice=ethToWeiString(value.toString(), decimals);
      //如果是全部转账
      if(valuePrice==chainBalance && maxValue){
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(CoinType.ATOM.name);
        return mme;
      }
    } /*else {
      valuePrice=ethToWeiString(value.toString(), tokenDecimals);
      if (valuePrice > balance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;
        return mme;
      }
      if (totalGasPrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(CoinType.ATOM.name);
        return mme;
      }
    }*/
    MessageModel mmtx=await transfer_atom_send(fromAddress, toAddress, valuePrice, path, totalGasPrice,contractAddress: contractAddress);
    if(mmtx.error==false){
      MessageModel mmr = MessageModel();
      mmr.data = {
        "txHash":mmtx.data,
        "value":value,
      };
      return mmr;
    }else{
      return mmtx;
    }
  }
  transfer_dot_send(String fromAddress, String toAddress, BigInt valuePrice, String path,BigInt totalGasPrice,String coinType,
      {String contractAddress = "",String isTest="main",String? privateKey,bool returnSignHash=false})async{
    DotApi dotApi=DotApi();
    bool test=isTest=="main"?false:true;
    MessageModel genesisHash=await dotApi.getGenesisHash(index: 0,isTest: test);
    if(genesisHash.error){
      return genesisHash;
    }
    MessageModel nonce=await dotApi.getNonce(fromAddress,isTest: test);
    if(nonce.error){
      return nonce;
    }
    MessageModel getRuntimeVersion=await dotApi.getRuntimeVersion(isTest: test);
    if(getRuntimeVersion.error){
      return getRuntimeVersion;
    }
    MessageModel blockHash=await dotApi.getGenesisHash(isTest: test);
    if(blockHash.error){
      return blockHash;
    }
    MessageModel blockNumber=await dotApi.getChainHeader(isTest: test);
    if(blockNumber.error){
      return blockNumber;
    }
    Map<String,dynamic> signMap={
      "amount":dataUtils.bigIntToHex(valuePrice, need0x: true),
      "toAddress":toAddress,
      "genesisHash":genesisHash.data,//base64
      "blockHash":blockHash.data,//base64
      "nonce":nonce.data,
      "specVersion":getRuntimeVersion.data['specVersion'],
      "transactionVersion":getRuntimeVersion.data['transactionVersion'],
      "blockNumber":dataUtils.hexToBigInt(blockNumber.data['number']).toInt(),
    };
    if(contractAddress !=""){

    }
    String signStr;
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk:privateKey??"",);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }//发起交易
    MessageModel mmtx=await dotApi.submitTxHash(signStr,isTest:test);
    return mmtx;
  }
  //Cosmos
  transfer_atom(String fromAddress, String toAddress, double value,
      int decimals, String path,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true,String? privateKey})async{
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas(CoinType.ATOM.name,
        contract: contractAddress == "" ? false : true);
    MessageModel mm =
    await getBalanceAll_trx(fromAddress);

    //获取余额
    BigInt chainBalance = BigInt.zero;
    if (mm.error == true) {
      return mm;
    } else {
      chainBalance = mm.data;
    }
    BigInt balance = BigInt.zero;
    if (contractAddress != "") {
      MessageModel mmToken =
      await getBalanceAll_trx(fromAddress, contractAddress: contractAddress);
      if (mmToken.error == true) {
        return mmToken;
      } else {
        balance = mmToken.data;
      }
      if (balance == BigInt.zero) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;//"TRC20 余额不足";
        return mme;
      }
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("TRX");//"TRX 余额不足";
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Cosmos.name, CoinType.ATOM.name,
        isTest: false);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice = mmg.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice=ethToWeiString(value.toString(), decimals);
      //如果是全部转账
      if(valuePrice==chainBalance && maxValue){
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(CoinType.ATOM.name);
        return mme;
      }
    } else {
      valuePrice=ethToWeiString(value.toString(), tokenDecimals);
      if (valuePrice > balance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;
        return mme;
      }
      if (totalGasPrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(CoinType.ATOM.name);
        return mme;
      }
    }
    MessageModel mmtx=await transfer_atom_send(fromAddress, toAddress, valuePrice, path, totalGasPrice,contractAddress: contractAddress);
    if(mmtx.error==false){
      MessageModel mmr = MessageModel();
      mmr.data = {
        "txHash":mmtx.data,
        "value":value,
      };
      return mmr;
    }else{
      return mmtx;
    }
  }
  transfer_atom_send(String fromAddress, String toAddress, BigInt valuePrice, String path,BigInt totalGasPrice,
      {String contractAddress = "",String isTest="main",String? privateKey})async{
    AtomApi atomApi=AtomApi();
    MessageModel amm=await atomApi.getAccounts(fromAddress);
    if(amm.error){
      return amm;
    }
    Map<String,dynamic> signMap={
      "chainId":"cosmoshub-4",
      "toAddress":toAddress,
      "accountNumber":amm.data['account_number'],
      "sequence":amm.data['sequence'],
      "memo":"memo",
      "fee":{
        "gas":totalGasPrice.toString(),
        "amount":"5000",
        "denom":"uatom",
      },
      "amount":{
        "amount":valuePrice.toString(),
        "denom":"uatom",
      },
    };
    if(contractAddress !=""){

    }
    String signStr;
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        CoinType.ATOM.name,
        path,
        signMap,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(CoinType.ATOM.name, path, signMap, pk:privateKey??"",);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }//发起交易
    MessageModel mmtx=await atomApi.sendTxs(signStr);
    return mmtx;
  }
  //tron 转账
  transfer_trx(String fromAddress, String toAddress, double value,
      int decimals, String path,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true}) async {
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas(CoinType.TRX.name,
        contract: contractAddress == "" ? false : true);
    MessageModel mm =
    await getBalanceAll_trx(fromAddress);

    //获取余额
    BigInt chainBalance = BigInt.zero;
    if (mm.error == true) {
      return mm;
    } else {
      chainBalance = mm.data;
    }
    BigInt balance = BigInt.zero;
    if (contractAddress != "") {
      MessageModel mmToken =
      await getBalanceAll_trx(fromAddress, contractAddress: contractAddress);
      if (mmToken.error == true) {
        return mmToken;
      } else {
        balance = mmToken.data;
      }
      if (balance == BigInt.zero) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;//"TRC20 余额不足";
        return mme;
      }
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("TRX");//"TRX 余额不足";
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Tron.name, CoinType.TRX.name,
        isTest: false);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice = mmg.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice=ethToWeiString(value.toString(), decimals);
      //如果是全部转账
      if(valuePrice==chainBalance && maxValue){
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5("TRX");
        return mme;
      }
    } else {
      valuePrice=ethToWeiString(value.toString(), tokenDecimals);
      if (valuePrice > balance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;
        return mme;
      }
      if (totalGasPrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5("TRX");
        return mme;
      }
    }
    MessageModel mmtx=await transfer_trx_send(fromAddress, toAddress, valuePrice, path, totalGasPrice,contractAddress: contractAddress);
    if(mmtx.error==false){
      MessageModel mmr = MessageModel();
      mmr.data = {
        "txHash":mmtx.data,
        "value":value,
      };
      return mmr;
    }else{
      return mmtx;
    }
  }
  //trx提交
  transfer_trx_send(String fromAddress, String toAddress, BigInt valuePrice, String path,BigInt totalGasPrice,
      {String contractAddress = "",String isTest="main",String? privateKey})async{
    //签名
    TrxApi trxApi=TrxApi();
    //获取最新块
    MessageModel mmlbn =await trxApi.getBlockNow_trx(isTest:isTest=="main"?false:true);
    if (mmlbn.error) {
      return mmlbn;
    }
    Map<String, dynamic> blockInfo = mmlbn.data['raw_data'];
    /*await tokenViewApi.getLatestBlockNumber_trx(isTest: isTest=="main"?false:true);
    if (mmlbn.error) {
      return mmlbn;
    }
    Map<String, dynamic> blockInfo = mmlbn.data['block_header']['raw_data'];
    */
    Map<String, dynamic> txData = {
      "ownerAddress": fromAddress,
      "toAddress": toAddress,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "blockTime": blockInfo['timestamp'],
      "txTrieRoot": blockInfo['txTrieRoot'],
      "witnessAddress": blockInfo['witness_address'],
      "parentHash": blockInfo['parentHash'],
      "version": blockInfo['version'],
      "number": blockInfo['number'],
      "feeLimit": totalGasPrice.toInt()
    };
    if (contractAddress != "") {
      txData['cmd'] = "TRC20";
      txData['contractAddress'] = contractAddress;
      txData['amount'] = dataUtils.bigIntToHex(valuePrice, need0x: false);
    } else {
      txData['amount'] = valuePrice.toInt();
      txData['cmd'] = CoinType.TRX.name;
    }

    String signStr;
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        CoinType.TRX.name,
        path,
        txData,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(CoinType.TRX.name, path, txData, pk:privateKey??"",);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }//发起交易
    MessageModel mmtx=await trxApi.sendTx_trx(signStr,isTest:isTest=="main"?false:true);
    return mmtx;
    /*MessageModel mmtx = await tokenViewApi.sendTx(
        BlockchainType.Tron.name, CoinType.TRX.name, signStr,
        netMode: isTest);
    if (mmtx.error == false) {
      MessageModel mmr = MessageModel();
      if (mmtx.data['result']) {
        mmr.data = mmtx.data['txid'];
        return mmr;
      } else {
        mmr.data = mmtx.data['message'];
        mmr.error = true;
        return mmr;
      }
    } else {
      return mmtx;
    }*/
  }

  transfer_sol(Map<String,dynamic> chainMap,String fromAddress, String toAddress, double value,
      int decimals, String path,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true}) async {
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas(CoinType.SOL.name,
        contract: contractAddress == "" ? false : true);
    BigInt balance = BigInt.zero;
    BigInt chainBalance  = BigInt.zero;
    MessageModel mmb =
    await getBalance_sol(fromAddress, contractAddress: contractAddress);
    if (mmb.error) {
      return mmb;
    } else {
      balance = mmb.data;
    }
    if (balance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m4;
      return mme;
    }
    MessageModel mmchain = await getBalance_sol(fromAddress);
    if (mmchain.error) {
      return mmchain;
    } else {
      chainBalance = mmchain.data;
    }
    if (balance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("SOL");
      return mme;
    }
    //gasprice
    BigInt gasPrice = BigInt.zero;
    MessageModel mmgas = await tokenViewApi.getGasPrice(
        BlockchainType.Solana.name, CoinType.SOL.name,
        isTest: false);
    if (mmgas.error) {
      return mmgas;
    } else {
      gasPrice = mmgas.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice = ethToWeiString(value.toString(), decimals);
      //如果是全部转账
      if(valuePrice==chainBalance && maxValue){
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5("SOL");
        return mme;
      }
    } else {
      valuePrice = ethToWeiString(value.toString(), tokenDecimals);
      if (totalGasPrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5("SOL");
        return mme;
      }
      if ( valuePrice > balance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;
        return mme;
      }
    }
    MessageModel rmm=await transfer_sol_send(fromAddress, toAddress, valuePrice, path, totalGasPrice,contractAddress:contractAddress ,tokenDecimals: tokenDecimals);
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value":value
      };
    }
    return rmm;
  }
  //solana 提交
  transfer_sol_send(String fromAddress, String toAddress, BigInt valuePrice, String path,BigInt totalGasPrice,
      {String contractAddress = "",int tokenDecimals=0,String isTest="main",String? privateKey})async{
    SolApi solApi=SolApi();
    String recipientTokenAddress="";
    if(contractAddress!=""){
      recipientTokenAddress=await trustdart.getPubKeySOL(toAddress,contractAddress);
      if(recipientTokenAddress==""){
        MessageModel rmm=MessageModel.error();
        rmm.data="Error";
        return rmm;
      }
      /*MessageModel rBalance= await TokenViewApi.getBalance(BlockchainType.Solana.name, "", toAddress,contract: contractAddress,isTest: isTest=="main"?false:true);
      if(rBalance.error){
        return rBalance;
      }else{
        if(rBalance.data !=null){
          recipientTokenAddress=rBalance.data['account'];
        }
      }*/
      MessageModel rdataAccount=await solApi.getAccountInfo(recipientTokenAddress,isTest: isTest=="main"?false:true);
      //MessageModel rdataAccount=await tokenViewApi.getAccountInfo_solana(recipientTokenAddress,isTest: isTest=="main"?false:true);
      if(rdataAccount.error==true){
        return rdataAccount;
      }else{
        if(rdataAccount.data==null){
          recipientTokenAddress="";
        }
      }
    }

    //获取最新块信息
    MessageModel mmblock =await solApi.getLatestBlockhash(isTest: isTest=="main"?false:true);
    //await tokenViewApi.getRecentBlockhash_solana(isTest: isTest=="main"?false:true);
    String recentBlockhash = "";
    if (mmblock.error) {
      return mmblock;
    } else {
      recentBlockhash = mmblock.data;
    }
    //签名
    Map<String, dynamic> txData = {};
    if (contractAddress == "") {
      txData = {
        "type": "SOL",
        "recentBlockhash": recentBlockhash,
        "transferTransaction": {
          "recipient": toAddress,
          "value": valuePrice.toString(),
        },
        "encodeType": "base58",
      };
    } else {
      txData={
        "type":"tokenCreate",
        "recentBlockhash": recentBlockhash,
        "tokenTransferTransaction": {
          "tokenMintAddress": contractAddress,
          "senderTokenAddress": fromAddress,
          "recipientTokenAddress": recipientTokenAddress,
          "recipientMainAddress":toAddress,
          "amount": valuePrice.toString(),
          "decimals": tokenDecimals.toString(),
        },
        "encodeType": "base58",
      };
    }
    String signStr;
    WalletInfo wi;
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        CoinType.SOL.name,
        path,
        txData,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(CoinType.SOL.name, path, txData,  pk:privateKey??"",);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return;
    }
    //发送交易
    return await solApi.sendTransaction(signStr,isTest: isTest=="main"?false:true);
    //return await tokenViewApi.sendTx(BlockchainType.Solana.name, CoinType.SOL.name, signStr, netMode: isTest);
  }

  //erc721Or1155 721、1155
  transfer_eth_721({
    String fromAddress="",
    required String toAddress,
    required String contractAddress,
    required double value,
    int nftNum=1,
    required String tokenId,
    required erc721Or1155,
    String? coinType,
    bool isTest=false,
  })async{
    if(coinType==null){
      coinType=CoinType.ETH.name;
    }
    WalletActionProvider wap = Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false);
    Map<String, dynamic>? txChainMap = wap.walletMap[coinType];
    if (txChainMap == null) {
      MessageModel mm = MessageModel.error();
      mm.data = S.current.g_key_wallet_m1(coinType);
      return mm;
    }
    if (fromAddress == "") {
      String? fAddress = wap.getAddress(coinType,
          addrType: "legacy");
      if (fAddress == null) {
        MessageModel mm = MessageModel.error();
        mm.data = S.current.g_key_wallet_m3(coinType);
        return mm;
      } else {
        fromAddress = fAddress;
      }
    }
    //获取每个byte 消耗多少gas
    int gas =
    GetCoinGas(coinType, contract: true);
    /*MessageModel mm = await getBalance_eth(coinType, fromAddress,
        contractAddress: "");*/
    //获取余额
    //BigInt balance = BigInt.zero;
    BigInt chainBalance = BigInt.zero;
    /*if (mm.error == true) {
      return mm;
    } else {
      balance = mm.data;
    }
    if (balance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m4;
      return mme;
    }*/
    MessageModel mmchain =
    await getBalance_eth(coinType, fromAddress, contractAddress: "",isTest: isTest);
    if (mmchain.error == true) {
      return mmchain;
    } else {
      chainBalance = mmchain.data;
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5(coinType);
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    BigInt gasPrice2 = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Ethereum.name, coinType,
        isTest: isTest);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice2 = mmg.data;
      gasPrice = mmg.data;
      if(get1559WithChainSymbol(coinType)){
        gasPrice=gasPrice*BigInt.from(2);
      }
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = ethToWeiString(value.toString(), 18);
    if(valuePrice==chainBalance){
      valuePrice=valuePrice-totalGasPrice;
      value=toEther(valuePrice.toString(),18).toDouble();
    }
    if (totalGasPrice + valuePrice > chainBalance) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5(coinType);
      return mme;
    }

    //获取nonce值
    MessageModel mmn = await tokenViewApi.getTransactionCount_eth(
        coinType, fromAddress,netMode:isTest?"test":"main");
    String nonceHex = "";
    if (mmn.error) {
      return mmn;
    } else {
      nonceHex = dataUtils.bigIntToHex(mmn.data, need0x: false);
    }
    String gasPriceHex = dataUtils.bigIntToHex(gasPrice, need0x: false);
    String amountHex;
    if(contractAddress==""){
      amountHex=dataUtils.bigIntToHex(valuePrice,
          need0x: false);
    }else{
      amountHex=dataUtils.bigIntToHex(valuePrice,
          need0x: false);
    }


    String chainIdHex =
    dataUtils.bigIntToHex(BigInt.from(isTest?txChainMap['baseInfo']['chainId_test']:txChainMap['baseInfo']['chainId']), need0x: false);
    String gasLimitHex = dataUtils.bigIntToHex(BigInt.from(gas), need0x: false);
    String gasPrice2Hex = dataUtils.bigIntToHex(gasPrice2, need0x: false);
    Map<String, String> signMap = {
      "chainId": chainIdHex,
      "gasPrice": gasPriceHex,
      "gasPrice2": gasPrice2Hex,
      "gasLimit": gasLimitHex, //"C350",
      "toAddress": toAddress,
      'nonce': nonceHex,
      'contract': contractAddress.toLowerCase(),
      'amount': amountHex,
      'erc721Or1155': erc721Or1155,
      "tokenId":dataUtils.bigIntToHex(BigInt.parse(tokenId),need0x: false),
      "trValue":dataUtils.bigIntToHex(BigInt.from(nftNum),need0x: false),
    };
    if(get1559WithChainSymbol(coinType)){
      signMap["is1559"]='true';
    }else{
      signMap["is1559"]='false';
    }
    String signStr;
    //从keystore中取出助记词
    WalletInfo wi = wap.walletInfo;
    String path=txChainMap['baseInfo']['path'][txChainMap['addrType']];
    int pathIndex=txChainMap["pathIndex"]??0;
    path=getPathWithIndex(path, pathIndex);
    signStr = await trustdart.signTransaction(
        coinType, path, signMap, mnemonic: wi.mnemonic??"",pk: wi.password??"");

    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    signStr = "0x" + signStr;
    return await tokenViewApi.sendTx(
        BlockchainType.Ethereum.name, coinType, signStr,
        netMode: isTest?"test":"main");
  }
  transfer_eth(int chainId, String coinType, String fromAddress,
      String toAddress, double value, int decimals, String path,
      {String contractAddress = "",int tokenDecimals=0,bool isTest=false,bool maxValue=true,String? message,}) async {
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas(coinType, contract: contractAddress == "" ? false : true);
    //获取余额
    BigInt balance = BigInt.zero;
    BigInt chainBalance = BigInt.zero;
    if(contractAddress !=""){
      MessageModel mm = await getBalance_eth(coinType, fromAddress,
          contractAddress: contractAddress,isTest:isTest);
      if (mm.error == true) {
        return mm;
      } else {
        balance = mm.data;
      }
      if (balance == BigInt.zero) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;
        return mme;
      }
    }
    MessageModel mmchain =
    await getBalance_eth(coinType, fromAddress, contractAddress: "",isTest:isTest);
    if (mmchain.error == true) {
      return mmchain;
    } else {
      chainBalance = mmchain.data;
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5(coinType);
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    BigInt gasPrice2 = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Ethereum.name, coinType,
        isTest: isTest);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice2 = mmg.data;
      gasPrice = mmg.data;
      if(get1559WithChainSymbol(coinType)){
        gasPrice=gasPrice*BigInt.from(2);
      }
    }
    //gas费消耗最大数
    BigInt totalGasPrice = BigInt.zero;
    bool addLatest=true;
    if(coinType==CoinType.GO.name
        || coinType==CoinType.OKT.name
        || coinType==CoinType.METIS.name
        || coinType==CoinType.MTR.name
        || coinType==CoinType.VIC.name
        || coinType==CoinType.OP.name
        || coinType==CoinType.BOBA.name
    ){
      addLatest=true;
    }
    /*else{
      MessageModel estimate_mm=await TokenViewApi.getGasEstimate_eth_v2(
          fromAddress,
          toAddress,
          gasPrice,
        ethToWeiString(value.toString(), contractAddress==""?decimals:tokenDecimals),
          BigInt.from(gas),
          coinType,
          contract: contractAddress,
        isTest:isTest,
      );
      if(estimate_mm.error){
        return estimate_mm;
      }else{
        gas=(estimate_mm.data as BigInt).toInt();
        totalGasPrice=gasPrice * BigInt.from(gas);
      }
    }*/
    MessageModel estimate_mm=await TokenViewApi().getGasEstimate_eth_v2(
        fromAddress,
        toAddress,
        gasPrice,
        ethToWeiString(value.toString(), contractAddress==""?decimals:tokenDecimals),
        BigInt.from(gas),
        coinType,
        contract: contractAddress,
        isTest: isTest,);
    if(estimate_mm.error==false){
      gas=(estimate_mm.data as BigInt).toInt();
      if(coinType==CoinType.OP.name
          || coinType==CoinType.BOBA.name){
        gas=(gas*1.5).toInt();
      }
      totalGasPrice=gasPrice * BigInt.from(gas);
    }else{
      return estimate_mm;
    }

    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice = ethToWeiString(value.toString(), decimals);
      if(valuePrice==chainBalance && maxValue==true){
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if(value<0){
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(coinType==CoinType.N.name?CoinType.N.name:coinType);
        return mme;
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(coinType==CoinType.N.name?CoinType.N.name:coinType);
        return mme;
      }
    }
    else {
      valuePrice = ethToWeiString(value.toString(), tokenDecimals);
      if (valuePrice > balance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4;
        return mme;
      }
      if (totalGasPrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(coinType==CoinType.N.name?CoinType.N.name:coinType);
        return mme;
      }
    }
    MessageModel rmm=await transfer_eth_send(
      fromAddress, toAddress,
      valuePrice, path, gasPrice, gasPrice2,gas,
      coinType, chainId,
      contractAddress: contractAddress,
      isTest:isTest?"test":"main",
      message: message,
    );
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value": value,
      };
    }
    return rmm;
  }
  //以太坊提交
  transfer_eth_send(
      String fromAddress,
      String toAddress,
      BigInt valuePrice,
      String path,
      BigInt gasPrice,
      BigInt gasPrice2,
      int gas,
      String coinType,
      int chainId,
      {String contractAddress = "",
        String isTest="main",
        String? privateKey,
        String? nonce,
        String? message,
        String erc721Or1155="",
        bool returnSignHash=false,//返回签名数据
        String? rpc,
      })async{
    String nonceHex = "";
    //获取nonce值
    if(nonce==null){
      MessageModel mmn = await tokenViewApi.getTransactionCount_eth(
          coinType, fromAddress,
          netMode: isTest,rpc: rpc);
      if (mmn.error) {
        return mmn;
      } else {
        nonceHex = dataUtils.bigIntToHex(mmn.data, need0x: false);
      }
    }else{
      nonceHex = dataUtils.strip0x(nonce);
    }

    if(gasPrice==BigInt.zero){
      MessageModel rmm=MessageModel.error();
      rmm.data="Gas price error";
      return rmm;
    }
    String gasPriceHex = dataUtils.bigIntToHex(gasPrice,
        need0x: false);
    String gasPrice2Hex = dataUtils.bigIntToHex(gasPrice2,
        need0x: false);
    String amountHex=dataUtils.bigIntToHex(valuePrice,
        need0x: false);
    String chainIdHex = dataUtils.bigIntToHex(BigInt.from(chainId), need0x: false);
    String gasLimitHex = dataUtils.bigIntToHex(BigInt.from(gas*4), need0x: false);
    String messageHex="";
    if(message !=null){
      /*var encodedString = utf8.encode(message);
      var encodedLength = encodedString.length;
      var data = ByteData(encodedLength+4);
      data.setUint32(0, encodedLength,Endian.big);
      var bytes = data.buffer.asUint8List();
      message.codeUnits;*/
      if(Platform.isAndroid){
        messageHex=message;
      }else{
        messageHex= bytesToHex(message.codeUnits);
      }
    }

    //data:image/png;base64,
    String imageData="";
    //"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAhKSURBVHgB7ZxNbBNHFMff2OugoqSNBALCh+qKEKAXiPgSIpGMyqUnoAJuVQLHSnzdCj0Ah0JvEGh7JEnbE1SkXKBSW9VSQAgCSlAlPpIguSolJQLJSiIQsdfT+U+8zu56be+uZx0H8pPA9noZPH+/9+bNvBkzqiD9sWh9anJ+lDE9xlgmSsQ+JM7XyzcZRS03c0qIa0nxDH/ucx4Sr9nAphuP4lRBGAUMREmn5rULQXaKlxCjnsonnmHUrYdT8a3xRIICJBCBbKLEKFikWJt7h7ooAJQKBGEy6ZrDnPgRUmMprmFMuCRnXZPaZLdKq1Ii0EwKY8cQasONwVOkgLIF6mtZE2Nc78wLsjMMhOLEjm7sHfyFysC3QNJq9MgJzukIVTFCqHOhcOpUczyRJB/4EuhWbE00ktL/rDarKQSsaTKc2u4nNoXII3CpSFrvny3iAGHl0Ug60n+3deUu8ognge62rD7MSFjODAdin9QTD/X0bVvtKSS4FuheS9MJosw5muWI3OzsVF9c3u/mJljO2yCOGTF1Obrp5uOSfSopkPRbYZr0FiLytu2bbgzHi91T1MUwWglxOskjNQ3LqK55C4Xr6kgF761aK9tTDSPWcysWjRa/pwDIc/RUxNdoFT3+DS349DP5/NXQQ5oYuE3PLl4gfWKc/NB0/kcpkD4xlm3vjmxPBUgBRJ7UXChPKmhBSAL9iAPrqW/dkXs9X3z79S07fItjWCMI174vn9csWUaqQAog+1oAR4Hutjbt8psh163fIjti5lnnt+QXtGcn2fs7qQR97WtpjDm952xBGX6WfLL0wEHL68mRp/Ty+hXyi1N7qgUCIcY6EVbs1zX7BeQIIrpHyQcN+w/mmX9Nw3La0DtIXrjX2iQfEcdUtGcweOhzGu+/7fgeXC2droHXnDRft1gQRi3OeTv5ALHC/m2XA0ZAle25gRE/bLcii0A16Uyb3znWioNfkUoW7WlXGoxdUp+1ohwWF5PW42N+D9cyj1xAHx+jtBiWwTzhFnbeiFhSCOQ9lbYeg6wVnTOG/ZxAd1pXtYvUMkoeKdSZBwd20uR//8rnDeL9pfut94yIkc0peMNVV5//Ke964vSXlvsX7W2nFYeOW+5B8H5y/AsqE7meLh7lNCTnYiFObeQRdKbx9Pd510c6L+TEka9FUjdpsxh0LlxrzbQRd9Ce3bUQWO1ijl7uygu4sGIVGXe22CCRAskphcfqg/FNO3XGKcu150LIlRbta59+LcRBe+81rrXcB2FhPU7gup51YwNk8XbhfRAzgrUUKKzrMQ//WLqVkzjFOgMLsFvRwux0BOjj4/TiWk/ePRDWbI2W/09cf36523INn8ksvF+ybjYlkFf3QgC2mzc69ljkGfjQtcLMMcWw8+LXHksbyd7fLN823AZtGIkgXLVUkjl6qTvPiuY3rqVyMdxMjll3W1Zx8gH8PXrsjHQXKc7zp9TQfogW75vS+5/zX4tOT3/DuG/l6e+kAOh4sfkZ2i6U1NnBILB4TxuN/txNzy91+Z732UiGtdRHTJZtppZRfYFOw6xhOR93Xs1zO8QjWIIZxAmV4DOIWTmlx8cc3395vce12GYymUizJjcPlFEdg3m/Hh7LfpArMicyY6QAZpEWmGJPJRjvv0N+wCaL0NQuCzU4WQuASHbhZgPQBkF6HSmkmEiVtpxy4ZxFkUmXVcJBMK1t3my5ZuRBdqtBcjiO1cVONauBTswTMVDVF8FCfJ2IQUKgMmIQxMmbRgiBIJJMBvdOZxBy5BKBdORicAIhxVBpqVqQFVIM87XrN5Mmcp3EmWO+RpIZRcxNNQoYTB4x0iE3wfRk3pLlpIpKCB64QOZpAmLSQkXmj3b/2rudgsbz5oV3jZDcTTqHM6JmFriLFQNzMrcVijoxWlY8j+KU1Dix+8xnFaNcXg0/9FQSmoFEMymmGjxBcxTivoYd7GLOQTMB1m3cWkWdLVuvBNBGCJSJs8D32zuDNWR7NaSqYPpAKFKTStDUeYg5bGDvUChb/xmgOezE8Zcc5oWvXRVxKEYVBmvQo5d/cHXvBy2fiNUAtdXbYuD8Bx6lQFrkTZeejvje0eGXtJifFauwmlG0zuwanCTCo5xqZN0sTnMY5I5Z5TLpmXAzLG65rYTOX7WGKoXhXiAnUNbNsBWtYpvEkQNV2zIs9iyaz57lZvNwMzHt6KB3nAznllKtZblD0yaxo+GdzYlgPWkt3WW+ZpnNw4r6Wpo6xOTV9VZ9L7y8doUmfNao7NjLzSqA9dhPBOUtd8CK9FSkLYi1auxvxp9ywU4QbHZwixsxYT0be4dP2q/nCTRlRY37GTHf5eigweappR4KkW5yKE6Zo07XHZdcp84vZKo2YDvt6CjGq6EHJe7IdGzsfeJ4dLPgmnRY009W63IsxHlx3d35GlR5i1kQXEv2tQAFl1zhardia7bL04VVeIDu9dDDvGvGtAWC4HxIsvePUqWhZPaoZsGRu+RKELboF4tH2O5i38U6awqELLO7kGvlbiEX9G1rPMIYq/hkNkg450c33RwueaDOVV0MDXHiSg7qVwPoixtxgKfF1rfBktxajoHn1ejsEU2cQpxtJ5/FXJPvLnUE087cDwuUwFdtfmv8USIcSTVXczI5TaYDRy79/iJM2QUf6XKZ0Nlq/HETMfnc79Wl8tohRYh86STjrK0KhEKs6dC09Dm/P2hiRmnJELFJS6fbZ0gopcIYBFZTxfGq7BGHGAVLHOvpWDJWKYxB4EVnWBUOyygUSxY6gxTFTMWr8vL4NQ+vz25gxx7t+uxO26jlRmMlgTFR9eV/YyMB9hGgVB60KGb+B9+2t6/PwdCOAAAAAElFTkSuQmCC";

    Map<String, String> signMap = {
      "chainId": chainIdHex,
      "gasPrice": gasPriceHex,
      "gasPrice2": gasPrice2Hex,
      "gasLimit": gasLimitHex,
      "toAddress": toAddress,
      'nonce': nonceHex,
      'contract': contractAddress.toLowerCase(),
      'amount': amountHex,
      'msgData':messageHex,
      'erc721Or1155': erc721Or1155,
    };
    if(get1559WithChainSymbol(coinType)){
      signMap["is1559"]='true';
    }else{
      signMap["is1559"]='false';
    }
    String signStr;
    //从keystore中取出助记词
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType, path, signMap,  pk:privateKey??"",);
    }

    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    signStr = "0x" + signStr;
    if(returnSignHash){
      MessageModel rmm=MessageModel();
      rmm.data=signStr;
      return rmm;
    }
    return await tokenViewApi.sendTx(
        BlockchainType.Ethereum.name, coinType, signStr,
        netMode: isTest,rpc: rpc);
  }

  transfer_btc(String coinType, String fromAddress, String toAddress,
      double value, String path,{bool maxValue=true,String isTest="main"}) async {
    MessageModel checkLastModel=await checkLastTx_btc(coinType, fromAddress);
    if(checkLastModel.error){
      return checkLastModel;
    }
    BigInt valuePrice=ethToWeiString(value.toString(), 8);
    //获取平均gasfee
    int averageValue = 0;
    if (coinType.toUpperCase() == CoinType.BTC.name) {
      MessageModel gasFeeMM = await tokenViewApi.getGasFee_btc(isTest: isTest=="main"?false:true);
      if (gasFeeMM.error) {
        return gasFeeMM;
      } else {
        averageValue = gasFeeMM.data;
      }
    } else {
      averageValue = GetCoinGas(coinType.toUpperCase());
    }

    //获取余额
    BigInt balance = BigInt.zero;
    MessageModel mmb =
    await getBalance_btc(coinType.toUpperCase(), fromAddress,isTest: isTest=="main"?false:true);
    if (mmb.error) {
      return mmb;
    } else {
      balance = mmb.data;
    }
    if(balance==BigInt.zero){
      MessageModel mmr =MessageModel.error();
      mmr.data=S.current.g_key_wallet_m5(coinType);
      return mmr;
    }
    bool allValue=false;
    if(balance==valuePrice && maxValue){
      allValue=true;
    }
    List<Map<String, dynamic>> utxos = [];
    String utxoAddress=fromAddress;
    if(coinType.toUpperCase()==CoinType.BCH.name){
      utxoAddress=Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).getAddress(coinType,addrType: "legacy");
    }
    MessageModel mmutxo = await getUTXO(coinType.toUpperCase(), value, utxoAddress,
        utxos, 0, averageValue, 1000, 1,allValue,isTest: isTest=="main"?false:true);
    if (mmutxo.error) {
      return mmutxo;
    } else {
      utxos = mmutxo.data['utxo'];
    }
    int byteSize= await getSignByteSize(coinType,path,utxos,valuePrice,averageValue,fromAddress,toAddress,max: allValue,);
    //(utxos.length * 148 + 78) * averageValue;
    int byteSizeFees=byteSize*averageValue;
    if(allValue){
      //int byteSizeFees = (utxos.length * 148 + 44) * averageValue;
      value=value-toEther(byteSizeFees.toString(),8).toDouble();
    }else{
      if(BigInt.from(byteSizeFees)+valuePrice > balance){
        MessageModel mmr =MessageModel.error();
        mmr.data=S.current.g_key_wallet_m5(coinType);
        return mmr;
      }
    }
    MessageModel rmm=await transfer_btc_send(coinType, fromAddress, toAddress,  valuePrice.toInt(),path, averageValue, byteSizeFees,utxos,max: allValue,isTest:isTest);
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value":value,
      };
    }
    return rmm;
  }
  //btc交易发送,max转账最大值
  transfer_btc_send(
      String coinType,
      String fromAddress,
      String toAddress,
      int valuePrice,
      String path,
      int gas,
      int totalGasPrice,
      List<Map<String, dynamic>> utxos,
      {bool max=false,String contractAddress = "",String isTest="main",String? privateKey})async{
    //签名
    Map<String, dynamic> btcTxMap = {
      "toAddress": toAddress,
      "amount": valuePrice,
      "byteFee": gas,
      "changeAddress": fromAddress,
      "fees":totalGasPrice,
      "utxo": utxos,
      "max":max,
    };
    String signStr;
    if(privateKey ==null || privateKey==""){
      signStr = await trustdart.signTransaction(
        coinType.toUpperCase(),
        path,
        btcTxMap,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType.toUpperCase(), path, btcTxMap,  pk:privateKey??"",);
    }
    if (signStr == "") {
      MessageModel rmm = MessageModel.error();
      rmm.data = S.current.g_key_wallet_m6;
      return rmm;
    }
    //发送交易
    return await tokenViewApi.sendTx(
        BlockchainType.Bitcoin.name, coinType.toUpperCase(), signStr,netMode: isTest);
  }
  getUTXO(
      String coinType,
      double value,
      String address,
      List<Map<String, dynamic>> utxos,
      int input2Price,
      int gasFee,
      int pageSize,
      int pageNum,
      bool allValue,
  {
    bool isTest=false,
  }
      ) async {
    MessageModel mm = await tokenViewApi.getUTXO_btc(
        coinType.toUpperCase(), address,
        pageSize: pageSize, pageNum: pageNum,isTest:isTest);
    if (mm.error) {
      return mm;
    } else {
      bool lastPage = false;
      List<dynamic> unspents = mm.data;
      if (unspents.length < (pageSize * pageNum)) {
        //是最后一页
        lastPage = true;
      }
      /*if (unspents.length >= 2) {
        unspents.sort((a, b) {
          Map<String, dynamic> am = a;
          Map<String, dynamic> bm = b;
          double aValue = double.parse(am['value']);
          double bValue = double.parse(bm['value']);
          if (aValue < bValue) {
            return 1;
          } else {
            return -1;
          }
        });
      }*/
      MessageModel mmutxoC =
      await calculateGasFee(value, unspents, utxos, input2Price, gasFee,isTest: isTest);
      if (mmutxoC.error) {
        if (lastPage) {
          if(allValue==false){
            mmutxoC.data = S.current.g_key_wallet_m5(coinType);
          }
          return mmutxoC;
        } else {
          return await getUTXO(coinType, value, address, mmutxoC.data['utxo'],
              mmutxoC.data['inputPrice'], gasFee, pageSize, pageNum + 1,allValue,isTest: isTest);
        }
      } else {
        return mmutxoC;
      }
    }
  }

  calculateGasFee(double value, List<dynamic> unspents,
      List<Map<String, dynamic>> utxos, int input2Price, int gasFee,{bool isTest=false}) async {
    int valuePrice = ethToWeiString(value.toString(), 8).toInt();
    //List<Map<String,dynamic>> utxos=[];//输出账单
    //int input2Price=0;//实际输入金额
    bool ok = false; //是否满足条件默认false；
    for (Map<String, dynamic> unspent in unspents) {
      if(isTest){
        if(unspent['hex']==null){
          MessageModel utxoTx = await BtcApi(test: true).getUTXOTxid(unspent['txid']);
          if (utxoTx.error == false) {
            unspent['hex'] = utxoTx.data['vout']?[unspent['vout']]?['scriptpubkey'];
          }
        }
        int amount=unspent['value'];
        input2Price+=amount.toInt();
        utxos.add({
          "txid":unspent['txid'],
          "vout":unspent['vout'],
          "value": amount.toString(),
          "script": unspent['hex'],
        });
      }else{
        BigInt amount=ethToWeiString(double.parse(unspent['value']).toString(),8) ;
        input2Price+=amount.toInt();
        utxos.add({
          "txid": unspent['txid'],
          "vout": unspent['output_no'], //
          "value": amount.toString(),
          "script": unspent['hex'], //unspent['script]
        });
      }
      int byteSizeFees = (utxos.length * 148 + 78) *
          gasFee; //计算公式  inputNum*148 + outputNum *34 +10 (+/-)40

      if (byteSizeFees + valuePrice <= input2Price) {
        //如果 当前input gas费+转账金额+output gas费 == 账单金额; 退出循环，返回 outputByteSizeFess +inputByteSizeFees
        ok = true;
        break;
      }
    }
    MessageModel rmm = MessageModel();
    if (ok = false) {
      rmm.error = true;
    }
    rmm.data = {
      "utxo": utxos,
      "inputPrice": input2Price,
    };
    return rmm;
  }
  //Btc 计算 打包 字段数
  getSignByteSize(
      String coinType,
      String path,
      List<Map<String,dynamic>> utxos,
      BigInt price,//转账金额
      int byteFee,//转账需要的旷工费
      String address,//当前钱包地址
      String toAddress,//转账地址
          {bool max=false,//是否全部转出
        String? privateKey,//是否是导入钱包
      })async{
    Map<String,dynamic> btcTxMap={
      "utxo":utxos,
      "toAddress":toAddress,//toTextEditingController.text,
      "amount":price,
      "byteFee":byteFee,
      "changeAddress":address,
      "max":max,
    };
    String signByteSize=await transactionMaxValue(
      BlockchainType.Bitcoin.name,
      coinType,
      btcTxMap,
      path,
      privateKey: privateKey,
    );
    if(signByteSize == ""){
      return 0;
    }else{
      return int.parse(signByteSize);
    }
  }

  //Algorand转账
  transfer_algo( String fromAddress,
      String toAddress, double value, int decimals, String path,{bool maxValue=true}) async {
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas("ALGO", contract: false);
    //获取余额
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain = await getBalance_algo(fromAddress);
    if (mmchain.error == true) {
      return mmchain;
    } else {
      chainBalance = mmchain.data;
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("ALGO");
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Algorand.name, "ALGO",
        isTest: false);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice =BigInt.from(mmg.data['min-fee']);
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice =  ethToWeiString(value.toString(), decimals);
    if(valuePrice==chainBalance && maxValue){
      valuePrice=valuePrice-totalGasPrice;
      value=toEther(valuePrice.toString(),decimals).toDouble();
    }
    if (totalGasPrice + valuePrice > chainBalance) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("ALGO");
      return mme;
    }
    MessageModel rmm=await transfer_algo_send(
      fromAddress, toAddress,
      valuePrice.toString(), path,
    );
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value": value,
      };
    }
    return rmm;
  }
  transfer_algo_send(String fromAddress, String toAddress,
      String value, String path,{String contractAddress="",String isTest="main",String? privateKey,String type="ALGO"})async{
    Map<String,dynamic> txData={
      "type":type,
      "toAddress":toAddress,
      "amount":value,
      "assetId":contractAddress,
    };
    AlgoApi algoApi=AlgoApi();
    MessageModel mminfo=await algoApi.getTransactionsParams(isTest: isTest=="main"?false:true);
    if(mminfo.error){
      return mminfo;
    }else{
      txData['fee']=mminfo.data['min-fee'];
      txData['genesisId']=mminfo.data['genesis-id'];
      txData['genesisHash']=mminfo.data['genesis-hash'];
      txData['round']=mminfo.data['last-round'];
    }

    Map<dynamic,dynamic> rValue;
    if(privateKey !=null){
      rValue = await trustdart.signTransaction_byteArray(
        CoinType.ALGO.name,
        path,
        txData,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      rValue = await trustdart.signTransaction_byteArray(CoinType.ALGO.name, path, txData,  pk:privateKey!,);
    }
    Uint8List signStr;
    if(rValue['result']==true){
      signStr=hexToBytes(rValue['signHash']);
    }else{
      MessageModel rmm = MessageModel.error();
      rmm.data = S.current.g_key_wallet_m6;
      return rmm;
    }
    return await tokenViewApi.sendTx(BlockchainType.Algorand.name,"ALGO" , signStr,netMode: isTest);
  }

  //Tezos转账
  transfer_xtz( String fromAddress,
      String toAddress, double value, int decimals, String path,{bool maxValue=true}) async {
    //获取每个byte 消耗多少gas
    int gas = GetCoinGas("XTZ", contract: false);
    //获取余额
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain = await getBalance_xtz(fromAddress);
    if (mmchain.error == true) {
      return mmchain;
    } else {
      chainBalance = mmchain.data;
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("XTZ");
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Algorand.name, "XTZ",
        isTest: false);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice=mmg.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice =  ethToWeiString(value.toString(), decimals);
    if(valuePrice==chainBalance && maxValue){
      valuePrice=valuePrice-totalGasPrice;
      value=toEther(valuePrice.toString(),decimals).toDouble();
    }
    if (totalGasPrice + valuePrice > chainBalance) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("XTZ");
      return mme;
    }
    MessageModel rmm=await transfer_xtz_send(
      fromAddress, toAddress,
      valuePrice.toInt(), path,
    );
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value": value,
      };
    }
    return rmm;
  }
  transfer_xtz_send(String fromAddress, String toAddress,
      int value, String path,{bool isTest=false,String? privateKey})async{
    Map<String,dynamic> signMap={
      "amount":value,
      "toAddress":toAddress,
      "fee":500,
      "counter":10,
      "gasLimit":1101,
      "storageLimit":257,
      "reveal":true,//是否揭露
    };
    XtzApi xtzApi=XtzApi();
    MessageModel mmCounter=await xtzApi.getCounter_xtz(fromAddress,isTest);
    if(mmCounter.error){
      return mmCounter;
    }else{
      signMap['counter']=int.parse(mmCounter.data.toString())+1;
    }
    MessageModel mmBranch=await xtzApi.getBranch_xgz(isTest);
    if(mmBranch.error){
      return mmBranch;
    }else{
      signMap['branch']=mmBranch.data.toString();
    }

    MessageModel mmReveal=await xtzApi.getBalance_xtz(fromAddress,"","revealed",isTest);
    if(mmReveal.error){
      return mmReveal;
    }else{
      signMap['reveal']=mmReveal.data;
    }
    WalletInfo wi = Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo;
    String signStr=await trustdart.signTransaction(
      CoinType.XTZ.name,
      path,
      signMap,
      mnemonic: wi.mnemonic??"",
      pk: wi.privateKey??"",
    );
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return;
    }
    return await xtzApi.sendTx_xtz(signStr,isTest);
  }
  //Ripple转账
  transfer_xrp( String fromAddress,
      String toAddress, double value, int decimals, String path,{bool maxValue=true}) async {
    //目标地址 是否创建了账号
    bool isCreate=false;
    XrpApi xrpApi=XrpApi();
    MessageModel mm=await xrpApi.getAccountInfo_xrp(toAddress, false);
    if(mm.error){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_t_45(toAddress);
      return rmm;
    }else{
      if(mm.data['validated']){
        isCreate=true;
      }
    }
    if(isCreate==false){
      if(value<10){
        MessageModel rmm=MessageModel.error();
        rmm.data=S.current.g_key_t_54;
        return rmm;
      }
    }

    //获取每个byte 消耗多少gas
    int gas = GetCoinGas("XRP", contract: false);
    //获取余额
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain = await getBalance_xtz(fromAddress);
    if (mmchain.error == true) {
      return mmchain;
    } else {
      chainBalance = mmchain.data;
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("XRP");
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Algorand.name, "XRP",
        isTest: false);
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice=mmg.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice =  ethToWeiString(value.toString(), decimals);
    if(valuePrice==chainBalance && maxValue){
      valuePrice=valuePrice-totalGasPrice;
      value=toEther(valuePrice.toString(),decimals).toDouble();
    }
    if (totalGasPrice + valuePrice > chainBalance) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("XRP");
      return mme;
    }
    MessageModel rmm=await transfer_xrp_send(
      fromAddress, toAddress,
      valuePrice,
      totalGasPrice,
      path,
      0,
    );
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value": value,
      };
    }
    return rmm;
  }
  transfer_xrp_send(String fromAddress, String toAddress,
      BigInt value,BigInt totalGasPrice, String path,int sequence,{bool isTest=false,String? privateKey})async{
    Map<String,dynamic> signMap={
      "amount":value.toString(),
      "toAddress":toAddress,
      "sequence":sequence,
      "ledgerIndex":0,
      "fee":totalGasPrice.toString(),
      "txType":"XRP",
      "issuer":"",
      "currency":""
    };
    XrpApi xrpApi=XrpApi();
    if(sequence==0){
      MessageModel mmSequence=await xrpApi.getAccountInfo_xrp(fromAddress,isTest);
      if(mmSequence.error){
        return mmSequence;
      }else{
        signMap['sequence']=mmSequence.data['sequence'];
      }
    }
    MessageModel mmLedgerIndex=await xrpApi.getLedger_xrp(isTest: isTest);
    if(mmLedgerIndex.error){
      return mmLedgerIndex;
    }else{
      signMap['ledgerIndex']=mmLedgerIndex.data;
    }
    WalletInfo wi = Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo;
    String signStr=await trustdart.signTransaction(CoinType.XRP.name, path, signMap,mnemonic: wi.mnemonic??"",pk: wi.privateKey??"",);

    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return;
    }
    return await xrpApi.sendTx_xrp(signStr,isTest);
  }

  transfer_fil_send(
      String fromAddress,
      String toAddress,
      BigInt value,
      BigInt totalGasPrice,
      String path,
      String nonce,
      String gasLimit,
      String gasFeeCap,
      String gasPremium,{bool isTest=false,String? privateKey})async{
    Map<String,dynamic> signMap={
      "amount":dataUtils.bigIntToHex(value, need0x: false),//value.toString(),
      "toAddress":toAddress,
      "nonce":nonce,
      "gasLimit":gasLimit,
      "gasFeeCap":dataUtils.bigIntToHex(BigInt.parse(gasFeeCap),need0x:false),//gasFeeCap,
      "gasPremium":dataUtils.bigIntToHex(BigInt.parse(gasPremium),need0x:false),//gasPremium
    };
    String signStr;
    //从keystore中取出助记词
    if(privateKey ==null){
      signStr = await trustdart.signTransaction(
        CoinType.FIL.name,
        path,
        signMap,
        mnemonic: Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(CoinType.FIL.name, path, signMap, pk:privateKey??"",);
    }

    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    //signStr = "0x" + signStr;
    FilApi filApi=FilApi();
    return await filApi.sendTx(signStr,isTest:isTest);
  }
/*
  ///获取币的余额
  ///returnDoubleValue 返回double类型，默认false 返回BigInt
  getBalance(String chainSymbol,
      {String contractAddress = "",
        String address = "",
        bool returnDoubleValue = false}) async {
    WalletActionProvider wap = Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false);
    if(chainSymbol == "BSC"){
      chainSymbol = "BNB";
    }
    if(chainSymbol == "AVAXC"){
      chainSymbol = "AVAX";
    }
    if(chainSymbol == "OPTIMISM"){
      chainSymbol = "OP";
    }
    Map<String, dynamic>? txChainMap =
    wap.walletMap[chainSymbol.toString().toUpperCase()];
    if (txChainMap == null) {
      MessageModel mm = MessageModel.error();
      mm.data = S.current.g_key_wallet_m1(chainSymbol);
      return mm;
    }
    Map<String, dynamic>? token = null;
    if (contractAddress != "") {
      if (txChainMap['mainnets'].length != 0) {
        token = txChainMap['mainnets'][contractAddress.toUpperCase()];
      }
      if (token == null) {
        MessageModel mm = MessageModel.error();
        mm.data = S.current.g_key_wallet_m2;
        return mm;
      }
    }

    if (address == "") {
      String? addr = wap.getAddress(txChainMap['baseInfo']['coinType'],
          addrType: txChainMap['addrType']);
      if (addr == null) {
        MessageModel mm = MessageModel.error();
        mm.data = S.current.g_key_wallet_m3(txChainMap['baseInfo']['coinType']);
        return mm;
      } else {
        address = addr;
      }
    }
    String blockchain = txChainMap['baseInfo']['blockchainType'];
    MessageModel rmm = MessageModel();
    switch (blockchain) {
      case "Bitcoin":
        rmm = await getBalance_btc(chainSymbol, address);
        break;
      case "Ethereum":
        rmm = await getBalance_eth(chainSymbol, address,
            contractAddress: contractAddress);
        break;
      case "Solana":
        rmm = await getBalance_sol(address, contractAddress: contractAddress);
        break;
      case "Tron":
        rmm = await getBalance_trx(address, contractAddress: contractAddress);
        break;
      case "Algorand":
        rmm= await getBalance_algo(address);
        break;
      case "Tezos":
        rmm=await getBalance_xtz(address);
        break;
      case "Ripple":
        rmm=await getBalance_xrp(address);
        break;
    }
    if (returnDoubleValue) {
      if (rmm.error == false) {
        if (contractAddress == "") {
          rmm.data =
              toEther(rmm.data.toString(), txChainMap['baseInfo']['decimals']);
        } else {
          rmm.data = toEther(rmm.data.toString(), token!['decimals']);
        }
      }
    }
    return rmm;
  }
*/
  //获取余额 tron
  getBalance_trx(String fromAddress,
      {String contractAddress = ""}) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Tron.name, CoinType.TRX.name, fromAddress,
        isTest: false);
    //获取余额
    BigInt balance = BigInt.zero;
    if (mm.error == true) {
      return mm;
    } else {
      if (contractAddress != "") {
        List<dynamic> trc20 = mm.data['trc20'];
        for (Map owner in trc20) {
          List<dynamic> keys=owner.keys.toList();
          for(int i=0;i<keys.length;i++){
            if(contractAddress.toUpperCase()==keys[i].toString().toUpperCase()){
              String? cBalance = owner[keys[i]];
              if (cBalance != null) {
                balance = BigInt.parse(cBalance);
                break;
              }
            }
          }
        }
      } else {
        if (mm.data != null) {
          balance = BigInt.from(mm.data['balance']);
        }
      }
    }
    MessageModel rmm = MessageModel();
    rmm.data = balance;
    return rmm;
  }

  getBalanceAll_trx(String fromAddress,
      {String contractAddress = ""}) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Tron.name, CoinType.TRX.name, fromAddress,contract: contractAddress,
        isTest: false);
    return mm;
  }

  //获取余额 solana
  getBalance_sol(String fromAddress,
      {String contractAddress = ""}) async {
    MessageModel rData= await tokenViewApi.getBalance(BlockchainType.Solana.name, "", fromAddress,contract: contractAddress);
    /*if(contractAddress !=""){
      BigInt balance=BigInt.zero;
      if(rData.data.length !=0){
        balance=BigInt.from(rData.data[0]['account']['data']['parsed']['info']['tokenAmount']['uiAmount']);
      }
      rData.data=balance;
    }*/
    return rData;
  }
  /*static getBalance_sol(Map<String, dynamic> chainMap,String fromAddress,
      {String contractAddress = ""}) async {
    BigInt balance=BigInt.zero;
    if(contractAddress==""){
      balance= BigInt.parse(chainMap['baseInfo']['balance']);
    }else{
      Map<String,dynamic> token=chainMap['mainnets'][contractAddress.toUpperCase()];
      balance= BigInt.parse(token['balance']);
    }
    MessageModel rmm = MessageModel();
    rmm.data = balance;
    return rmm;
  }*/

  //获取余额 eth
  getBalance_eth(String coinType, String fromAddress,
      {String contractAddress = "",bool isTest=false}) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Ethereum.name, coinType, fromAddress,contract:contractAddress,
        isTest: isTest);
    return mm;
  }

  getBalance_btc(String coinType, String fromAddress,{bool isTest=false}) async {
    if(coinType==CoinType.BCH.name){
      fromAddress=Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).getAddress(coinType,addrType: 'legacy');
    }
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Bitcoin.name, coinType, fromAddress,
        isTest: isTest);
    return mm;
  }
  getBalance_algo(String fromAddress) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Algorand.name, "ALGO", fromAddress,
        isTest: false);
    return mm;
  }
  getBalance_xtz(String fromAddress) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Tezos.name, "XTZ", fromAddress,
        isTest: false);
    return mm;
  }
  getBalance_xrp(String fromAddress) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Ripple.name, "XRP", fromAddress,
        isTest: false);
    return mm;
  }

  //根据最后一笔交易，判断此次交易是否可以进行交易，当确认数小于6时，交易不能进行
  checkLastTx_btc(String coinType, String fromAddress)async{
    MessageModel txModel=await getTxList_btc(coinType, fromAddress,pageNum: 1,pageSize: 1);
    if(txModel.error){
      return txModel;
    }else{
      if(txModel.data.length >= 1){
        Map<String,dynamic> btcData=txModel.data[0];
        if(btcData['txCount']==0){
          txModel.data=true;
        }else{
          if(btcData['txs'].length >=1){
            if(double.parse(btcData['txs'][0]['confirmations'].toString())>=6){
              txModel.data=true;
            }else{
              txModel.error=true;
              txModel.data=S.current.g_key_wallet_m19(coinType);
            }
          }else{
            txModel.error=true;
            txModel.data="error";
          }
        }
      }else{
        txModel.error=false;
        txModel.data=true;
      }
      return txModel;
    }
  }
  //获取交易记录列表
  //btc 比特币类
  getTxList_btc(String coinType, String fromAddress,{int pageNum=1,int pageSize=20})async{
    if(coinType==CoinType.BCH.name){
      fromAddress=Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).getAddress(coinType,addrType: 'legacy');
    }
    return await tokenViewApi.getTxList_btc( coinType, fromAddress,pageNum: 1,pageSize: 1);
  }
  //获取地址列表
  getAddressList(List<dynamic> chainMap) async {
    WalletInfo wi = Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletInfo;

    List<Map<String, dynamic>> addrssList = [];

    for (Map<String, dynamic> chain in chainMap) {
      Map<String,dynamic>? coinMap=wi.coinInfo![chain['coin_name'].toString().toUpperCase()];
      String path = "";
      String addrType = "legacy";
      if(coinMap==null){
        List<dynamic>? derivation = json.decode(chain['derivation']);
        if (derivation == null) continue;
        String bct = chain['class_name'].toString().toUpperCase();
        if (bct == BlockchainType.Ethereum.name.toUpperCase()) {
          path = derivation[0]['path'];
        } else if (bct == BlockchainType.Tron.name.toUpperCase()) {
          path = derivation[0]['path'];
        } else if (bct == BlockchainType.Solana.name.toUpperCase()) {
          String? pName = derivation[0]['name'];
          if (pName == null) {
            path = derivation[0]['path'];
          }
        } else {
          Map<String, dynamic> paths = {};
          for (Map<dynamic, dynamic> p in derivation) {
            String pPath = p['path'];
            /*if (chain['coin_name'].toString().toUpperCase() == "BCH") {
              //paths["segwit"] = pPath;
              paths["legacy"] = pPath;
            } else {*/
            int pIndex = pPath.indexOf("44");
            if (pIndex >= 0) {
              paths['legacy'] = pPath;
            } else {
              pIndex = pPath.indexOf("84");
              if (pIndex >= 0) {
                paths['segwit'] = pPath;
              }
            }
            //}
          }
          String? pathLegacy = paths['segwit'];
          if (pathLegacy == null) {
            path = paths['legacy'];
            addrType = "legacy";
          } else {
            path = pathLegacy;
            addrType = "segwit";
          }
        }
      }else{
        addrType=coinMap['addrType'];
        int pathIndex=coinMap["pathIndex"] ?? 0;
        path=coinMap['baseInfo']['path'][addrType];
        path=getPathWithIndex(path, pathIndex);
      }
      Map<Object?, Object?> addrssMap = await trustdart.generateAddress(
        chain['coin_name'].toString().toUpperCase(),
        path,
        addrType,
        mnemonic: wi.mnemonic??"",
        pk:wi.privateKey??"",
      );
      addrssList.add({
        "chain": chain['coin_name'].toString().toUpperCase(),
        "chain_path_name": addrType,
        "address": addressDealWith(addrssMap[addrType].toString(), chain['coin_name'].toString().toUpperCase()),
      });
    }
    return json.encode(addrssList);
  }
}
