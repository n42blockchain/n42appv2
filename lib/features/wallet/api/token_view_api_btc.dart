part of 'token_view_api.dart';

// ── Bitcoin (BTC) ──────────────────────────────────────────────────────────

extension TokenViewApiBtc on TokenViewApi {
  /// 获取 BTC 类 gasifee 等级数据
  Future<MessageModel> getGasFeeBtc({bool isTest = false}) async {
    try {
      if (isTest) {
        return await BtcApi(test: isTest).getGasfee();
      }
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/blockchain/fee/byte',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = a['data'];
      } else {
        mm.error = true;
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 BTC 类余额
  Future<MessageModel> getBalanceBtc(
    String coinType,
    String address, {
    bool returnDouble = false,
  }) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/vipapi/account/balance?coin=${coinType.toLowerCase()}&addr=$address',
        params: {},
        header: header,
      );
      final mm = MessageModel();
      if (a['code'] == 200) {
        mm.data = returnDouble
            ? double.parse(a['data'].toString())
            : ethToWeiString(a['data'].toString(), 8);
      } else {
        mm.error = true;
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 BTC 类 UTXO 列表
  Future<MessageModel> getUTXOBtc(
    String coinType,
    String address, {
    int pageSize = 100,
    int pageNum = 1,
    bool isTest = false,
  }) async {
    try {
      if (isTest) {
        return await BtcApi(test: isTest).getUtxos(address);
      }
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/vipapi/utxo/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize',
        params: {},
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else if (a['code'] == 404) {
        mm.error = false;
        mm.data = [];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 BTC 类交易记录
  Future<MessageModel> getTxListBtc(
    String coinType,
    String address, {
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '${url}v1/vipapi/address/tx/list?coin=${coinType.toLowerCase()}&addr=$address&page=$pageNum&page_size=$pageSize',
        params: {},
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else if (a['code'] == 404) {
        mm.error = false;
        mm.data = [];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 广播交易（BTC 类）
  Future<MessageModel> sendTxBtc(
    String coinType,
    String signHash, {
    bool isTest = false,
  }) async {
    try {
      if (isTest) {
        return await BtcApi(test: isTest).sendTxHttp(signHash);
      }
      final params = {
        'coin': coinType.toLowerCase(),
        'tx_hash': signHash,
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/vipapi/onchainwallet/rawtransaction',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
