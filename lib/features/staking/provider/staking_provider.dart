// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/staking/api/atom_staking_api.dart';
import 'package:n42_wallet/features/staking/api/eth_staking_api.dart';
import 'package:n42_wallet/features/staking/api/sol_staking_api.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';

/// Staking 状态枚举
enum StakingState { initial, loading, loaded, error }

/// Staking Provider
///
/// 管理多链质押状态和操作
class StakingProvider extends ChangeNotifier {
  // APIs
  final EthStakingApi _ethApi = EthStakingApi();
  final SolStakingApi _solApi = SolStakingApi();
  final AtomStakingApi _atomApi = AtomStakingApi();

  // 状态
  StakingState _state = StakingState.initial;
  String? _errorMessage;

  // 当前选择的协议
  StakingProtocol? _selectedProtocol;

  // 验证者列表
  List<Validator> _validators = [];
  Validator? _selectedValidator;

  // 用户质押仓位
  List<StakingPosition> _positions = [];

  // APY 信息
  double _currentApy = 0;

  // Getters
  StakingState get state => _state;
  String? get errorMessage => _errorMessage;
  StakingProtocol? get selectedProtocol => _selectedProtocol;
  List<Validator> get validators => _validators;
  Validator? get selectedValidator => _selectedValidator;
  List<StakingPosition> get positions => _positions;
  double get currentApy => _currentApy;

  /// 获取所有支持的协议
  List<StakingProtocol> get supportedProtocols => StakingProtocols.all;

  /// 获取用户所有活跃仓位
  List<StakingPosition> get activePositions => _positions
      .where((p) => p.status == StakingPositionStatus.active)
      .toList();

  /// 获取用户所有解绑中的仓位
  List<StakingPosition> get unbondingPositions => _positions
      .where((p) => p.status == StakingPositionStatus.unbonding)
      .toList();

  /// 计算总质押价值
  BigInt get totalStakedValue {
    return _positions.fold(BigInt.zero, (sum, p) => sum + p.stakedAmount);
  }

  /// 计算总待领取奖励
  BigInt get totalPendingRewards {
    return _positions.fold(BigInt.zero, (sum, p) => sum + p.pendingRewards);
  }

  /// 选择协议
  void selectProtocol(StakingProtocol protocol) {
    _selectedProtocol = protocol;
    _selectedValidator = null;
    _validators = [];
    _currentApy = protocol.apy;
    notifyListeners();
  }

  /// 选择验证者
  void selectValidator(Validator validator) {
    _selectedValidator = validator;
    notifyListeners();
  }

  /// 清除选择
  void clearSelection() {
    _selectedProtocol = null;
    _selectedValidator = null;
    _validators = [];
    notifyListeners();
  }

  /// 加载验证者列表
  Future<void> loadValidators() async {
    if (_selectedProtocol == null) return;

    _state = StakingState.loading;
    notifyListeners();

    try {
      switch (_selectedProtocol!.chainType) {
        case StakingChainType.ethereum:
          // Lido 没有验证者选择，直接使用协议
          _validators = [];
          _currentApy = _selectedProtocol!.apy;
          _tryUpdateApy(await _ethApi.getLidoApy());
          break;

        case StakingChainType.solana:
          _validators = _extractList<Validator>(
            await _solApi.getValidators(limit: 100),
          );
          _tryUpdateApy(await _solApi.getEstimatedApy());
          break;

        case StakingChainType.cosmos:
          _validators = _extractList<Validator>(
            await _atomApi.getValidators(limit: 100),
          );
          _tryUpdateApy(await _atomApi.getInflationAndApy(), mapKey: 'apy');
          break;

        case StakingChainType.polkadot:
          throw UnsupportedError('DOT staking is not yet supported');
      }

      _state = StakingState.loaded;
    } catch (e) {
      _state = StakingState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// 加载用户质押仓位
  Future<void> loadUserPositions(
    String address,
    StakingChainType chainType,
  ) async {
    _state = StakingState.loading;
    notifyListeners();

    try {
      switch (chainType) {
        case StakingChainType.ethereum:
          final result = await _ethApi.getStakingPosition(address);
          _positions = (!result.error && result.data != null)
              ? [result.data as StakingPosition]
              : [];
          break;

        case StakingChainType.solana:
          _positions = _extractList<StakingPosition>(
            await _solApi.getStakeAccounts(address),
          );
          break;

        case StakingChainType.cosmos:
          final allPositions = <StakingPosition>[
            ..._extractList<StakingPosition>(
              await _atomApi.getDelegations(address),
            ),
            ..._extractList<StakingPosition>(
              await _atomApi.getUnbondingDelegations(address),
            ),
          ];

          // 获取待领取奖励并更新仓位
          final rewardsResult = await _atomApi.getDelegationRewards(address);
          if (!rewardsResult.error && rewardsResult.data != null) {
            final rewardsData = rewardsResult.data as Map<String, dynamic>;
            final byValidator =
                rewardsData['byValidator'] as Map<String, BigInt>;

            for (var position in allPositions) {
              if (position.validator != null &&
                  byValidator.containsKey(position.validator!.address)) {
                // 创建新的 position 对象，包含奖励信息
                final idx = allPositions.indexOf(position);
                allPositions[idx] = StakingPosition(
                  id: position.id,
                  protocol: position.protocol,
                  validator: position.validator,
                  stakedAmount: position.stakedAmount,
                  rewardsEarned: position.rewardsEarned,
                  pendingRewards:
                      byValidator[position.validator!.address] ?? BigInt.zero,
                  stakedAt: position.stakedAt,
                  unbondingAt: position.unbondingAt,
                  status: position.status,
                );
              }
            }
          }

          _positions = allPositions;
          break;

        case StakingChainType.polkadot:
          throw UnsupportedError('DOT staking is not yet supported');
      }

      _state = StakingState.loaded;
    } catch (e) {
      _state = StakingState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// 加载所有链的用户仓位
  Future<void> loadAllUserPositions(
    Map<StakingChainType, String> addresses,
  ) async {
    _state = StakingState.loading;
    notifyListeners();

    List<StakingPosition> allPositions = [];

    try {
      for (final entry in addresses.entries) {
        final chainType = entry.key;
        final address = entry.value;

        if (address.isEmpty) continue;

        switch (chainType) {
          case StakingChainType.ethereum:
            final result = await _ethApi.getStakingPosition(address);
            if (!result.error && result.data != null) {
              allPositions.add(result.data as StakingPosition);
            }
            break;

          case StakingChainType.solana:
            allPositions.addAll(
              _extractList<StakingPosition>(
                await _solApi.getStakeAccounts(address),
              ),
            );
            break;

          case StakingChainType.cosmos:
            allPositions.addAll(
              _extractList<StakingPosition>(
                await _atomApi.getDelegations(address),
              ),
            );
            allPositions.addAll(
              _extractList<StakingPosition>(
                await _atomApi.getUnbondingDelegations(address),
              ),
            );
            break;

          case StakingChainType.polkadot:
            // DOT staking not yet supported; skip silently in multi-chain load
            break;
        }
      }

      _positions = allPositions;
      _state = StakingState.loaded;
    } catch (e) {
      _state = StakingState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// 从 API 结果中提取列表数据，失败时返回空列表
  List<T> _extractList<T>(MessageModel result) {
    if (!result.error && result.data != null) {
      return result.data as List<T>;
    }
    return [];
  }

  /// 从 API 结果中更新 APY（如果请求成功）
  void _tryUpdateApy(MessageModel result, {String? mapKey}) {
    if (result.error || result.data == null) return;
    if (mapKey != null) {
      final data = result.data as Map<String, dynamic>;
      _currentApy = data[mapKey] ?? _selectedProtocol!.apy;
    } else {
      _currentApy = result.data as double;
    }
  }

  /// 从 API 结果中提取交易响应，统一处理成功/失败逻辑
  StakingTransactionResponse _extractTxResponse(MessageModel result) {
    if (!result.error && result.data != null) {
      return result.data as StakingTransactionResponse;
    }
    return StakingTransactionResponse.error(
      result.data?.toString() ?? 'Failed to build transaction',
    );
  }

  /// 构建质押交易
  Future<StakingTransactionResponse?> buildStakeTransaction({
    required String fromAddress,
    required BigInt amount,
  }) async {
    if (_selectedProtocol == null) {
      return StakingTransactionResponse.error('No protocol selected');
    }

    try {
      switch (_selectedProtocol!.chainType) {
        case StakingChainType.ethereum:
          final result = await _ethApi.buildStakeTransaction(
            fromAddress: fromAddress,
            amount: amount,
          );
          return _extractTxResponse(result);

        case StakingChainType.solana:
          if (_selectedValidator == null) {
            return StakingTransactionResponse.error('No validator selected');
          }
          final result = await _solApi.buildStakeTransaction(
            fromAddress: fromAddress,
            validatorAddress: _selectedValidator!.address,
            amount: amount,
          );
          return _extractTxResponse(result);

        case StakingChainType.cosmos:
          if (_selectedValidator == null) {
            return StakingTransactionResponse.error('No validator selected');
          }
          final result = await _atomApi.buildDelegateMessage(
            delegatorAddress: fromAddress,
            validatorAddress: _selectedValidator!.address,
            amount: amount,
          );
          return _extractTxResponse(result);

        case StakingChainType.polkadot:
          return StakingTransactionResponse.error(
            'DOT staking not yet implemented',
          );
      }
    } catch (e) {
      return StakingTransactionResponse.error(e.toString());
    }
  }

  /// 构建解除质押交易
  Future<StakingTransactionResponse?> buildUnstakeTransaction({
    required StakingPosition position,
    required BigInt amount,
    required String fromAddress,
  }) async {
    try {
      switch (position.protocol.chainType) {
        case StakingChainType.ethereum:
          // Lido stETH 可以直接在 DEX 交易，无需解除质押
          return StakingTransactionResponse.error(
            'stETH can be traded directly on DEX without unstaking',
          );

        case StakingChainType.solana:
          final result = await _solApi.buildUnstakeTransaction(
            stakeAccountAddress: position.id,
            fromAddress: fromAddress,
          );
          return _extractTxResponse(result);

        case StakingChainType.cosmos:
          if (position.validator == null) {
            return StakingTransactionResponse.error('No validator in position');
          }
          final result = await _atomApi.buildUndelegateMessage(
            delegatorAddress: fromAddress,
            validatorAddress: position.validator!.address,
            amount: amount,
          );
          return _extractTxResponse(result);

        case StakingChainType.polkadot:
          return StakingTransactionResponse.error(
            'DOT unstaking not yet implemented',
          );
      }
    } catch (e) {
      return StakingTransactionResponse.error(e.toString());
    }
  }

  /// 构建领取奖励交易
  Future<StakingTransactionResponse?> buildClaimRewardsTransaction({
    required StakingPosition position,
    required String fromAddress,
  }) async {
    try {
      switch (position.protocol.chainType) {
        case StakingChainType.ethereum:
          // Lido stETH 奖励自动复投，无需领取
          return StakingTransactionResponse.error(
            'stETH rewards are auto-compounded, no claim needed',
          );

        case StakingChainType.solana:
          // Solana 原生质押奖励自动添加到质押余额
          return StakingTransactionResponse.error(
            'Solana staking rewards are auto-added to stake balance',
          );

        case StakingChainType.cosmos:
          if (position.validator == null) {
            return StakingTransactionResponse.error('No validator in position');
          }
          final result = await _atomApi.buildClaimRewardsMessage(
            delegatorAddress: fromAddress,
            validatorAddress: position.validator!.address,
          );
          return _extractTxResponse(result);

        case StakingChainType.polkadot:
          return StakingTransactionResponse.error(
            'DOT claim not yet implemented',
          );
      }
    } catch (e) {
      return StakingTransactionResponse.error(e.toString());
    }
  }

  /// 获取质押统计
  StakingStats getStats() {
    final activePos = activePositions;
    final totalStaked = activePos.fold(
      BigInt.zero,
      (sum, p) => sum + p.stakedAmount,
    );
    final totalRewards = activePos.fold(
      BigInt.zero,
      (sum, p) => sum + p.pendingRewards,
    );
    final totalApy = activePos.fold(0.0, (sum, p) => sum + p.protocol.apy);

    return StakingStats(
      totalStaked: totalStaked,
      totalRewards: totalRewards,
      averageApy: activePos.isNotEmpty ? totalApy / activePos.length : 0,
      activePositions: activePos.length,
    );
  }

  /// 重置状态
  void reset() {
    _state = StakingState.initial;
    _errorMessage = null;
    _selectedProtocol = null;
    _selectedValidator = null;
    _validators = [];
    _positions = [];
    _currentApy = 0;
    notifyListeners();
  }
}
