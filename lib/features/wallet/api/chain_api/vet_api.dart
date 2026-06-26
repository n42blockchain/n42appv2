import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// VeChain (VET) — Thorest REST API
class VetApi {
  static const _coinType = CoinType.VET;
  static const _header = {'Content-Type': 'application/json'};

  String _base(bool isTest) =>
      RequestUrl().getUrl2(_coinType.name, 'rpc', isTest: isTest);

  static MessageModel _err(dynamic e) => MessageModel.error()..data = e;

  /// 获取账户余额（VET + VTHO energy）
  Future<MessageModel> getAccount(String address, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/accounts/$address',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取最新区块（用于确认区块高度）
  Future<MessageModel> getBestBlock({bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/blocks/best',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 广播已签名交易（raw 为十六进制编码的 RLP 交易）
  Future<MessageModel> sendTransaction(
    String rawTx, {
    bool isTest = false,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_base(isTest)}/transactions',
        params: {},
        data: {'raw': rawTx},
        defaultReturn: false,
        header: _header,
        enableRetry: false,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 查询交易回执（confirmed + reverted 状态）
  Future<MessageModel> getTransactionReceipt(
    String txId, {
    bool isTest = false,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/transactions/$txId/receipt',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 查询交易详情
  Future<MessageModel> getTransaction(
    String txId, {
    bool isTest = false,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/transactions/$txId',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 执行合约只读调用（用于查询代币余额等）
  Future<MessageModel> callContract(
    Map<String, dynamic> clause, {
    bool isTest = false,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_base(isTest)}/accounts/*',
        params: {},
        data: {
          'clauses': [clause],
        },
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 估算 gas（VTHO）消耗
  Future<MessageModel> estimateGas(
    List<Map<String, dynamic>> clauses,
    String caller, {
    bool isTest = false,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_base(isTest)}/accounts/*',
        params: {'caller': caller},
        data: {'clauses': clauses},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }
}
