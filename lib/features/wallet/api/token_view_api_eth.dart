part of 'token_view_api.dart';

// ── Ethereum (ETH) ─────────────────────────────────────────────────────────

extension TokenViewApiEth on TokenViewApi {
  // ── 内部辅助 ────────────────────────────────────────────────────────────────

  /// 统一 POST 请求 + 通用响应解析（code 200 + data.error.code 检查）。
  /// [onSuccess] 从 `a['data']` 中提取业务数据；返回 null 表示 RPC 层报错。
  Future<MessageModel> _ethPost(
    String path,
    Map<String, dynamic> params, {
    required Object? Function(Map<String, dynamic> data) onSuccess,
  }) async {
    try {
      final a = await BaseApi.requestEmptyH.post(
        '$url$path',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        final result = onSuccess(a['data'] as Map<String, dynamic>);
        if (result != null) {
          mm.error = false;
          mm.data = result;
        } else {
          mm.data = a['data']['error']['message'];
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 解析含 `error.code` + `result` 的标准 RPC 响应，将 hex result 转为 BigInt。
  Object? _parseRpcHexResult(Map<String, dynamic> data) {
    if (data['error']['code'] != 0) return null;
    return hexToInt(data['result'].toString());
  }

  /// 解析含 `error.code` + `result` 的标准 RPC 响应，result 保持字符串。
  Object? _parseRpcStringResult(Map<String, dynamic> data) {
    if (data['error']['code'] != 0) return null;
    return data['result'].toString();
  }

  static String _toHex(BigInt v) => '0x${v.toRadixString(16)}';

  // ── 余额 ────────────────────────────────────────────────────────────────────

  /// 获取 ETH 类余额（含代币）
  Future<MessageModel> getBalanceEth(
    String coinType,
    String address,
    String contract, {
    bool returnDouble = false,
    bool isTest = false,
    String? rpc,
  }) async {
    if (rpc != null) {
      return await EthAPI.init(null, rpc, null).getBalance(address, contract);
    }
    final netMode = isTest ? 'test' : 'main';
    final String path;
    final Map<String, dynamic> params;

    if (contract.isEmpty) {
      path = 'v2/eth/balance';
      params = {
        'address': address,
        'coin': coinType.toLowerCase(),
        'net_mode': netMode,
        'tag': 'latest',
      };
    } else {
      path = 'v2/eth/call';
      params = {
        'from': address,
        'to': contract,
        'coin': coinType.toLowerCase(),
        'net_mode': netMode,
        'tag': 'latest',
      };
    }

    return _ethPost(
      path,
      params,
      onSuccess: (data) {
        String result = data['result'];
        if (result == '0x') result = '0x0';
        return hexToInt(result);
      },
    );
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

  // ── Gas 估算 ────────────────────────────────────────────────────────────────

  /// ETH 预估 gas（低级接口，直接传 params map）
  Future<MessageModel> getGasEstimateEth(Map<String, dynamic> params) async {
    return _ethPost(
      'v2/eth/estimate/gas',
      params,
      onSuccess: _parseRpcHexResult,
    );
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
    final gasPriceHex = _toHex(gasPrice);
    final gasHex = _toHex(gas);

    // 构建基础参数（contract 为空/非空共享）
    final params = <String, dynamic>{
      'from': from,
      'to': contract.isEmpty ? to : contract,
      'gas': gasHex,
      'coin': coinType,
      'net_mode': netMode,
      'id': AppGlobals.nextId,
    };

    // EIP-1559 vs legacy gas price
    params[use1559 ? 'maxFeePerGas' : 'gasPrice'] = gasPriceHex;

    // 合约调用：构建 transfer calldata
    if (contract.isNotEmpty) {
      final toAddress = strip0x(to);
      final methodId = bytesToHex(
        keccakAscii('transfer(address,uint256)'),
      ).substring(0, 8).toLowerCase();
      final valueHex = bytesToHex(padUint8ListTo32(unsignedIntToBytes(value)));
      params['data'] =
          '0x${methodId}000000000000000000000000$toAddress$valueHex';
    } else if (data.isNotEmpty) {
      params['data'] = data;
    }

    return await getGasEstimateEth(params);
  }

  // ── Nonce / 交易计数 ────────────────────────────────────────────────────────

  /// 获取交易数量（nonce 值）
  Future<MessageModel> getTransactionCountEth(
    String coinType,
    String address, {
    String netMode = 'main',
    String? rpc,
  }) async {
    if (rpc != null) {
      return await EthAPI.init(null, rpc, null).getTransactionCount(address);
    }
    final params = {
      'coin': coinType.toLowerCase(),
      'hex_address': address,
      'net_mode': netMode,
      'tag': 'pending',
    };
    return _ethPost(
      'v2/eth/transaction/count',
      params,
      onSuccess: _parseRpcHexResult,
    );
  }

  // ── 广播交易 ────────────────────────────────────────────────────────────────

  /// 广播交易（ETH 类）
  Future<MessageModel> sendTxEth(
    String coinType,
    String signHash,
    String netMode, {
    String? rpc,
  }) async {
    if (rpc != null) {
      return await EthAPI.init(null, rpc, null).sendTransaction(signHash);
    }
    final params = {
      'coin': coinType,
      'signed_tx': signHash,
      'net_mode': netMode,
    };
    return _ethPost(
      'v2/eth/raw/transaction',
      params,
      onSuccess: _parseRpcStringResult,
    );
  }

  // ── 交易收据 ────────────────────────────────────────────────────────────────

  /// 获取交易收据（ETH 类）
  Future<MessageModel> getTransactionReceiptEth(
    String coinType,
    String txHash, {
    bool isTest = false,
    String? rpc,
  }) async {
    if (rpc != null) {
      return await EthAPI.init(null, rpc, null).getTransactionReceipt(txHash);
    }
    final params = {
      'tx_hash': txHash,
      'coin': coinType,
      'net_mode': isTest ? 'test' : 'main',
    };
    return _ethPost(
      'v2/eth/transaction/receipt',
      params,
      onSuccess: (data) {
        return data;
      },
    );
  }

  // ── Gas Price ───────────────────────────────────────────────────────────────

  /// 获取 ETH 类 gasPrice
  Future<MessageModel> getGasPriceEth(
    String coinType, {
    bool isTest = false,
    String? rpc,
  }) async {
    if (rpc != null) {
      return await EthAPI.init(null, rpc, null).getGasPrice();
    }
    final params = {'coin': coinType, 'net_mode': isTest ? 'test' : 'main'};
    return _ethPost('v2/eth/gas/price', params, onSuccess: _parseRpcHexResult);
  }
}
