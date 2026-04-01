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
      return MessageModel.error()..data = S.current.g_key_wallet_m1(coinType);
    }
    if (fromAddress == "") {
      String? fAddress = wap.getAddress(coinType, addrType: "legacy");
      if (fAddress == null) {
        return MessageModel.error()..data = S.current.g_key_wallet_m3(coinType);
      }
      fromAddress = fAddress;
    }
    //获取每个byte 消耗多少gas
    int gas =
    getCoinGas(coinType, contract: true);
    BigInt chainBalance = BigInt.zero;
    MessageModel mmchain =
    await getBalanceEth(coinType, fromAddress, contractAddress: "",isTest: isTest);
    if (mmchain.error == true) return mmchain;
    chainBalance = mmchain.data;
    if (chainBalance == BigInt.zero) {
      return MessageModel.error()..data = S.current.g_key_wallet_m5(coinType);
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    BigInt gasPrice2 = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Ethereum.name, coinType,
        isTest: isTest) ?? MessageModel.error();
    if (mmg.error == true) return mmg;
    gasPrice2 = mmg.data;
    gasPrice = mmg.data;
    if(get1559WithChainSymbol(coinType)){
      gasPrice=gasPrice*BigInt.from(2);
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = ethToWeiString(value.toString(), 18);
    if(valuePrice==chainBalance){
      if (totalGasPrice >= valuePrice) {
        return MessageModel.error()..data = S.current.g_key_wallet_m5(coinType);
      }
      valuePrice=valuePrice-totalGasPrice;
      value=toEther(valuePrice.toString(),18).toDouble();
    }
    if (valuePrice <= BigInt.zero || totalGasPrice + valuePrice > chainBalance) {
      return MessageModel.error()..data = S.current.g_key_wallet_m5(coinType);
    }
    //获取nonce值
    MessageModel mmn = await tokenViewApi.getTransactionCountEth(
        coinType, fromAddress,netMode:isTest?"test":"main");
    if (mmn.error) return mmn;
    String nonceHex = dataUtils.bigIntToHex(mmn.data, need0x: false);
    String gasPriceHex = dataUtils.bigIntToHex(gasPrice, need0x: false);
    String amountHex = dataUtils.bigIntToHex(valuePrice, need0x: false);

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
      "is1559": get1559WithChainSymbol(coinType) ? 'true' : 'false',
    };
    //从keystore中取出助记词
    WalletInfo wi = wap.walletInfo;
    String path=txChainMap['baseInfo']['path'][txChainMap['addrType']];
    int pathIndex=txChainMap["pathIndex"]??0;
    path=getPathWithIndex(path, pathIndex);
    String signStr = await trustdart.signTransaction(
        coinType, path, signMap, mnemonic: wi.mnemonic??"",pk: wi.privateKey??"");
    if(signStr==""){
      return MessageModel.error()..data=S.current.g_key_wallet_m6;
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
      if (mm.error == true) return mm;
      balance = mm.data;
      if (balance == BigInt.zero) {
        return MessageModel.error()..data = S.current.g_key_wallet_m4;
      }
    }
    MessageModel mmchain =
    await getBalanceEth(coinType, fromAddress, contractAddress: "",isTest:isTest);
    if (mmchain.error == true) return mmchain;
    chainBalance = mmchain.data;
    if (chainBalance == BigInt.zero) {
      return MessageModel.error()..data = S.current.g_key_wallet_m5(coinType);
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    BigInt gasPrice2 = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Ethereum.name, coinType,
        isTest: isTest) ?? MessageModel.error();
    if (mmg.error == true) return mmg;
    gasPrice2 = mmg.data;
    gasPrice = mmg.data;
    if(get1559WithChainSymbol(coinType)){
      gasPrice=gasPrice*BigInt.from(2);
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
    if(estimateMm.error==true) return estimateMm;
    gas=(estimateMm.data as BigInt).toInt();
    if(coinType==CoinType.OP.name || coinType==CoinType.BOBA.name){
      gas=(gas*1.5).toInt();
    }
    totalGasPrice=gasPrice * BigInt.from(gas);

    final String displayCoinType = coinType==CoinType.N.name?CoinType.N.name:coinType;
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice = ethToWeiString(value.toString(), decimals);
      if(valuePrice==chainBalance && maxValue==true){
        if (totalGasPrice >= valuePrice) {
          return MessageModel.error()..data = S.current.g_key_wallet_m5(displayCoinType);
        }
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if(value<0 || valuePrice <= BigInt.zero || totalGasPrice + valuePrice > chainBalance){
        return MessageModel.error()..data = S.current.g_key_wallet_m5(displayCoinType);
      }
    } else {
      valuePrice = ethToWeiString(value.toString(), tokenDecimals);
      if (valuePrice > balance) {
        return MessageModel.error()..data = S.current.g_key_wallet_m4;
      }
      if (totalGasPrice > chainBalance) {
        return MessageModel.error()..data = S.current.g_key_wallet_m5(displayCoinType);
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
    //获取nonce值
    String nonceHex;
    if(nonce==null){
      MessageModel mmn = await tokenViewApi.getTransactionCountEth(
          coinType, fromAddress,
          netMode: isTest,rpc: rpc);
      if (mmn.error) return mmn;
      nonceHex = dataUtils.bigIntToHex(mmn.data, need0x: false);
    }else{
      nonceHex = dataUtils.strip0x(nonce);
    }
    if(gasPrice==BigInt.zero){
      return MessageModel.error()..data="Gas price error";
    }
    String gasPriceHex = dataUtils.bigIntToHex(gasPrice,
        need0x: false);
    String gasPrice2Hex = dataUtils.bigIntToHex(gasPrice2,
        need0x: false);
    String amountHex=dataUtils.bigIntToHex(valuePrice,
        need0x: false);
    String chainIdHex = dataUtils.bigIntToHex(BigInt.from(chainId), need0x: false);
    // Apply a 20% safety buffer to the estimated gas limit (was 4x, which
    // unnecessarily locked user funds during tx execution)
    final int gasWithBuffer = (gas * 1.2).ceil();
    String gasLimitHex = dataUtils.bigIntToHex(BigInt.from(gasWithBuffer), need0x: false);
    String messageHex = message == null
        ? ""
        : Platform.isAndroid ? message : bytesToHex(message.codeUnits);

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
      "is1559": get1559WithChainSymbol(coinType) ? 'true' : 'false',
    };
    //从keystore中取出助记词
    String signStr;
    if(privateKey ==null){
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        coinType, path, signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk:privateKey);
    }
    if(signStr==""){
      return MessageModel.error()..data=S.current.g_key_wallet_m6;
    }
    signStr = "0x$signStr";
    if(returnSignHash){
      return MessageModel()..data=signStr;
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
    return await tokenViewApi.getBalance(
        BlockchainType.Ethereum.name, coinType, fromAddress,contract:contractAddress,
        isTest: isTest) ?? MessageModel.error();
  }
}
