part of 'token_view_api.dart';

// ── Tron (TRX) ─────────────────────────────────────────────────────────────

extension TokenViewApiTrx on TokenViewApi {
  /// 获取 TRX gasPrice
  Future<MessageModel> getGasPriceTrx({bool isTest = false}) async {
    try {
      final params = {'net_mode': isTest ? 'test' : 'main'};
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/trx/gas/price',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        if (a['data']['error']['code'] != 0) {
          mm.data = a['data']['error']['message'];
        } else {
          mm.error = false;
          mm.data = hexToInt(a['data']['result'].toString());
        }
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 TRX 交易收据
  Future<MessageModel> getTransactionReceiptTrx(
    String txHash, {
    bool isTest = false,
  }) async {
    try {
      final params = {
        'tx_hash': txHash,
        'net_mode': isTest ? 'test' : 'main',
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/trx/transaction/receipt',
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

  /// 获取 TRX 最新块信息
  Future<MessageModel> getLatestBlockNumberTrx({bool isTest = false}) async {
    try {
      final params = {'net_mode': isTest ? 'test' : 'main'};
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/trx/latest/block',
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

  /// 创建 TRX 转账交易
  Future<MessageModel> createTxTrx(
    String sendAddress,
    String toAddress,
    int amount,
    dynamic netMode,
  ) async {
    try {
      final params = <String, dynamic>{
        'coin': 'trx',
        'owner_address': sendAddress,
        'to_address': toAddress,
        'visible': false,
        'amount': amount,
      };
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/vipapi/onchainwallet/transaction',
        params: params,
        data: params,
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == 200) {
        mm.error = false;
        mm.data = a['data']['raw_data_hex'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 广播交易（TRX）
  Future<MessageModel> sendTxTrx(String signHash, String netMode) async {
    try {
      final sign = Map<String, dynamic>.from(json.decode(signHash));
      sign['visible'] = false;
      sign['net_mode'] = 'main';
      final a = await BaseApi.requestEmptyH.post(
        '${url}v1/trx/broadcast/transaction',
        params: sign,
        data: sign,
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
