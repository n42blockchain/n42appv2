part of '../transfer_api.dart';

/// Other chain transfer methods: ALGO, XTZ, XRP, FIL, ZIL.
///
/// Contains: transferAlgo, transferAlgoSend, transferXtz, transferXtzSend,
/// transferXrp, transferXrpSend, transferFilSend, transferZilSend,
/// getBalanceAlgo, getBalanceXtz, getBalanceXrp
mixin _TransferOthersMixin on _TransferBaseMixin {
  //Algorand转账
  Future<MessageModel> transferAlgo( String fromAddress,
      String toAddress, double value, int decimals, String path,{bool maxValue=true}) async {
    //获取每个byte 消耗多少gas
    int gas = getCoinGas("ALGO", contract: false);
    //获取余额
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain = await getBalanceAlgo(fromAddress);
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
        isTest: false) ?? MessageModel.error();
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
    MessageModel rmm=await transferAlgoSend(
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
  Future<MessageModel> transferAlgoSend(String fromAddress, String toAddress,
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
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      rValue = await trustdart.signTransactionByteArray(
        CoinType.ALGO.name,
        path,
        txData,
        mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
      );
    }else{
      rValue = await trustdart.signTransactionByteArray(CoinType.ALGO.name, path, txData,  pk:privateKey!,);
    }
    Uint8List signStr;
    if(rValue['result']==true){
      signStr=hexToBytes(rValue['signHash']);
    }else{
      MessageModel rmm = MessageModel.error();
      rmm.data = S.current.g_key_wallet_m6;
      return rmm;
    }
    return await tokenViewApi.sendTx(BlockchainType.Algorand.name,"ALGO" , signStr,netMode: isTest) ?? MessageModel.error();
  }

  //Tezos转账
  Future<MessageModel> transferXtz( String fromAddress,
      String toAddress, double value, int decimals, String path,{bool maxValue=true}) async {
    //获取每个byte 消耗多少gas
    int gas = getCoinGas("XTZ", contract: false);
    //获取余额
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain = await getBalanceXtz(fromAddress);
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
        isTest: false) ?? MessageModel.error();
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
    MessageModel rmm=await transferXtzSend(
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
  Future<MessageModel> transferXtzSend(String fromAddress, String toAddress,
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
    MessageModel mmCounter=await xtzApi.getCounterXtz(fromAddress,isTest);
    if(mmCounter.error){
      return mmCounter;
    }else{
      signMap['counter']=int.parse(mmCounter.data.toString())+1;
    }
    MessageModel mmBranch=await xtzApi.getBranchXgz(isTest);
    if(mmBranch.error){
      return mmBranch;
    }else{
      signMap['branch']=mmBranch.data.toString();
    }

    MessageModel mmReveal=await xtzApi.getBalanceXtz(fromAddress,"","revealed",isTest);
    if(mmReveal.error){
      return mmReveal;
    }else{
      signMap['reveal']=mmReveal.data;
    }
    if (!AppGlobals.appContext.mounted) {
      return MessageModel.error()..data = 'Context is no longer valid';
    }
    WalletInfo wi = globalWapAdapter.walletInfo;
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
      return rmm;
    }
    // Validate signature before broadcast
    final xtzValidationError = validateSignature(signStr, CoinType.XTZ.name);
    if (xtzValidationError != null) return xtzValidationError;
    return await xtzApi.sendTxXtz(signStr,isTest);
  }
  //Ripple转账
  Future<MessageModel> transferXrp( String fromAddress,
      String toAddress, double value, int decimals, String path,{bool maxValue=true}) async {
    //目标地址 是否创建了账号
    bool isCreate=false;
    XrpApi xrpApi=XrpApi();
    MessageModel mm=await xrpApi.getAccountInfoXrp(toAddress, false);
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
    int gas = getCoinGas("XRP", contract: false);
    //获取余额
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain = await getBalanceXtz(fromAddress);
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
        isTest: false) ?? MessageModel.error();
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
    MessageModel rmm=await transferXrpSend(
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
  Future<MessageModel> transferXrpSend(String fromAddress, String toAddress,
      BigInt value,BigInt totalGasPrice, String path,int sequence,{bool isTest=false,String? privateKey,int? destinationTag})async{
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
    if (destinationTag != null) {
      signMap['destinationTag'] = destinationTag;
    }
    XrpApi xrpApi=XrpApi();
    if(sequence==0){
      MessageModel mmSequence=await xrpApi.getAccountInfoXrp(fromAddress,isTest);
      if(mmSequence.error){
        return mmSequence;
      }else{
        signMap['sequence']=mmSequence.data['sequence'];
      }
    }
    MessageModel mmLedgerIndex=await xrpApi.getLedgerXrp(isTest: isTest);
    if(mmLedgerIndex.error){
      return mmLedgerIndex;
    }else{
      signMap['ledgerIndex']=mmLedgerIndex.data;
    }
    if (!AppGlobals.appContext.mounted) {
      return MessageModel.error()..data = 'Context is no longer valid';
    }
    WalletInfo wi = globalWapAdapter.walletInfo;
    String signStr=await trustdart.signTransaction(CoinType.XRP.name, path, signMap,mnemonic: wi.mnemonic??"",pk: wi.privateKey??"",);

    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    // Validate signature before broadcast
    final xrpValidationError = validateSignature(signStr, CoinType.XRP.name);
    if (xrpValidationError != null) return xrpValidationError;
    return await xrpApi.sendTxXrp(signStr,isTest);
  }

  Future<MessageModel> transferFilSend(
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
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        CoinType.FIL.name,
        path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(CoinType.FIL.name, path, signMap, pk:privateKey,);
    }

    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    // Validate signature before broadcast
    final filValidationError = validateSignature(signStr, CoinType.FIL.name);
    if (filValidationError != null) return filValidationError;
    //signStr = "0x$signStr";
    FilApi filApi=FilApi();
    return await filApi.sendTx(signStr,isTest:isTest);
  }

  Future<MessageModel> getBalanceAlgo(String fromAddress) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Algorand.name, "ALGO", fromAddress,
        isTest: false) ?? MessageModel.error();
    return mm;
  }
  Future<MessageModel> getBalanceXtz(String fromAddress) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Tezos.name, "XTZ", fromAddress,
        isTest: false) ?? MessageModel.error();
    return mm;
  }
  Future<MessageModel> getBalanceXrp(String fromAddress) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Ripple.name, "XRP", fromAddress,
        isTest: false) ?? MessageModel.error();
    return mm;
  }

  // Zilliqa 转账
  Future<MessageModel> transferZilSend(String fromAddress, String toAddress, BigInt valuePrice, String path, int gas, BigInt gasPrice, String coinType,
      {String contractAddress = "", String isTest = "main", String? privateKey}) async {
    ZilApi zilApi = ZilApi(isTest: isTest == "main" ? false : true);

    // 获取网络 ID
    MessageModel networkIdMM = await zilApi.getNetworkId();
    if (networkIdMM.error) {
      return networkIdMM;
    }

    // 获取最新区块信息以获取版本号
    MessageModel latestBlockMM = await zilApi.getLatestTxBlock();
    if (latestBlockMM.error) {
      return latestBlockMM;
    }
    int version = latestBlockMM.data['header']['Version'];

    // 获取账户余额以获取 nonce
    MessageModel balanceMM = await zilApi.getBalance(fromAddress,nonce: true);
    if (balanceMM.error) {
      // 账户未找到，nonce 为 0
      if (balanceMM.data.toString().contains('not found') || balanceMM.data.toString().contains('-5')) {
        // nonce = 0，继续执行
      } else {
        return balanceMM;
      }
    }

    // 构建签名数据
    Map<String, dynamic> signMap = {
      "version": version,
      "nonce": balanceMM.data['nonce']+1, // 需要从账户信息中获取，这里简化处理
      "toAddress": toAddress,
      "amount": valuePrice.toString(),
      "gasPrice": gasPrice.toString(),
      "gasLimit": gas.toString(),
      "code": "",
      "data": "",
    };

    // 签名交易
    String signStr;
    if (privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? "",
      );
    } else {
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk: privateKey);
    }

    if (signStr == "") {
      MessageModel rmm = MessageModel.error();
      rmm.data = S.current.g_key_wallet_m6;
      return rmm;
    }

    // 解析签名结果并构建交易参数
    Map<String, dynamic> signedData = json.decode(signStr);
    Map<String, dynamic> txParams = {
      "version": signedData['version'],
      "nonce": signedData['nonce'],
      "toAddr": signedData['toAddr'],
      "amount": signedData['amount'],
      "pubKey": signedData['pubKey'],
      "gasPrice": signedData['gasPrice'],
      "gasLimit": signedData['gasLimit'],
      "code": signedData['code'] ?? "",
      "data": signedData['data'] ?? "",
      "signature": signedData['signature'],
    };

    // 发送交易
    MessageModel mmtx = await zilApi.createTransaction(txParams);
    return mmtx;
  }
}
