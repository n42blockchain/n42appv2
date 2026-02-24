part of '../transfer_api.dart';

/// Solana chain transfer methods.
///
/// Contains: transferSol, transferSolSend, getBalanceSol
mixin _TransferSolMixin on _TransferBaseMixin {
  Future<MessageModel> transferSol(Map<String,dynamic> chainMap,String fromAddress, String toAddress, double value,
      int decimals, String path,
      {String contractAddress = "",int tokenDecimals=0,bool maxValue=true}) async {
    //获取每个byte 消耗多少gas
    int gas = getCoinGas(CoinType.SOL.name,
        contract: contractAddress == "" ? false : true);
    BigInt balance = BigInt.zero;
    BigInt chainBalance  = BigInt.zero;
    MessageModel mmb =
    await getBalanceSol(fromAddress, contractAddress: contractAddress);
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
    MessageModel mmchain = await getBalanceSol(fromAddress);
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
        isTest: false) ?? MessageModel.error();
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
    MessageModel rmm=await transferSolSend(fromAddress, toAddress, valuePrice, path, totalGasPrice,contractAddress:contractAddress ,tokenDecimals: tokenDecimals);
    if(rmm.error==false){
      rmm.data={
        "txHash":rmm.data,
        "value":value
      };
    }
    return rmm;
  }
  //solana 提交
  Future<MessageModel> transferSolSend(String fromAddress, String toAddress, BigInt valuePrice, String path,BigInt totalGasPrice,
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
      MessageModel rdataAccount=await solApi.getAccountInfo(recipientTokenAddress,isTest: isTest=="main"?false:true);
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
    if(privateKey ==null){
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        CoinType.SOL.name,
        path,
        txData,
        mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
      );
    }else{
      signStr = await trustdart.signTransaction(CoinType.SOL.name, path, txData,  pk:privateKey,);
    }
    if(signStr==""){
      MessageModel rmm=MessageModel.error();
      rmm.data=S.current.g_key_wallet_m6;
      return rmm;
    }
    // Validate signature before broadcast
    final validationError = validateSignature(signStr, CoinType.SOL.name);
    if (validationError != null) return validationError;
    //发送交易
    return await solApi.sendTransaction(signStr,isTest: isTest=="main"?false:true);
  }

  //获取余额 solana
  Future<MessageModel> getBalanceSol(String fromAddress,
      {String contractAddress = ""}) async {
    MessageModel rData= await tokenViewApi.getBalance(BlockchainType.Solana.name, "", fromAddress,contract: contractAddress) ?? MessageModel.error();
    return rData;
  }
}
