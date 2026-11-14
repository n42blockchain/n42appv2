import 'dart:convert';

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
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

  final Future<HttpStatusResult> Function(
    String url,
    Map<String, String> header,
  )?
  _lookup;

  XlmApi({
    Future<HttpStatusResult> Function(String url, Map<String, String> header)?
    lookup,
    Future<dynamic> Function(
      String url,
      Map<String, String> body, {
      required Map<String, dynamic> header,
      required bool enableRetry,
    })?
    submit,
  }) : _submit = submit,
       _lookup = lookup;

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
      final dynamic raw = _submit != null
          ? await _submit(url, body, header: header, enableRetry: false)
          : await BaseApi.requestEmptyH.requestWithStatus(
              url,
              method: 'POST',
              data: body,
              header: header,
            );
      final response = raw is HttpStatusResult
          ? raw
          : HttpStatusResult(200, raw);
      final status = response.statusCode;
      if (status == 400) {
        // Horizon answers 400 only after stellar-core refused the envelope
        // (or it failed in a ledger): it was not and will not be applied.
        final problem = response.jsonObject;
        final type = problem?['type'];
        if (problem != null &&
            problem['status'] == 400 &&
            type is String &&
            (type.endsWith('/transaction_failed') ||
                type.endsWith('/transaction_malformed'))) {
          return _err(BroadcastRejected(_rejectionReason(problem)));
        }
      }
      if (status == null || status < 200 || status > 202) {
        return _err('Stellar submission status is unknown');
      }
      final data = response.jsonObject;
      if (data == null ||
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

  static String _rejectionReason(Map<String, dynamic> problem) {
    final extras = problem['extras'];
    final codes = extras is Map ? extras['result_codes'] : null;
    if (codes is Map) {
      final tx = codes['transaction'];
      final ops = codes['operations'];
      final parts = [
        if (tx is String) tx,
        if (ops is List) ...ops.whereType<String>(),
      ];
      if (parts.isNotEmpty) return 'Stellar rejected the transaction: ${parts.join(', ')}';
    }
    return 'Stellar rejected the transaction';
  }

  /// Single GET that exposes the HTTP status (no retry, no error mapping) so
  /// a definite 404 can be told apart from a transport failure.
  Future<HttpStatusResult> lookup(String path, {required bool isTest}) {
    final url = '${_base(isTest)}$path';
    if (_lookup != null) return _lookup(url, _header);
    return BaseApi.requestEmptyH.requestWithStatus(
      url,
      method: 'GET',
      header: _header,
      timeout: const Duration(seconds: 15),
    );
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
