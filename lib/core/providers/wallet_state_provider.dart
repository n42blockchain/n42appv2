// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/src/component/enums/load.dart';

/// Simplified wallet info for state management
class WalletStateInfo {
  final String uuid;
  final String name;
  final int index;
  final Map<String, dynamic> coinInfo;

  const WalletStateInfo({
    required this.uuid,
    required this.name,
    required this.index,
    this.coinInfo = const {},
  });

  WalletStateInfo copyWith({
    String? uuid,
    String? name,
    int? index,
    Map<String, dynamic>? coinInfo,
  }) {
    return WalletStateInfo(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      index: index ?? this.index,
      coinInfo: coinInfo ?? this.coinInfo,
    );
  }
}

/// Wallet state
class WalletState {
  final List<WalletStateInfo> wallets;
  final int currentIndex;
  final Load loadState;
  final Load balanceLoadState;
  final String? totalBalance;
  final String? error;

  const WalletState({
    this.wallets = const [],
    this.currentIndex = -1,
    this.loadState = Load.finish,
    this.balanceLoadState = Load.finish,
    this.totalBalance,
    this.error,
  });

  WalletState copyWith({
    List<WalletStateInfo>? wallets,
    int? currentIndex,
    Load? loadState,
    Load? balanceLoadState,
    String? totalBalance,
    String? error,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      currentIndex: currentIndex ?? this.currentIndex,
      loadState: loadState ?? this.loadState,
      balanceLoadState: balanceLoadState ?? this.balanceLoadState,
      totalBalance: totalBalance ?? this.totalBalance,
      error: error,
    );
  }

  /// Get current wallet
  WalletStateInfo? get currentWallet {
    if (currentIndex >= 0 && currentIndex < wallets.length) {
      return wallets[currentIndex];
    }
    return null;
  }

  /// Check if has wallets
  bool get hasWallets => wallets.isNotEmpty;

  /// Check if loading
  bool get isLoading => loadState == Load.loading;

  /// Check if balance is loading
  bool get isBalanceLoading => balanceLoadState == Load.loading;
}

/// Wallet state notifier
class WalletStateNotifier extends StateNotifier<WalletState> {
  WalletStateNotifier() : super(const WalletState());

  /// Set loading state
  void setLoading(Load load) {
    state = state.copyWith(loadState: load);
  }

  /// Set balance loading state
  void setBalanceLoading(Load load) {
    state = state.copyWith(balanceLoadState: load);
  }

  /// Set wallets list
  void setWallets(List<WalletStateInfo> wallets) {
    state = state.copyWith(
      wallets: wallets,
      currentIndex: wallets.isNotEmpty ? 0 : -1,
    );
  }

  /// Switch to wallet by index
  void switchWallet(int index) {
    if (index >= 0 && index < state.wallets.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// Update total balance
  void updateTotalBalance(String balance) {
    state = state.copyWith(totalBalance: balance);
  }

  /// Update current wallet's coin info
  void updateCoinInfo(Map<String, dynamic> coinInfo) {
    if (state.currentWallet == null) return;

    final updatedWallet = state.currentWallet!.copyWith(coinInfo: coinInfo);
    final newWallets = List<WalletStateInfo>.from(state.wallets);
    newWallets[state.currentIndex] = updatedWallet;

    state = state.copyWith(wallets: newWallets);
  }

  /// Set error
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clear state
  void clear() {
    state = const WalletState();
  }

  /// Refresh (notify listeners)
  void refresh() {
    state = state.copyWith();
  }
}

/// Wallet state provider
///
/// This is the new Riverpod-based wallet state management.
/// It coexists with the legacy WalletActionProvider for gradual migration.
///
/// Usage:
/// ```dart
/// // Read state
/// final walletState = ref.watch(walletStateProvider);
/// final currentWallet = walletState.currentWallet;
///
/// // Modify state
/// ref.read(walletStateProvider.notifier).switchWallet(1);
/// ref.read(walletStateProvider.notifier).updateTotalBalance('\$1,234.56');
/// ```
final walletStateProvider =
    StateNotifierProvider<WalletStateNotifier, WalletState>((ref) {
  return WalletStateNotifier();
});

/// Current wallet name provider (derived)
final currentWalletNameProvider = Provider<String?>((ref) {
  final state = ref.watch(walletStateProvider);
  return state.currentWallet?.name;
});

/// Wallet count provider (derived)
final walletCountProvider = Provider<int>((ref) {
  return ref.watch(walletStateProvider).wallets.length;
});

/// Total balance provider (derived)
final totalBalanceProvider = Provider<String?>((ref) {
  return ref.watch(walletStateProvider).totalBalance;
});

/// Is wallet loading provider (derived)
final isWalletLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletStateProvider).isLoading;
});
