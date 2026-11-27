import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:http/http.dart' as http;

/// Horizen (ZEN) — Insight REST API (原始 UTXO 主链，非 EON EVM 侧链)
class ZenApi {
  static const _coinType = CoinType.ZEN;

  String _base(bool isTest) =>
      RequestUrl().getUrl2(_coinType.name, 'api', isTest: isTest);

  static MessageModel _err(dynamic e) => MessageModel.error()..data = e;

  /// GET 一个 JSON 端点，成功返回 data，失败返回 error 消息
  static Future<MessageModel> _getJson(
    String url, {
    Map<String, dynamic> params = const {},
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        url,
        params: params,
        defaultReturn: false,
        header: {'Content-Type': 'application/json'},
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取地址信息（余额、txid 列表等）
  Future<MessageModel> getAddress(String address, {bool isTest = false}) =>
      _getJson('${_base(isTest)}addr/$address');

  /// 获取地址 UTXO 列表（构造交易所需）
  Future<MessageModel> getUtxos(String address, {bool isTest = false}) =>
      _getJson('${_base(isTest)}addr/$address/utxo');

  /// 广播已签名交易（raw hex）
  Future<MessageModel> sendTransaction(
    String rawTxHex, {
    bool isTest = false,
  }) async {
    final url = '${_base(isTest)}tx/send';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'rawtx=$rawTxHex',
      );
      if (response.statusCode == 200) {
        return MessageModel()..data = response.body;
      } else {
        return MessageModel.error()
          ..data = 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return _err(e);
    }
  }

  /// 查询交易详情
  Future<MessageModel> getTransaction(String txId, {bool isTest = false}) =>
      _getJson('${_base(isTest)}tx/$txId');

  /// 估算手续费（返回 ZEN/KB，nbBlocks=目标确认块数）
  Future<MessageModel> estimateFee({int nbBlocks = 2, bool isTest = false}) =>
      _getJson(
        '${_base(isTest)}utils/estimatefee',
        params: {'nbBlocks': nbBlocks},
      );

  /// 查询区块信息（by hash）
  Future<MessageModel> getBlock(String blockHash, {bool isTest = false}) =>
      _getJson('${_base(isTest)}block/$blockHash');
}
