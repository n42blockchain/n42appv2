part of '../transfer_api.dart';

/// Bitcoin family chain transfer methods.
///
/// Contains: transferBtc, transferBtcSend, getUTXO, calculateGasFee,
/// getSignByteSize, getBalanceBtc, checkLastTxBtc, getTxListBtc
mixin _TransferBtcMixin on _TransferBaseMixin {
  Future<MessageModel> transferBtc(String coinType, String fromAddress, String toAddress,
      double value, String path,{bool maxValue=true,String isTest="main"}) async {
    MessageModel checkLastModel=await checkLastTxBtc(coinType, fromAddress);
    if(checkLastModel.error){
      return checkLastModel;
    }
    BigInt valuePrice=ethToWeiString(value.toString(), 8);
    //获取平均gasfee
    int averageValue = 0;
    if (coinType.toUpperCase() == CoinType.BTC.name) {
      MessageModel gasFeeMM = await tokenViewApi.getGasFeeBtc(isTest: isTest=="main"?false:true);
      if (gasFeeMM.error) {
        return gasFeeMM;
      } else {
        averageValue = gasFeeMM.data;
      }
    } else {
      averageValue = getCoinGas(coinType.toUpperCase());
    }

    //获取余额
    BigInt balance = BigInt.zero;
    MessageModel mmb =
    await getBalanceBtc(coinType.toUpperCase(), fromAddress,isTest: isTest=="main"?false:true);
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
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      utxoAddress=globalWapAdapter.getAddress(coinType,addrType: "legacy");
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
    MessageModel rmm=await transferBtcSend(coinType, fromAddress, toAddress,  valuePrice.toInt(),path, averageValue, byteSizeFees,utxos,max: allValue,isTest:isTest);
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value":value,
      };
    }
    return rmm;
  }
  //btc交易发送,max转账最大值
  Future<MessageModel> transferBtcSend(
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
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        coinType.toUpperCase(),
        path,
        btcTxMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType.toUpperCase(), path, btcTxMap,  pk:privateKey,);
    }
    if (signStr == "") {
      MessageModel rmm = MessageModel.error();
      rmm.data = S.current.g_key_wallet_m6;
      return rmm;
    }
    // Validate signature before broadcast
    final validationError = validateSignature(signStr, coinType.toUpperCase());
    if (validationError != null) return validationError;
    //发送交易
    return await tokenViewApi.sendTx(
        BlockchainType.Bitcoin.name, coinType.toUpperCase(), signStr,netMode: isTest) ?? MessageModel.error();
  }
  Future<MessageModel> getUTXO(
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
    MessageModel mm = await tokenViewApi.getUTXOBtc(
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

  Future<MessageModel> calculateGasFee(double value, List<dynamic> unspents,
      List<Map<String, dynamic>> utxos, int input2Price, int gasFee,{bool isTest=false}) async {
    int valuePrice = ethToWeiString(value.toString(), 8).toInt();
    //List<Map<String,dynamic>> utxos=[];//输出账单
    //int input2Price=0;//实际输入金额
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
        break;
      }
    }
    MessageModel rmm = MessageModel();
    rmm.data = {
      "utxo": utxos,
      "inputPrice": input2Price,
    };
    return rmm;
  }
  //Btc 计算 打包 字段数
  Future<int> getSignByteSize(
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

  Future<MessageModel> getBalanceBtc(String coinType, String fromAddress,{bool isTest=false}) async {
    if(coinType==CoinType.BCH.name){
      fromAddress=globalWapAdapter.getAddress(coinType,addrType: 'legacy');
    }
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Bitcoin.name, coinType, fromAddress,
        isTest: isTest) ?? MessageModel.error();
    return mm;
  }

  //根据最后一笔交易，判断此次交易是否可以进行交易，当确认数小于6时，交易不能进行
  Future<MessageModel> checkLastTxBtc(String coinType, String fromAddress)async{
    MessageModel txModel=await getTxListBtc(coinType, fromAddress,pageNum: 1,pageSize: 1);
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
  Future<MessageModel> getTxListBtc(String coinType, String fromAddress,{int pageNum=1,int pageSize=20})async{
    if(coinType==CoinType.BCH.name){
      fromAddress=globalWapAdapter.getAddress(coinType,addrType: 'legacy');
    }
    return await tokenViewApi.getTxListBtc( coinType, fromAddress,pageNum: 1,pageSize: 1);
  }
}
