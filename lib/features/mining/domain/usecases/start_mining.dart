// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/core/usecase/usecase.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';
import 'package:n42_wallet/features/mining/domain/repositories/mining_repository.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';

// **Status: designed but not wired into the production mining path.** The
// five use cases below (StartMining / StopMining / GetMiningStatus /
// GetMiningPlans / ClaimMiningRewards) build on top of [MiningRepository]
// — which IS wired through `miningRepositoryProvider` (lib/features/mining/
// presentation/providers/mining_providers.dart) — but no production widget
// calls them. Production mining UI talks to [MiningV2Provider] directly via
// `miningBridgeProvider`, and the staking flow does its own native-plugin
// orchestration (see features/mining_v2/).
//
// These use cases are retained as the canonical Clean-Arch surface for
// mining: if a future refactor moves the V2 imperative pages onto the
// repository layer, this file is the contract to satisfy. Do not invent
// new mining UseCases elsewhere; extend the set here.

/// Start Mining Use Case
class StartMining implements UseCase<MiningSessionEntity, StartMiningParams> {
  final MiningRepository _miningRepository;
  final IWalletService _walletService;

  StartMining(this._miningRepository, this._walletService);

  @override
  Future<Either<Failure, MiningSessionEntity>> call(
    StartMiningParams params,
  ) async {
    // Validate wallet exists
    final wallet = _walletService.getWalletByAddress(params.walletAddress);
    if (wallet == null) {
      return const Left(ValidationFailure(message: 'Wallet not found'));
    }

    // Start mining
    return await _miningRepository.startMining(
      planId: params.planId,
      walletAddress: params.walletAddress,
    );
  }
}

/// Parameters for StartMining use case
class StartMiningParams extends Equatable {
  final String planId;
  final String walletAddress;

  const StartMiningParams({required this.planId, required this.walletAddress});

  @override
  List<Object?> get props => [planId, walletAddress];
}

/// Stop Mining Use Case
class StopMining implements UseCase<void, String> {
  final MiningRepository _repository;

  StopMining(this._repository);

  @override
  Future<Either<Failure, void>> call(String sessionId) async {
    return await _repository.stopMining(sessionId);
  }
}

/// Get Mining Status Use Case
class GetMiningStatus implements UseCase<MiningStatusEntity, NoParams> {
  final MiningRepository _repository;

  GetMiningStatus(this._repository);

  @override
  Future<Either<Failure, MiningStatusEntity>> call(NoParams params) async {
    return await _repository.getMiningStatus();
  }
}

/// Get Mining Plans Use Case
class GetMiningPlans implements UseCase<List<MiningPlanEntity>, NoParams> {
  final MiningRepository _repository;

  GetMiningPlans(this._repository);

  @override
  Future<Either<Failure, List<MiningPlanEntity>>> call(NoParams params) async {
    return await _repository.getMiningPlans();
  }
}

/// Claim Mining Rewards Use Case
class ClaimMiningRewards implements UseCase<String, ClaimRewardsParams> {
  final MiningRepository _repository;

  ClaimMiningRewards(this._repository);

  @override
  Future<Either<Failure, String>> call(ClaimRewardsParams params) async {
    if (params.amount.isEmpty) {
      return const Left(ValidationFailure(message: 'Amount is required'));
    }

    return await _repository.claimRewards(
      walletAddress: params.walletAddress,
      amount: params.amount,
    );
  }
}

/// Parameters for ClaimMiningRewards use case
class ClaimRewardsParams extends Equatable {
  final String walletAddress;
  final String amount;

  const ClaimRewardsParams({required this.walletAddress, required this.amount});

  @override
  List<Object?> get props => [walletAddress, amount];
}
