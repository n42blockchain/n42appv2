import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fast_base58/fast_base58.dart';

const String _kTronProApiKey = String.fromEnvironment(
  'TRON_PRO_API_KEY',
  defaultValue: '',
);
const Duration _kProxyReadTimeout = Duration(seconds: 4);
const Duration _kProxyWriteTimeout = Duration(seconds: 6);

class TrxApi {
  late String url;
  late Map<String, String> header;

  TrxApi() {
    url = '';
    header = {
      'content-type': 'application/json',
      if (_kTronProApiKey.isNotEmpty) 'TRON-PRO-API-KEY': _kTronProApiKey,
    };
  }

  /// Helper: call baseRPCEth and convert hex result to BigInt
  Future<MessageModel> _rpcHexResult(
    String method,
    List<dynamic> params, {
    bool? isTest,
  }) async {
    final result = await baseRPCEth(method, params, isTest: isTest);
    final mm = resultToMessageModel(result);
    if (mm.error == false) mm.data = hexToInt(mm.data);
    return mm;
  }

  //获取余额
  Future<MessageModel> getBalanceTrx(
    String address,
    String contract, {
    bool isTest = false,
  }) async {
    address = getAddressTron(address);
    if (contract == '') {
      return _rpcHexResult('eth_getBalance', [
        '0x$address',
        'latest',
      ], isTest: isTest);
    }
    contract = getAddressTron(contract);
    final addr = strip0x(address);
    return _rpcHexResult('eth_call', [
      {
        'from': '0x$address',
        'to': '0x$contract',
        'data': '0x70a08231000000000000000000000000$addr',
      },
      'latest',
    ], isTest: isTest);
  }

  Future<MessageModel> getGasPriceTrx({bool isTest = false}) async {
    return _rpcHexResult('eth_gasPrice', [], isTest: isTest);
  }

  Future<MessageModel> getGasEstimateTrx(
    String from,
    String to,
    BigInt gasPrice,
    BigInt value,
    BigInt gas, {
    String contract = '',
    bool isTest = false,
  }) async {
    from = getAddressTron(from);
    to = getAddressTron(to);

    final Map<String, dynamic> params;
    if (contract == '') {
      params = {
        'from': from,
        'to': to,
        'gasPrice': '0x${gasPrice.toRadixString(16)}',
        'gas': '0x${gas.toRadixString(16)}',
        'value': '0x${value.toRadixString(16)}',
      };
    } else {
      contract = getAddressTron(contract);
      final selector = bytesToHex(
        keccakAscii('transfer(address,uint256)'),
      ).substring(0, 8).toLowerCase();
      final valueHex = bytesToHex(padUint8ListTo32(unsignedIntToBytes(value)));
      params = {
        'from': '0x$from',
        'to': '0x$contract',
        'gasPrice': '0x${gasPrice.toRadixString(16)}',
        'gas': '0x${gas.toRadixString(16)}',
        'data': '0x${selector}0000000000000000000000$to$valueHex',
      };
    }
    return _rpcHexResult('eth_estimateGas', [params], isTest: isTest);
  }

  //获取最新块信息
  Future<MessageModel> getBlockNowTrx({bool isTest = false}) async {
    final proxyUrl = ProxyConfig.trxPath('wallet/getnowblock', isTest: isTest);
    try {
      final proxyData = await BaseApi.requestEmptyH.post(
        proxyUrl,
        params: {},
        header: ProxyConfig.mergeAuthHeaders(proxyUrl, header),
        timeout: _kProxyReadTimeout,
      );
      if (proxyData['block_header'] != null) {
        return MessageModel()..data = proxyData['block_header'];
      }
    } catch (e) {
      // Fall back to direct TronGrid when proxy is unavailable.
      AppLogger.w('TrxApi', 'getBlockNowTrx proxy error: $e');
    }

    try {
      final urlStr = RequestUrl().getUrl2(
        CoinType.TRX.name,
        'rpc',
        isTest: isTest,
      );
      final data = await BaseApi.requestEmptyH.post(
        '$urlStr/wallet/getnowblock',
        params: {},
        header: header,
      );
      if (data['block_header'] == null) {
        return MessageModel.error()..data = data['message'];
      }
      return MessageModel()..data = data['block_header'];
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<MessageModel> createTransaction(
    String fromAddress,
    String toAddress,
    int amount, {
    bool isTest = false,
  }) async {
    final proxyUrl = ProxyConfig.trxPath(
      'wallet/createtransaction',
      isTest: isTest,
    );
    final requestBody = {
      'owner_address': fromAddress,
      'to_address': toAddress,
      'amount': amount,
      'visible': true,
    };

    try {
      final proxyData = await BaseApi.requestEmptyH.post(
        proxyUrl,
        params: {},
        data: requestBody,
        header: ProxyConfig.mergeAuthHeaders(proxyUrl, header),
        timeout: _kProxyWriteTimeout,
      );
      final txid = proxyData['txid']?.toString() ?? '';
      if (proxyData['result'] != false && txid.isNotEmpty) {
        return MessageModel()..data = txid;
      }
    } catch (e) {
      // Fall back to direct TronGrid when proxy is unavailable.
      AppLogger.w('TrxApi', 'createTransaction proxy error: $e');
    }

    try {
      final apiUrl = RequestUrl().getUrl2(
        CoinType.TRX.name,
        'api',
        isTest: isTest,
      );
      final rData = await BaseApi.requestEmptyH.post(
        '$apiUrl/wallet/createtransaction',
        params: {},
        data: requestBody,
      );
      if (rData['result'] == false) {
        return MessageModel()
          ..error = true
          ..data = rData['message'];
      }
      return MessageModel()..data = rData['txid'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  //广播交易
  Future<MessageModel> sendTxTrx(String signStr, {bool isTest = false}) async {
    final proxyUrl = ProxyConfig.trxPath(
      'wallet/broadcasttransaction',
      isTest: isTest,
    );
    final dynamic requestBody;
    try {
      requestBody = jsonDecode(signStr);
    } catch (e) {
      return MessageModel.error()..data = 'Invalid transaction data: $e';
    }

    try {
      final proxyData = await BaseApi.requestEmptyH.post(
        proxyUrl,
        params: {},
        data: requestBody,
        header: ProxyConfig.mergeAuthHeaders(proxyUrl, header),
        timeout: _kProxyWriteTimeout,
      );
      final txid = proxyData['txid']?.toString() ?? '';
      if (proxyData['result'] != false && txid.isNotEmpty) {
        return MessageModel()..data = txid;
      }
    } catch (e) {
      // Fall back to direct TronGrid when proxy is unavailable.
      AppLogger.w('TrxApi', 'sendTxTrx proxy error: $e');
    }

    try {
      final urlStr = RequestUrl().getUrl2(
        CoinType.TRX.name,
        'api',
        isTest: isTest,
      );
      final rData = await BaseApi.requestEmptyH.post(
        '$urlStr/wallet/broadcasttransaction',
        params: {},
        data: requestBody,
        header: header,
      );
      if (rData['result'] == false) {
        return MessageModel()
          ..error = true
          ..data = rData['Error'];
      }
      return MessageModel()..data = rData['txid'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<Result<dynamic, AppError>> baseRPCEth(
    String method,
    dynamic value, {
    bool? isTest,
    bool enableRetry = true,
  }) async {
    final postData = {
      'jsonrpc': '2.0',
      'method': method,
      'params': value,
      'id': AppGlobals.nextId,
    };
    final proxyUrl = ProxyConfig.trxPath('jsonrpc', isTest: isTest ?? false);

    try {
      final data = await BaseApi.requestEmptyH.post(
        proxyUrl,
        params: {},
        data: postData,
        header: ProxyConfig.mergeAuthHeaders(proxyUrl, header),
        enableRetry: enableRetry,
        timeout: _kProxyReadTimeout,
      );
      if (!data.containsKey('error')) {
        return Result.success(data['result']);
      }
    } catch (e) {
      // Fall back to direct TronGrid when proxy is unavailable.
      AppLogger.w('TrxApi', 'baseRPCEth proxy error: $e');
    }

    try {
      final urlStr =
          '${RequestUrl().getUrl2("TRX", "rpc", isTest: isTest)}/jsonrpc';
      final data = await BaseApi.requestEmptyH.post(
        urlStr,
        params: {},
        data: postData,
        header: header,
        enableRetry: enableRetry,
      );
      if (data.containsKey('error')) {
        final errorMsg = data['error'] is Map
            ? (data['error']['message']?.toString() ?? 'RPC error')
            : data['error']?.toString() ?? 'RPC error';
        return Result.failure(
          AppError.blockchain(
            errorMsg,
            code: 'TRX_RPC_ERROR',
            originalError: data['error'],
          ),
        );
      }
      return Result.success(data['result']);
    } catch (e, st) {
      return Result.failure(
        AppError.network(e.toString(), originalError: e, stackTrace: st),
      );
    }
  }

  String getAddressTron(String address) {
    final decodeStr = Base58Decode(address);
    final hexAddress = bytesToHex(Uint8List.fromList(decodeStr));
    return '41${hexAddress.substring(2, 42).toLowerCase()}';
  }
}
