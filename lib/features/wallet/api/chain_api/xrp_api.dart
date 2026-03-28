import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class XrpApi {
  Future<Map<String, dynamic>> _rpc(
    String method,
    List<dynamic> params,
    bool isTest,
  ) async {
    final uri = RequestUrl().getUrl2(CoinType.XRP.name, 'rpc', isTest: isTest);
    final data = await BaseApi.requestEmptyH.post(
      uri,
      params: {},
      data: {'method': method, 'params': params},
    );
    return data as Map<String, dynamic>;
  }

  static MessageModel _errorMm(dynamic e) => MessageModel.error()..data = e;

  static MessageModel _rpcError(Map<String, dynamic> result) =>
      MessageModel.error()..data = result['error'];

  /// Helper: execute RPC, check status == 'success', extract data via [extractor].
  Future<MessageModel> _rpcCall(
    String method,
    List<dynamic> params,
    bool isTest,
    dynamic Function(Map<String, dynamic> result) extractor,
  ) async {
    try {
      final data = await _rpc(method, params, isTest);
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()..data = extractor(result);
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  Future<MessageModel> getAccountInfoXrp(String address, bool isTest) async {
    try {
      final data = await _rpc(
        'account_info',
        [{'account': address, 'ledger_index': 'validated'}],
        isTest,
      );
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        final accountData = result['account_data'] as Map<String, dynamic>?;
        return MessageModel()
          ..data = {
            'balance': accountData != null
                ? BigInt.parse(accountData['Balance'] ?? '0')
                : BigInt.zero,
            'sequence': accountData?['Sequence'] ?? 0,
            'account': accountData != null,
            'ownerCount': accountData?['OwnerCount'] ?? 0,
          };
      }
      // error_code 19 = account not found，余额为 0
      if (result['error_code'] == 19) {
        return MessageModel()
          ..data = {
            'balance': BigInt.zero,
            'sequence': 0,
            'account': false,
            'ownerCount': 0,
          };
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  Future<MessageModel> getGasPriceXrp(bool isTest) async {
    return _rpcCall('fee', [{}], isTest,
        (r) => BigInt.parse(r['drops']['minimum_level']));
  }

  Future<MessageModel> getTxInfoXrp(String txHash, bool isTest) async {
    return _rpcCall('tx', [{'transaction': txHash, 'binary': false}], isTest,
        (r) => r['meta']['TransactionResult']);
  }

  /// 获取服务器信息（reserve / fee / load factor）
  Future<MessageModel> getServerStateXrp({bool isTest = false}) async {
    return _rpcCall('server_state', [{'ledger_index': 'current'}], isTest, (r) {
      final ledger = r['state']['validated_ledger'] as Map<String, dynamic>;
      return {
        'reserve_base': ledger['reserve_base'],
        'reserve_inc': ledger['reserve_inc'],
        'base_fee': ledger['base_fee'],
        'load_base': r['state']['load_base'],
        'load_factor': r['state']['load_factor'],
      };
    });
  }

  /// 获取当前账本信息
  Future<MessageModel> getLedgerXrp({bool isTest = false}) async {
    return _rpcCall('ledger', [{'ledger_index': 'current'}], isTest,
        (r) => r['ledger_current_index']);
  }

  /// 获取账户交易记录
  Future<MessageModel> getTxsXrp(
    String address, {
    int ledgerIndexMin = -1,
    int limit = 10,
    bool isTest = false,
  }) async {
    return _rpcCall(
      'account_tx',
      [{'account': address, 'ledger_index_min': ledgerIndexMin, 'ledger_index_max': -1, 'limit': limit}],
      isTest,
      (r) => r['transactions'],
    );
  }

  /// 广播已签名交易
  Future<MessageModel> sendTxXrp(String signHash, bool isTest) async {
    try {
      final data = await _rpc('submit', [{'tx_blob': signHash}], isTest);
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        if (result['engine_result'].toString().startsWith('tes')) {
          return MessageModel()..data = result['tx_json']['hash'];
        }
        return MessageModel.error()..data = result['engine_result_message'];
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  /// 获取 Hook 合约信息
  Future<MessageModel> getHookInfo(String address, {bool isTest = false}) async {
    return _rpcCall('account_objects', [{'account': address, 'type': 'hook'}], isTest,
        (r) => r['account_objects']);
  }

  /// 获取 AMM 池信息
  Future<MessageModel> getAMMInfo(
    Map<String, dynamic> ammInfo, {
    bool isTest = false,
  }) async {
    return _rpcCall('amm_info', [ammInfo], isTest,
        (r) => r['amm']);
  }

  /// 获取 Trustline 代币（IOU）信息
  Future<MessageModel> getTrustline(String address, {bool isTest = false}) async {
    return _rpcCall('account_lines', [{'account': address}], isTest,
        (r) => r['lines']);
  }

  /// 获取账户交易历史
  Future<MessageModel> getTxHistory(
    String address, {
    int limit = 10,
    bool isTest = false,
  }) async {
    return _rpcCall('account_tx', [{'account': address, 'limit': limit}], isTest,
        (r) => r['transactions']);
  }
}
