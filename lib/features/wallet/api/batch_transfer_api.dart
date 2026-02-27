// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
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

  // 不同链上的 Multicall3 地址映射
  static const Map<String, String> multicall3Addresses = {
    'ETH': '0xcA11bde05977b3631167028862bE2a173976CA11',
    'BSC': '0xcA11bde05977b3631167028862bE2a173976CA11',
    'POLYGON': '0xcA11bde05977b3631167028862bE2a173976CA11',
    'ARBITRUM': '0xcA11bde05977b3631167028862bE2a173976CA11',
    'OPTIMISM': '0xcA11bde05977b3631167028862bE2a173976CA11',
    'AVALANCHE': '0xcA11bde05977b3631167028862bE2a173976CA11',
    'FANTOM': '0xcA11bde05977b3631167028862bE2a173976CA11',
    'BASE': '0xcA11bde05977b3631167028862bE2a173976CA11',
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

    if (items.isEmpty) {
      return CsvParseResult.failure(errors, lines.length - startIndex);
    }
    if (errors.isNotEmpty) {
      return CsvParseResult.partial(items, errors, lines.length - startIndex);
    }
    return CsvParseResult.success(items, lines.length - startIndex);
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
      final multicallAddr = getMulticall3Address(chainSymbol);
      final isNative = tokenAddress == null || tokenAddress.isEmpty;

      final data = isNative
          ? _buildNativeMulticallData(items)
          : _buildErc20MulticallData(tokenAddress, items);
      final totalValue = isNative
          ? items.fold(BigInt.zero, (sum, item) => sum + item.amount)
          : BigInt.zero;

      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_estimateGas',
        'params': [
          {
            'from': fromAddress,
            'to': multicallAddr,
            'data': data,
            'value': totalValue == BigInt.zero
                ? '0x0'
                : '0x${totalValue.toRadixString(16)}',
          }
        ],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );

      if (response['result'] != null) {
        final gasLimit = _hexToBigInt(response['result'].toString());
        // 增加 30% 安全边际（批量交易更复杂）
        final safeGasLimit =
            gasLimit * BigInt.from(130) ~/ BigInt.from(100);
        return MessageModel()
          ..error = false
          ..data = safeGasLimit;
      }

      // 默认估算：原生 ~21000/笔，ERC20 ~65000/笔
      final defaultGas = isNative
          ? BigInt.from(21000 * items.length + 50000)
          : BigInt.from(65000 * items.length + 50000);
      return MessageModel()
        ..error = false
        ..data = defaultGas;
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = BigInt.from(100000 * items.length);
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
    final gasLimit =
        gasLimitResult.data as BigInt? ?? BigInt.from(500000);

    // 尝试 EIP-1559
    try {
      final feeHistoryParams = {
        'jsonrpc': '2.0',
        'method': 'eth_feeHistory',
        'params': [4, 'latest', <int>[25, 50, 75]],
        'id': 1,
      };
      final feeResponse = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: feeHistoryParams,
        data: feeHistoryParams,
        header: {'Content-Type': 'application/json'},
      );
      if (feeResponse['result'] != null) {
        final baseFeeHistory =
            feeResponse['result']['baseFeePerGas'] as List<dynamic>?;
        if (baseFeeHistory != null && baseFeeHistory.isNotEmpty) {
          final latestBaseFee =
              _hexToBigInt(baseFeeHistory.last.toString());
          const maxPriorityFee = 1500000000; // 1.5 Gwei
          final maxPriorityBig = BigInt.from(maxPriorityFee);
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
      final gasPriceParams = {
        'jsonrpc': '2.0',
        'method': 'eth_gasPrice',
        'params': <dynamic>[],
        'id': 1,
      };
      final gasPriceResponse = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: gasPriceParams,
        data: gasPriceParams,
        header: {'Content-Type': 'application/json'},
      );
      if (gasPriceResponse['result'] != null) {
        final gasPrice =
            _hexToBigInt(gasPriceResponse['result'].toString());
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

    // 默认 5 Gwei
    final defaultGasPrice = BigInt.from(5000000000);
    return BatchGasEstimate(
      gasLimit: gasLimit,
      gasPrice: defaultGasPrice,
      totalFee: gasLimit * defaultGasPrice,
      isEip1559: false,
    );
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
      final multicallAddr = getMulticall3Address(chainSymbol);
      final isNative = tokenAddress == null || tokenAddress.isEmpty;

      final data = isNative
          ? _buildNativeMulticallData(items)
          : _buildErc20MulticallData(tokenAddress, items);
      final totalValue = isNative
          ? items.fold(BigInt.zero, (sum, item) => sum + item.amount)
          : BigInt.zero;

      final txData = <String, String>{
        'chainId': '0x${chainId.toRadixString(16)}',
        'nonce': '0x${nonce.toRadixString(16)}',
        'to': multicallAddr,
        'value': '0x${totalValue.toRadixString(16)}',
        'data': data,
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
        ..error = false
        ..data = {
          'txData': txData,
          'rawData': data,
          'multicallAddress': multicallAddr,
          'recipientCount': items.length,
          'totalValue': totalValue.toString(),
        };
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 nonce
  Future<int> getNonce(String rpcUrl, String address) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_getTransactionCount',
        'params': [address, 'pending'],
        'id': 1,
      };
      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );
      if (response['result'] != null) {
        return _hexToBigInt(response['result'].toString()).toInt();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// 广播交易
  Future<MessageModel> broadcastTransaction(
      String rpcUrl, String signedTx) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_sendRawTransaction',
        'params': [signedTx],
        'id': 1,
      };
      final response = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: params,
        data: params,
        header: {'Content-Type': 'application/json'},
      );
      if (response['result'] != null) {
        return MessageModel()
          ..error = false
          ..data = response['result'].toString();
      } else if (response['error'] != null) {
        return MessageModel()
          ..error = true
          ..data =
              response['error']['message'] ?? 'Transaction failed';
      }
      return MessageModel.error()..data = 'Unknown error';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 轮询 tx receipt，最多 [maxAttempts] 次，每次间隔 [intervalMs] ms。
  /// 返回 null 表示超时；receipt['status'] == '0x1' 表示成功。
  static Future<Map<String, dynamic>?> waitForReceipt(
    String rpcUrl,
    String txHash, {
    int maxAttempts = 20,
    int intervalMs = 3000,
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(Duration(milliseconds: intervalMs));
      try {
        final resp = await http.post(
          Uri.parse(rpcUrl),
          body: jsonEncode({
            'jsonrpc': '2.0',
            'method': 'eth_getTransactionReceipt',
            'params': [txHash],
            'id': 1,
          }),
          headers: {'Content-Type': 'application/json'},
        );
        final result = jsonDecode(resp.body)['result'];
        if (result != null) return Map<String, dynamic>.from(result);
      } catch (_) {}
    }
    return null;
  }
}
