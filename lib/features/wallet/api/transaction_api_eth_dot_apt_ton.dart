part of 'transaction_api.dart';

extension TransactionApiEthDotAptTon on TransactionApi {
  // ---------------------------------------------------------------------------
  // ETH-compatible — Etherscan-style API
  // ---------------------------------------------------------------------------

  /// 以太坊兼容链通用交易列表
  Future<MessageModel> commonEthTransactionList(
    String miniName,
    String address, {
    int? fromBlock = 0,
    int? endBlock = 99999999999,
    int? page = 1,
    int? offset = 10,
    bool isTest = false,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(miniName, isTest: isTest);
      if (hostUrl == '') {
        mm.error = true;
        mm.data = null;
        return mm;
      }
      final endblockStr = endBlock != null ? '&endblock=$endBlock' : '';
      final requestUrl =
          '${hostUrl}module=account&action=txlist&address=$address'
          '&startblock=$fromBlock&page=$page&offset=$offset&sort=desc$endblockStr';
      final data = await BaseApi.requestEmptyH
          .get(requestUrl, params: {}, header: header);
      if (data != null && data['status'] == '1') {
        mm.data = (data['result'] as List)
            .map((e) => CommonResponseItemModel.fromJson(e))
            .toList();
      } else {
        mm.error = true;
        mm.data = data?['message'];
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  /// ERC-20 合约代币交易列表（Etherscan tokentx）
  Future<MessageModel> commContractTransactionList(
    String name,
    String address,
    String contractAddress, {
    int? fromBlock = 0,
    int? endBlock = 99999999999,
    int? page = 1,
    int? offset = 10,
    bool isTest = false,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(name, isTest: isTest);
      if (hostUrl == '') {
        mm.data = null;
        return mm;
      }
      final requestUrl =
          '${hostUrl}module=account&action=tokentx&address=$address'
          '&contractaddress=$contractAddress&startblock=$fromBlock'
          '&endblock=$endBlock&page=$page&offset=$offset&sort=desc';
      final data = await BaseApi.requestEmptyH
          .get(requestUrl, params: {}, header: header);
      if (data != null && data['status'] == '1') {
        mm.data = (data['result'] as List)
            .map((e) => CommonResponseItemModel.fromJson(e))
            .toList();
      } else {
        mm.error = true;
        mm.data = data?['message'];
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // DOT / Polkadot — Subscan API v2
  // ---------------------------------------------------------------------------

  /// DOT、KSM、ACA 交易列表，via Subscan transfers API
  Future<MessageModel> dotTransactionList(
    String address,
    String coinType, {
    bool isTest = false,
  }) async {
    final mm = MessageModel();
    try {
      final hostUrl = getHostByCoinMiniName(coinType, isTest: isTest);
      if (hostUrl == null || hostUrl.isEmpty) {
        mm.data = null;
        return mm;
      }
      final url = '${hostUrl}api/v2/scan/transfers';
      final h = Map<String, String>.from(header)
        ..['x-api-key'] = ApiKeysConfig.dotApiKey;
      final data = await BaseApi.requestEmptyH.post(
        url,
        params: {},
        data: {'address': address, 'row': 25, 'page': 0},
        header: h,
      );
      if (data != null && data['code'] == 0) {
        final transfers = data['data']['transfers'] as List? ?? [];
        // DOT decimals = 10; KSM / ACA = 12
        final decimals = coinType == 'DOT' ? 10 : 12;
        mm.data = transfers.map<CommonResponseItemModel>((e) {
          return CommonResponseItemModel()
            ..hash =
                e['extrinsic_hash'] as String? ?? e['hash'] as String? ?? ''
            ..from = e['from'] as String? ?? ''
            ..to = e['to'] as String? ?? ''
            ..value = _parseToSmallestUnit(
                    e['amount'] as String? ?? '0', decimals)
                .toString()
            ..timeStamp = (e['block_timestamp'] as int?)?.toString() ?? '0'
            ..txreceiptStatus = (e['success'] == true) ? '1' : '0'
            ..gas = '0'
            ..gasPrice = '0'
            ..contractAddress = '';
        }).toList();
      } else {
        mm.error = true;
        mm.data = data?['message'] ?? 'Subscan error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // APT / Aptos — Aptos REST API
  // ---------------------------------------------------------------------------

  /// APT 交易列表，via Aptos REST `/accounts/{addr}/transactions`
  Future<MessageModel> aptTransactionList(
    String address, {
    bool isTest = false,
  }) async {
    final mm = MessageModel();
    try {
      final rpcUrl = RequestUrl().getUrl2('APT', 'rpc', isTest: isTest);
      if (rpcUrl.isEmpty) {
        mm.data = null;
        return mm;
      }
      final url = '${rpcUrl}accounts/$address/transactions?limit=25';
      final data =
          await BaseApi.requestEmptyH.get(url, params: {}, header: header);
      if (data is List) {
        mm.data = data
            .map<CommonResponseItemModel?>((e) {
              if (e['type'] != 'user_transaction') return null;
              final payload = e['payload'] as Map<String, dynamic>?;
              final args = payload?['arguments'] as List?;
              final tsMicro =
                  int.tryParse(e['timestamp']?.toString() ?? '0') ?? 0;
              final gasUsed =
                  int.tryParse(e['gas_used']?.toString() ?? '0') ?? 0;
              final gasUnitPrice =
                  int.tryParse(e['gas_unit_price']?.toString() ?? '0') ?? 0;
              return CommonResponseItemModel()
                ..hash = e['hash'] as String? ?? ''
                ..from = e['sender'] as String? ?? ''
                ..to = (args != null && args.isNotEmpty)
                    ? args[0].toString()
                    : ''
                ..value = (args != null && args.length > 1)
                    ? args[1].toString()
                    : '0' // octas (10^8 per APT)
                ..timeStamp = (tsMicro ~/ 1000000).toString()
                ..txreceiptStatus = (e['success'] == true) ? '1' : '0'
                ..gas = gasUsed.toString()
                ..gasPrice = (gasUsed * gasUnitPrice).toString() // octas
                ..contractAddress = '';
            })
            .whereType<CommonResponseItemModel>()
            .toList();
      } else {
        mm.error = true;
        mm.data = 'Aptos API error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // TON — TON Center v2 API
  // ---------------------------------------------------------------------------

  /// TON 交易列表，via TON Center v2 `/getTransactions`
  Future<MessageModel> tonTransactionList(
    String address, {
    bool isTest = false,
  }) async {
    final mm = MessageModel();
    try {
      final rpcUrl = RequestUrl().getUrl2('TON', 'rpc', isTest: isTest);
      if (rpcUrl.isEmpty) {
        mm.data = null;
        return mm;
      }
      final url = '${rpcUrl}getTransactions?address=$address&limit=20';
      final data =
          await BaseApi.requestEmptyH.get(url, params: {}, header: header);
      if (data != null && data['ok'] == true) {
        final txList = data['result'] as List? ?? [];
        mm.data = txList
            .map<CommonResponseItemModel?>((e) {
              try {
                final inMsg = e['in_msg'] as Map<String, dynamic>?;
                if (inMsg == null) return null;
                final txId = e['transaction_id'] as Map<String, dynamic>?;
                return CommonResponseItemModel()
                  ..hash = txId?['hash'] as String? ?? ''
                  ..from = inMsg['source'] as String? ?? ''
                  ..to = inMsg['destination'] as String? ?? address
                  ..value = inMsg['value']?.toString() ?? '0' // nanoTON
                  ..timeStamp = e['utime']?.toString() ?? '0' // Unix seconds
                  ..txreceiptStatus = '1'
                  ..gasPrice = e['fee']?.toString() ?? '0' // nanoTON
                  ..gas = '0'
                  ..contractAddress = '';
              } catch (_) {
                return null;
              }
            })
            .whereType<CommonResponseItemModel>()
            .toList();
      } else {
        mm.error = true;
        mm.data = 'TON API error';
      }
    } catch (e) {
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  /// 将人类可读小数金额字符串（如 "1.5000000000"）转换为最小单位 BigInt
  static BigInt _parseToSmallestUnit(String amount, int decimals) {
    try {
      final parts = amount.split('.');
      final intPart = BigInt.parse(parts[0].isEmpty ? '0' : parts[0]);
      final fracRaw = parts.length > 1 ? parts[1] : '';
      final fracPadded =
          fracRaw.padRight(decimals, '0').substring(0, decimals);
      final fracPart = BigInt.parse(fracPadded);
      return intPart * BigInt.from(10).pow(decimals) + fracPart;
    } catch (_) {
      return BigInt.zero;
    }
  }
}
