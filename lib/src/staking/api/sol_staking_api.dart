// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/src/http/base_api.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/staking/models/staking_models.dart';
import 'package:n42_wallet/src/wallet/utils/chain/wallet_chain_registry.dart';

/// Solana Native Staking API
///
/// Solana 原生质押允许用户将 SOL 委托给验证者
class SolStakingApi {
  static const String _mainnetRpc = 'https://api.mainnet-beta.solana.com';
  static const String _stakeProgramId = 'Stake11111111111111111111111111111111111111';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  String get _rpc {
    return chainUrlMap['SOL']?['baseInfo']?['service'] ?? _mainnetRpc;
  }

  /// 获取验证者列表
  Future<MessageModel> getValidators({int limit = 100}) async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getVoteAccounts',
        'params': [],
      };

      final response = await BaseApi.requestEmptyH.post(
        _rpc,
        params: params,
        data: params,
        header: _headers,
      );

      final mm = MessageModel();

      if (response['result'] != null) {
        final currentValidators = response['result']['current'] as List<dynamic>? ?? [];

        final validators = currentValidators.take(limit).map((v) {
          final commission = v['commission'] ?? 0;
          // 估算 APY: 基础 APY 减去佣金
          final baseApy = 7.0;
          final apy = baseApy * (100 - commission) / 100;

          return Validator(
            address: v['votePubkey'] ?? '',
            name: shortenStakingAddress(v['votePubkey'] ?? '', prefixLen: 6, suffixLen: 4),
            description: 'Solana Validator',
            logoUri: '',
            commission: commission.toDouble(),
            apy: apy,
            totalStaked: BigInt.tryParse(v['activatedStake']?.toString() ?? '0') ?? BigInt.zero,
            delegatorCount: 0, // 无法从此 API 获取
            isActive: true,
            uptime: 100.0,
          );
        }).toList();

        mm.data = validators;
        mm.error = false;
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
      final params = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getProgramAccounts',
        'params': [
          _stakeProgramId,
          {
            'encoding': 'jsonParsed',
            'filters': [
              {
                'memcmp': {
                  'offset': 12,
                  'bytes': walletAddress,
                },
              },
            ],
          },
        ],
      };

      final response = await BaseApi.requestEmptyH.post(
        _rpc,
        params: params,
        data: params,
        header: _headers,
      );

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

          final stakeAmount = BigInt.tryParse(delegation['stake']?.toString() ?? '0') ?? BigInt.zero;
          final validatorAddress = delegation['voter'] ?? '';

          // 确定状态
          StakingPositionStatus status;
          DateTime? unbondingAt;

          if (stake['meta']?['deactivationEpoch'] != null) {
            final deactivationEpochStr = stake['meta']['deactivationEpoch'].toString();
            // max uint64 in string form to avoid integer overflow
            final isMaxEpoch = deactivationEpochStr == '18446744073709551615';
            if (isMaxEpoch) {
              status = StakingPositionStatus.active;
            } else {
              status = StakingPositionStatus.unbonding;
              // Solana 一个 epoch 约 2-3 天
              unbondingAt = DateTime.now().add(Duration(days: 2));
            }
          } else {
            status = StakingPositionStatus.active;
          }

          positions.add(StakingPosition(
            id: account['pubkey'] ?? '',
            protocol: StakingProtocols.solNative,
            validator: Validator(
              address: validatorAddress,
              name: shortenStakingAddress(validatorAddress, prefixLen: 6, suffixLen: 4),
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
          ));
        }

        mm.data = positions;
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = response['error']?['message'] ?? 'Failed to get stake accounts';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取当前 epoch 信息
  Future<MessageModel> getEpochInfo() async {
    try {
      final params = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getEpochInfo',
        'params': [],
      };

      final response = await BaseApi.requestEmptyH.post(
        _rpc,
        params: params,
        data: params,
        header: _headers,
      );

      final mm = MessageModel();

      if (response['result'] != null) {
        mm.data = {
          'epoch': response['result']['epoch'],
          'slotIndex': response['result']['slotIndex'],
          'slotsInEpoch': response['result']['slotsInEpoch'],
          'absoluteSlot': response['result']['absoluteSlot'],
        };
        mm.error = false;
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
      final params = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getStakeMinimumDelegation',
        'params': [],
      };

      final response = await BaseApi.requestEmptyH.post(
        _rpc,
        params: params,
        data: params,
        header: _headers,
      );

      final mm = MessageModel();

      if (response['result']?['value'] != null) {
        mm.data = BigInt.from(response['result']['value']);
        mm.error = false;
      } else {
        // 默认最低 0.01 SOL
        mm.data = BigInt.from(10000000); // 0.01 SOL in lamports
        mm.error = false;
      }

      return mm;
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = BigInt.from(10000000);
    }
  }

  /// 获取当前估算的年化收益率
  Future<MessageModel> getEstimatedApy() async {
    try {
      // Solana 原生质押的 APY 约为 7%
      // 实际值取决于网络状态和通胀率
      final params = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getInflationRate',
        'params': [],
      };

      final response = await BaseApi.requestEmptyH.post(
        _rpc,
        params: params,
        data: params,
        header: _headers,
      );

      final mm = MessageModel();

      if (response['result'] != null) {
        // 通胀率约等于质押 APY
        final total = response['result']['total'] ?? 0.07;
        mm.data = (total * 100).toDouble();
        mm.error = false;
      } else {
        mm.data = 7.0;
        mm.error = false;
      }

      return mm;
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = 7.0;
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
      // Solana 质押交易需要特殊的序列化
      // 这里只返回交易参数，实际签名需要在钱包端完成
      final txData = {
        'type': 'stake',
        'from': fromAddress,
        'validator': validatorAddress,
        'amount': amount.toString(),
        'stakeProgramId': _stakeProgramId,
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

  /// 构建解除委托的交易
  Future<MessageModel> buildUnstakeTransaction({
    required String stakeAccountAddress,
    required String fromAddress,
  }) async {
    try {
      final txData = {
        'type': 'deactivate',
        'stakeAccount': stakeAccountAddress,
        'authority': fromAddress,
        'stakeProgramId': _stakeProgramId,
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

  /// 构建提取已解绑资金的交易
  Future<MessageModel> buildWithdrawTransaction({
    required String stakeAccountAddress,
    required String toAddress,
    required BigInt amount,
  }) async {
    try {
      final txData = {
        'type': 'withdraw',
        'stakeAccount': stakeAccountAddress,
        'to': toAddress,
        'amount': amount.toString(),
        'stakeProgramId': _stakeProgramId,
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

}
