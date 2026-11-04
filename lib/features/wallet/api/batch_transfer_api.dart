// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';

part 'batch_transfer_encoding.dart';

/// Multicall3 批量转账 API
///
/// 使用 Multicall3 合约实现批量转账，节省 Gas 费用
class BatchTransferApi {
  // Multicall3 合约地址 (大多数 EVM 链通用)
  static const String multicall3Address =
      '0xcA11bde05977b3631167028862bE2a173976CA11';

  // ERC20 transfer 函数选择器: transfer(address,uint256)
  static const String erc20TransferSelector = '0xa9059cbb';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // 不同链上的 Multicall3 地址映射
  static const Map<String, String> multicall3Addresses = {
    'ETH': multicall3Address,
    'BSC': multicall3Address,
    'POLYGON': multicall3Address,
    'ARBITRUM': multicall3Address,
    'OPTIMISM': multicall3Address,
    'AVALANCHE': multicall3Address,
    'FANTOM': multicall3Address,
    'BASE': multicall3Address,
    'ZKSYNC': '0xF9cda624FBC7e059355ce98a31693d299FACd963',
  };

  /// 获取链对应的 Multicall3 地址
  String getMulticall3Address(String chainSymbol) {
    return multicall3Addresses[chainSymbol.toUpperCase()] ?? multicall3Address;
  }

  /// 检查链是否支持 Multicall3
  bool supportsMulticall(String chainSymbol) {
    return multicall3Addresses.containsKey(chainSymbol.toUpperCase());
  }

  /// 构建 multicall 调用数据和总值
  ({String data, BigInt totalValue}) _buildMulticallParams({
    required String? tokenAddress,
    required List<BatchTransferItem> items,
  }) {
    final isNative = tokenAddress == null || tokenAddress.isEmpty;
    final data = isNative
        ? _buildNativeMulticallData(items)
        : _buildErc20MulticallData(tokenAddress, items);
    final totalValue = isNative
        ? items.fold(BigInt.zero, (sum, item) => sum + item.amount)
        : BigInt.zero;
    return (data: data, totalValue: totalValue);
  }

  /// 执行 JSON-RPC 调用
  Future<dynamic> _rpcCall(String rpcUrl, String method, List<dynamic> params) {
    final body = {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': 1,
    };
    return BaseApi.requestEmptyH.post(
      rpcUrl,
      params: body,
      data: body,
      header: _jsonHeaders,
    );
  }

  /// 解析 CSV 内容
  CsvParseResult parseCsv(String csvContent, int decimals) {
    final lines = csvContent
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return CsvParseResult.failure(['CSV file is empty'], 0);
    }

    // 如果第一行不是地址则视为表头，跳过
    final startIndex = lines[0].startsWith('0x') ? 0 : 1;

    final items = <BatchTransferItem>[];
    final errors = <String>[];

    for (int i = startIndex; i < lines.length; i++) {
      try {
        items.add(BatchTransferItem.fromCsvRow(lines[i], i, decimals));
      } catch (e) {
        errors.add(e.toString());
      }
    }

    final totalRows = lines.length - startIndex;
    if (items.isEmpty) return CsvParseResult.failure(errors, totalRows);
    if (errors.isNotEmpty) {
      return CsvParseResult.partial(items, errors, totalRows);
    }
    return CsvParseResult.success(items, totalRows);
  }

  /// 估算批量转账 Gas
  Future<MessageModel> estimateBatchGas({
    required String rpcUrl,
    required String chainSymbol,
    required String fromAddress,
    required String? tokenAddress,
    required List<BatchTransferItem> items,
  }) async {
    try {
      if (!supportsMulticall(chainSymbol)) {
        return MessageModel.error()..data = 'Unsupported batch network';
      }
      if (tokenAddress != null && tokenAddress.isNotEmpty) {
        return MessageModel.error()
          ..data = 'ERC-20 batching requires a smart-account execution path';
      }
      final multicallAddr = getMulticall3Address(chainSymbol);
      final params = _buildMulticallParams(
        tokenAddress: tokenAddress,
        items: items,
      );

      final response = await _rpcCall(rpcUrl, 'eth_estimateGas', [
        {
          'from': fromAddress,
          'to': multicallAddr,
          'data': params.data,
          'value': params.totalValue == BigInt.zero
              ? '0x0'
              : '0x${params.totalValue.toRadixString(16)}',
        },
      ]);

      final result = response['result'];
      if (response['error'] != null ||
          result is! String ||
          !RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(result)) {
        return MessageModel.error()..data = 'RPC gas estimation failed';
      }
      final gasLimit = BigInt.parse(result.substring(2), radix: 16);
      if (gasLimit <= BigInt.zero || gasLimit > BigInt.from(9007199254740991)) {
        return MessageModel.error()..data = 'Invalid RPC gas estimate';
      }
      return MessageModel()
        ..data =
            (gasLimit * BigInt.from(120) + BigInt.from(99)) ~/ BigInt.from(100);
    } catch (_) {
      return MessageModel.error()..data = 'RPC gas estimation failed';
    }
  }

  /// 获取 Gas 价格信息
  Future<BatchGasEstimate> getGasEstimate({
    required String rpcUrl,
    required String chainSymbol,
    required String fromAddress,
    required String? tokenAddress,
    required List<BatchTransferItem> items,
  }) async {
    final gasLimitResult = await estimateBatchGas(
      rpcUrl: rpcUrl,
      chainSymbol: chainSymbol,
      fromAddress: fromAddress,
      tokenAddress: tokenAddress,
      items: items,
    );
    if (gasLimitResult.error || gasLimitResult.data is! BigInt) {
      throw StateError('RPC gas estimation failed');
    }
    final gasLimit = gasLimitResult.data as BigInt;

    // 尝试 EIP-1559
    try {
      final feeResponse = await _rpcCall(rpcUrl, 'eth_feeHistory', [
        4,
        'latest',
        <int>[25, 50, 75],
      ]);
      if (feeResponse['result'] != null) {
        final baseFeeHistory =
            feeResponse['result']['baseFeePerGas'] as List<dynamic>?;
        if (baseFeeHistory != null && baseFeeHistory.isNotEmpty) {
          final latestBaseFee = _hexToBigInt(baseFeeHistory.last.toString());
          final maxPriorityBig = BigInt.from(1500000000); // 1.5 Gwei
          final maxFee = latestBaseFee * BigInt.from(2) + maxPriorityBig;
          return BatchGasEstimate(
            gasLimit: gasLimit,
            gasPrice: latestBaseFee + maxPriorityBig,
            maxFeePerGas: maxFee,
            maxPriorityFeePerGas: maxPriorityBig,
            totalFee: gasLimit * maxFee,
            isEip1559: true,
          );
        }
      }
    } catch (_) {
      // 回退到 Legacy gas 价格
    }

    // Legacy gas price
    try {
      final gasPriceResponse = await _rpcCall(
        rpcUrl,
        'eth_gasPrice',
        <dynamic>[],
      );
      if (gasPriceResponse['result'] != null) {
        final gasPrice = _hexToBigInt(gasPriceResponse['result'].toString());
        return BatchGasEstimate(
          gasLimit: gasLimit,
          gasPrice: gasPrice,
          totalFee: gasLimit * gasPrice,
          isEip1559: false,
        );
      }
    } catch (_) {
      // 使用默认值
    }

    throw StateError('RPC fee quote unavailable');
  }

  /// 构建批量转账交易
  Future<MessageModel> buildBatchTransaction({
    required String chainSymbol,
    required String fromAddress,
    required String? tokenAddress,
    required List<BatchTransferItem> items,
    required BigInt gasLimit,
    required int nonce,
    required int chainId,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) async {
    try {
      if (!supportsMulticall(chainSymbol)) {
        return MessageModel.error()..data = 'Unsupported batch network';
      }
      if (tokenAddress != null && tokenAddress.isNotEmpty) {
        return MessageModel.error()
          ..data = 'ERC-20 batching requires a smart-account execution path';
      }
      final multicallAddr = getMulticall3Address(chainSymbol);
      final params = _buildMulticallParams(
        tokenAddress: tokenAddress,
        items: items,
      );

      final txData = <String, String>{
        'chainId': '0x${chainId.toRadixString(16)}',
        'nonce': '0x${nonce.toRadixString(16)}',
        'to': multicallAddr,
        'value': '0x${params.totalValue.toRadixString(16)}',
        'data': params.data,
        'gasLimit': '0x${gasLimit.toRadixString(16)}',
      };

      if (maxFeePerGas != null && maxPriorityFeePerGas != null) {
        txData['maxFeePerGas'] = '0x${maxFeePerGas.toRadixString(16)}';
        txData['maxPriorityFeePerGas'] =
            '0x${maxPriorityFeePerGas.toRadixString(16)}';
        txData['type'] = '0x2';
      } else if (gasPrice != null) {
        txData['gasPrice'] = '0x${gasPrice.toRadixString(16)}';
      }

      return MessageModel()
        ..data = {
          'txData': txData,
          'rawData': params.data,
          'multicallAddress': multicallAddr,
          'recipientCount': items.length,
          'totalValue': params.totalValue.toString(),
        };
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 nonce
  Future<int> getNonce(String rpcUrl, String address) async {
    final response = await _rpcCall(rpcUrl, 'eth_getTransactionCount', [
      address,
      'pending',
    ]);
    final value = response['result'];
    if (response['error'] != null ||
        value is! String ||
        !RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(value)) {
      throw StateError('RPC nonce unavailable');
    }
    final nonce = BigInt.parse(value.substring(2), radix: 16);
    if (nonce > BigInt.from(9007199254740991)) {
      throw StateError('Invalid RPC nonce');
    }
    return nonce.toInt();
  }

  /// 广播交易
  Future<MessageModel> broadcastTransaction(
    String rpcUrl,
    String signedTx,
  ) async {
    try {
      final response = await _rpcCall(rpcUrl, 'eth_sendRawTransaction', [
        signedTx,
      ]);
      if (response['result'] != null) {
        return MessageModel()..data = response['result'].toString();
      } else if (response['error'] != null) {
        return MessageModel()
          ..error = true
          ..data = response['error']['message'] ?? 'Transaction failed';
      }
      return MessageModel.error()..data = 'Unknown error';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<bool> isReceiptFinal(
    String rpcUrl,
    int chainId,
    Map<String, dynamic> receipt, {
    Future<dynamic> Function(String method, List<dynamic> params)? rpc,
  }) async {
    final call =
        rpc ??
        (String method, List<dynamic> params) =>
            _rpcCall(rpcUrl, method, params);
    final chain = await call('eth_chainId', []);
    final head = await call('eth_blockNumber', []);
    final block = await call('eth_getBlockByNumber', [
      receipt['blockNumber'],
      false,
    ]);
    BigInt? quantity(dynamic value) =>
        value is String && RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(value)
        ? BigInt.tryParse(value.substring(2), radix: 16)
        : null;
    final number = quantity(receipt['blockNumber']);
    final latest = quantity(head['result']);
    return quantity(chain['result']) == BigInt.from(chainId) &&
        number != null &&
        latest != null &&
        latest >= number + BigInt.from(11) &&
        block['result'] is Map &&
        block['result']['hash'] == receipt['blockHash'];
  }

  Future<Map<String, dynamic>?> pollReceipt(String rpcUrl, String txHash) =>
      waitForReceipt(rpcUrl, txHash);

  /// 轮询 tx receipt，最多 [maxAttempts] 次，每次间隔 [intervalMs] ms。
  /// 返回 null 表示超时；receipt['status'] == '0x1' 表示成功。
  static Future<Map<String, dynamic>?> waitForReceipt(
    String rpcUrl,
    String txHash, {
    int maxAttempts = 20,
    int intervalMs = 3000,
    http.Client? client,
  }) async {
    final hashPattern = RegExp(r'^0x[0-9a-fA-F]{64}$');
    if (!hashPattern.hasMatch(txHash) || maxAttempts < 1 || intervalMs < 0) {
      throw ArgumentError('Invalid receipt polling request');
    }
    final transport = client ?? http.Client();
    try {
      for (var i = 0; i < maxAttempts; i++) {
        await Future<void>.delayed(Duration(milliseconds: intervalMs));
        try {
          final resp = await transport
              .post(
                Uri.parse(rpcUrl),
                body: jsonEncode({
                  'jsonrpc': '2.0',
                  'method': 'eth_getTransactionReceipt',
                  'params': [txHash],
                  'id': 1,
                }),
                headers: _jsonHeaders,
              )
              .timeout(const Duration(seconds: 10));
          if (resp.statusCode != 200) continue;
          final envelope = jsonDecode(resp.body);
          if (envelope is! Map ||
              envelope['jsonrpc'] != '2.0' ||
              envelope['id'] != 1 ||
              envelope.containsKey('error')) {
            continue;
          }
          final result = envelope['result'];
          if (result is! Map ||
              result['transactionHash'] is! String ||
              (result['transactionHash'] as String).toLowerCase() !=
                  txHash.toLowerCase() ||
              result['blockHash'] is! String ||
              !hashPattern.hasMatch(result['blockHash'] as String) ||
              result['blockNumber'] is! String ||
              !RegExp(r'^0x(?:0|[1-9a-fA-F][0-9a-fA-F]*)$')
                  .hasMatch(result['blockNumber'] as String) ||
              !['0x0', '0x1'].contains(result['status'])) {
            continue;
          }
          return Map<String, dynamic>.from(result);
        } catch (_) {
          // Malformed/unavailable receipts remain unknown, never reverted.
          AppLogger.w(
            'BatchTransferApi',
            'Receipt unavailable; keeping transaction pending',
          );
        }
      }
      return null;
    } finally {
      if (client == null) transport.close();
    }
  }
}
