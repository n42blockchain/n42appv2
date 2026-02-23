// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:n42_wallet/src/https/base_api.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/wallet/models/batch_transfer_model.dart';

/// Multicall3 批量转账 API
///
/// 使用 Multicall3 合约实现批量转账，节省 Gas 费用
class BatchTransferApi {
  // Multicall3 合约地址 (大多数 EVM 链通用)
  static const String multicall3Address = '0xcA11bde05977b3631167028862bE2a173976CA11';

  // 函数选择器
  static const String aggregateSelector = '0x252dba42'; // aggregate(Call[])
  static const String aggregate3Selector = '0x82ad56cb'; // aggregate3(Call3[])
  static const String tryAggregateSelector = '0xbce38bd7'; // tryAggregate(bool,Call[])

  // ERC20 transfer 函数选择器
  static const String erc20TransferSelector = '0xa9059cbb'; // transfer(address,uint256)

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
    final lines = csvContent.split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return CsvParseResult.failure(['CSV file is empty'], 0);
    }

    // 检查是否有表头（第一行包含非地址内容）
    int startIndex = 0;
    if (!lines[0].startsWith('0x')) {
      startIndex = 1; // 跳过表头
    }

    final items = <BatchTransferItem>[];
    final errors = <String>[];

    for (int i = startIndex; i < lines.length; i++) {
      try {
        final item = BatchTransferItem.fromCsvRow(lines[i], i, decimals);
        items.add(item);
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

      BigInt totalValue = BigInt.zero;
      String data;

      if (isNative) {
        // 原生代币批量转账：使用 aggregate3Value
        data = _buildNativeMulticallData(items);
        totalValue = items.fold(BigInt.zero, (sum, item) => sum + item.amount);
      } else {
        // ERC20 代币批量转账
        data = _buildErc20MulticallData(tokenAddress, items);
      }

      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_estimateGas',
        'params': [
          {
            'from': fromAddress,
            'to': multicallAddr,
            'data': data,
            if (!isNative || totalValue == BigInt.zero)
              'value': '0x0'
            else
              'value': '0x${totalValue.toRadixString(16)}',
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
        final safeGasLimit = gasLimit * BigInt.from(130) ~/ BigInt.from(100);
        return MessageModel()
          ..error = false
          ..data = safeGasLimit;
      }

      // 默认估算：每笔转账约 21000 gas (原生) 或 65000 gas (ERC20)
      final defaultGas = isNative
          ? BigInt.from(21000 * items.length + 50000)
          : BigInt.from(65000 * items.length + 50000);
      return MessageModel()
        ..error = false
        ..data = defaultGas;
    } catch (e) {
      // 回退到简单估算
      final defaultGas = BigInt.from(100000 * items.length);
      return MessageModel()
        ..error = false
        ..data = defaultGas;
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
    // 获取 gas limit
    final gasLimitResult = await estimateBatchGas(
      rpcUrl: rpcUrl,
      chainSymbol: chainSymbol,
      fromAddress: fromAddress,
      tokenAddress: tokenAddress,
      items: items,
    );

    final gasLimit = gasLimitResult.data as BigInt? ?? BigInt.from(500000);

    // 尝试获取 EIP-1559 费用
    try {
      final feeHistoryParams = {
        'jsonrpc': '2.0',
        'method': 'eth_feeHistory',
        'params': [4, 'latest', [25, 50, 75]],
        'id': 1,
      };

      final feeResponse = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: feeHistoryParams,
        data: feeHistoryParams,
        header: {'Content-Type': 'application/json'},
      );

      if (feeResponse['result'] != null) {
        final result = feeResponse['result'];
        final baseFeeHistory = result['baseFeePerGas'] as List<dynamic>?;

        if (baseFeeHistory != null && baseFeeHistory.isNotEmpty) {
          final latestBaseFee = _hexToBigInt(baseFeeHistory.last.toString());
          final maxPriorityFee = BigInt.from(1500000000); // 1.5 Gwei
          final maxFee = latestBaseFee * BigInt.from(2) + maxPriorityFee;

          return BatchGasEstimate(
            gasLimit: gasLimit,
            gasPrice: latestBaseFee + maxPriorityFee,
            maxFeePerGas: maxFee,
            maxPriorityFeePerGas: maxPriorityFee,
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
        'params': [],
        'id': 1,
      };

      final gasPriceResponse = await BaseApi.requestEmptyH.post(
        rpcUrl,
        params: gasPriceParams,
        data: gasPriceParams,
        header: {'Content-Type': 'application/json'},
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

      BigInt totalValue = BigInt.zero;
      String data;

      if (isNative) {
        data = _buildNativeMulticallData(items);
        totalValue = items.fold(BigInt.zero, (sum, item) => sum + item.amount);
      } else {
        data = _buildErc20MulticallData(tokenAddress, items);
      }

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
        txData['maxPriorityFeePerGas'] = '0x${maxPriorityFeePerGas.toRadixString(16)}';
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
  Future<MessageModel> broadcastTransaction(String rpcUrl, String signedTx) async {
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
          ..data = response['error']['message'] ?? 'Transaction failed';
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

  // ============ Helper Methods ============

  /// 构建原生代币 Multicall 数据 (aggregate3Value)
  String _buildNativeMulticallData(List<BatchTransferItem> items) {
    // aggregate3Value(Call3Value[] calldata calls)
    // Call3Value: { target, allowFailure, value, callData }
    const selector = '0xe8917eb5';

    // 构建 calls 数组
    final callsData = StringBuffer();

    // 数组偏移 (32 bytes)
    callsData.write(_padLeft('20', 64)); // 偏移到数组位置

    // 数组长度
    callsData.write(_padLeft(items.length.toRadixString(16), 64));

    // 每个 Call3Value 结构的偏移
    int currentOffset = items.length * 32; // 初始偏移
    final offsets = <String>[];
    final structures = <String>[];

    for (int i = 0; i < items.length; i++) {
      offsets.add(_padLeft(currentOffset.toRadixString(16), 64));

      final item = items[i];
      final structure = StringBuffer();

      // target (address)
      structure.write(_padLeft(item.toAddress.toLowerCase().replaceFirst('0x', ''), 64));
      // allowFailure (bool) - false
      structure.write(_padLeft('0', 64));
      // value (uint256)
      structure.write(_padLeft(item.amount.toRadixString(16), 64));
      // callData offset
      structure.write(_padLeft('80', 64)); // 4 * 32 = 128 = 0x80
      // callData length (0 for native transfer)
      structure.write(_padLeft('0', 64));

      structures.add(structure.toString());
      currentOffset += 160; // 5 * 32 bytes per structure
    }

    // 组装最终数据
    final result = StringBuffer(selector);
    result.write(callsData);
    for (final offset in offsets) {
      result.write(offset);
    }
    for (final structure in structures) {
      result.write(structure);
    }

    return result.toString();
  }

  /// 构建 ERC20 Multicall 数据 (aggregate3)
  String _buildErc20MulticallData(String tokenAddress, List<BatchTransferItem> items) {
    // aggregate3(Call3[] calldata calls)
    // Call3: { target, allowFailure, callData }
    const selector = '0x82ad56cb';

    final result = StringBuffer(selector);

    // 数组偏移
    result.write(_padLeft('20', 64));

    // 数组长度
    result.write(_padLeft(items.length.toRadixString(16), 64));

    // 计算每个 Call3 的偏移
    int baseOffset = items.length * 32;
    final offsets = <String>[];
    final calls = <String>[];

    for (int i = 0; i < items.length; i++) {
      offsets.add(_padLeft(baseOffset.toRadixString(16), 64));

      final item = items[i];
      final callData = _buildErc20TransferData(item.toAddress, item.amount);
      final callDataBytes = (callData.length - 2) ~/ 2; // 去除 0x 后的字节数

      final call = StringBuffer();
      // target (token address)
      call.write(_padLeft(tokenAddress.toLowerCase().replaceFirst('0x', ''), 64));
      // allowFailure (bool) - false
      call.write(_padLeft('0', 64));
      // callData offset (固定 0x60 = 96)
      call.write(_padLeft('60', 64));
      // callData length
      call.write(_padLeft(callDataBytes.toRadixString(16), 64));
      // callData (padded to 32 bytes)
      final paddedCallData = callData.replaceFirst('0x', '');
      final paddedLength = ((paddedCallData.length + 63) ~/ 64) * 64;
      call.write(paddedCallData.padRight(paddedLength, '0'));

      calls.add(call.toString());
      baseOffset += 128 + paddedLength ~/ 2; // 4 * 32 + callData
    }

    // 写入偏移
    for (final offset in offsets) {
      result.write(offset);
    }

    // 写入 call 数据
    for (final call in calls) {
      result.write(call);
    }

    return result.toString();
  }

  /// 构建 ERC20 transfer 调用数据
  String _buildErc20TransferData(String to, BigInt amount) {
    final toPadded = _padLeft(to.toLowerCase().replaceFirst('0x', ''), 64);
    final amountHex = _padLeft(amount.toRadixString(16), 64);
    return '$erc20TransferSelector$toPadded$amountHex';
  }

  String _padLeft(String str, int length) {
    return str.padLeft(length, '0');
  }

  BigInt _hexToBigInt(String hex) {
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }
    if (hex.isEmpty) return BigInt.zero;
    return BigInt.parse(hex, radix: 16);
  }
}
