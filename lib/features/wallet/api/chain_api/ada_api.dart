import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Cardano (ADA) — Blockfrost REST API
/// 需要在构造时传入 project_id（Blockfrost API Key）。
class AdaApi {
  static const _coinType = CoinType.ADA;

  final String projectId;
  AdaApi({required this.projectId});

  String _base(bool isTest) =>
      RequestUrl().getUrl2(_coinType.name, 'rpc', isTest: isTest);

  Map<String, String> get _header => {
        'Content-Type': 'application/json',
        'project_id': projectId,
      };

  static MessageModel _err(dynamic e) => MessageModel.error()..data = e;

  /// 获取地址信息（余额，单位 lovelace，1 ADA = 1,000,000 lovelace）
  Future<MessageModel> getAddressInfo(String address, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/addresses/$address',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取地址 UTxO 列表（构造交易所需）
  Future<MessageModel> getAddressUtxos(String address, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/addresses/$address/utxos',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 广播已签名交易（CBOR 编码，Base16/hex 字符串）
  Future<MessageModel> sendTransaction(String txCborHex, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_base(isTest)}/tx/submit',
        params: {},
        data: txCborHex,
        defaultReturn: false,
        header: {
          'Content-Type': 'application/cbor',
          'project_id': projectId,
        },
        enableRetry: false,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 查询交易详情
  Future<MessageModel> getTransaction(String txHash, {bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/txs/$txHash',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取最新区块信息（协议参数、slot、epoch）
  Future<MessageModel> getLatestBlock({bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/blocks/latest',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 获取当前 epoch 协议参数（手续费、min UTxO 等）
  Future<MessageModel> getLatestEpochParams({bool isTest = false}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base(isTest)}/epochs/latest/parameters',
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
