part of 'transaction_api.dart';

const String _kLegacySolscanApiToken = String.fromEnvironment(
  'SOLSCAN_API_TOKEN',
  defaultValue: '',
);
const String _kLegacyTronProApiKey = String.fromEnvironment(
  'TRON_PRO_API_KEY',
  defaultValue: '',
);
const Duration _kProxyExplorerTimeout = Duration(seconds: 4);

List<dynamic> _txListValue(dynamic value) {
  if (value is List) return value;
  return const [];
}

Map<String, dynamic>? _txMapValue(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return null;
}

String _txStringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

int explorerStartFromPage(int? page, int? pageSize) {
  final normalizedPage = page == null || page < 1 ? 1 : page;
  final normalizedPageSize = pageSize == null || pageSize < 1 ? 20 : pageSize;
  return (normalizedPage - 1) * normalizedPageSize;
}

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
      final data = await BaseApi.requestEmptyH.get(
        url,
        params: {},
        header: header,
      );
      if (data != null) {
        final res = BtcResponse.fromJson(data);
        final list = <BtcTranDetail>[];
        for (final element in res.txrefs) {
          final records = await db.selectBtcTransationRecordTxHash(
            element.txHash,
          );
          if (records.isNotEmpty &&
              (records.first.outputModels?.isNotEmpty ?? false)) {
            continue;
          }
          final innerUrl = '${hostUrl}txs/${element.txHash}';
          final inData = await BaseApi.requestEmptyH.get(innerUrl, params: {});
          if (inData != null) {
            list.add(BtcTranDetail.fromJson(inData));
          }
        }
        mm.data = list;
      } else {
        mm.error = true;
        mm.data = 'No data returned';
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
    final proxyResult = await _solTransactionListViaProxy(
      address,
      page: page,
      offset: offset,
    );
    if (!proxyResult.error) {
      return proxyResult;
    }
    debugPrint(
      '[TransactionApi] SOL proxy txlist fallback: ${proxyResult.data}',
    );
    return _solTransactionListViaSolscan(address, page: page, offset: offset);
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
    int? offset = 20,
  }) async {
    final proxyResult = await _trxTransactionListViaProxy(
      address,
      page: page,
      offset: offset,
    );
    if (!proxyResult.error) {
      return proxyResult;
    }
    debugPrint(
      '[TransactionApi] TRX proxy txlist fallback: ${proxyResult.data}',
    );
    return _trxTransactionListViaLegacy(
      address,
      page: page,
      offset: offset,
      includeToAddress: true,
    );
  }

  Future<MessageModel> trxContractTransactionList(
    String address,
    String contractAddress, {
    int? fromBlock = 0,
    int? endBlock = 99999999999,
    int? page = 1,
    int? offset = 20,
  }) async {
    final proxyResult = await _trxContractTransactionListViaProxy(
      address,
      contractAddress,
      page: page,
      offset: offset,
    );
    if (!proxyResult.error) {
      return proxyResult;
    }
    debugPrint(
      '[TransactionApi] TRX proxy tokentx fallback: ${proxyResult.data}',
    );
    return _trxTransactionListViaLegacy(
      address,
      page: page,
      offset: offset,
      includeToAddress: false,
      contractAddress: contractAddress,
    );
  }

  /// TRX 根据交易 hash 获取交易信息
  Future<MessageModel> trxTransactionInfoHash(
    String hash, {
    bool isTest = false,
  }) async {
    final mm = MessageModel();
    final proxyUrl = ProxyConfig.trxPath('transaction-info', isTest: isTest);
    try {
      final proxyData = await BaseApi.requestEmptyH.get(
        proxyUrl,
        params: {'hash': hash},
        header: ProxyConfig.mergeAuthHeaders(proxyUrl, header),
        timeout: _kProxyExplorerTimeout,
      );
      if (proxyData is Map && proxyData.isNotEmpty) {
        mm.data = proxyData;
        return mm;
      }
    } catch (e) {
      // Fall back to legacy direct request when proxy is unavailable.
      debugPrint('[TransactionApi] trxTransactionInfoHash proxy error: $e');
    }

    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      final requestUrl = '${hostUrl}transaction-info?hash=$hash';
      final h = Map<String, String>.from(header);
      if (_kLegacyTronProApiKey.isNotEmpty) {
        h['TRON-PRO-API-KEY'] = _kLegacyTronProApiKey;
      }
      final data = await BaseApi.requestEmptyH.get(
        requestUrl,
        params: {},
        header: h,
      );
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

  Future<MessageModel> _solTransactionListViaProxy(
    String address, {
    int? page,
    int? offset,
  }) async {
    final mm = MessageModel();
    try {
      final data = await BaseApi.requestEmptyH.get(
        ProxyConfig.explorerTxlist('sol'),
        params: {'address': address, 'page': '$page', 'size': '$offset'},
        header: header,
        timeout: _kProxyExplorerTimeout,
      );
      final items = extractExplorerItems(data);
      if (items.isEmpty && hasExplorerItemContainer(data)) {
        mm.data = <SOLTransactionItem>[];
        return mm;
      }

      final mapped = items
          .map(SOLTransactionItem.fromExplorerJson)
          .where((item) => (item.txHash ?? '').isNotEmpty)
          .toList();
      if (mapped.isNotEmpty) {
        mm.data = mapped;
      } else {
        mm.error = true;
        mm.data = data is Map ? data['message'] ?? data['error'] : null;
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  Future<MessageModel> _solTransactionListViaSolscan(
    String address, {
    int? page,
    int? offset,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('SOL');
      final start = explorerStartFromPage(page, offset);
      final requestUrl =
          '${hostUrl}account/solTransfers?account=$address&limit=$offset&offset=$start';
      final h = Map<String, String>.from(header);
      if (_kLegacySolscanApiToken.isNotEmpty) {
        h['token'] = _kLegacySolscanApiToken;
      }
      final data = await BaseApi.requestEmptyH.get(
        requestUrl,
        params: {},
        header: h,
      );
      if (data != null) {
        final res = _txListValue(data['data']);
        mm.data = res
            .whereType<Map>()
            .map(
              (e) => SOLTransactionItem.fromJson(
                e.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList();
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

  Future<MessageModel> _trxTransactionListViaProxy(
    String address, {
    int? page,
    int? offset,
  }) async {
    final mm = MessageModel();
    try {
      final data = await BaseApi.requestEmptyH.get(
        ProxyConfig.explorerTxlist('trx'),
        params: {'address': address, 'page': '$page', 'size': '$offset'},
        header: header,
        timeout: _kProxyExplorerTimeout,
      );
      final items = extractExplorerItems(data);
      if (items.isNotEmpty || hasExplorerItemContainer(data)) {
        mm.data = items
            .map((e) => CommonResponseItemModel.fromJson(e))
            .toList();
      } else {
        mm.error = true;
        mm.data = data is Map ? data['message'] ?? data['error'] : null;
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  Future<MessageModel> _trxContractTransactionListViaProxy(
    String address,
    String contractAddress, {
    int? page,
    int? offset,
  }) async {
    final mm = MessageModel();
    try {
      final data = await BaseApi.requestEmptyH.get(
        ProxyConfig.explorerTokentx('trx'),
        params: {
          'address': address,
          'contractAddress': contractAddress,
          'page': '$page',
          'size': '$offset',
        },
        header: header,
        timeout: _kProxyExplorerTimeout,
      );
      final items = extractExplorerItems(data);
      if (items.isNotEmpty || hasExplorerItemContainer(data)) {
        mm.data = items
            .map((e) => CommonResponseItemModel.fromJson(e))
            .toList();
      } else {
        mm.error = true;
        mm.data = data is Map ? data['message'] ?? data['error'] : null;
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  Future<MessageModel> _trxTransactionListViaLegacy(
    String address, {
    int? page,
    int? offset,
    required bool includeToAddress,
    String contractAddress = '',
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName('TRX');
      final start = explorerStartFromPage(page, offset);
      final requestUrl =
          '${hostUrl}transaction?address=$address&limit=$offset&start=$start&sort=-timestamp&count=true';
      final h = Map<String, String>.from(header);
      if (_kLegacyTronProApiKey.isNotEmpty) {
        h['TRON-PRO-API-KEY'] = _kLegacyTronProApiKey;
      }
      final data = await BaseApi.requestEmptyH.get(
        requestUrl,
        params: {},
        header: h,
      );
      if (data != null) {
        final res = _txListValue(data['data']);
        final mapped = res
            .whereType<Map>()
            .map(
              (e) => _parseTrxItem(
                e.map((key, value) => MapEntry(key.toString(), value)),
                includeToAddress: includeToAddress,
              ),
            )
            .where((item) {
              if (contractAddress.isEmpty) return true;
              return (item.contractAddress ?? '').toLowerCase() ==
                  contractAddress.toLowerCase();
            })
            .toList();
        mm.data = mapped;
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

  CommonResponseItemModel _parseTrxItem(
    Map<String, dynamic> e, {
    required bool includeToAddress,
  }) {
    final item = CommonResponseItemModel.fromJson(e)
      ..blockHash = e['block'].toString()
      ..hash = _txStringValue(e['hash'])
      ..timeStamp = e['timestamp'].toString()
      ..from = _txStringValue(e['ownerAddress']);
    if (includeToAddress) {
      item.to = _txStringValue(e['toAddress']);
      item.value = _txStringValue(e['amount']);
    }
    final triggerInfo = _txMapValue(e['trigger_info']);
    if (triggerInfo != null) {
      item.contractAddress = _txStringValue(triggerInfo['contract_address']);
      if (item.contractAddress != '') {
        final parameters = _txMapValue(triggerInfo['parameter']);
        item.to = _txStringValue(parameters?['_to']);
        item.value = _txStringValue(parameters?['_value']);
      }
    }
    return item;
  }
}
