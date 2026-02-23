// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';

/// Mining Repository Interface
///
/// Defines the contract for mining data operations.
abstract class MiningRepository {
  /// Get current mining status
  Future<Either<Failure, MiningStatusEntity>> getMiningStatus();

  /// Get available mining plans
  Future<Either<Failure, List<MiningPlanEntity>>> getMiningPlans();

  /// Get mining plan by ID
  Future<Either<Failure, MiningPlanEntity?>> getMiningPlan(String planId);

  /// Start mining
  Future<Either<Failure, MiningSessionEntity>> startMining({
    required String planId,
    required String walletAddress,
  });

  /// Stop mining
  Future<Either<Failure, void>> stopMining(String sessionId);

  /// Get mining history
  Future<Either<Failure, List<MiningSessionEntity>>> getMiningHistory({
    required String walletAddress,
    int page = 1,
    int limit = 20,
  });

  /// Get mining rewards
  Future<Either<Failure, MiningRewardsEntity>> getMiningRewards(String walletAddress);

  /// Claim mining rewards
  Future<Either<Failure, String>> claimRewards({
    required String walletAddress,
    required String amount,
  });

  /// Get mining statistics
  Future<Either<Failure, MiningStatisticsEntity>> getMiningStatistics(String walletAddress);

  /// Get full node (beacon validator) info by validator public key.
  ///
  /// Returns [null] if not staked or beacon data not yet loaded.
  Future<Either<Failure, FullNodeEntity?>> getFullNode(String pubKey);

  /// Subscribe to mining status updates
  Stream<MiningStatusEntity> get miningStatusStream;
}

