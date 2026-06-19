// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// Solana Native Staking API
///
/// Solana 原生质押允许用户将 SOL 委托给验证者
class SolStakingApi {
  static const String _mainnetRpc = 'https://api.mainnet-beta.solana.com';
  static const String _stakeProgramId =
      'Stake11111111111111111111111111111111111111';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  String get _rpc {
    return chainUrlMap['SOL']?['baseInfo']?['service'] ?? _mainnetRpc;
  }

  /// 构建 JSON-RPC 请求体
  Map<String, dynamic> _rpcBody(
    String method, [
    List<dynamic> params = const [],
  ]) {
    return {'jsonrpc': '2.0', 'id': 1, 'method': method, 'params': params};
  }

  /// 执行 JSON-RPC 调用
  Future<dynamic> _rpcCall(String method, [List<dynamic> params = const []]) {
    final body = _rpcBody(method, params);
    return BaseApi.requestEmptyH.post(
      _rpc,
      params: body,
      data: body,
      header: _headers,
    );
  }

  /// 构建质押交易成功的 MessageModel
  MessageModel _buildTxResponse(Map<String, dynamic> txData) {
    return MessageModel()
      ..data = StakingTransactionResponse.success(txHash: '', txData: txData);
  }

  /// 获取验证者列表
  Future<MessageModel> getValidators({int limit = 100}) async {
    try {
      final response = await _rpcCall('getVoteAccounts');

      final mm = MessageModel();
      if (response['result'] != null) {
        final currentValidators =
            response['result']['current'] as List<dynamic>? ?? [];

        mm.data = currentValidators.take(limit).map((v) {
          final commission = v['commission'] ?? 0;
          // 估算 APY: 基础 APY 减去佣金
          final baseApy = 7.0;
          final apy = baseApy * (100 - commission) / 100;

          return Validator(
            address: v['votePubkey'] ?? '',
            name: shortenStakingAddress(
              v['votePubkey'] ?? '',
              prefixLen: 6,
              suffixLen: 4,
            ),
            description: 'Solana Validator',
            logoUri: '',
            commission: commission.toDouble(),
            apy: apy,
            totalStaked:
                BigInt.tryParse(v['activatedStake']?.toString() ?? '0') ??
                BigInt.zero,
            delegatorCount: 0, // 无法从此 API 获取
            isActive: true,
            uptime: 100.0,
          );
        }).toList();
      } else {
        mm.error = true;
        mm.data = response['error']?['message'] ?? 'Failed to get validators';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取用户的质押账户
  Future<MessageModel> getStakeAccounts(String walletAddress) async {
    try {
      final response = await _rpcCall('getProgramAccounts', [
        _stakeProgramId,
        {
          'encoding': 'jsonParsed',
          'filters': [
            {
              'memcmp': {'offset': 12, 'bytes': walletAddress},
            },
          ],
        },
      ]);

      final mm = MessageModel();
      if (response['result'] != null) {
        final accounts = response['result'] as List<dynamic>;
        final positions = <StakingPosition>[];

        for (final account in accounts) {
          final parsed = account['account']?['data']?['parsed']?['info'];
          if (parsed == null) continue;

          final stake = parsed['stake'];
          if (stake == null) continue;

          final delegation = stake['delegation'];
          if (delegation == null) continue;

          final stakeAmount =
              BigInt.tryParse(delegation['stake']?.toString() ?? '0') ??
              BigInt.zero;
          final validatorAddress = delegation['voter'] ?? '';

          // 确定状态
          StakingPositionStatus status;
          DateTime? unbondingAt;

          final deactivationEpochStr = stake['meta']?['deactivationEpoch']
              ?.toString();
          if (deactivationEpochStr != null) {
            // max uint64 in string form to avoid integer overflow
            if (deactivationEpochStr == '18446744073709551615') {
              status = StakingPositionStatus.active;
            } else {
              status = StakingPositionStatus.unbonding;
              // Solana 一个 epoch 约 2-3 天
              unbondingAt = DateTime.now().add(Duration(days: 2));
            }
          } else {
            status = StakingPositionStatus.active;
          }

          positions.add(
            StakingPosition(
              id: account['pubkey'] ?? '',
              protocol: StakingProtocols.solNative,
              validator: Validator(
                address: validatorAddress,
                name: shortenStakingAddress(
                  validatorAddress,
                  prefixLen: 6,
                  suffixLen: 4,
                ),
                description: '',
                logoUri: '',
                commission: 0,
                apy: 7.0,
                totalStaked: BigInt.zero,
                delegatorCount: 0,
                isActive: true,
                uptime: 100,
              ),
              stakedAmount: stakeAmount,
              rewardsEarned: BigInt.zero,
              pendingRewards: BigInt.zero,
              stakedAt: DateTime.now().subtract(Duration(days: 30)),
              unbondingAt: unbondingAt,
              status: status,
            ),
          );
        }

        mm.data = positions;
      } else {
        mm.error = true;
        mm.data =
            response['error']?['message'] ?? 'Failed to get stake accounts';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取当前 epoch 信息
  Future<MessageModel> getEpochInfo() async {
    try {
      final response = await _rpcCall('getEpochInfo');

      final mm = MessageModel();
      if (response['result'] != null) {
        final result = response['result'];
        mm.data = {
          'epoch': result['epoch'],
          'slotIndex': result['slotIndex'],
          'slotsInEpoch': result['slotsInEpoch'],
          'absoluteSlot': result['absoluteSlot'],
        };
      } else {
        mm.error = true;
        mm.data = 'Failed to get epoch info';
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取质押最低金额
  Future<MessageModel> getStakeMinimumDelegation() async {
    try {
      final response = await _rpcCall('getStakeMinimumDelegation');

      final mm = MessageModel();
      if (response['result']?['value'] != null) {
        mm.data = BigInt.from(response['result']['value']);
      } else {
        // 默认最低 0.01 SOL
        mm.data = BigInt.from(10000000); // 0.01 SOL in lamports
      }
      return mm;
    } catch (e) {
      return MessageModel()..data = BigInt.from(10000000);
    }
  }

  /// 获取当前估算的年化收益率
  Future<MessageModel> getEstimatedApy() async {
    try {
      // Solana 原生质押的 APY 约为 7%
      // 实际值取决于网络状态和通胀率
      final response = await _rpcCall('getInflationRate');

      final mm = MessageModel();
      if (response['result'] != null) {
        // 通胀率约等于质押 APY
        final total = response['result']['total'] ?? 0.07;
        mm.data = (total * 100).toDouble();
      } else {
        mm.data = 7.0;
      }
      return mm;
    } catch (e) {
      return MessageModel()..data = 7.0;
    }
  }

  /// 构建创建质押账户和委托的交易
  ///
  /// 注意：Solana 质押需要多步操作：
  /// 1. 创建质押账户
  /// 2. 初始化质押账户
  /// 3. 委托给验证者
  /// 这些通常在一个交易中完成
  Future<MessageModel> buildStakeTransaction({
    required String fromAddress,
    required String validatorAddress,
    required BigInt amount,
  }) async {
    try {
      return _buildTxResponse({
        'type': 'stake',
        'from': fromAddress,
        'validator': validatorAddress,
        'amount': amount.toString(),
        'stakeProgramId': _stakeProgramId,
      });
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 构建解除委托的交易
  Future<MessageModel> buildUnstakeTransaction({
    required String stakeAccountAddress,
    required String fromAddress,
  }) async {
    try {
      return _buildTxResponse({
        'type': 'deactivate',
        'stakeAccount': stakeAccountAddress,
        'authority': fromAddress,
        'stakeProgramId': _stakeProgramId,
      });
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 构建提取已解绑资金的交易
  Future<MessageModel> buildWithdrawTransaction({
    required String stakeAccountAddress,
    required String toAddress,
    required BigInt amount,
  }) async {
    try {
      return _buildTxResponse({
        'type': 'withdraw',
        'stakeAccount': stakeAccountAddress,
        'to': toAddress,
        'amount': amount.toString(),
        'stakeProgramId': _stakeProgramId,
      });
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
