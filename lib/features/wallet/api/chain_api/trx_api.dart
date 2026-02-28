import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fast_base58/fast_base58.dart';

class TrxApi {
  late String url;
  late Map<String, String> header;

  TrxApi() {
    url = '';
    header = {'content-type': 'application/json', 'TRON-PRO-API-KEY': 'c0093859-4ae0-47b5-8650-6b14fec2d771'};
  }

  /// Helper: call baseRPCEth and convert hex result to BigInt
  Future<MessageModel> _rpcHexResult(String method, List<dynamic> params, {bool? isTest}) async {
    final result = await baseRPCEth(method, params, isTest: isTest);
    final mm = resultToMessageModel(result);
    if (mm.error == false) mm.data = hexToInt(mm.data);
    return mm;
  }

  //获取余额
  Future<MessageModel> getBalanceTrx(String address, String contract, {bool isTest = false}) async {
    address = getAddressTron(address);
    if (contract == '') {
      return _rpcHexResult('eth_getBalance', ['0x$address', 'latest']);
    }
    contract = getAddressTron(contract);
    final addr = strip0x(address);
    return _rpcHexResult('eth_call', [
      {'from': '0x$address', 'to': '0x$contract', 'data': '0x70a082310000000000000000000000$addr'},
      'latest',
    ]);
  }

  Future<MessageModel> getGasPriceTrx({bool isTest = false}) async {
    return _rpcHexResult('eth_gasPrice', [], isTest: isTest);
  }

  Future<MessageModel> getGasEstimateTrx(
    String from, String to, BigInt gasPrice, BigInt value, BigInt gas, {
    String contract = '', bool isTest = false,
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
      final selector = bytesToHex(keccakAscii('transfer(address,uint256)')).substring(0, 8).toLowerCase();
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
    try {
      final urlStr = RequestUrl().getUrl2(CoinType.TRX.name, 'rpc', isTest: isTest);
      final data = await BaseApi.requestEmptyH.post('$urlStr/wallet/getnowblock', params: {}, header: header);
      if (data['block_header'] == null) {
        return MessageModel.error()..data = data['message'];
      }
      return MessageModel()..data = data['block_header'];
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<MessageModel> createTransaction(String fromAddress, String toAddress, int amount, {bool isTest = false}) async {
    try {
      final apiUrl = RequestUrl().getUrl2(CoinType.TRX.name, 'api', isTest: isTest);
      final rData = await BaseApi.requestEmptyH.post(
        '$apiUrl/wallet/createtransaction',
        params: {},
        data: {'owner_address': fromAddress, 'to_address': toAddress, 'amount': amount, 'visible': true},
      );
      if (rData['result'] == false) {
        return MessageModel()..error = true..data = rData['message'];
      }
      return MessageModel()..data = rData['txid'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  //广播交易
  Future<MessageModel> sendTxTrx(String signStr, {bool isTest = false}) async {
    try {
      final urlStr = RequestUrl().getUrl2(CoinType.TRX.name, 'api', isTest: isTest);
      final rData = await BaseApi.requestEmptyH.post(
        '$urlStr/wallet/broadcasttransaction',
        params: {},
        data: jsonDecode(signStr),
        header: header,
      );
      if (rData['result'] == false) {
        return MessageModel()..error = true..data = rData['Error'];
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
    try {
      final postData = {'jsonrpc': '2.0', 'method': method, 'params': value, 'id': AppGlobals.nextId};
      final urlStr = '${RequestUrl().getUrl2("TRX", "rpc", isTest: isTest)}/jsonrpc';
      final data = await BaseApi.requestEmptyH.post(urlStr, params: {}, data: postData, header: header, enableRetry: enableRetry);
      if (data.containsKey('error')) {
        final errorMsg = data['error'] is Map
            ? (data['error']['message']?.toString() ?? 'RPC error')
            : data['error']?.toString() ?? 'RPC error';
        return Result.failure(AppError.blockchain(errorMsg, code: 'TRX_RPC_ERROR', originalError: data['error']));
      }
      return Result.success(data['result']);
    } catch (e, st) {
      return Result.failure(AppError.network(e.toString(), originalError: e, stackTrace: st));
    }
  }

  String getAddressTron(String address) {
    final decodeStr = Base58Decode(address);
    final hexAddress = bytesToHex(Uint8List.fromList(decodeStr));
    return '41${hexAddress.substring(2, 42).toLowerCase()}';
  }
}
