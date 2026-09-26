import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class TonApi {
  String url = "";
  TonApi({bool isTest = false}) {
    // TON RPC now goes through server proxy — API key injected server-side.
    url = isTest
        ? RequestUrl().getUrl2(CoinType.TON.name, "rpc", isTest: true)
        : '${ProxyConfig.tonRpc}/';
  }
  Future<MessageModel> getBalanceTon(String address) async {
    final result = await baseRPCTon("getAddressBalance", {
      "address": address,
    }, 'jsonRPC');
    final rmm = resultToMessageModel(result);
    if (rmm.error == false) {
      rmm.data = BigInt.parse(rmm.data);
    }
    return rmm;
  }

  Future<MessageModel> getSeqnoTon(String address) async {
    final result = await baseRPC2Ton({
      "address": address,
      "method": "seqno",
      "stack": [],
    }, 'runGetMethod');
    final rmm = resultToMessageModel(result);
    if (rmm.error == false) {
      if (rmm.data['exit_code'] == 0) {
        rmm.data = int.parse(rmm.data['stack'][0][1]);
      } else {
        rmm.data = 0;
      }
    }
    return rmm;
  }

  //发送交易（明确禁用重试，防止双发）
  Future<MessageModel> submitTon(String signStr) async {
    final result = await baseRPC2Ton(
      {"boc": signStr},
      'sendBoc',
      enableRetry: false,
    );
    final rmm = resultToMessageModel(result);
    if (rmm.error == false) {
      rmm.data = rmm.data['@extra'];
    }
    return rmm;
  }

  Future<Result<dynamic, AppError>> baseRPCTon(
    String method,
    dynamic value,
    String path, {
    bool enableRetry = true,
  }) async {
    try {
      Map<String, dynamic> postData = {
        "jsonrpc": "2.0",
        "method": method,
        "params": value,
        "id": AppGlobals.nextId,
      };
      final data = await BaseApi.requestEmptyH.post(
        url + path,
        params: {},
        data: postData,
        enableRetry: enableRetry,
      );
      if (data['ok'] == false) {
        return Result.failure(
          AppError.blockchain(
            data['description']?.toString() ??
                data['error']?.toString() ??
                'RPC error',
            code: 'TON_RPC_ERROR',
            originalError: data,
          ),
        );
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(
        AppError.network(e.toString(), originalError: e, stackTrace: st),
      );
    }
  }

  Future<Result<dynamic, AppError>> baseRPC2Ton(
    dynamic value,
    String path, {
    bool enableRetry = true,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        url + path,
        params: {},
        data: value,
        header: {'Content-Type': 'application/json'},
        enableRetry: enableRetry,
      );
      if (data['ok'] == false) {
        return Result.failure(
          AppError.blockchain(
            data['description']?.toString() ??
                data['error']?.toString() ??
                'RPC error',
            code: 'TON_RPC2_ERROR',
            originalError: data,
          ),
        );
      }
      return Result.success(data['result']);
    } catch (e, st) {
      // BaseHttp converts DioException to a localized String upstream.
      return Result.failure(
        AppError.network(e.toString(), originalError: e, stackTrace: st),
      );
    }
  }
}
