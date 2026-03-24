part of '../transfer_api.dart';

/// Other chain transfer methods: ALGO, XTZ, XRP, FIL, ZIL.
///
/// Contains: transferAlgo, transferAlgoSend, transferXtz, transferXtzSend,
/// transferXrp, transferXrpSend, transferFilSend, transferZilSend,
/// getBalanceAlgo, getBalanceXtz, getBalanceXrp
mixin _TransferOthersMixin on _TransferBaseMixin {
  /// Common balance + gas validation for non-EVM transfers.
  /// Returns `(adjustedValue, valuePrice, totalGasPrice)` on success,
  /// or a [MessageModel] error.
  Future<Object> _validateBalanceAndGas({
    required String coinSymbol,
    required String fromAddress,
    required Future<MessageModel> Function(String) getBalance,
    required String blockchainName,
    required BigInt Function(dynamic gasPriceData) extractGasPrice,
    required double value,
    required int decimals,
    required bool maxValue,
  }) async {
    // 获取余额
    final mmchain = await getBalance(fromAddress);
    if (mmchain.error == true) return mmchain;
    final BigInt chainBalance = mmchain.data;
    if (chainBalance == BigInt.zero) {
      return MessageModel.error()..data = S.current.g_key_wallet_m5(coinSymbol);
    }

    // 获取 gas 费
    final mmg =
        await tokenViewApi.getGasPrice(
          blockchainName,
          coinSymbol,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmg.error == true) return mmg;
    final BigInt gasPrice = extractGasPrice(mmg.data);

    // 计算总 gas 费用
    final int gas = getCoinGas(coinSymbol, contract: false);
    final BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = ethToWeiString(value.toString(), decimals);
    double adjustedValue = value;

    if (valuePrice == chainBalance && maxValue) {
      if (totalGasPrice >= valuePrice) {
        return MessageModel.error()
          ..data = S.current.g_key_wallet_m5(coinSymbol);
      }
      valuePrice = valuePrice - totalGasPrice;
      adjustedValue = toEther(valuePrice.toString(), decimals).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        totalGasPrice + valuePrice > chainBalance) {
      return MessageModel.error()..data = S.current.g_key_wallet_m5(coinSymbol);
    }

    return (adjustedValue, valuePrice, totalGasPrice);
  }

  /// Wrap a send result with txHash + value on success.
  MessageModel _wrapSendResult(MessageModel rmm, double value) {
    if (rmm.error == false) {
      rmm.data = {"txHash": rmm.data, "value": value};
    }
    return rmm;
  }

  /// Return a sign-failure [MessageModel].
  MessageModel _signFailureError() =>
      MessageModel.error()..data = S.current.g_key_wallet_m6;

  /// Check context validity before signing.
  MessageModel? _checkContextMounted() {
    if (!AppGlobals.appContext.mounted) {
      return MessageModel.error()..data = 'Context is no longer valid';
    }
    return null;
  }

  //Algorand转账
  Future<MessageModel> transferAlgo(
    String fromAddress,
    String toAddress,
    double value,
    int decimals,
    String path, {
    bool maxValue = true,
  }) async {
    final result = await _validateBalanceAndGas(
      coinSymbol: "ALGO",
      fromAddress: fromAddress,
      getBalance: getBalanceAlgo,
      blockchainName: BlockchainType.Algorand.name,
      extractGasPrice: (data) => BigInt.from(data['min-fee']),
      value: value,
      decimals: decimals,
      maxValue: maxValue,
    );
    if (result is MessageModel) return result;
    final (adjustedValue, valuePrice, _) = result as (double, BigInt, BigInt);

    final rmm = await transferAlgoSend(
      fromAddress,
      toAddress,
      valuePrice.toString(),
      path,
    );
    return _wrapSendResult(rmm, adjustedValue);
  }

  Future<MessageModel> transferAlgoSend(
    String fromAddress,
    String toAddress,
    String value,
    String path, {
    String contractAddress = "",
    String isTest = "main",
    String? privateKey,
    String type = "ALGO",
  }) async {
    Map<String, dynamic> txData = {
      "type": type,
      "toAddress": toAddress,
      "amount": value,
      "assetId": contractAddress,
    };
    AlgoApi algoApi = AlgoApi();
    MessageModel mminfo = await algoApi.getTransactionsParams(
      isTest: isTest == "main" ? false : true,
    );
    if (mminfo.error) return mminfo;
    txData['fee'] = mminfo.data['min-fee'];
    txData['genesisId'] = mminfo.data['genesis-id'];
    txData['genesisHash'] = mminfo.data['genesis-hash'];
    txData['round'] = mminfo.data['last-round'];

    Map<dynamic, dynamic> rValue;
    if (privateKey != null) {
      rValue = await trustdart.signTransactionByteArray(
        CoinType.ALGO.name,
        path,
        txData,
        pk: privateKey,
      );
    } else {
      final ctxError = _checkContextMounted();
      if (ctxError != null) return ctxError;
      rValue = await trustdart.signTransactionByteArray(
        CoinType.ALGO.name,
        path,
        txData,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? "",
      );
    }
    if (rValue['result'] != true) return _signFailureError();
    final Uint8List signStr = hexToBytes(rValue['signHash']);
    return await tokenViewApi.sendTx(
          BlockchainType.Algorand.name,
          "ALGO",
          signStr,
          netMode: isTest,
        ) ??
        MessageModel.error();
  }

  //Tezos转账
  Future<MessageModel> transferXtz(
    String fromAddress,
    String toAddress,
    double value,
    int decimals,
    String path, {
    bool maxValue = true,
  }) async {
    final result = await _validateBalanceAndGas(
      coinSymbol: "XTZ",
      fromAddress: fromAddress,
      getBalance: getBalanceXtz,
      blockchainName: BlockchainType.Algorand.name,
      extractGasPrice: (data) => data as BigInt,
      value: value,
      decimals: decimals,
      maxValue: maxValue,
    );
    if (result is MessageModel) return result;
    final (adjustedValue, valuePrice, _) = result as (double, BigInt, BigInt);

    final rmm = await transferXtzSend(
      fromAddress,
      toAddress,
      valuePrice.toInt(),
      path,
    );
    return _wrapSendResult(rmm, adjustedValue);
  }

  Future<MessageModel> transferXtzSend(
    String fromAddress,
    String toAddress,
    int value,
    String path, {
    bool isTest = false,
    String? privateKey,
  }) async {
    Map<String, dynamic> signMap = {
      "amount": value,
      "toAddress": toAddress,
      "fee": 500,
      "counter": 10,
      "gasLimit": 1101,
      "storageLimit": 257,
      "reveal": true,
    };
    XtzApi xtzApi = XtzApi();
    MessageModel mmCounter = await xtzApi.getCounterXtz(fromAddress, isTest);
    if (mmCounter.error) return mmCounter;
    signMap['counter'] = int.parse(mmCounter.data.toString()) + 1;

    MessageModel mmBranch = await xtzApi.getBranchXgz(isTest);
    if (mmBranch.error) return mmBranch;
    signMap['branch'] = mmBranch.data.toString();

    MessageModel mmReveal = await xtzApi.getBalanceXtz(
      fromAddress,
      "",
      "revealed",
      isTest,
    );
    if (mmReveal.error) return mmReveal;
    signMap['reveal'] = mmReveal.data;

    final ctxError = _checkContextMounted();
    if (ctxError != null) return ctxError;
    WalletInfo wi = globalWapAdapter.walletInfo;
    String signStr = await trustdart.signTransaction(
      CoinType.XTZ.name,
      path,
      signMap,
      mnemonic: wi.mnemonic ?? "",
      pk: wi.privateKey ?? "",
    );
    if (signStr == "") return _signFailureError();
    final xtzValidationError = validateSignature(signStr, CoinType.XTZ.name);
    if (xtzValidationError != null) return xtzValidationError;
    return await xtzApi.sendTxXtz(signStr, isTest);
  }

  //Ripple转账
  Future<MessageModel> transferXrp(
    String fromAddress,
    String toAddress,
    double value,
    int decimals,
    String path, {
    bool maxValue = true,
  }) async {
    // 检查目标地址是否已激活
    XrpApi xrpApi = XrpApi();
    MessageModel mm = await xrpApi.getAccountInfoXrp(toAddress, false);
    if (mm.error) {
      return MessageModel.error()..data = S.current.g_key_t_45(toAddress);
    }
    final bool isCreate = mm.data['validated'] == true;
    if (!isCreate && value < 10) {
      return MessageModel.error()..data = S.current.g_key_t_54;
    }

    final result = await _validateBalanceAndGas(
      coinSymbol: "XRP",
      fromAddress: fromAddress,
      getBalance: getBalanceXtz,
      blockchainName: BlockchainType.Algorand.name,
      extractGasPrice: (data) => data as BigInt,
      value: value,
      decimals: decimals,
      maxValue: maxValue,
    );
    if (result is MessageModel) return result;
    final (adjustedValue, valuePrice, totalGasPrice) =
        result as (double, BigInt, BigInt);

    final rmm = await transferXrpSend(
      fromAddress,
      toAddress,
      valuePrice,
      totalGasPrice,
      path,
      0,
    );
    return _wrapSendResult(rmm, adjustedValue);
  }

  Future<MessageModel> transferXrpSend(
    String fromAddress,
    String toAddress,
    BigInt value,
    BigInt totalGasPrice,
    String path,
    int sequence, {
    bool isTest = false,
    String? privateKey,
    int? destinationTag,
  }) async {
    Map<String, dynamic> signMap = {
      "amount": value.toString(),
      "toAddress": toAddress,
      "sequence": sequence,
      "ledgerIndex": 0,
      "fee": totalGasPrice.toString(),
      "txType": "XRP",
      "issuer": "",
      "currency": "",
      ...switch (destinationTag) {
        final tag? => {"destinationTag": tag},
        null => const <String, dynamic>{},
      },
    };
    XrpApi xrpApi = XrpApi();
    if (sequence == 0) {
      MessageModel mmSequence = await xrpApi.getAccountInfoXrp(
        fromAddress,
        isTest,
      );
      if (mmSequence.error) return mmSequence;
      signMap['sequence'] = mmSequence.data['sequence'];
    }
    MessageModel mmLedgerIndex = await xrpApi.getLedgerXrp(isTest: isTest);
    if (mmLedgerIndex.error) return mmLedgerIndex;
    signMap['ledgerIndex'] = mmLedgerIndex.data;

    final ctxError = _checkContextMounted();
    if (ctxError != null) return ctxError;
    WalletInfo wi = globalWapAdapter.walletInfo;
    String signStr = await trustdart.signTransaction(
      CoinType.XRP.name,
      path,
      signMap,
      mnemonic: wi.mnemonic ?? "",
      pk: wi.privateKey ?? "",
    );
    if (signStr == "") return _signFailureError();
    final xrpValidationError = validateSignature(signStr, CoinType.XRP.name);
    if (xrpValidationError != null) return xrpValidationError;
    return await xrpApi.sendTxXrp(signStr, isTest);
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
    String gasPremium, {
    bool isTest = false,
    String? privateKey,
  }) async {
    Map<String, dynamic> signMap = {
      "amount": dataUtils.bigIntToHex(value, need0x: false),
      "toAddress": toAddress,
      "nonce": nonce,
      "gasLimit": gasLimit,
      "gasFeeCap": dataUtils.bigIntToHex(
        BigInt.parse(gasFeeCap),
        need0x: false,
      ),
      "gasPremium": dataUtils.bigIntToHex(
        BigInt.parse(gasPremium),
        need0x: false,
      ),
    };
    String signStr;
    if (privateKey == null) {
      final ctxError = _checkContextMounted();
      if (ctxError != null) return ctxError;
      signStr = await trustdart.signTransaction(
        CoinType.FIL.name,
        path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? "",
      );
    } else {
      signStr = await trustdart.signTransaction(
        CoinType.FIL.name,
        path,
        signMap,
        pk: privateKey,
      );
    }
    if (signStr == "") return _signFailureError();
    final filValidationError = validateSignature(signStr, CoinType.FIL.name);
    if (filValidationError != null) return filValidationError;
    FilApi filApi = FilApi();
    return await filApi.sendTx(signStr, isTest: isTest);
  }

  Future<MessageModel> getBalanceAlgo(String fromAddress) async {
    return await tokenViewApi.getBalance(
          BlockchainType.Algorand.name,
          "ALGO",
          fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
  }

  Future<MessageModel> getBalanceXtz(String fromAddress) async {
    return await tokenViewApi.getBalance(
          BlockchainType.Tezos.name,
          "XTZ",
          fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
  }

  Future<MessageModel> getBalanceXrp(String fromAddress) async {
    return await tokenViewApi.getBalance(
          BlockchainType.Ripple.name,
          "XRP",
          fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
  }

  // Zilliqa 转账
  Future<MessageModel> transferZilSend(
    String fromAddress,
    String toAddress,
    BigInt valuePrice,
    String path,
    int gas,
    BigInt gasPrice,
    String coinType, {
    String contractAddress = "",
    String isTest = "main",
    String? privateKey,
  }) async {
    ZilApi zilApi = ZilApi(isTest: isTest != "main");

    MessageModel networkIdMM = await zilApi.getNetworkId();
    if (networkIdMM.error) return networkIdMM;

    MessageModel latestBlockMM = await zilApi.getLatestTxBlock();
    if (latestBlockMM.error) return latestBlockMM;
    int version = latestBlockMM.data['header']['Version'];

    MessageModel balanceMM = await zilApi.getBalance(fromAddress, nonce: true);
    if (balanceMM.error) {
      final errStr = balanceMM.data.toString();
      if (!errStr.contains('not found') && !errStr.contains('-5')) {
        return balanceMM;
      }
    }

    Map<String, dynamic> signMap = {
      "version": version,
      "nonce": balanceMM.data['nonce'] + 1,
      "toAddress": toAddress,
      "amount": valuePrice.toString(),
      "gasPrice": gasPrice.toString(),
      "gasLimit": gas.toString(),
      "code": "",
      "data": "",
    };

    String signStr;
    if (privateKey == null) {
      final ctxError = _checkContextMounted();
      if (ctxError != null) return ctxError;
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? "",
      );
    } else {
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        pk: privateKey,
      );
    }
    if (signStr == "") return _signFailureError();

    final Map<String, dynamic> signedData = json.decode(signStr);
    final Map<String, dynamic> txParams = {
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

    return await zilApi.createTransaction(txParams);
  }
}
