import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class SuiApi {
  String url = "";
  SuiApi({bool isTest = false}) {
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
    final result = await baseRPCSui("suix_getOwnedObjects", [
      address,
      {
        "filter": {
          "MatchAll": [
            {"StructType": "0x2::coin::Coin<0x2::sui::SUI>"},
            {"AddressOwner": address},
          ],
        },
        "options": {
          "showType": true,
          "showOwner": true,
          "showPreviousTransaction": true,
          "showContent": false,
        },
      },
    ]);
    final rmm = resultToMessageModel(result);
    if (rmm.error == false) {
      return rmm.data['data'] ?? [];
    }
    return [];
  }

  //模拟交易
  Future<MessageModel> dryRunTransactionBlock(String signStr) async {
    final result = await baseRPCSui("sui_dryRunTransactionBlock", [signStr]);
    final rmm = resultToMessageModel(result);
    if (rmm.error == false) {
      if (rmm.data['effects']['status'] == 'success') {
        //computationCost + storageCost - storageRebate
        int computationCost = int.parse(
          rmm.data['effects']['gasUsed']['computationCost'],
        );
        int storageCost = int.parse(
          rmm.data['effects']['gasUsed']['storageCost'],
        );
        int storageRebate = int.parse(
          rmm.data['effects']['gasUsed']['storageRebate'],
        );
        rmm.data = BigInt.from(computationCost + storageCost - storageRebate);
      }
    }
    return rmm;
  }

  //交易上链（明确禁用重试，防止双发）
  Future<MessageModel> submit(String transactionBlock, String signStr) async {
    return resultToMessageModel(
      await baseRPCSui("sui_executeTransactionBlock", [
        transactionBlock,
        [signStr],
        "WaitForEffectsCert",
        {"showEffects": true, "showEvents": true},
      ], enableRetry: false),
    );
  }

  //查询交易信息
  Future<MessageModel> getTransactionBlock(String txHash) async {
    return resultToMessageModel(
      await baseRPCSui("sui_getTransactionBlock", [
        txHash,
        {
          "showInput": false,
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
    var value, {
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
