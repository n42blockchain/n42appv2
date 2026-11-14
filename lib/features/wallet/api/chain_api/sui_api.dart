import 'package:fast_base58/fast_base58.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class SuiApi {
  String url = "";

  /// Optional JSON-RPC transport (tests); defaults to the shared HTTP client.
  final Future<dynamic> Function(String url, Map<String, dynamic> body)? post;
  SuiApi({bool isTest = false, this.post}) {
    url = RequestUrl().getUrl2(CoinType.SUI.name, "rpc", isTest: isTest);
  }
  Future<MessageModel> getBalanceSui(String address) async {
    final result = await baseRPCSui("suix_getBalance", [
      address,
      "0x2::sui::SUI",
    ]);
    final rmm = resultToMessageModel(result);
    if (rmm.error == false) {
      rmm.data = BigInt.parse(rmm.data['totalBalance']);
    }
    return rmm;
  }

  Future<MessageModel> getGasPriceSui() async {
    final result = await baseRPCSui("suix_getReferenceGasPrice", []);
    final rmm = resultToMessageModel(result);
    if (rmm.error == false) {
      rmm.data = BigInt.parse(rmm.data);
    }
    return rmm;
  }

  //用户所有的对象，NFT，合约等
  Future<List<dynamic>> getOwnedObjects(String address) async {
    final objects = <dynamic>[];
    final cursors = <String>{};
    String? cursor;
    while (true) {
      final result = await baseRPCSui("suix_getOwnedObjects", [
        address,
        {
          "filter": {"StructType": "0x2::coin::Coin<0x2::sui::SUI>"},
          "options": {"showContent": true},
        },
        cursor,
        50,
      ]);
      final response = resultToMessageModel(result);
      final page = response.data;
      if (response.error ||
          page is! Map ||
          page['data'] is! List ||
          page['hasNextPage'] is! bool) {
        return [];
      }
      objects.addAll(page['data'] as List);
      if (page['hasNextPage'] == false) return objects;
      final next = page['nextCursor'];
      if (next is! String || next.isEmpty || !cursors.add(next)) return [];
      cursor = next;
    }
  }

  //模拟交易
  Future<MessageModel> dryRunTransactionBlock(String signStr) async {
    final result = await baseRPCSui("sui_dryRunTransactionBlock", [signStr]);
    final rmm = resultToMessageModel(result);
    if (rmm.error) return rmm;
    final data = rmm.data;
    final effects = data is Map ? data['effects'] : null;
    final status = effects is Map ? effects['status'] : null;
    final gas = effects is Map ? effects['gasUsed'] : null;
    if (status is! Map || status['status'] != 'success' || gas is! Map) {
      return MessageModel.error()..data = 'Sui simulation was not successful';
    }
    BigInt? cost(String key) {
      final value = gas[key];
      if (value is! String || !RegExp(r'^[0-9]+$').hasMatch(value)) return null;
      return BigInt.tryParse(value);
    }

    final computation = cost('computationCost');
    final storage = cost('storageCost');
    final rebate = cost('storageRebate');
    if (computation == null || storage == null || rebate == null) {
      return MessageModel.error()..data = 'Invalid Sui simulation gas usage';
    }
    final net = computation + storage - rebate;
    return MessageModel()..data = net.isNegative ? BigInt.zero : net;
  }

  //交易上链（明确禁用重试，防止双发）
  Future<MessageModel> submit(String transactionBlock, String signStr) async {
    final response = resultToMessageModel(
      await baseRPCSui("sui_executeTransactionBlock", [
        transactionBlock,
        [signStr],
        {"showEffects": true, "showEvents": true},
      ], enableRetry: false),
    );
    if (response.error) return response;
    final data = response.data;
    final digest = data is Map ? data['digest'] : null;
    final effects = data is Map ? data['effects'] : null;
    final status = effects is Map ? effects['status'] : null;
    var validDigest = false;
    if (digest is String) {
      try {
        final bytes = Base58Decode(digest);
        validDigest = bytes.length == 32 && Base58Encode(bytes) == digest;
      } catch (_) {
        // A malformed RPC response is not evidence of successful execution.
      }
    }
    if (!validDigest || status is! Map || status['status'] != 'success') {
      return MessageModel.error()
        ..data = 'Sui transaction execution was not confirmed';
    }
    return response;
  }

  /// Read one transaction with its effects and input (for the sender).
  Future<MessageModel> getTransactionBlock(String txHash) async {
    return resultToMessageModel(
      await baseRPCSui("sui_getTransactionBlock", [
        txHash,
        {
          "showInput": true,
          "showRawInput": false,
          "showEffects": true,
          "showEvents": false,
          "showObjectChanges": false,
          "showBalanceChanges": false,
          "showRawEffects": false,
        },
      ]),
    );
  }

  Future<Result<dynamic, AppError>> baseRPCSui(
    String method,
    dynamic value, {
    bool enableRetry = true,
  }) async {
    try {
      Map<String, dynamic> postData = {
        "jsonrpc": "2.0",
        "method": method,
        "params": value,
        "id": AppGlobals.nextId,
      };
      final data = post != null
          ? await post!(url, postData)
          : await BaseApi.requestEmptyH.post(
              url,
              params: {},
              data: postData,
              enableRetry: enableRetry,
            );
      if (data.containsKey('error')) {
        return Result.failure(
          AppError.blockchain(
            data['error']?.toString() ?? 'RPC error',
            code: 'SUI_RPC_ERROR',
            originalError: data['error'],
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
