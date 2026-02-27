import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/models/message_model.dart';

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

  static MessageModel _errorMm(dynamic e) {
    final mm = MessageModel.error();
    mm.data = e;
    return mm;
  }

  static MessageModel _rpcError(Map<String, dynamic> result) {
    final mm = MessageModel.error();
    mm.data = result['error'];
    return mm;
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
            'ownerCount': accountData?['OwnerCount'] ?? 0, //持有的对象
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
    try {
      final data = await _rpc('fee', [{}], isTest);
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()
          ..data = BigInt.parse(result['drops']['minimum_level']); //minimum_level\median_fee
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  Future<MessageModel> getTxInfoXrp(String txHash, bool isTest) async {
    try {
      final data = await _rpc(
        'tx',
        [{'transaction': txHash, 'binary': false}],
        isTest,
      );
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()..data = result['meta']['TransactionResult'];
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  //获取服务器信息
  Future<MessageModel> getServerStateXrp({bool isTest = false}) async {
    try {
      final data = await _rpc(
        'server_state',
        [{'ledger_index': 'current'}],
        isTest,
      );
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        final ledger = result['state']['validated_ledger'] as Map<String, dynamic>;
        return MessageModel()
          ..data = {
            'reserve_base': ledger['reserve_base'], //激活账户必须持有的最小值
            //每添加一个对象（如 trust line、挂单、payment channel）需加锁
            'reserve_inc': ledger['reserve_inc'],
            'base_fee': ledger['base_fee'], //理论最低手续费单位（网络空闲时）
            'load_base': result['state']['load_base'], //固定值，表示最小负载因子基准，一般为 256（不能变）
            //当前节点对费用的整体乘数因子，用来估算"标准"费用。
            // 计算：实际费用 = base_fee × (load_factor / load_base)
            'load_factor': result['state']['load_factor'],
          };
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  //获取当前账本信息
  Future<MessageModel> getLedgerXrp({bool isTest = false}) async {
    try {
      final data = await _rpc(
        'ledger',
        [{'ledger_index': 'current'}],
        isTest,
      );
      if (data['status'] == 'success') {
        return MessageModel()..data = data['result']['ledger_current_index'];
      }
      return _rpcError(data['result'] as Map<String, dynamic>);
    } catch (e) {
      return _errorMm(e);
    }
  }

  //获取全部交易记录
  /*
  * {
  "result": {
    "transactions": [
      {
        "tx": {
          "TransactionType": "Payment",
          "Account": "rUserAddress",
          "Destination": "rAnotherAddress",
          "Amount": "1000000",
          "Fee": "12"
        }
      }
    ]
  }
}*/
  /*TransactionType: 交易类型（Payment = 发送 XRP, TrustSet = 信任设置, AMMDeposit = AMM 交易）
Amount: 交易金额（单位 drops，1 XRP = 1,000,000 drops）
Fee: 交易费用（10-12 drops）*/
  Future<MessageModel> getTxsXrp(
    String address, {
    int ledgerIndexMin = -1,
    int limit = 10,
    bool isTest = false,
  }) async {
    try {
      final data = await _rpc(
        'account_tx',
        [{'account': 'rUserAddress', 'ledger_index_min': ledgerIndexMin, 'ledger_index_max': -1, 'limit': limit}],
        isTest,
      );
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()..data = result['transactions'];
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  //广播
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

  //获取hook合约信息
  /*{
  "result": {
    "account_objects": [
      {
        "LedgerEntryType": "Hook",
        "HookNamespace": "0xABCDEF",
        "HookOn": "0000000000000000",
        "HookParameters": [
          {
            "HookParameter": {
              "HookParamKey": "0x74657374",
              "HookParamValue": "0x123456"
            }
          }
        ],
        "Flags": 1
      }
    ]
  }
}*/
  /*
  * HookNamespace: 合约的命名空间
HookParameters: 传递给合约的参数
Flags: 合约的状态标志*/
  Future<MessageModel> getHookInfo(String address, {bool isTest = false}) async {
    try {
      final data = await _rpc(
        'account_objects',
        [{'account': address, 'type': 'hook'}],
        isTest,
      );
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()..data = BigInt.parse(result['account_objects']);
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  //获取AMM合约信息
  /*{
  "result": {
    "amm": {
      "Account": "rAMMPoolAddress",
      "Amount": "100000000",
      "Amount2": {
        "currency": "USDT",
        "issuer": "rIssuerAddress",
        "value": "5000"
      },
      "TradingFee": 30
    }
  }
}*/
  /*Account: AMM 池的账户地址
Amount: XRP 储备
Amount2: USDT 储备
TradingFee: 交易费用（单位 basis points，即 30 = 0.3%）*/
  Future<MessageModel> getAMMInfo(
    Map<String, dynamic> ammInfo, {
    bool isTest = false,
  }) async {
    /*Map<String,dynamic> ammInfo={
      "asset":{
        "currency":"XRP",
      },
      "asset2": { "currency": "USDT", "issuer": "rIssuerAddress" }
    };*/
    try {
      final data = await _rpc('amm_info', [ammInfo], isTest);
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()..data = BigInt.parse(result['amm']);
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  //获取 Trustline 代币（IOU）合约信息
  /*{
  "result": {
    "lines": [
      {
        "currency": "USDT",
        "account": "rIssuerAddress",
        "balance": "500",
        "limit": "1000",
        "limit_peer": "0",
        "quality_in": 0,
        "quality_out": 0
      }
    ]
  }
}*/
  /*currency: 代币符号
account: 代币发行者
balance: 账户持有的 USDT 数量
limit: 账户信任额度（最多持有 1000 USDT）*/
  Future<MessageModel> getTrustline(String address, {bool isTest = false}) async {
    try {
      final data = await _rpc('account_lines', [{address}], isTest);
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()..data = BigInt.parse(result['lines']);
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }

  Future<MessageModel> getTxHistory(
    String address, {
    int limit = 10,
    bool isTest = false,
  }) async {
    //tx_history
    try {
      final data = await _rpc(
        'account_tx',
        [{'account': address, 'limit': limit}],
        isTest,
      );
      final result = data['result'] as Map<String, dynamic>;
      if (result['status'] == 'success') {
        return MessageModel()..data = result['transactions'];
      }
      return _rpcError(result);
    } catch (e) {
      return _errorMm(e);
    }
  }
}
