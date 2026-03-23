part of '../transfer_api.dart';

/// TRON chain transfer methods.
///
/// Contains: transferTrx, transferTrxSend, getBalanceTrx, getBalanceAllTrx
mixin _TransferTrxMixin on _TransferBaseMixin {
  //tron 转账
  Future<MessageModel> transferTrx(
    String fromAddress,
    String toAddress,
    double value,
    int decimals,
    String path, {
    String contractAddress = "",
    int tokenDecimals = 0,
    bool maxValue = true,
  }) async {
    //获取每个byte 消耗多少gas
    int gas = getCoinGas(
      CoinType.TRX.name,
      contract: contractAddress == "" ? false : true,
    );
    MessageModel mm = await getBalanceAllTrx(fromAddress);

    //获取余额
    BigInt chainBalance = BigInt.zero;
    if (mm.error == true) {
      return mm;
    } else {
      chainBalance = mm.data;
    }
    BigInt balance = BigInt.zero;
    if (contractAddress != "") {
      MessageModel mmToken = await getBalanceAllTrx(
        fromAddress,
        contractAddress: contractAddress,
      );
      if (mmToken.error == true) {
        return mmToken;
      } else {
        balance = mmToken.data;
      }
      if (balance == BigInt.zero) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m4; //"TRC20 余额不足";
        return mme;
      }
    }
    if (chainBalance == BigInt.zero) {
      MessageModel mme = MessageModel.error();
      mme.data = S.current.g_key_wallet_m5("TRX"); //"TRX 余额不足";
      return mme;
    }
    //获取gas 费
    BigInt gasPrice = BigInt.zero; //当前旷工费
    MessageModel mmg =
        await tokenViewApi.getGasPrice(
          BlockchainType.Tron.name,
          CoinType.TRX.name,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmg.error) {
      mmg = await TrxApi().getGasPriceTrx(isTest: false);
    }
    if (mmg.error == true) {
      return mmg;
    } else {
      gasPrice = mmg.data;
    }
    //gas费消耗最大数
    BigInt totalGasPrice = gasPrice * BigInt.from(gas);
    BigInt valuePrice = BigInt.zero;
    if (contractAddress == "") {
      valuePrice = ethToWeiString(value.toString(), decimals);
      //如果是全部转账
      if (valuePrice == chainBalance && maxValue) {
        if (totalGasPrice >= valuePrice) {
          return MessageModel.error()..data = S.current.g_key_wallet_m5("TRX");
        }
        valuePrice = valuePrice - totalGasPrice;
        value = toEther(valuePrice.toString(), decimals).toDouble();
      }
      if (valuePrice <= BigInt.zero || totalGasPrice + valuePrice > chainBalance) {
        MessageModel mme = MessageModel.error();
        mme.data = S.current.g_key_wallet_m5("TRX");
        return mme;
      }
    } else {
      valuePrice = ethToWeiString(value.toString(), tokenDecimals);
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
    MessageModel mmtx = await transferTrxSend(
      fromAddress,
      toAddress,
      valuePrice,
      path,
      totalGasPrice,
      contractAddress: contractAddress,
    );
    if (mmtx.error == false) {
      MessageModel mmr = MessageModel();
      mmr.data = {"txHash": mmtx.data, "value": value};
      return mmr;
    } else {
      return mmtx;
    }
  }

  //trx提交
  Future<MessageModel> transferTrxSend(
    String fromAddress,
    String toAddress,
    BigInt valuePrice,
    String path,
    BigInt totalGasPrice, {
    String contractAddress = "",
    String isTest = "main",
    String? privateKey,
  }) async {
    //签名
    TrxApi trxApi = TrxApi();
    final bool isTestnet = isTest == "main" ? false : true;
    //获取最新块
    MessageModel mmlbn = await tokenViewApi.getLatestBlockNumberTrx(
      isTest: isTestnet,
    );
    if (mmlbn.error || !_hasUsableTrxBlockData(mmlbn.data)) {
      mmlbn = await trxApi.getBlockNowTrx(isTest: isTestnet);
    }
    if (mmlbn.error) {
      return mmlbn;
    }
    Map<String, dynamic> blockInfo = mmlbn.data['raw_data'];
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
      "feeLimit": totalGasPrice.toString(),
    };
    if (contractAddress != "") {
      txData['cmd'] = "TRC20";
      txData['contractAddress'] = contractAddress;
      txData['amount'] = dataUtils.bigIntToHex(valuePrice, need0x: false);
    } else {
      // Use toString() instead of toInt() to prevent overflow for large amounts
      txData['amount'] = valuePrice.toString();
      txData['cmd'] = CoinType.TRX.name;
    }

    String signStr;
    if (privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return MessageModel.error()..data = 'Context is no longer valid';
      }
      signStr = await trustdart.signTransaction(
        CoinType.TRX.name,
        path,
        txData,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? "",
      );
    } else {
      signStr = await trustdart.signTransaction(
        CoinType.TRX.name,
        path,
        txData,
        pk: privateKey,
      );
    }
    if (signStr == "") {
      MessageModel rmm = MessageModel.error();
      rmm.data = S.current.g_key_wallet_m6;
      return rmm;
    }
    // Validate signature before broadcast
    final validationError = validateSignature(signStr, CoinType.TRX.name);
    if (validationError != null) return validationError;
    //发起交易
    MessageModel mmtx = await tokenViewApi.sendTxTrx(signStr, isTest);
    final txHash = _extractTrxBroadcastHash(mmtx.data);
    if (mmtx.error || txHash.isEmpty) {
      mmtx = await trxApi.sendTxTrx(signStr, isTest: isTestnet);
      if (!mmtx.error) {
        mmtx.data = _extractTrxBroadcastHash(mmtx.data);
      }
      return mmtx;
    }
    mmtx.data = txHash;
    return mmtx;
  }

  //获取余额 tron
  Future<MessageModel> getBalanceTrx(
    String fromAddress, {
    String contractAddress = "",
  }) async {
    MessageModel mm =
        await tokenViewApi.getBalance(
          BlockchainType.Tron.name,
          CoinType.TRX.name,
          fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
    //获取余额
    BigInt balance = BigInt.zero;
    if (mm.error == true) {
      return mm;
    } else {
      if (contractAddress != "") {
        List<dynamic> trc20 = mm.data['trc20'];
        for (Map owner in trc20) {
          List<dynamic> keys = owner.keys.toList();
          for (int i = 0; i < keys.length; i++) {
            if (contractAddress.toUpperCase() ==
                keys[i].toString().toUpperCase()) {
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

  bool _hasUsableTrxBlockData(dynamic data) {
    return data is Map && data['raw_data'] is Map;
  }

  String _extractTrxBroadcastHash(dynamic data) {
    if (data is String) {
      return data;
    }
    if (data is Map) {
      final direct = data['txid']?.toString();
      if (direct != null && direct.isNotEmpty) {
        return direct;
      }
      final nested = data['transaction'] is Map
          ? data['transaction']['txid']?.toString()
          : null;
      if (nested != null && nested.isNotEmpty) {
        return nested;
      }
      final hash = data['hash']?.toString();
      if (hash != null && hash.isNotEmpty) {
        return hash;
      }
    }
    return '';
  }
}
