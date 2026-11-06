import 'dart:convert';

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Stellar (XLM) — Horizon REST API
class XlmApi {
  final Future<dynamic> Function(
    String url,
    Map<String, String> body, {
    required Map<String, dynamic> header,
    required bool enableRetry,
  })?
  _submit;

  XlmApi({
    Future<dynamic> Function(
      String url,
      Map<String, String> body, {
      required Map<String, dynamic> header,
      required bool enableRetry,
    })?
    submit,
  }) : _submit = submit;

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
  Future<MessageModel> sendTransaction(
    String txXdr, {
    bool isTest = false,
  }) async {
    try {
      // Preserve the exact signed envelope. Reject altered/noncanonical base64
      // before transport; full XDR/signature validation belongs to the signer.
      if (txXdr.isEmpty || base64Encode(base64Decode(txXdr)) != txXdr) {
        return _err('Invalid signed Stellar transaction encoding');
      }
      final url = '${_base(isTest)}/transactions';
      final body = {'tx': txXdr};
      final header = <String, dynamic>{
        'content-type': 'application/x-www-form-urlencoded',
      };
      final data = _submit != null
          ? await _submit(url, body, header: header, enableRetry: false)
          : await BaseApi.requestEmptyH.post(
              url,
              params: {},
              data: body,
              defaultReturn: false,
              header: header,
              enableRetry: false,
            );
      if (data is! Map ||
          data['successful'] != true ||
          data['hash'] is! String ||
          !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(data['hash'] as String)) {
        return _err('Invalid Stellar submission response; status is unknown');
      }
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 查询交易状态
  Future<MessageModel> getTransaction(
    String txHash, {
    bool isTest = false,
  }) async {
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
