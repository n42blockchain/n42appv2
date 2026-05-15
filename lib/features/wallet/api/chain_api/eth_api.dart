import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/explorer_response_utils.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:web3dart/web3dart.dart';

class EthAPI {
  String? cType;
  String? rpc;
  String? api;

  EthAPI();
  EthAPI.init(this.cType, this.rpc, this.api);

  /// Resolve coinType with fallback to instance cType.
  String? _coin(String? coinType) => coinType ?? cType;

  /// Execute RPC call and parse hex result to BigInt on success.
  Future<MessageModel> _rpcWithHexParse(
    String method,
    dynamic params, {
    String? coinType,
    bool isTest = false,
    bool enableRetry = true,
  }) async {
    final result = await baseRPCEth(method, params, coinType: _coin(coinType), isTest: isTest, enableRetry: enableRetry);
    final mm = resultToMessageModel(result);
    if (mm.error == false) mm.data = hexToInt(mm.data);
    return mm;
  }

  /// 获取余额（native 或 ERC-20 合约）
  Future<MessageModel> getBalance(String address, String contract, {bool isTest = false, String? coinType}) async {
    if (contract.isEmpty) {
      return _rpcWithHexParse('eth_getBalance', [address, 'latest'], coinType: coinType, isTest: isTest);
    }
    final addr = strip0x(address);
    return _rpcWithHexParse(
      'eth_call',
      [{'from': address, 'to': contract, 'data': '0x70a08231000000000000000000000000$addr'}, 'latest'],
      coinType: coinType,
      isTest: isTest,
    );
  }

  /// 获取 gasPrice
  Future<MessageModel> getGasPrice({bool isTest = false, String? coinType}) async {
    return _rpcWithHexParse('eth_gasPrice', [], coinType: coinType, isTest: isTest);
  }

  /// 估算 gas limit
  Future<MessageModel> getGasLimit(
    String from,
    String to,
    BigInt gasPrice,
    BigInt value,
    BigInt gas, {
    String? coinType,
    String contract = '',
    String data = '',
    bool isTest = false,
    bool addLatest = true,
  }) async {
    final coin = _coin(coinType);
    final gasPriceHex = '0x${gasPrice.toRadixString(16)}';
    final gasPriceKey = get1559WithChainSymbol(coin ?? '') ? 'maxFeePerGas' : 'gasPrice';
    final gasHex = '0x${gas.toRadixString(16)}';

    final Map<String, dynamic> params;
    if (contract.isEmpty) {
      params = {
        'from': from,
        'to': to,
        'gas': gasHex,
        'value': '0x${value.toRadixString(16)}',
        gasPriceKey: gasPriceHex,
        if (data.isNotEmpty) 'data': data,
      };
    } else {
      final toAddress = strip0x(to);
      final selector = bytesToHex(keccakAscii('transfer(address,uint256)')).substring(0, 8).toLowerCase();
      final valueHex = bytesToHex(padUint8ListTo32(unsignedIntToBytes(value)));
      params = {
        'from': from,
        'to': contract,
        'gas': gasHex,
        'data': '0x${selector}000000000000000000000000$toAddress$valueHex',
        gasPriceKey: gasPriceHex,
      };
    }

    final rpcParams = addLatest ? [params, 'latest'] : [params];
    return _rpcWithHexParse('eth_estimateGas', rpcParams, coinType: coin, isTest: isTest);
  }

  Future<MessageModel> getGasLimitByMap(Map<String, dynamic> map, {String? coinType, bool isTest = false, bool addLatest = true}) async {
    final param = addLatest ? [map, 'latest'] : [map];
    return _rpcWithHexParse('eth_estimateGas', param, coinType: coinType, isTest: isTest);
  }

  /// 获取交易收据
  Future<MessageModel> getTransactionReceipt(String txHash, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth('eth_getTransactionReceipt', [txHash], coinType: _coin(coinType), isTest: isTest),
    );
  }

  /// 获取交易信息
  Future<MessageModel> getTransactionByHash(String txHash, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth('eth_getTransactionByHash', [txHash], coinType: _coin(coinType), isTest: isTest),
    );
  }

  /// 获取 nonce 值
  Future<MessageModel> getTransactionCount(String address, {String? coinType, bool isTest = false}) async {
    return _rpcWithHexParse('eth_getTransactionCount', [address, 'latest'], coinType: coinType, isTest: isTest);
  }

  /// 发送交易，返回交易 hash（明确禁用重试，防止双发）
  Future<MessageModel> sendTransaction(String value, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth('eth_sendRawTransaction', [value], coinType: _coin(coinType), isTest: isTest, enableRetry: false),
    );
  }

  /// Raw eth_call，用于 AA 操作（如从 EntryPoint 获取 nonce）
  Future<MessageModel> ethCallRaw(String to, String data, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth('eth_call', [{'to': to, 'data': data}, 'latest'], coinType: _coin(coinType), isTest: isTest),
    );
  }

  /// 获取合约代码（用于检查智能账户是否已部署）
  Future<MessageModel> getCode(String address, {String? coinType, bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCEth('eth_getCode', [address, 'latest'], coinType: _coin(coinType), isTest: isTest),
    );
  }

  Future<Result<dynamic, AppError>> baseRPCEth(
    String method,
    dynamic value, {
    String? coinType,
    bool? isTest,
    bool enableRetry = true,
  }) async {
    try {
      final String url;
      if (coinType == null) {
        final rpcUrl = rpc;
        if (rpcUrl == null || rpcUrl.isEmpty) {
          return Result.failure(AppError.blockchain('ETH RPC URL is not configured', code: 'ETH_NO_RPC_URL'));
        }
        url = rpcUrl;
      } else {
        url = RequestUrl().getUrl2(coinType, 'rpc', isTest: isTest);
      }
      final postData = {'jsonrpc': '2.0', 'method': method, 'params': value, 'id': AppGlobals.nextId};
      final data = await BaseApi.requestEmptyH.post(url, params: {}, data: postData, enableRetry: enableRetry);
      if (data.containsKey('error')) {
        final errorObj = data['error'];
        final errorMsg = errorObj is Map
            ? (errorObj['message']?.toString() ?? errorObj.toString())
            : errorObj?.toString() ?? 'RPC error';
        return Result.failure(AppError.blockchain(errorMsg, code: 'ETH_RPC_ERROR', originalError: data['error']));
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(AppError.network(e.toString(), originalError: e, stackTrace: st));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // ERC-20 合约元数据读取（name / symbol / decimals）
  // 仅支持 EVM 兼容链，通过原始 eth_call 实现，无需完整 ABI 文件。
  // ──────────────────────────────────────────────────────────────

  /// 从 EVM 合约地址读取 ERC-20 Token 元信息。
  ///
  /// 成功时返回 `{name, symbol, decimals}`，失败（非合约地址/RPC 超时）返回 null。
  static Future<({String name, String symbol, int decimals})?> getErc20TokenInfo(
    String contractAddress,
    String rpcUrl,
  ) async {
    try {
      final ethAPI = EthAPI.init(null, rpcUrl, null);
      final addr = contractAddress.toLowerCase();

      // 并行调用 name() / symbol() / decimals() 三个 view 函数
      // 函数选择器（keccak256 前 4 字节）：
      //   name()     → 0x06fdde03
      //   symbol()   → 0x95d89b41
      //   decimals() → 0x313ce567
      final results = await Future.wait([
        ethAPI.baseRPCEth('eth_call', [{'to': addr, 'data': '0x06fdde03'}, 'latest']),
        ethAPI.baseRPCEth('eth_call', [{'to': addr, 'data': '0x95d89b41'}, 'latest']),
        ethAPI.baseRPCEth('eth_call', [{'to': addr, 'data': '0x313ce567'}, 'latest']),
      ]);

      if (results.any((r) => r.isFailure)) return null;

      final nameHex = results[0].valueOrNull?.toString() ?? '';
      final symbolHex = results[1].valueOrNull?.toString() ?? '';
      final decimalsHex = results[2].valueOrNull?.toString() ?? '';

      final name = _abiDecodeString(nameHex);
      final symbol = _abiDecodeString(symbolHex);
      final decimals = _abiDecodeUint8(decimalsHex);

      // 至少 symbol 非空才认为是合法的 ERC-20 合约
      if (symbol.isEmpty && name.isEmpty) return null;

      return (name: name, symbol: symbol, decimals: decimals);
    } catch (_) {
      return null;
    }
  }

  /// ABI 解码 `string` 返回值（动态类型）。
  ///
  /// 格式：[32B offset][32B length][data bytes]（均为 hex，去掉 0x 前缀后操作）
  static String _abiDecodeString(String hex) {
    try {
      final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
      if (clean.length < 128) return '';
      final lengthHex = clean.substring(64, 128);
      final length = int.parse(lengthHex, radix: 16);
      if (length == 0) return '';
      if (clean.length < 128 + length * 2) return '';
      final dataHex = clean.substring(128, 128 + length * 2);
      final bytes = Uint8List.fromList(
        List.generate(dataHex.length ~/ 2, (i) => int.parse(dataHex.substring(i * 2, i * 2 + 2), radix: 16)),
      );
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return '';
    }
  }

  /// ABI 解码 `uint8` 返回值（定长 32 字节，取低 1 字节）。
  static int _abiDecodeUint8(String hex) {
    try {
      final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
      if (clean.isEmpty) return 18;
      return int.parse(clean.substring(clean.length > 2 ? clean.length - 2 : 0), radix: 16);
    } catch (_) {
      return 18; // ERC-20 默认 18 位小数
    }
  }

  /// 获取 address 的交易列表
  Future<MessageModel> getTxList(
    String address, {
    String? coinType,
    String contractAddress = '',
    bool isTest = false,
    int page = 1,
    int offset = 10,
  }) async {
    try {
      final hasContract = contractAddress.isNotEmpty;
      final normalizedCoin = _coin(coinType)?.toUpperCase();
      final proxyChain = !isTest
          ? switch (normalizedCoin) {
              'ETH' => 'eth',
              'BNB' => 'bnb',
              'BASE' => 'base',
              _ => null,
            }
          : null;
      final params = proxyChain == null
          ? <String, dynamic>{
              'address': address,
              'action': hasContract ? 'tokentx' : 'txlist',
              'module': 'account',
              'page': page,
              'offset': offset,
              if (hasContract) 'contractaddress': contractAddress,
            }
          : <String, dynamic>{
              'address': address,
              'page': '$page',
              'size': '$offset',
              if (hasContract) 'contractAddress': contractAddress,
            };
      final resolvedCoin = _coin(coinType);
      final apiUrl = proxyChain == null
          ? (resolvedCoin == null
              ? (api ?? '')
              : RequestUrl().getUrl2(resolvedCoin, 'api', isTest: isTest))
          : (hasContract
              ? ProxyConfig.explorerTokentx(proxyChain)
              : ProxyConfig.explorerTxlist(proxyChain));
      final data = await BaseApi.requestEmptyH.get(apiUrl, params: params);
      if (data.containsKey('error')) {
        return MessageModel()..error = true..data = data['error'];
      }
      final items = extractExplorerItems(data);
      if (items.isEmpty && !hasExplorerItemContainer(data)) {
        return MessageModel()
          ..error = true
          ..data = data['message'] ?? data['msg'];
      }
      return MessageModel()..data = items;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
