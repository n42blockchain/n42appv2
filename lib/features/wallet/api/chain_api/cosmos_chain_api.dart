import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// 通用 Cosmos SDK 链 REST API（LCD）
///
/// 所有 Cosmos 生态链的公共接口，子类只需传入 baseUrl 和 nativeDenom 即可。
class CosmosChainApi {
  final String baseUrl;
  final String nativeDenom;

  static const _header = {'Content-Type': 'application/json'};

  CosmosChainApi(this.baseUrl, this.nativeDenom);

  String get _base => baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

  /// 查询指定面额余额，默认查原生代币
  Future<MessageModel> getBalance(String address, {String? denom}) async {
    try {
      final d = denom ?? nativeDenom;
      final data = await BaseApi.requestEmptyH.get(
        '${_base}cosmos/bank/v1beta1/balances/$address',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      final balances = data['balances'] as List<dynamic>? ?? [];
      BigInt balance = BigInt.zero;
      for (final b in balances) {
        final m = b as Map<String, dynamic>;
        if (m['denom'] == d) {
          balance = BigInt.parse(m['amount'].toString());
          break;
        }
      }
      return MessageModel()..data = balance;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 查询账户下所有代币余额
  Future<MessageModel> getAllBalances(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base}cosmos/bank/v1beta1/balances/$address',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data['balances'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 查询账户信息（sequence_number / account_number）
  Future<MessageModel> getAccount(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base}cosmos/auth/v1beta1/accounts/$address',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data['account'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 广播已签名交易（明确禁用重试，防止双发）
  Future<MessageModel> sendTx(String txBytes, {String mode = 'BROADCAST_MODE_SYNC'}) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_base}cosmos/tx/v1beta1/txs',
        params: {},
        data: {'tx_bytes': txBytes, 'mode': mode},
        defaultReturn: false,
        header: _header,
        enableRetry: false,
      );
      final txResp = data['tx_response'] as Map<String, dynamic>?;
      if (txResp == null) return MessageModel.error()..data = data['message'] ?? 'no tx_response';
      if ((txResp['code'] as int? ?? 0) != 0) return MessageModel.error()..data = txResp['raw_log'];
      return MessageModel()..data = txResp['txhash'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 模拟交易，用于估算 gas
  Future<MessageModel> simulateTx(String txBytes) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${_base}cosmos/tx/v1beta1/simulate',
        params: {},
        data: {'tx_bytes': txBytes},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 查询节点最新区块高度
  Future<MessageModel> getLatestBlock() async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${_base}cosmos/base/tendermint/v1beta1/blocks/latest',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      return MessageModel()..data = data['block']['header'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
