// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42appv2/src/component/enums/load.dart';

/// Mining wallet info
class MiningWalletInfo {
  final int index;
  final String name;
  final String address;
  final bool supportsNChain;

  const MiningWalletInfo({
    required this.index,
    required this.name,
    required this.address,
    this.supportsNChain = true,
  });

  MiningWalletInfo copyWith({
    int? index,
    String? name,
    String? address,
    bool? supportsNChain,
  }) {
    return MiningWalletInfo(
      index: index ?? this.index,
      name: name ?? this.name,
      address: address ?? this.address,
      supportsNChain: supportsNChain ?? this.supportsNChain,
    );
  }
}

/// Mining state
class MiningState {
  final List<MiningWalletInfo> wallets;
  final int selectedWalletIndex;
  final bool isDeposited;
  final bool isMining;
  final String? balance;
  final String? pendingRewards;
  final String? totalMined;
  final Load loadState;
  final String? error;

  const MiningState({
    this.wallets = const [],
    this.selectedWalletIndex = -1,
    this.isDeposited = false,
    this.isMining = false,
    this.balance,
    this.pendingRewards,
    this.totalMined,
    this.loadState = Load.finish,
    this.error,
  });

  MiningState copyWith({
    List<MiningWalletInfo>? wallets,
    int? selectedWalletIndex,
    bool? isDeposited,
    bool? isMining,
    String? balance,
    String? pendingRewards,
    String? totalMined,
    Load? loadState,
    String? error,
  }) {
    return MiningState(
      wallets: wallets ?? this.wallets,
      selectedWalletIndex: selectedWalletIndex ?? this.selectedWalletIndex,
      isDeposited: isDeposited ?? this.isDeposited,
      isMining: isMining ?? this.isMining,
      balance: balance ?? this.balance,
      pendingRewards: pendingRewards ?? this.pendingRewards,
      totalMined: totalMined ?? this.totalMined,
      loadState: loadState ?? this.loadState,
      error: error,
    );
  }

  /// Get selected wallet
  MiningWalletInfo? get selectedWallet {
    if (selectedWalletIndex >= 0 && selectedWalletIndex < wallets.length) {
      return wallets[selectedWalletIndex];
    }
    return null;
  }

  /// Check if has wallets
  bool get hasWallets => wallets.isNotEmpty;

  /// Check if loading
  bool get isLoading => loadState == Load.loading;

  /// Can start mining
  bool get canMine => isDeposited && !isMining && selectedWallet != null;
}

/// Mining state notifier
class MiningStateNotifier extends StateNotifier<MiningState> {
  MiningStateNotifier() : super(const MiningState());

  /// Set loading state
  void setLoading(Load load) {
    state = state.copyWith(loadState: load);
  }

  /// Set wallets list
  void setWallets(List<MiningWalletInfo> wallets) {
    state = state.copyWith(
      wallets: wallets,
      selectedWalletIndex: wallets.isNotEmpty ? 0 : -1,
    );
  }

  /// Select wallet by index
  void selectWallet(int index) {
    if (index >= 0 && index < state.wallets.length) {
      state = state.copyWith(selectedWalletIndex: index);
    }
  }

  /// Set deposit status
  void setDeposited(bool deposited) {
    state = state.copyWith(isDeposited: deposited);
  }

  /// Set mining status
  void setMining(bool mining) {
    state = state.copyWith(isMining: mining);
  }

  /// Update balance
  void updateBalance(String balance) {
    state = state.copyWith(balance: balance);
  }

  /// Update pending rewards
  void updatePendingRewards(String rewards) {
    state = state.copyWith(pendingRewards: rewards);
  }

  /// Update total mined
  void updateTotalMined(String total) {
    state = state.copyWith(totalMined: total);
  }

  /// Set error
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Reset all data
  void reset() {
    state = const MiningState();
  }

  /// Refresh (notify listeners)
  void refresh() {
    state = state.copyWith();
  }
}

/// Mining state provider
///
/// This is the new Riverpod-based mining state management.
/// It coexists with the legacy MiningV2Provider for gradual migration.
///
/// Usage:
/// ```dart
/// // Read state
/// final miningState = ref.watch(miningStateProvider);
/// final isMining = miningState.isMining;
///
/// // Modify state
/// ref.read(miningStateProvider.notifier).setMining(true);
/// ref.read(miningStateProvider.notifier).updateBalance('1,234.56');
/// ```
final miningStateProvider =
    StateNotifierProvider<MiningStateNotifier, MiningState>((ref) {
  return MiningStateNotifier();
});

/// Is mining provider (derived)
final isMiningProvider = Provider<bool>((ref) {
  return ref.watch(miningStateProvider).isMining;
});

/// Mining balance provider (derived)
final miningBalanceProvider = Provider<String?>((ref) {
  return ref.watch(miningStateProvider).balance;
});

/// Pending rewards provider (derived)
final pendingRewardsProvider = Provider<String?>((ref) {
  return ref.watch(miningStateProvider).pendingRewards;
});

/// Can mine provider (derived)
final canMineProvider = Provider<bool>((ref) {
  return ref.watch(miningStateProvider).canMine;
});

/// Selected mining wallet provider (derived)
final selectedMiningWalletProvider = Provider<MiningWalletInfo?>((ref) {
  return ref.watch(miningStateProvider).selectedWallet;
});
