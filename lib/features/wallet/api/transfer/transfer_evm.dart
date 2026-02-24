part of '../transfer_api.dart';

/// EVM/Ethereum chain transfer methods.
///
/// Contains: transferEth721, transferEth, transferEthSend, getBalanceEth
mixin _TransferEvmMixin on _TransferBaseMixin {
  //erc721Or1155 721、1155
  Future<MessageModel> transferEth721({
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
    coinType ??= CoinType.ETH.name;
    WalletActionProvider wap = globalWapAdapter;
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
    getCoinGas(coinType, contract: true);
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain =
    await getBalanceEth(coinType, fromAddress, contractAddress: "",isTest: isTest);
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
        isTest: isTest) ?? MessageModel.error();
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
    MessageModel mmn = await tokenViewApi.getTransactionCountEth(
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
    signStr = "0x$signStr";
    // Validate signature before broadcast
    final validationError = validateSignature(signStr, coinType);
    if (validationError != null) return validationError;
    return await tokenViewApi.sendTx(
        BlockchainType.Ethereum.name, coinType, signStr,
        netMode: isTest?"test":"main") ?? MessageModel.error();
  }
  Future<MessageModel> transferEth(int chainId, String coinType, String fromAddress,
      String toAddress, double value, int decimals, String path,
      {String contractAddress = "",int tokenDecimals=0,bool isTest=false,bool maxValue=true,String? message,}) async {
    //获取每个byte 消耗多少gas
    int gas = getCoinGas(coinType, contract: contractAddress == "" ? false : true);
    //获取余额
    BigInt balance = BigInt.zero;
    BigInt chainBalance = BigInt.zero;
    if(contractAddress !=""){
      MessageModel mm = await getBalanceEth(coinType, fromAddress,
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
    await getBalanceEth(coinType, fromAddress, contractAddress: "",isTest:isTest);
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
        isTest: isTest) ?? MessageModel.error();
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
    MessageModel estimateMm=await TokenViewApi().getGasEstimateEthV2(
        fromAddress,
        toAddress,
        gasPrice,
        ethToWeiString(value.toString(), contractAddress==""?decimals:tokenDecimals),
        BigInt.from(gas),
        coinType,
        contract: contractAddress,
        isTest: isTest,);
    if(estimateMm.error==false){
      gas=(estimateMm.data as BigInt).toInt();
      if(coinType==CoinType.OP.name
          || coinType==CoinType.BOBA.name){
        gas=(gas*1.5).toInt();
      }
      totalGasPrice=gasPrice * BigInt.from(gas);
    }else{
      return estimateMm;
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
    MessageModel rmm=await transferEthSend(
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
  Future<MessageModel> transferEthSend(
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
      MessageModel mmn = await tokenViewApi.getTransactionCountEth(
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
      if(Platform.isAndroid){
        messageHex=message;
      }else{
        messageHex= bytesToHex(message.codeUnits);
      }
    }

    //"data:image/png;base64,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";

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
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType, path, signMap,  pk:privateKey,);
    }

    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    signStr = "0x$signStr";
    if(returnSignHash){
      MessageModel rmm=MessageModel();
      rmm.data=signStr;
      return rmm;
    }
    // Validate signature before broadcast
    final validationError = validateSignature(signStr, coinType);
    if (validationError != null) return validationError;
    return await tokenViewApi.sendTx(
        BlockchainType.Ethereum.name, coinType, signStr,
        netMode: isTest,rpc: rpc) ?? MessageModel.error();
  }

  //获取余额 eth
  Future<MessageModel> getBalanceEth(String coinType, String fromAddress,
      {String contractAddress = "",bool isTest=false}) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Ethereum.name, coinType, fromAddress,contract:contractAddress,
        isTest: isTest) ?? MessageModel.error();
    return mm;
  }
}
