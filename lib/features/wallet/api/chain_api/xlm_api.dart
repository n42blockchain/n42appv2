import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Stellar (XLM) — Horizon REST API
class XlmApi {
  static const _coinType = CoinType.XLM;
  static const _header = {'Content-Type': 'application/json'};

  String _base(bool isTest) =>
      RequestUrl().getUrl2(_coinType.name, 'rpc', isTest: isTest);

  static MessageModel _err(dynamic e) => MessageModel.error()..data = e;

  /// 获取账户信息（余额 + sequence number）
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

  /// 广播已签名交易（XDR 格式，form-data tx= 字段）
  Future<MessageModel> sendTransaction(String txXdr, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_base(isTest)}/transactions',
        params: {},
        data: {'tx': txXdr},
        defaultReturn: false,
        header: {'Content-Type': 'application/x-www-form-urlencoded'},
        enableRetry: false,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 查询交易状态
  Future<MessageModel> getTransaction(String txHash, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/transactions/$txHash',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取账户近期交易记录
  Future<MessageModel> getAccountTransactions(
    String address, {
    int limit = 10,
    bool isTest = false,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/accounts/$address/transactions',
        params: {'limit': limit, 'order': 'desc'},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取最新账本（用于费率估算）
  Future<MessageModel> getLatestLedger({bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/ledgers',
        params: {'order': 'desc', 'limit': 1},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取费率统计（base_fee_in_stroops）
  Future<MessageModel> getFeeStats({bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/fee_stats',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }
}
