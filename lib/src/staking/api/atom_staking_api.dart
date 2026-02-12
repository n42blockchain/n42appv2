// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/staking/models/staking_models.dart';

/// Cosmos (ATOM) Native Staking API
///
/// Cosmos Hub 原生质押，委托给验证者
class AtomStakingApi {
  static const String _cosmosRestApi = 'https://cosmos-rest.publicnode.com';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 获取验证者列表
  Future<MessageModel> getValidators({
    String status = 'BOND_STATUS_BONDED',
    int limit = 100,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_cosmosRestApi/cosmos/staking/v1beta1/validators?status=$status&pagination.limit=$limit',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['validators'] != null) {
        final validatorsList = response['validators'] as List<dynamic>;

        final validators = validatorsList.map((v) {
          final commission = double.tryParse(
            v['commission']?['commission_rates']?['rate'] ?? '0',
          ) ?? 0;

          // 估算 APY: 基础 APY 约 15%，减去佣金
          final baseApy = 15.0;
          final apy = baseApy * (1 - commission);

          return Validator(
            address: v['operator_address'] ?? '',
            name: v['description']?['moniker'] ?? 'Unknown',
            description: v['description']?['details'] ?? '',
            logoUri: v['description']?['identity'] != null
                ? 'https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=${v['description']['identity']}&fields=pictures'
                : '',
            commission: commission * 100, // 转换为百分比
            apy: apy,
            totalStaked: BigInt.tryParse(v['tokens']?.toString() ?? '0') ?? BigInt.zero,
            delegatorCount: 0,
            isActive: v['status'] == 'BOND_STATUS_BONDED',
            uptime: 100.0,
          );
        }).toList();

        // 按质押量排序
        validators.sort((a, b) => b.totalStaked.compareTo(a.totalStaked));

        mm.data = validators;
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = response['message'] ?? 'Failed to get validators';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取用户的委托列表
  Future<MessageModel> getDelegations(String delegatorAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_cosmosRestApi/cosmos/staking/v1beta1/delegations/$delegatorAddress',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['delegation_responses'] != null) {
        final delegations = response['delegation_responses'] as List<dynamic>;
        final positions = <StakingPosition>[];

        for (final d in delegations) {
          final delegation = d['delegation'];
          final balance = d['balance'];

          if (delegation == null || balance == null) continue;

          final validatorAddress = delegation['validator_address'] ?? '';
          final stakedAmount = BigInt.tryParse(balance['amount']?.toString() ?? '0') ?? BigInt.zero;

          if (stakedAmount == BigInt.zero) continue;

          positions.add(StakingPosition(
            id: '${delegatorAddress}_$validatorAddress',
            protocol: StakingProtocols.atomNative,
            validator: Validator(
              address: validatorAddress,
              name: shortenStakingAddress(validatorAddress),
              description: '',
              logoUri: '',
              commission: 0,
              apy: 15.0,
              totalStaked: BigInt.zero,
              delegatorCount: 0,
              isActive: true,
              uptime: 100,
            ),
            stakedAmount: stakedAmount,
            rewardsEarned: BigInt.zero,
            pendingRewards: BigInt.zero,
            stakedAt: DateTime.now().subtract(Duration(days: 30)),
            status: StakingPositionStatus.active,
          ));
        }

        mm.data = positions;
        mm.error = false;
      } else {
        mm.data = <StakingPosition>[];
        mm.error = false;
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取用户的解绑委托
  Future<MessageModel> getUnbondingDelegations(String delegatorAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_cosmosRestApi/cosmos/staking/v1beta1/delegators/$delegatorAddress/unbonding_delegations',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['unbonding_responses'] != null) {
        final unbondings = response['unbonding_responses'] as List<dynamic>;
        final positions = <StakingPosition>[];

        for (final u in unbondings) {
          final validatorAddress = u['validator_address'] ?? '';
          final entries = u['entries'] as List<dynamic>? ?? [];

          for (final entry in entries) {
            final balance = BigInt.tryParse(entry['balance']?.toString() ?? '0') ?? BigInt.zero;
            final completionTime = DateTime.tryParse(entry['completion_time'] ?? '');

            if (balance == BigInt.zero) continue;

            positions.add(StakingPosition(
              id: '${delegatorAddress}_${validatorAddress}_unbonding',
              protocol: StakingProtocols.atomNative,
              validator: Validator(
                address: validatorAddress,
                name: shortenStakingAddress(validatorAddress),
                description: '',
                logoUri: '',
                commission: 0,
                apy: 0,
                totalStaked: BigInt.zero,
                delegatorCount: 0,
                isActive: false,
                uptime: 0,
              ),
              stakedAmount: balance,
              rewardsEarned: BigInt.zero,
              pendingRewards: BigInt.zero,
              stakedAt: DateTime.now().subtract(Duration(days: 30)),
              unbondingAt: completionTime,
              status: StakingPositionStatus.unbonding,
            ));
          }
        }

        mm.data = positions;
        mm.error = false;
      } else {
        mm.data = <StakingPosition>[];
        mm.error = false;
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取用户的待领取奖励
  Future<MessageModel> getDelegationRewards(String delegatorAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_cosmosRestApi/cosmos/distribution/v1beta1/delegators/$delegatorAddress/rewards',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['rewards'] != null) {
        final rewards = response['rewards'] as List<dynamic>;
        final rewardsByValidator = <String, BigInt>{};

        for (final r in rewards) {
          final validatorAddress = r['validator_address'] ?? '';
          final rewardList = r['reward'] as List<dynamic>? ?? [];

          BigInt totalReward = BigInt.zero;
          for (final reward in rewardList) {
            if (reward['denom'] == 'uatom') {
              // 去掉小数部分
              final amountStr = reward['amount']?.toString() ?? '0';
              final dotIndex = amountStr.indexOf('.');
              final intPart = dotIndex > 0 ? amountStr.substring(0, dotIndex) : amountStr;
              totalReward += BigInt.tryParse(intPart) ?? BigInt.zero;
            }
          }

          if (totalReward > BigInt.zero) {
            rewardsByValidator[validatorAddress] = totalReward;
          }
        }

        // 总奖励
        BigInt totalRewards = BigInt.zero;
        final total = response['total'] as List<dynamic>? ?? [];
        for (final t in total) {
          if (t['denom'] == 'uatom') {
            final amountStr = t['amount']?.toString() ?? '0';
            final dotIndex = amountStr.indexOf('.');
            final intPart = dotIndex > 0 ? amountStr.substring(0, dotIndex) : amountStr;
            totalRewards += BigInt.tryParse(intPart) ?? BigInt.zero;
          }
        }

        mm.data = {
          'byValidator': rewardsByValidator,
          'total': totalRewards,
        };
        mm.error = false;
      } else {
        mm.data = {
          'byValidator': <String, BigInt>{},
          'total': BigInt.zero,
        };
        mm.error = false;
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取质押参数
  Future<MessageModel> getStakingParams() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_cosmosRestApi/cosmos/staking/v1beta1/params',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['params'] != null) {
        final params = response['params'];
        mm.data = {
          'unbondingTime': params['unbonding_time'] ?? '1814400s', // 21 天
          'maxValidators': params['max_validators'] ?? 180,
          'maxEntries': params['max_entries'] ?? 7,
          'bondDenom': params['bond_denom'] ?? 'uatom',
        };
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Failed to get staking params';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取当前通胀率和年化收益
  Future<MessageModel> getInflationAndApy() async {
    try {
      // 获取通胀率
      final inflationResponse = await BaseApi.requestEmptyH.get(
        '$_cosmosRestApi/cosmos/mint/v1beta1/inflation',
        params: {},
        header: _headers,
      );

      double inflation = 0.15; // 默认 15%
      if (inflationResponse is Map && inflationResponse['inflation'] != null) {
        inflation = double.tryParse(inflationResponse['inflation'].toString()) ?? 0.15;
      }

      // 获取质押比例
      final poolResponse = await BaseApi.requestEmptyH.get(
        '$_cosmosRestApi/cosmos/staking/v1beta1/pool',
        params: {},
        header: _headers,
      );

      double stakingRatio = 0.6; // 默认 60%
      if (poolResponse is Map && poolResponse['pool'] != null) {
        final bonded = BigInt.tryParse(poolResponse['pool']['bonded_tokens']?.toString() ?? '0') ?? BigInt.zero;
        final notBonded = BigInt.tryParse(poolResponse['pool']['not_bonded_tokens']?.toString() ?? '0') ?? BigInt.zero;
        final total = bonded + notBonded;
        if (total > BigInt.zero) {
          stakingRatio = bonded.toDouble() / total.toDouble();
        }
      }

      // APY = 通胀率 / 质押比例
      final apy = inflation / stakingRatio * 100;

      return MessageModel()
        ..error = false
        ..data = {
          'inflation': inflation * 100,
          'stakingRatio': stakingRatio * 100,
          'apy': apy,
        };
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = {
          'inflation': 15.0,
          'stakingRatio': 60.0,
          'apy': 15.0,
        };
    }
  }

  /// 构建委托交易消息
  Future<MessageModel> buildDelegateMessage({
    required String delegatorAddress,
    required String validatorAddress,
    required BigInt amount,
  }) async {
    try {
      final msg = {
        '@type': '/cosmos.staking.v1beta1.MsgDelegate',
        'delegator_address': delegatorAddress,
        'validator_address': validatorAddress,
        'amount': {
          'denom': 'uatom',
          'amount': amount.toString(),
        },
      };

      return MessageModel()
        ..error = false
        ..data = StakingTransactionResponse.success(
          txHash: '',
          txData: {'messages': [msg]},
        );
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 构建解除委托交易消息
  Future<MessageModel> buildUndelegateMessage({
    required String delegatorAddress,
    required String validatorAddress,
    required BigInt amount,
  }) async {
    try {
      final msg = {
        '@type': '/cosmos.staking.v1beta1.MsgUndelegate',
        'delegator_address': delegatorAddress,
        'validator_address': validatorAddress,
        'amount': {
          'denom': 'uatom',
          'amount': amount.toString(),
        },
      };

      return MessageModel()
        ..error = false
        ..data = StakingTransactionResponse.success(
          txHash: '',
          txData: {'messages': [msg]},
        );
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 构建领取奖励交易消息
  Future<MessageModel> buildClaimRewardsMessage({
    required String delegatorAddress,
    required String validatorAddress,
  }) async {
    try {
      final msg = {
        '@type': '/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward',
        'delegator_address': delegatorAddress,
        'validator_address': validatorAddress,
      };

      return MessageModel()
        ..error = false
        ..data = StakingTransactionResponse.success(
          txHash: '',
          txData: {'messages': [msg]},
        );
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 构建重新委托交易消息
  Future<MessageModel> buildRedelegateMessage({
    required String delegatorAddress,
    required String srcValidatorAddress,
    required String dstValidatorAddress,
    required BigInt amount,
  }) async {
    try {
      final msg = {
        '@type': '/cosmos.staking.v1beta1.MsgBeginRedelegate',
        'delegator_address': delegatorAddress,
        'validator_src_address': srcValidatorAddress,
        'validator_dst_address': dstValidatorAddress,
        'amount': {
          'denom': 'uatom',
          'amount': amount.toString(),
        },
      };

      return MessageModel()
        ..error = false
        ..data = StakingTransactionResponse.success(
          txHash: '',
          txData: {'messages': [msg]},
        );
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

}
