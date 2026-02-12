// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/staking/models/staking_models.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';

/// ETH Staking API (Lido Protocol)
///
/// Lido 是以太坊上最大的流动性质押协议
/// 用户质押 ETH 后获得 stETH，可以随时在 DEX 交易
class EthStakingApi {
  /// Lido stETH 合约地址（同时用于质押和余额查询）
  static const String _lidoContractAddress = '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84';

  // Lido API 端点
  static const String _lidoStatsApi = 'https://eth-api.lido.fi';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 获取当前 Lido APY
  Future<MessageModel> getLidoApy() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_lidoStatsApi/v1/protocol/steth/apr/sma',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['data'] != null) {
        // APY 是百分比形式
        final apy = (response['data']['smaApr'] ?? 4.0).toDouble();
        mm.data = apy;
        mm.error = false;
      } else {
        // 使用默认 APY
        mm.data = 4.0;
        mm.error = false;
      }

      return mm;
    } catch (e) {
      // 返回默认 APY
      return MessageModel()
        ..error = false
        ..data = 4.0;
    }
  }

  /// 获取用户的 stETH 余额
  Future<MessageModel> getStEthBalance(String address) async {
    try {
      // 调用 stETH 合约的 balanceOf 方法
      final rpc = chainUrlMap['ETH']?['baseInfo']?['service'] ?? '';
      if (rpc.isEmpty) {
        return MessageModel.error()..data = 'RPC not configured';
      }

      // ERC20 balanceOf 函数签名
      final balanceOfSelector = '0x70a08231';
      final paddedAddress = address.toLowerCase().replaceFirst('0x', '').padLeft(64, '0');
      final data = '$balanceOfSelector$paddedAddress';

      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_call',
        'params': [
          {
            'to': _lidoContractAddress,
            'data': data,
          },
          'latest'
        ],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpc,
        params: params,
        data: params,
        header: _headers,
      );

      final mm = MessageModel();

      if (response['result'] != null) {
        final balanceHex = response['result'].toString();
        final balance = _hexToBigInt(balanceHex);
        mm.data = balance;
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = response['error']?['message'] ?? 'Failed to get balance';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取用户的质押仓位信息
  Future<MessageModel> getStakingPosition(String address) async {
    try {
      // 获取 stETH 余额
      final balanceResult = await getStEthBalance(address);
      if (balanceResult.error) {
        return balanceResult;
      }

      final stEthBalance = balanceResult.data as BigInt;

      // 构建质押仓位
      if (stEthBalance > BigInt.zero) {
        final position = StakingPosition(
          id: 'eth_lido_${address.substring(0, 10)}',
          protocol: StakingProtocols.ethLido,
          stakedAmount: stEthBalance,
          rewardsEarned: BigInt.zero, // stETH 是 rebase 代币，奖励直接反映在余额增长中
          pendingRewards: BigInt.zero,
          stakedAt: DateTime.now().subtract(Duration(days: 30)), // 无法准确知道质押时间
          status: StakingPositionStatus.active,
        );

        return MessageModel()
          ..error = false
          ..data = position;
      }

      return MessageModel()
        ..error = false
        ..data = null;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 构建质押交易数据
  ///
  /// 用户调用 Lido 合约的 submit 方法质押 ETH
  Future<MessageModel> buildStakeTransaction({
    required String fromAddress,
    required BigInt amount,
  }) async {
    try {
      // submit(address _referral) 函数签名
      // 我们使用零地址作为推荐人
      final submitSelector = '0xa1903eab';
      final referral = '0x0000000000000000000000000000000000000000'.replaceFirst('0x', '').padLeft(64, '0');
      final data = '$submitSelector$referral';

      // 获取 gas 估算
      final rpc = chainUrlMap['ETH']?['baseInfo']?['service'] ?? '';

      final gasParams = {
        'jsonrpc': '2.0',
        'method': 'eth_estimateGas',
        'params': [
          {
            'from': fromAddress,
            'to': _lidoContractAddress,
            'value': '0x${amount.toRadixString(16)}',
            'data': data,
          }
        ],
        'id': 1,
      };

      final gasResponse = await BaseApi.requestEmptyH.post(
        rpc,
        params: gasParams,
        data: gasParams,
        header: _headers,
      );

      BigInt gasLimit = BigInt.from(100000); // 默认 gas limit
      if (gasResponse['result'] != null) {
        gasLimit = _hexToBigInt(gasResponse['result'].toString());
        // 增加 20% 安全边际
        gasLimit = gasLimit * BigInt.from(120) ~/ BigInt.from(100);
      }

      final txData = {
        'to': _lidoContractAddress,
        'value': '0x${amount.toRadixString(16)}',
        'data': data,
        'gasLimit': '0x${gasLimit.toRadixString(16)}',
      };

      return MessageModel()
        ..error = false
        ..data = StakingTransactionResponse.success(
          txHash: '',
          txData: txData,
        );
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取 stETH 到 ETH 的兑换率
  Future<MessageModel> getStEthToEthRate() async {
    try {
      // 调用 getPooledEthByShares 方法
      // 传入 1e18 (1 stETH) 获取对应的 ETH 数量
      final rpc = chainUrlMap['ETH']?['baseInfo']?['service'] ?? '';

      final selector = '0x7a28fb88'; // getPooledEthByShares
      final oneStEth = BigInt.from(10).pow(18).toRadixString(16).padLeft(64, '0');
      final data = '$selector$oneStEth';

      final params = {
        'jsonrpc': '2.0',
        'method': 'eth_call',
        'params': [
          {
            'to': _lidoContractAddress,
            'data': data,
          },
          'latest'
        ],
        'id': 1,
      };

      final response = await BaseApi.requestEmptyH.post(
        rpc,
        params: params,
        data: params,
        header: _headers,
      );

      final mm = MessageModel();

      if (response['result'] != null) {
        final ethAmount = _hexToBigInt(response['result'].toString());
        // 转换为浮点数比率
        final rate = ethAmount.toDouble() / 1e18;
        mm.data = rate;
        mm.error = false;
      } else {
        // 默认 1:1
        mm.data = 1.0;
        mm.error = false;
      }

      return mm;
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = 1.0;
    }
  }

  /// 获取 Lido 协议统计数据
  Future<MessageModel> getLidoStats() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_lidoStatsApi/v1/protocol/steth/stats',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map) {
        mm.data = {
          'totalStaked': response['data']?['totalPooledEther'] ?? '0',
          'totalStakers': response['data']?['uniqueHolders'] ?? 0,
          'apr': response['data']?['apr'] ?? 4.0,
        };
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Failed to get stats';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  BigInt _hexToBigInt(String hexStr) {
    String cleaned = hexStr;
    if (cleaned.startsWith('0x') || cleaned.startsWith('0X')) {
      cleaned = cleaned.substring(2);
    }
    if (cleaned.isEmpty) return BigInt.zero;
    return BigInt.parse(cleaned, radix: 16);
  }
}
