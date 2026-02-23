// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';

/// Gas 追踪和估算 API
///
/// 提供 EIP-1559 Gas 费用估算，支持慢/标准/快三档选择
class GasTrackerApi {
  static GasTrackerApi? _instance;

  GasTrackerApi._();

  factory GasTrackerApi() {
    _instance ??= GasTrackerApi._();
    return _instance!;
  }

  /// 获取 Gas 估算数据
  ///
  /// [coinType] 链符号，如 ETH、BNB 等
  /// [isTest] 是否测试网
  /// [isContract] 是否合约调用（影响 gas limit）
  /// [customGasLimit] 自定义 gas limit，如果为 null 则使用默认值
  Future<MessageModel> getGasEstimate({
    required String coinType,
    bool isTest = false,
    bool isContract = false,
    BigInt? customGasLimit,
  }) async {
    try {
      // 获取链配置
      final chainConfig = chainUrlMap[coinType];
      if (chainConfig == null) {
        return MessageModel.error()..data = 'Unsupported chain: $coinType';
      }

      final baseInfo = chainConfig['baseInfo'] as Map<String, dynamic>?;
      if (baseInfo == null) {
        return MessageModel.error()..data = 'Chain config error';
      }

      final decimals = baseInfo['decimals'] as int? ?? 18;
      final unit = (baseInfo['unit'] ?? coinType).toString().toUpperCase();
      final rpc = isTest
          ? baseInfo['service_test'] as String?
          : baseInfo['service'] as String?;

      if (rpc == null || rpc.isEmpty) {
        return MessageModel.error()..data = 'RPC endpoint not configured';
      }

      // 计算 gas limit
      final gasLimit = customGasLimit ?? BigInt.from(getCoinGas(coinType, contract: isContract));

      // 检查是否支持 EIP-1559
      final supportsEIP1559 = get1559WithChainSymbol(coinType);

      if (supportsEIP1559) {
        // 获取 EIP-1559 费用历史
        return await _getEIP1559GasEstimate(
          rpc: rpc,
          gasLimit: gasLimit,
          chainSymbol: coinType,
          decimals: decimals,
          unit: unit,
        );
      } else {
        // Legacy 模式
        return await _getLegacyGasEstimate(
          rpc: rpc,
          gasLimit: gasLimit,
          chainSymbol: coinType,
          decimals: decimals,
          unit: unit,
        );
      }
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 EIP-1559 Gas 估算
  Future<MessageModel> _getEIP1559GasEstimate({
    required String rpc,
    required BigInt gasLimit,
    required String chainSymbol,
    required int decimals,
    required String unit,
  }) async {
    try {
      // 调用 eth_feeHistory 获取历史数据
      final feeHistoryResult = await _callEthFeeHistory(rpc, 10, [10, 50, 90]);

      if (feeHistoryResult.error) {
        // 如果 feeHistory 失败，降级到 legacy 模式
        return await _getLegacyGasEstimate(
          rpc: rpc,
          gasLimit: gasLimit,
          chainSymbol: chainSymbol,
          decimals: decimals,
          unit: unit,
        );
      }

      final feeHistory = feeHistoryResult.data as Map<String, dynamic>;

      // 解析 baseFeePerGas
      final baseFeeList = (feeHistory['baseFeePerGas'] as List<dynamic>)
          .map((e) => _hexToBigInt(e.toString()))
          .toList();

      // 解析 reward（优先费历史）
      final rewardList = (feeHistory['reward'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>)
              .map((r) => _hexToBigInt(r.toString()))
              .toList())
          .toList() ?? [];

      // 创建估算模型
      final gasEstimate = GasEstimateModel.fromFeeHistory(
        baseFeeHistory: baseFeeList,
        rewardHistory: rewardList,
        gasLimit: gasLimit,
        supportsEIP1559: true,
        chainSymbol: chainSymbol,
        decimals: decimals,
        unit: unit,
      );

      final mm = MessageModel();
      mm.error = false;
      mm.data = gasEstimate;
      return mm;
    } catch (e) {
      // 降级到 legacy 模式
      return await _getLegacyGasEstimate(
        rpc: rpc,
        gasLimit: gasLimit,
        chainSymbol: chainSymbol,
        decimals: decimals,
        unit: unit,
      );
    }
  }

  /// 获取 Legacy Gas 估算
  Future<MessageModel> _getLegacyGasEstimate({
    required String rpc,
    required BigInt gasLimit,
    required String chainSymbol,
    required int decimals,
    required String unit,
  }) async {
    try {
      // 获取当前 gas price
      final gasPriceResult = await _callEthGasPrice(rpc);

      if (gasPriceResult.error) {
        return gasPriceResult;
      }

      final currentGasPrice = gasPriceResult.data as BigInt;

      // 创建三档估算
      final gasEstimate = GasEstimateModel(
        supportsEIP1559: false,
        slow: GasOption.legacy(
          gasPrice: currentGasPrice * BigInt.from(90) ~/ BigInt.from(100),
          estimatedSeconds: 180,
        ),
        standard: GasOption.legacy(
          gasPrice: currentGasPrice,
          estimatedSeconds: 60,
        ),
        fast: GasOption.legacy(
          gasPrice: currentGasPrice * BigInt.from(130) ~/ BigInt.from(100),
          estimatedSeconds: 15,
        ),
        gasLimit: gasLimit,
        chainSymbol: chainSymbol,
        decimals: decimals,
        unit: unit,
      );

      final mm = MessageModel();
      mm.error = false;
      mm.data = gasEstimate;
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 调用 eth_feeHistory RPC
  Future<MessageModel> _callEthFeeHistory(
    String rpc,
    int blockCount,
    List<int> rewardPercentiles,
  ) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_feeHistory',
        'params': [
          '0x${blockCount.toRadixString(16)}',
          'latest',
          rewardPercentiles,
        ],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpc,
        params: params,
        data: params,
        header: {'content-type': 'application/json'},
      );

      final mm = MessageModel();

      if (response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'RPC error';
        return mm;
      }

      if (response['result'] != null) {
        mm.error = false;
        mm.data = response['result'];
        return mm;
      }

      mm.error = true;
      mm.data = 'Invalid response';
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 调用 eth_gasPrice RPC
  Future<MessageModel> _callEthGasPrice(String rpc) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_gasPrice',
        'params': [],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpc,
        params: params,
        data: params,
        header: {'content-type': 'application/json'},
      );

      final mm = MessageModel();

      if (response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'RPC error';
        return mm;
      }

      if (response['result'] != null) {
        mm.error = false;
        mm.data = _hexToBigInt(response['result'].toString());
        return mm;
      }

      mm.error = true;
      mm.data = 'Invalid response';
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 调用 eth_maxPriorityFeePerGas RPC
  Future<MessageModel> getMaxPriorityFeePerGas(String rpc) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_maxPriorityFeePerGas',
        'params': [],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpc,
        params: params,
        data: params,
        header: {'content-type': 'application/json'},
      );

      final mm = MessageModel();

      if (response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'RPC error';
        return mm;
      }

      if (response['result'] != null) {
        mm.error = false;
        mm.data = _hexToBigInt(response['result'].toString());
        return mm;
      }

      mm.error = true;
      mm.data = 'Invalid response';
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取当前区块的 base fee
  Future<MessageModel> getBaseFee({
    required String coinType,
    bool isTest = false,
  }) async {
    try {
      final chainConfig = chainUrlMap[coinType];
      if (chainConfig == null) {
        return MessageModel.error()..data = 'Unsupported chain';
      }

      final baseInfo = chainConfig['baseInfo'] as Map<String, dynamic>?;
      String? rpc;
      if (isTest) {
        rpc = baseInfo?['service_test'] as String?;
      } else {
        rpc = baseInfo?['service'] as String?;
      }

      if (rpc == null || rpc.isEmpty) {
        return MessageModel.error()..data = 'RPC not configured';
      }

      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_getBlockByNumber',
        'params': ['latest', false],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpc,
        params: params,
        data: params,
        header: {'content-type': 'application/json'},
      );

      final mm = MessageModel();

      if (response['error'] != null) {
        mm.error = true;
        mm.data = response['error']['message'] ?? 'RPC error';
        return mm;
      }

      final result = response['result'];
      if (result != null && result['baseFeePerGas'] != null) {
        mm.error = false;
        mm.data = _hexToBigInt(result['baseFeePerGas'].toString());
        return mm;
      }

      mm.error = true;
      mm.data = 'baseFeePerGas not available';
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 将十六进制字符串转换为 BigInt
  BigInt _hexToBigInt(String hex) {
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }
    if (hex.isEmpty) return BigInt.zero;
    return BigInt.parse(hex, radix: 16);
  }

  /// 格式化确认时间（通用缩写，便于 i18n）
  static String formatEstimatedTime(int seconds) {
    if (seconds < 60) {
      return '~${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '~${minutes}min';
    } else {
      final hours = seconds ~/ 3600;
      return '~${hours}hr';
    }
  }
}
