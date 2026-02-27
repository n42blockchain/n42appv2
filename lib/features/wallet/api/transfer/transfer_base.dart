part of '../transfer_api.dart';

/// Base mixin providing shared utilities for all transfer operations.
///
/// Contains: tokenViewApi, dataUtils, trustdart, addressDealWith,
/// symbolDealWith, validateSignature, getAddressList
mixin _TransferBaseMixin {
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi {
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }

  DataUtils? _dataUtils;
  DataUtils get dataUtils {
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }

  Trustdart? _trustdart;
  Trustdart get trustdart {
    _trustdart ??= Trustdart();
    return _trustdart!;
  }
  //地址处理
  String addressDealWith(String address,String chainSymbol){
    if(chainSymbol==CoinType.BCH.name){
      List<String> addrs=address.split(':');
      if(addrs.length==2){
        return addrs[1];
      }
    }
    return address;
  }
  //Symbol处理
  String symbolDealWith(String symbol) {
    return switch (symbol) {
      "BSC" => "BNB",
      "AVAXC" => "AVAX",
      "OPTIMISM" => "OP",
      _ => symbol,
    };
  }

  /// Validate signed transaction before broadcasting
  /// Returns null if valid, or error MessageModel if invalid
  MessageModel? validateSignature(String signedTx, String coinType) {
    final result = SignatureValidator.validateSignedTransaction(
      signedTx: signedTx,
      coinType: coinType,
    );
    if (!result.isValid) {
      return MessageModel.error()..data = result.errorMessage ?? 'Signature validation failed';
    }
    return null;
  }

  //最大交易金额
  Future<String> transactionMaxValue(String blockchain,String coinType,Map<String,dynamic> signData,String path,{String? privateKey})async{
    String rStr="";
    switch (blockchain) {
      case "Bitcoin":
        if(privateKey ==null){
          rStr = await trustdart.signTransactionMaxValue(
            coinType.toUpperCase(),
            path,
            signData,
            mnemonic: globalWapAdapter.walletInfo.mnemonic??"",
          );
        }else{
          rStr = await trustdart.signTransactionMaxValue(coinType.toUpperCase(), "", signData, pk: privateKey,);
        }
        break;

    }
    return rStr;
  }

  //获取地址列表
  Future<String> getAddressList(List<dynamic> chainMap) async {
    WalletInfo wi = globalWapAdapter.walletInfo;

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
            int pIndex = pPath.indexOf("44");
            if (pIndex >= 0) {
              paths['legacy'] = pPath;
            } else {
              pIndex = pPath.indexOf("84");
              if (pIndex >= 0) {
                paths['segwit'] = pPath;
              }
            }
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

  Future<MessageModel> getBalanceAllTrx(String fromAddress,
      {String contractAddress = ""}) async {
    MessageModel mm = await tokenViewApi.getBalance(
        BlockchainType.Tron.name, CoinType.TRX.name, fromAddress,contract: contractAddress,
        isTest: false) ?? MessageModel.error();
    return mm;
  }
}
