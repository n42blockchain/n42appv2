part of 'transaction_api.dart';

extension TransactionApiBtcSolTrx on TransactionApi {
  // ---------------------------------------------------------------------------
  // BTC — Blockchair API
  // https://blockchair.com/api/docs#link_203
  // ---------------------------------------------------------------------------

  Future<MessageModel> btcTransactionList(
    String coinType,
    String address, {
    int? page = 1,
    int? offset = 10,
    int? fromBlock = 0,
    int? endBlock = 99999999999,
    bool isTest = false,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(coinType, isTest: isTest);
      if (hostUrl == '') {
        mm.data = null;
        return mm;
      }
      final url = '${hostUrl}addrs/$address';
      final data =
          await BaseApi.requestEmptyH.get(url, params: {}, header: header);
      if (data != null) {
        final res = BtcResponse.fromJson(data);
        final list = <BtcTranDetail>[];
        for (final element in res.txrefs) {
          final records = await db
              .selectBtcTransationRecordTxHash(element.txHash);
          if (records.isNotEmpty &&
              (records.first.outputModels?.isNotEmpty ?? false)) {
            continue;
          }
          final innerUrl = '${hostUrl}txs/${element.txHash}';
          final inData =
              await BaseApi.requestEmptyH.get(innerUrl, params: {});
          if (inData != null) {
            list.add(BtcTranDetail.fromJson(inData));
          }
        }
        mm.data = list;
      } else {
        mm.error = true;
        mm.data = data['message'];
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // SOL — Solscan public API
  // https://public-api.solscan.io/docs/#/
  // ---------------------------------------------------------------------------

  Future<MessageModel> solTransactionList(
    String address, {
    int? fromBlock = 0,
    int? endBlock = 99999999999,
    int? page = 1,
    int? offset = 10,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('SOL');
      final requestUrl =
          '${hostUrl}account/solTransfers?account=$address&limit=$offset&offset=$page';
      final h = Map<String, String>.from(header)
        ..['token'] =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3MjI4NDg0NTUxODAsImVtYWlsIjoiamlhbmd5aXdlaUBzdGFybGluay13b3JsZC5jbiIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MSIsImlhdCI6MTcyMjg0ODQ1NX0.nN1kusKNvwXb_SUnpFrhsHoYfUuArbiLqC4HHk5UnNI';
      final data =
          await BaseApi.requestEmptyH.get(requestUrl, params: {}, header: h);
      if (data != null) {
        final res = data['data'] as List;
        mm.data = res.map((e) => SOLTransactionItem.fromJson(e)).toList();
      } else {
        mm.error = true;
        mm.data = data['message'];
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // TRX — Tron Scan API
  // https://cn.developers.tron.network/reference/get-transaction-info-by-account-address
  // ---------------------------------------------------------------------------

  Future<MessageModel> trxTransactionList(
    String address, {
    int? fromBlock = 0,
    int? endBlock = 99999999999,
    int? page = 1,
    int? offset = 999999,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      final requestUrl =
          '${hostUrl}transaction?address=$address&limit=$offset&start=$page&sort=-timestamp&count=true';
      final h = Map<String, String>.from(header)
        ..['TRON-PRO-API-KEY'] = '1908ecd1-99f1-4480-9353-c5a643b907b4';
      final data =
          await BaseApi.requestEmptyH.get(requestUrl, params: {}, header: h);
      if (data != null) {
        final res = data['data'] as List;
        mm.data =
            res.map((e) => _parseTrxItem(e, includeToAddress: true)).toList();
      } else {
        mm.error = true;
        mm.data = 'Error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  Future<MessageModel> trxContractTransactionList(
    String address,
    String contractAddress, {
    int? fromBlock = 0,
    int? endBlock = 99999999999,
    int? page = 1,
    int? offset = 999999,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      final requestUrl =
          '${hostUrl}transaction?address=$address&limit=$offset&start=$page&sort=-timestamp&count=true';
      final h = Map<String, String>.from(header)
        ..['TRON-PRO-API-KEY'] = '1908ecd1-99f1-4480-9353-c5a643b907b4';
      final data =
          await BaseApi.requestEmptyH.get(requestUrl, params: {}, header: h);
      if (data != null) {
        final res = data['data'] as List;
        mm.data =
            res.map((e) => _parseTrxItem(e, includeToAddress: false)).toList();
      } else {
        mm.error = true;
        mm.data = 'Error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  /// TRX 根据交易 hash 获取交易信息
  Future<MessageModel> trxTransactionInfoHash(String hash) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      final requestUrl = '${hostUrl}transaction-info?hash=$hash';
      final h = Map<String, String>.from(header)
        ..['TRON-PRO-API-KEY'] = '1908ecd1-99f1-4480-9353-c5a643b907b4';
      final data =
          await BaseApi.requestEmptyH.get(requestUrl, params: {}, header: h);
      if (data != null) {
        mm.data = data;
      } else {
        mm.error = true;
        mm.data = 'Error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// 解析 TRX 交易条目，[includeToAddress] 控制是否从顶层字段填充 to/value
  CommonResponseItemModel _parseTrxItem(
    Map<String, dynamic> e, {
    required bool includeToAddress,
  }) {
    final item = CommonResponseItemModel.fromJson(e)
      ..blockHash = e['block'].toString()
      ..hash = e['hash'] as String
      ..timeStamp = e['timestamp'].toString()
      ..from = e['ownerAddress'] as String;
    if (includeToAddress) {
      item.to = e['toAddress'] as String;
      item.value = e['amount'] as String;
    }
    final triggerInfo = e['trigger_info'] as Map<String, dynamic>?;
    if (triggerInfo != null) {
      item.contractAddress =
          triggerInfo['contract_address'] as String? ?? '';
      if (item.contractAddress != '') {
        item.to = triggerInfo['parameter']['_to'] as String? ?? '';
        item.value = triggerInfo['parameter']['_value'] as String? ?? '';
      }
    }
    return item;
  }
}
