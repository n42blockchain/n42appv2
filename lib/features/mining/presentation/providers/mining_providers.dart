// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/features/mining/data/repositories/mining_repository_impl.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';
import 'package:n42_wallet/features/mining/domain/repositories/mining_repository.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

/// Global MiningV2Provider instance shared between legacy code and Riverpod.
/// Initialized in main() before runApp().
late final MiningV2Provider globalMiningInstance;

/// Riverpod bridge provider for MiningV2Provider.
///
/// Usage:
/// - `ref.read(miningBridgeProvider)` replaces `Provider.of<MiningV2Provider>(context, listen: false)`
/// - `ref.watch(miningBridgeProvider)` replaces `Consumer<MiningV2Provider>`
final miningBridgeProvider = ChangeNotifierProvider<MiningV2Provider>((ref) {
  return globalMiningInstance;
});

/// Derived provider for the current [FullNodeEntity].
/// Automatically updates whenever [MiningV2Provider] notifies listeners.
final fullNodeProvider = Provider<FullNodeEntity?>((ref) {
  return ref.watch(miningBridgeProvider).fullNodeEntity;
});

/// Clean-architecture [MiningRepository] backed by the live
/// [MiningV2Provider]. The repo wraps V2 reads in `Either<Failure, T>`
/// for the four mining use cases (`StartMining` / `StopMining` /
/// `GetMiningStatus` / `GetMiningPlans` / `ClaimMiningRewards`); UI code
/// that wants Clean-Arch error semantics resolves the repo through this
/// provider, while existing V2 pages continue to use [miningBridgeProvider]
/// directly.
///
/// `ref.onDispose` releases the V2 listener and closes the internal
/// status stream when the container tears down.
final miningRepositoryProvider = Provider<MiningRepository>((ref) {
  final repo = MiningRepositoryImpl(globalMiningInstance);
  ref.onDispose(repo.dispose);
  return repo;
});
