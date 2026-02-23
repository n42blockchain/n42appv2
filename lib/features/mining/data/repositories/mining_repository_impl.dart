// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';
import 'package:n42_wallet/features/mining/domain/repositories/mining_repository.dart';
import 'package:n42_wallet/src/miningV2/provider/mining_v2_provider.dart';

/// Concrete [MiningRepository] implementation backed by [MiningV2Provider].
///
/// This class bridges the clean-architecture V1 domain layer to the existing
/// V2 production implementation. It delegates reads to [MiningV2Provider] and
/// maps V2 data models to V1 entities so that domain use cases can be wired
/// without duplicating business logic.
///
/// Mutations (start / stop mining) are intentionally left as thin delegates
/// to [MiningV2Provider] because the actual staking flow requires native
/// plugin calls that already live in V2.
class MiningRepositoryImpl implements MiningRepository {
  final MiningV2Provider _v2;

  // Stream controller that re-emits V2 state changes as [MiningStatusEntity].
  final StreamController<MiningStatusEntity> _statusStreamController =
      StreamController<MiningStatusEntity>.broadcast();

  void Function()? _v2Listener;

  MiningRepositoryImpl(this._v2) {
    _v2Listener = () {
      if (!_statusStreamController.isClosed) {
        _statusStreamController.add(_buildStatusEntity());
      }
    };
    _v2.addListener(_v2Listener!);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  MiningStatusEntity _buildStatusEntity() {
    return MiningStatusEntity(
      isActive: _v2.miningStatus,
      totalPower: _v2.balanceInBeacon,
      lastUpdated: DateTime.now(),
    );
  }

  MiningPlanEntity _standardPlan() {
    return const MiningPlanEntity(
      id: 'standard',
      name: 'Standard Mining',
      description: 'Stake 32 N to participate in beacon-chain consensus mining.',
      stakeAmount: 32,
      stakeTokenSymbol: 'N',
      dailyRewardRate: 0,
      minDurationDays: 1,
      isAvailable: true,
      tierLevel: 1,
    );
  }

  MiningSessionEntity _sessionFromDailyWithdrawal(int idx) {
    final daily = _v2.taskList[idx];
    final amount = double.tryParse(daily.totalAmount ?? '0') ?? 0.0;
    return MiningSessionEntity(
      id: '${daily.day}-$idx',
      walletAddress: _v2.address ?? '',
      planId: 'standard',
      startTime: _parseDayToDateTime(daily.day),
      status: MiningSessionStatus.completed,
      earnedRewards: amount / 1e18,
      rewardTokenSymbol: 'N',
      miningPower: _v2.balanceInBeacon,
    );
  }

  DateTime _parseDayToDateTime(String? day) {
    if (day == null) return DateTime.now();
    try {
      final parts = day.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (_) {}
    return DateTime.now();
  }

  // ─── MiningRepository interface ─────────────────────────────────────────────

  @override
  Future<Either<Failure, MiningStatusEntity>> getMiningStatus() async {
    return Right(_buildStatusEntity());
  }

  @override
  Future<Either<Failure, List<MiningPlanEntity>>> getMiningPlans() async {
    return Right([_standardPlan()]);
  }

  @override
  Future<Either<Failure, MiningPlanEntity?>> getMiningPlan(String planId) async {
    if (planId == 'standard') return Right(_standardPlan());
    return const Right(null);
  }

  @override
  Future<Either<Failure, MiningSessionEntity>> startMining({
    required String planId,
    required String walletAddress,
  }) async {
    // V2 uses native staking flow (createDepositUnsignedTx). Callers should
    // use MiningV2Provider directly for the full staking flow. This shim
    // returns the current session if mining is already active.
    if (_v2.depositsEnable == true) {
      return Right(MiningSessionEntity(
        id: 'active-${walletAddress.hashCode}',
        walletAddress: walletAddress,
        planId: planId,
        startTime: DateTime.now(),
        status: MiningSessionStatus.active,
        earnedRewards: _v2.miningTotalRevenue,
        rewardTokenSymbol: 'N',
        miningPower: _v2.balanceInBeacon,
      ));
    }
    return const Left(
      ServerFailure(message: 'Mining not active. Use MiningV2Provider.createDepositUnsignedTx().'),
    );
  }

  @override
  Future<Either<Failure, void>> stopMining(String sessionId) async {
    // Actual unstaking uses V2's createExitDepositUnsignedTx().
    // Domain callers should trigger that via MiningV2Provider directly.
    return const Left(
      ServerFailure(message: 'Use MiningV2Provider.createExitDepositUnsignedTx() to stop mining.'),
    );
  }

  @override
  Future<Either<Failure, List<MiningSessionEntity>>> getMiningHistory({
    required String walletAddress,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final all = List.generate(
        _v2.taskList.length,
        (i) => _sessionFromDailyWithdrawal(i),
      );
      final start = (page - 1) * limit;
      if (start >= all.length) return const Right([]);
      return Right(all.sublist(start, (start + limit).clamp(0, all.length)));
    } catch (e) {
      return Left(ServerFailure(message: 'getMiningHistory failed: $e'));
    }
  }

  @override
  Future<Either<Failure, MiningRewardsEntity>> getMiningRewards(
      String walletAddress) async {
    return Right(MiningRewardsEntity(
      totalEarned: _v2.miningTotalRevenue,
      claimableAmount: 0,
      claimedAmount: _v2.miningTotalRevenue,
      tokenSymbol: 'N',
    ));
  }

  @override
  Future<Either<Failure, String>> claimRewards({
    required String walletAddress,
    required String amount,
  }) async {
    return const Left(
      ServerFailure(message: 'N chain rewards are distributed automatically; no manual claim needed.'),
    );
  }

  @override
  Future<Either<Failure, MiningStatisticsEntity>> getMiningStatistics(
      String walletAddress) async {
    final days = _v2.taskList.length;
    return Right(MiningStatisticsEntity(
      totalSessions: days,
      totalActiveDays: days,
      averageDailyRewards:
          days > 0 ? _v2.miningTotalRevenue / days : 0,
      bestDailyRewards: _v2.todayCycleRewardsValue > _v2.yesterdayCycleRewardsValue
          ? _v2.todayCycleRewardsValue
          : _v2.yesterdayCycleRewardsValue,
      totalRewards: _v2.miningTotalRevenue,
      tokenSymbol: 'N',
    ));
  }

  @override
  Future<Either<Failure, FullNodeEntity?>> getFullNode(String pubKey) async {
    try {
      final targetPubKey = pubKey.isNotEmpty
          ? pubKey
          : (_v2.miningKeypart?['publicKey'] ?? '');
      if (targetPubKey.isEmpty) return const Right(null);
      if (_v2.depositsEnable != true) return const Right(null);

      // Determine node status from V2 provider's cached beacon state.
      // showRedemption=true  → activation complete and ready
      // showRedemption2=true → exit_timestamp == 0 (normal/active)
      // showRedemption2=false → exit_timestamp != 0 (has exited or exiting)
      NodeStatus status;
      if (!_v2.showRedemption2 && _v2.exitTimestamp != 0) {
        // Node has exited the beacon chain
        status = NodeStatus.offline;
      } else if (_v2.showRedemption) {
        // Activation complete; online if WebSocket mining is active
        status = _v2.miningStatus ? NodeStatus.online : NodeStatus.offline;
      } else {
        // Pending activation
        status = NodeStatus.syncing;
      }

      final inactivityPct = double.tryParse(_v2.inactivityScorePercentage) ?? 0.0;
      final uptimePercentage = (100.0 - inactivityPct).clamp(0.0, 100.0);

      return Right(FullNodeEntity(
        id: targetPubKey,
        name: 'Beacon Validator',
        status: status,
        uptimePercentage: uptimePercentage,
        totalRewards: _v2.miningTotalRevenue,
        activatedAt: _v2.activationTime ?? DateTime.now(),
        expiresAt: _v2.exitTimestamp > 0
            ? DateTime.fromMillisecondsSinceEpoch(_v2.exitTimestamp * 1000)
            : null,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'getFullNode failed: $e'));
    }
  }

  @override
  Stream<MiningStatusEntity> get miningStatusStream =>
      _statusStreamController.stream;

  void dispose() {
    if (_v2Listener != null) {
      _v2.removeListener(_v2Listener!);
      _v2Listener = null;
    }
    _statusStreamController.close();
  }
}
