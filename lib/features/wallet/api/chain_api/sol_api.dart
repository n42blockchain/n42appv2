import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class SolApi {
  /// 获取账号信息
  Future<MessageModel> getAccountInfo(String address, {bool isTest = false}) async {
    final result = await baseRPCSol('getAccountInfo', [address, {'encoding': 'base64'}], isTest: isTest);
    final mm = resultToMessageModel(result);
    if (mm.error == false) mm.data = mm.data['value']['data'];
    return mm;
  }

  /// 获取最新区块 hash
  Future<MessageModel> getLatestBlockhash({bool isTest = false}) async {
    final result = await baseRPCSol('getLatestBlockhash', [], isTest: isTest);
    final mm = resultToMessageModel(result);
    if (mm.error == false) mm.data = mm.data['value']['blockhash'];
    return mm;
  }

  /// 获取余额（native 或 SPL Token）
  Future<MessageModel> getBalance(String address, String contract, {bool isTest = false}) async {
    if (contract == '') {
      final result = await baseRPCSol('getBalance', [address], isTest: isTest);
      final mm = resultToMessageModel(result);
      if (mm.error == false) mm.data = mm.data['value'];
      return mm;
    } else {
      final result = await baseRPCSol(
        'getTokenAccountsByOwner',
        [address, {'mint': contract}, {'encoding': 'jsonParsed'}],
        isTest: isTest,
      );
      final mm = resultToMessageModel(result);
      if (mm.error == false) {
        final List<dynamic> valueMap = mm.data['value'] as List<dynamic>? ?? [];
        if (valueMap.isNotEmpty) {
          mm.data = BigInt.parse(valueMap[0]['account']['data']['parsed']['info']['tokenAmount']['amount'].toString());
        } else {
          mm.data = BigInt.zero;
        }
      }
      return mm;
    }
  }

  /// 计算 gas 费
  Future<MessageModel> getFeeForMessage(String signMessage, {bool isTest = false}) async {
    final result = await baseRPCSol('getFeeForMessage', [signMessage], isTest: isTest);
    final mm = resultToMessageModel(result);
    if (mm.error == false) mm.data = mm.data['value'];
    return mm;
  }

  /// 虚拟交易
  Future<MessageModel> simulateTransaction(String signMessage, {bool isTest = false}) async {
    final result = await baseRPCSol('simulateTransaction', [signMessage, {'sigVerify': true}], isTest: isTest);
    final mm = resultToMessageModel(result);
    if (mm.error == false) mm.data = mm.data['value'];
    return mm;
  }

  /// 发起交易（明确禁用重试，防止双发）
  Future<MessageModel> sendTransaction(String signMessage, {bool isTest = false}) async {
    return resultToMessageModel(
      await baseRPCSol('sendTransaction', [signMessage, {'encoding': 'base58'}], isTest: isTest, enableRetry: false),
    );
  }

  Future<Result<dynamic, AppError>> baseRPCSol(
    String method,
    dynamic value, {
    bool? isTest,
    bool enableRetry = true,
  }) async {
    try {
      final postData = {'jsonrpc': '2.0', 'method': method, 'params': value, 'id': AppGlobals.nextId};
      final url = RequestUrl().getUrl2(CoinType.SOL.name, 'rpc', isTest: isTest);
      final data = await BaseApi.requestEmptyH.post(url, params: {}, data: postData, enableRetry: enableRetry);
      if (data.containsKey('error')) {
        return Result.failure(AppError.blockchain(
          data['message']?.toString() ?? 'RPC error',
          code: 'SOL_RPC_ERROR',
          originalError: data['error'],
        ));
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(AppError.network(e.toString(), originalError: e, stackTrace: st));
    }
  }
}
