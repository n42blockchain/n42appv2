// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
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

  static const Map<String, String> _jsonHeader = {
    'content-type': 'application/json',
  };

  /// 解析链配置并返回 RPC 端点和基础信息
  ///
  /// 成功时返回 `{rpc, decimals, unit, baseInfo}` 的 Map，
  /// 失败时返回 [MessageModel.error]。
  Object _resolveChainInfo(String coinType, {bool isTest = false}) {
    final chainConfig = chainUrlMap[coinType];
    if (chainConfig == null) {
      return MessageModel.error()..data = 'Unsupported chain: $coinType';
    }

    final baseInfo = chainConfig['baseInfo'] as Map<String, dynamic>?;
    if (baseInfo == null) {
      return MessageModel.error()..data = 'Chain config error';
    }

    final rpc = isTest
        ? baseInfo['service_test'] as String?
        : baseInfo['service'] as String?;

    if (rpc == null || rpc.isEmpty) {
      return MessageModel.error()..data = 'RPC endpoint not configured';
    }

    return {
      'rpc': rpc,
      'decimals': baseInfo['decimals'] as int? ?? 18,
      'unit': (baseInfo['unit'] ?? coinType).toString().toUpperCase(),
    };
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
      final resolved = _resolveChainInfo(coinType, isTest: isTest);
      if (resolved is MessageModel) return resolved;

      final info = resolved as Map<String, dynamic>;
      final rpc = info['rpc'] as String;
      final decimals = info['decimals'] as int;
      final unit = info['unit'] as String;

      final gasLimit =
          customGasLimit ?? BigInt.from(getCoinGas(coinType, contract: isContract));
      final supportsEIP1559 = get1559WithChainSymbol(coinType);

      if (supportsEIP1559) {
        return await _getEIP1559GasEstimate(
          rpc: rpc,
          gasLimit: gasLimit,
          chainSymbol: coinType,
          decimals: decimals,
          unit: unit,
        );
      } else {
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
      final rewardList =
          (feeHistory['reward'] as List<dynamic>?)
              ?.map((e) =>
                  (e as List<dynamic>).map((r) => _hexToBigInt(r.toString())).toList())
              .toList() ??
          [];

      final gasEstimate = GasEstimateModel.fromFeeHistory(
        baseFeeHistory: baseFeeList,
        rewardHistory: rewardList,
        gasLimit: gasLimit,
        supportsEIP1559: true,
        chainSymbol: chainSymbol,
        decimals: decimals,
        unit: unit,
      );

      return MessageModel()..data = gasEstimate;
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
      final gasPriceResult = await _callEthGasPrice(rpc);
      if (gasPriceResult.error) return gasPriceResult;

      final currentGasPrice = gasPriceResult.data as BigInt;

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

      return MessageModel()..data = gasEstimate;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // ── RPC helpers ───────────────────────────────────────────────────────────

  /// 解析通用 RPC 响应，提取 result 字段
  MessageModel _parseRpcResponse(dynamic response) {
    if (response['error'] != null) {
      return MessageModel.error()
        ..data = response['error']['message'] ?? 'RPC error';
    }
    if (response['result'] != null) {
      return MessageModel()..data = response['result'];
    }
    return MessageModel.error()..data = 'Invalid response';
  }

  /// 执行 RPC 调用并返回解析结果
  Future<MessageModel> _callRpc(String rpc, Map<String, dynamic> body) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        rpc,
        params: body,
        data: body,
        header: _jsonHeader,
      );
      return _parseRpcResponse(response);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 调用 eth_feeHistory RPC
  Future<MessageModel> _callEthFeeHistory(
    String rpc,
    int blockCount,
    List<int> rewardPercentiles,
  ) =>
      _callRpc(rpc, {
        'jsonrpc': '2.0',
        'method': 'eth_feeHistory',
        'params': [
          '0x${blockCount.toRadixString(16)}',
          'latest',
          rewardPercentiles,
        ],
        'id': 1,
      });

  /// 调用 eth_gasPrice RPC，result 转为 BigInt
  Future<MessageModel> _callEthGasPrice(String rpc) async {
    final result = await _callRpc(rpc, {
      'jsonrpc': '2.0',
      'method': 'eth_gasPrice',
      'params': [],
      'id': 1,
    });
    if (!result.error) result.data = _hexToBigInt(result.data.toString());
    return result;
  }

  /// 调用 eth_maxPriorityFeePerGas RPC
  Future<MessageModel> getMaxPriorityFeePerGas(String rpc) async {
    final result = await _callRpc(rpc, {
      'jsonrpc': '2.0',
      'method': 'eth_maxPriorityFeePerGas',
      'params': [],
      'id': 1,
    });
    if (!result.error) result.data = _hexToBigInt(result.data.toString());
    return result;
  }

  /// 获取当前区块的 base fee
  Future<MessageModel> getBaseFee({
    required String coinType,
    bool isTest = false,
  }) async {
    try {
      final resolved = _resolveChainInfo(coinType, isTest: isTest);
      if (resolved is MessageModel) return resolved;

      final rpc = (resolved as Map<String, dynamic>)['rpc'] as String;

      final result = await _callRpc(rpc, {
        'jsonrpc': '2.0',
        'method': 'eth_getBlockByNumber',
        'params': ['latest', false],
        'id': 1,
      });

      if (result.error) return result;

      final block = result.data;
      if (block != null && block['baseFeePerGas'] != null) {
        return MessageModel()
          ..data = _hexToBigInt(block['baseFeePerGas'].toString());
      }

      return MessageModel.error()..data = 'baseFeePerGas not available';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 将十六进制字符串转换为 BigInt
  BigInt _hexToBigInt(String hex) {
    final clean =
        (hex.startsWith('0x') || hex.startsWith('0X')) ? hex.substring(2) : hex;
    if (clean.isEmpty) return BigInt.zero;
    return BigInt.parse(clean, radix: 16);
  }

  /// 格式化确认时间（通用缩写，便于 i18n）
  static String formatEstimatedTime(int seconds) {
    if (seconds < 60) return '~${seconds}s';
    if (seconds < 3600) return '~${seconds ~/ 60}min';
    return '~${seconds ~/ 3600}hr';
  }
}
