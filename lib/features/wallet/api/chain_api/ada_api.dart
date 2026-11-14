import 'dart:typed_data';

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Cardano (ADA) — Blockfrost REST API
/// 需要在构造时传入 project_id（Blockfrost API Key）。
class AdaApi {
  static const _coinType = CoinType.ADA;

  final String projectId;
  final Future<dynamic> Function(
    String url,
    Uint8List bytes, {
    required Map<String, dynamic> header,
    required bool enableRetry,
  })?
  _submit;

  final Future<dynamic> Function(
    String url,
    Map<String, dynamic> query,
    Map<String, String> header,
  )?
  _readUtxoPage;

  final Future<dynamic> Function(String url, Map<String, String> header)?
  _readChainTip;

  AdaApi({
    required this.projectId,
    Future<dynamic> Function(String url, Map<String, String> header)?
    readChainTip,
    Future<dynamic> Function(
      String url,
      Map<String, dynamic> query,
      Map<String, String> header,
    )?
    readUtxoPage,
    Future<dynamic> Function(
      String url,
      Uint8List bytes, {
      required Map<String, dynamic> header,
      required bool enableRetry,
    })?
    submit,
  }) : _submit = submit,
       _readUtxoPage = readUtxoPage,
       _readChainTip = readChainTip;

  String _base(bool isTest) =>
      RequestUrl().getUrl2(_coinType.name, 'rpc', isTest: isTest);

  Map<String, String> get _header => {
    'Content-Type': 'application/json',
    'project_id': projectId,
  };

  static MessageModel _err(dynamic e) => MessageModel.error()..data = e;

  /// 获取地址信息（余额，单位 lovelace，1 ADA = 1,000,000 lovelace）
  Future<MessageModel> getAddressInfo(
    String address, {
    bool isTest = false,
  }) async {
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
  Future<MessageModel> getAddressUtxos(
    String address, {
    bool isTest = false,
  }) async {
    try {
      const pageSize = 100;
      const maxPages = 100;
      final base = _base(isTest);
      final url = '$base/addresses/${Uri.encodeComponent(address)}/utxos';
      final header = _header;
      Future<(String, int, int)> tip() async {
        final data = _readChainTip != null
            ? await _readChainTip('$base/blocks/latest', header)
            : await BaseApi.requestEmptyH.get(
                '$base/blocks/latest',
                params: {},
                defaultReturn: false,
                header: header,
              );
        if (data is! Map) {
          throw const FormatException('Invalid Cardano chain tip');
        }
        final hash = data['hash'];
        final height = data['height'];
        final slot = data['slot'];
        if (hash is! String ||
            !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash) ||
            height is! int ||
            height < 0 ||
            slot is! int ||
            slot < 0) {
          throw const FormatException('Invalid Cardano chain tip');
        }
        return (hash.toLowerCase(), height, slot);
      }

      final openingTip = await tip();
      final inputs = <Map<String, dynamic>>[];
      final seen = <String>{};
      for (var page = 1; page <= maxPages; page++) {
        final query = <String, dynamic>{
          'page': page,
          'count': pageSize,
          'order': 'asc',
        };
        final data = _readUtxoPage != null
            ? await _readUtxoPage(url, query, header)
            : await BaseApi.requestEmptyH.get(
                url,
                params: query,
                defaultReturn: false,
                header: header,
              );
        if (data is! List || data.length > pageSize) {
          return _err('Invalid Cardano UTxO page');
        }
        for (final item in data) {
          if (item is! Map<String, dynamic>) {
            return _err('Invalid Cardano UTxO');
          }
          final hash = item['tx_hash'];
          final index = item['output_index'];
          if (hash is! String ||
              !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash) ||
              index is! int ||
              index < 0 ||
              index > 0xffffffff) {
            return _err('Invalid Cardano UTxO outpoint');
          }
          // Do not deduplicate silently: overlap can indicate a moving page
          // boundary or a server that ignored pagination. Discard the scan.
          if (!seen.add('${hash.toLowerCase()}:$index')) {
            return _err(
              'Cardano UTxO pages changed or repeated; refresh required',
            );
          }
          inputs.add(Map<String, dynamic>.from(item));
        }
        if (data.length < pageSize) {
          // Pagination has no block-pinned endpoint. Reject observed chain
          // movement, including same-height forks; never return a partial Max.
          // This cannot prove atomicity against an inconsistent remote indexer.
          if (await tip() != openingTip) {
            return _err(
              'Cardano chain changed during input scan; refresh required',
            );
          }
          return MessageModel()..data = inputs;
        }
      }
      return _err(
        'Cardano UTxO scan limit reached; complete input set unavailable',
      );
    } catch (e) {
      return _err(e);
    }
  }

  /// 广播已签名交易（CBOR 编码，Base16/hex 字符串）
  Future<MessageModel> sendTransaction(
    String txCborHex, {
    bool isTest = false,
  }) async {
    try {
      final hex = txCborHex.startsWith('0x')
          ? txCborHex.substring(2)
          : txCborHex;
      if (hex.isEmpty ||
          hex.length.isOdd ||
          !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
        return _err('Invalid signed Cardano transaction encoding');
      }
      final bytes = Uint8List(hex.length ~/ 2);
      for (var i = 0; i < bytes.length; i++) {
        bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      }
      // The native bridge returns hex, but Blockfrost accepts raw CBOR bytes.
      // Keep replay disabled: a lost response does not mean rejection.
      final header = <String, dynamic>{
        'content-type': 'application/cbor',
        'project_id': projectId,
      };
      final url = '${_base(isTest)}/tx/submit';
      final dynamic raw = _submit != null
          ? await _submit(url, bytes, header: header, enableRetry: false)
          : await BaseApi.requestEmptyH.requestWithStatus(
              url,
              method: 'POST',
              data: bytes,
              header: header,
            );
      final response = raw is HttpStatusResult
          ? raw
          : HttpStatusResult(200, raw);
      final status = response.statusCode;
      if (status == 400) {
        // Blockfrost answers 400 when the node refused the transaction
        // (ledger validation failure): it is not in any mempool.
        final problem = response.jsonObject;
        if (problem != null &&
            problem['status_code'] == 400 &&
            problem['error'] == 'Bad Request') {
          final message = problem['message'];
          return _err(
            BroadcastRejected(
              message is String && message.isNotEmpty
                  ? 'Cardano rejected the transaction: $message'
                  : 'Cardano rejected the transaction',
            ),
          );
        }
      }
      if (status == null || status < 200 || status > 202) {
        return _err('Cardano submission status is unknown');
      }
      final data = response.data;
      if (data is! String || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(data)) {
        return _err('Invalid Cardano submission response; status is unknown');
      }
      return MessageModel()..data = data;
    } catch (e) {
      return _err(e);
    }
  }

  /// 查询交易详情
  Future<MessageModel> getTransaction(
    String txHash, {
    bool isTest = false,
  }) async {
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
