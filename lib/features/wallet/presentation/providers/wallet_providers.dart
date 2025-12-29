// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';

/// Wallet Info Data for Provider
/// Lightweight representation for state management
class WalletInfoData {
  final String address;
  final String name;
  final String chainType;
  final String? mnemonic;
  final String? privateKey;
  final String? avatarUrl;
  final bool isMainWallet;
  final DateTime createdAt;

  const WalletInfoData({
    required this.address,
    required this.name,
    required this.chainType,
    this.mnemonic,
    this.privateKey,
    this.avatarUrl,
    this.isMainWallet = false,
    required this.createdAt,
  });

  WalletInfoData copyWith({
    String? address,
    String? name,
    String? chainType,
    String? mnemonic,
    String? privateKey,
    String? avatarUrl,
    bool? isMainWallet,
    DateTime? createdAt,
  }) {
    return WalletInfoData(
      address: address ?? this.address,
      name: name ?? this.name,
      chainType: chainType ?? this.chainType,
      mnemonic: mnemonic ?? this.mnemonic,
      privateKey: privateKey ?? this.privateKey,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMainWallet: isMainWallet ?? this.isMainWallet,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Coin Balance Data
class CoinBalanceData {
  final String symbol;
  final String name;
  final String iconUrl;
  final double balance;
  final double balanceUsd;
  final double price;
  final double priceChange24h;
  final String? contractAddress;
  final String chainType;

  const CoinBalanceData({
    required this.symbol,
    required this.name,
    required this.iconUrl,
    required this.balance,
    required this.balanceUsd,
    required this.price,
    required this.priceChange24h,
    this.contractAddress,
    required this.chainType,
  });
}

// ============ Providers ============

/// Wallet List Provider (Async)
final walletListProvider =
    AsyncNotifierProvider<WalletListNotifier, List<WalletInfoData>>(() {
  return WalletListNotifier();
});

class WalletListNotifier extends AsyncNotifier<List<WalletInfoData>> {
  @override
  Future<List<WalletInfoData>> build() async {
    // Load wallets from storage
    return await _loadWallets();
  }

  Future<List<WalletInfoData>> _loadWallets() async {
    final spUtil = SPUtil();
    final walletAll = await spUtil.getWallsetInfo();
    
    if (walletAll == null) {
      return [];
    }

    // Parse wallet data from storage
    final List<WalletInfoData> wallets = [];
    // TODO: Implement actual parsing based on storage format
    
    return wallets;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadWallets());
  }

  Future<void> addWallet(WalletInfoData wallet) async {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([...current, wallet]);
    // TODO: Save to storage
  }

  Future<void> removeWallet(String address) async {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.where((w) => w.address != address).toList(),
    );
    // TODO: Save to storage
  }

  Future<void> updateWallet(WalletInfoData wallet) async {
    final current = state.valueOrNull ?? [];
    final index = current.indexWhere((w) => w.address == wallet.address);
    if (index != -1) {
      final updated = [...current];
      updated[index] = wallet;
      state = AsyncValue.data(updated);
      // TODO: Save to storage
    }
  }
}

/// Selected Wallet Index Provider
final selectedWalletIndexProvider =
    StateNotifierProvider<SelectedWalletIndexNotifier, int>((ref) {
  return SelectedWalletIndexNotifier();
});

class SelectedWalletIndexNotifier extends StateNotifier<int> {
  SelectedWalletIndexNotifier() : super(0) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    // TODO: Load from SPUtil
  }

  void select(int index) {
    state = index;
    // TODO: Save to storage
  }
}

/// Current Wallet Provider (Derived)
final currentWalletProvider = Provider<WalletInfoData?>((ref) {
  final wallets = ref.watch(walletListProvider);
  final index = ref.watch(selectedWalletIndexProvider);

  return wallets.whenOrNull(
    data: (list) {
      if (index < 0 || index >= list.length) return null;
      return list[index];
    },
  );
});

/// Wallet Balance Provider (Async)
final walletBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final wallet = ref.watch(currentWalletProvider);
  if (wallet == null) return 0.0;

  // TODO: Fetch balance from API
  return 0.0;
});

/// Coin List Provider (Async)
final coinListProvider =
    AsyncNotifierProvider.autoDispose<CoinListNotifier, List<CoinBalanceData>>(() {
  return CoinListNotifier();
});

class CoinListNotifier extends AutoDisposeAsyncNotifier<List<CoinBalanceData>> {
  @override
  Future<List<CoinBalanceData>> build() async {
    final wallet = ref.watch(currentWalletProvider);
    if (wallet == null) return [];

    // TODO: Fetch coin list from API
    return [];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> refreshCoin(String symbol) async {
    // Refresh specific coin balance
  }
}

/// Mining Wallet Index Provider
final miningWalletIndexProvider =
    StateNotifierProvider<MiningWalletIndexNotifier, int>((ref) {
  return MiningWalletIndexNotifier();
});

class MiningWalletIndexNotifier extends StateNotifier<int> {
  MiningWalletIndexNotifier() : super(0);

  void select(int index) {
    state = index;
  }
}

/// Mining Wallet Provider (Derived)
final miningWalletProvider = Provider<WalletInfoData?>((ref) {
  final wallets = ref.watch(walletListProvider);
  final index = ref.watch(miningWalletIndexProvider);

  return wallets.whenOrNull(
    data: (list) {
      if (index < 0 || index >= list.length) return null;
      return list[index];
    },
  );
});

