part of 'token_view_api.dart';

// ── Ethereum (ETH) ─────────────────────────────────────────────────────────

extension TokenViewApiEth on TokenViewApi {
  /// 获取 ETH 类余额（含代币）
  Future<MessageModel> getBalanceEth(
    String coinType,
    String address,
    String contract, {
    bool returnDouble = false,
    bool isTest = false,
    String? rpc,
  }) async {
    try {
      if (rpc != null) {
        return await EthAPI.init(null, rpc, null).getBalance(address, contract);
      }
      final netMode = isTest ? 'test' : 'main';
      dynamic a;
      if (contract.isEmpty) {
        final params = {
          'address': address,
          'coin': coinType.toLowerCase(),
          'net_mode': netMode,
          'tag': 'latest',
        };
        a = await BaseApi.requestEmptyH.post(
          '${url}v2/eth/balance',
          params: params,
          data: params,
          header: header,
        );
      } else {
        final params = {
          'from': address,
          'to': contract,
          'coin': coinType.toLowerCase(),
          'net_mode': netMode,
          'tag': 'latest',
        };
        a = await BaseApi.requestEmptyH.post(
          '${url}v2/eth/call',
          params: params,
          data: params,
          header: header,
        );
      }
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        String result = a['data']['result'];
        if (result == '0x') result = '0x0';
        mm.data = hexToInt(result);
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 ETH 类某地址的所有代币余额
  Future<MessageModel> getAllTokenBalanceEth(
    String coinType,
    String address,
  ) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/vipapi/eth-class/address/balance?coin=${coinType.toLowerCase()}&address=${address.toLowerCase()}',
        params: {},
        header: header,
      );
      final mm = MessageModel.error();
      final code = a['code'];
      if (code == 1 || code == 0) {
        mm.error = false;
        mm.data = a['data'];
      } else if (code == 404 || code == 400) {
        mm.error = false;
        mm.data = [];
      } else {
        mm.data = errorMessage(code);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// ETH 预估 gas（低级接口，直接传 params map）
  Future<MessageModel> getGasEstimateEth(Map<String, dynamic> params) async {
    try {
      final a = await BaseApi.requestEmptyH.post(
        '${url}v2/eth/estimate/gas',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = hexToInt(a['data']['result']);
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// ETH 预估 gas（高级接口）
  Future<MessageModel> getGasEstimateEthV2(
    String from,
    String to,
    BigInt gasPrice,
    BigInt value,
    BigInt gas,
    String coinType, {
    String contract = '',
    String data = '',
    bool isTest = false,
  }) async {
    if (coinType == CoinType.TRX.name) {
      return await TrxApi().getGasEstimateTrx(
        from,
        to,
        gasPrice,
        value,
        gas,
        contract: contract,
        isTest: isTest,
      );
    }
    final netMode = isTest ? 'test' : 'main';
    final use1559 = get1559WithChainSymbol(coinType);

    if (contract.isEmpty) {
      final params = <String, dynamic>{
        'from': from,
        'to': to,
        'gas': '0x${gas.toRadixString(16)}',
        'coin': coinType,
        'net_mode': netMode,
        'id': AppGlobals.nextId,
      };
      if (use1559) {
        params['maxFeePerGas'] = '0x${gasPrice.toRadixString(16)}';
      } else {
        params['gasPrice'] = '0x${gasPrice.toRadixString(16)}';
      }
      if (data.isNotEmpty) params['data'] = data;
      return await getGasEstimateEth(params);
    } else {
      final toAddress = strip0x(to);
      final methodId = bytesToHex(keccakAscii('transfer(address,uint256)'))
          .substring(0, 8)
          .toLowerCase();
      final valueHex = bytesToHex(padUint8ListTo32(unsignedIntToBytes(value)));
      final params = <String, dynamic>{
        'from': from,
        'to': contract,
        'gas': '0x${gas.toRadixString(16)}',
        'data': '0x${methodId}000000000000000000000000$toAddress$valueHex',
        'coin': coinType,
        'net_mode': netMode,
        'id': AppGlobals.nextId,
      };
      if (use1559) {
        params['maxFeePerGas'] = '0x${gasPrice.toRadixString(16)}';
      } else {
        params['gasPrice'] = '0x${gasPrice.toRadixString(16)}';
      }
      return await getGasEstimateEth(params);
    }
  }

  /// 获取交易数量（nonce 值）
  Future<MessageModel> getTransactionCountEth(
    String coinType,
    String address, {
    String netMode = 'main',
    String? rpc,
  }) async {
    try {
      if (rpc != null) {
        return await EthAPI.init(null, rpc, null).getTransactionCount(address);
      }
      final params = {
        'coin': coinType.toLowerCase(),
        'hex_address': address,
        'net_mode': netMode,
        'tag': 'pending',
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v2/eth/transaction/count',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = hexToInt(a['data']['result'].toString());
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 广播交易（ETH 类）
  Future<MessageModel> sendTxEth(
    String coinType,
    String signHash,
    String netMode, {
    String? rpc,
  }) async {
    try {
      if (rpc != null) {
        return await EthAPI.init(null, rpc, null).sendTransaction(signHash);
      }
      final params = {
        'coin': coinType,
        'signed_tx': signHash,
        'net_mode': netMode,
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v2/eth/raw/transaction',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = a['data']['result'].toString();
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取交易收据（ETH 类）
  Future<MessageModel> getTransactionReceiptEth(
    String coinType,
    String txHash, {
    bool isTest = false,
    String? rpc,
  }) async {
    try {
      if (rpc != null) {
        return await EthAPI.init(null, rpc, null).getTransactionReceipt(txHash);
      }
      final params = {
        'tx_hash': txHash,
        'coin': coinType,
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v2/eth/transaction/receipt',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 ETH 类 gasPrice
  Future<MessageModel> getGasPriceEth(
    String coinType, {
    bool isTest = false,
    String? rpc,
  }) async {
    try {
      if (rpc != null) {
        return await EthAPI.init(null, rpc, null).getGasPrice();
      }
      final params = {
        'coin': coinType,
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v2/eth/gas/price',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = hexToInt(a['data']['result'].toString());
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

}
