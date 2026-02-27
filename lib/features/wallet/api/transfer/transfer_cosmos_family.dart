part of '../transfer_api.dart';

/// Cosmos-family chain transfer methods: ATOM/Cosmos, DOT/Polkadot,
/// APT/Aptos, TON/TheOpenNetwork.
///
/// Contains: transferApt, transferAptSend, transferTonSend,
/// transferDot, transferDotSend, transferAtom, transferAtomSend
mixin _TransferCosmosFamilyMixin on _TransferBaseMixin {
  //Aptos
  Future<MessageModel> transferApt(String fromAddress, String toAddress, double value,
      int decimals, String path,String coinType,int chainId,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true,String? privateKey})async{
    //获取每个byte 消耗多少gas
    int gas = getCoinGas(coinType,
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
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5(coinType);//"TRX 余额不足";
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Cosmos.name, CoinType.ATOM.name,
        isTest: false) ?? MessageModel.error();
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
    }
    MessageModel mmtx = await transferAtomSend(fromAddress, toAddress, valuePrice, path, totalGasPrice, contractAddress: contractAddress);
    if (mmtx.error == false) {
      return MessageModel()..data = {"txHash": mmtx.data, "value": value};
    }
    return mmtx;
  }

  Future<MessageModel> transferAptSend(String fromAddress, String toAddress, BigInt valuePrice, String path,int gas,BigInt totalGasPrice,String coinType,int chainId,
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
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk:privateKey,);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    // Validate signature before broadcast
    final validationError = validateSignature(signStr, coinType);
    if (validationError != null) return validationError;
    //发起交易
    MessageModel mmtx=await aptApi.sendTxHash(signStr);
    return mmtx;
  }
  //TheOpenNetwork
  Future<MessageModel> transferTonSend(String fromAddress, String toAddress, BigInt valuePrice, String path,int gas,BigInt totalGasPrice,String coinType,
      {String contractAddress = "",String isTest="main",String? privateKey})async{
    TonApi tonApi=TonApi(isTest: isTest=="main"?false:true);
    MessageModel sequenceNumber=await tonApi.getSeqnoTon(fromAddress);
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
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk:privateKey,);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }//发起交易
    MessageModel mmtx=await tonApi.submitTon(signStr);
    return mmtx;
  }

  //Polkadot
  Future<MessageModel> transferDot(String fromAddress, String toAddress, double value,
      int decimals, String path,String coinType,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true,String? privateKey})async{
    //获取每个byte 消耗多少gas
    int gas = getCoinGas(coinType,
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
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5(coinType);
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero;
    MessageModel mmg = await tokenViewApi.getGasPrice(
        BlockchainType.Cosmos.name, CoinType.ATOM.name,
        isTest: false) ?? MessageModel.error();
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice = mmg.data;
    }
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice=ethToWeiString(value.toString(), decimals);
      if(valuePrice==chainBalance && maxValue){
        valuePrice=valuePrice-totalGasPrice;
        value=toEther(valuePrice.toString(),decimals).toDouble();
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5(CoinType.ATOM.name);
        return mme;
      }
    }
    MessageModel mmtx = await transferAtomSend(fromAddress, toAddress, valuePrice, path, totalGasPrice, contractAddress: contractAddress);
    if (mmtx.error == false) {
      return MessageModel()..data = {"txHash": mmtx.data, "value": value};
    }
    return mmtx;
  }

  Future<MessageModel> transferDotSend(String fromAddress, String toAddress, BigInt valuePrice, String path,BigInt totalGasPrice,String coinType,
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
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk:privateKey,);
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
  Future<MessageModel> transferAtom(String fromAddress, String toAddress, double value,
      int decimals, String path,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true,String? privateKey})async{
    //获取每个byte 消耗多少gas
    int gas = getCoinGas(CoinType.ATOM.name,
        contract: contractAddress == "" ? false : true);
    MessageModel mm =
    await getBalanceAllTrx(fromAddress);

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
      await getBalanceAllTrx(fromAddress, contractAddress: contractAddress);
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
        isTest: false) ?? MessageModel.error();
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
    MessageModel mmtx = await transferAtomSend(fromAddress, toAddress, valuePrice, path, totalGasPrice, contractAddress: contractAddress);
    if (mmtx.error == false) {
      return MessageModel()..data = {"txHash": mmtx.data, "value": value};
    }
    return mmtx;
  }

  Future<MessageModel> transferAtomSend(String fromAddress, String toAddress, BigInt valuePrice, String path, BigInt totalGasPrice,
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
    String signStr;
    if (privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        CoinType.ATOM.name,
        path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(CoinType.ATOM.name, path, signMap, pk:privateKey,);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    // Validate signature before broadcast
    final validationError = validateSignature(signStr, CoinType.ATOM.name);
    if (validationError != null) return validationError;
    //发起交易
    MessageModel mmtx=await atomApi.sendTxs(signStr);
    return mmtx;
  }
}
