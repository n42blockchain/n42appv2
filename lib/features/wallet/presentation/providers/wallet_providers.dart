// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';

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
  final String? timestamp;
  final Map<String, dynamic>? coinInfo;
  final Map<String, dynamic> coinSort;
  final int networkIndex;
  final bool? faceBinding;

  const WalletInfoData({
    required this.address,
    required this.name,
    required this.chainType,
    this.mnemonic,
    this.privateKey,
    this.avatarUrl,
    this.isMainWallet = false,
    required this.createdAt,
    this.timestamp,
    this.coinInfo,
    this.coinSort = const {"assets": 0, "name": -1},
    this.networkIndex = -1,
    this.faceBinding,
  });

  /// Create from legacy WalletInfo JSON
  factory WalletInfoData.fromLegacyJson(Map<String, dynamic> json) {
    // Extract first address from coinInfo for display
    String address = '';
    final coinInfo = json['coinInfo'] as Map<String, dynamic>?;
    if (coinInfo != null && coinInfo.isNotEmpty) {
      // Try to get ETH address as primary
      if (coinInfo['ETH'] != null) {
        address = _extractAddress(coinInfo['ETH']);
      } else {
        // Use first available
        final firstKey = coinInfo.keys.first;
        address = _extractAddress(coinInfo[firstKey]);
      }
    }

    return WalletInfoData(
      address: address,
      name: json['walletName'] as String? ?? 'Wallet',
      chainType: 'multi', // Multi-chain wallet
      mnemonic: json['mnemonic'] as String?,
      privateKey: json['privateKey'] as String?,
      isMainWallet: json['mainWallet'] as bool? ?? false,
      createdAt: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(json['timestamp'].toString()) ?? 0)
          : DateTime.now(),
      timestamp: json['timestamp'] as String?,
      coinInfo: coinInfo,
      coinSort: (json['coinSort'] as Map<String, dynamic>?) ?? {"assets": 0, "name": -1},
      networkIndex: json['networkIndex'] as int? ?? -1,
      faceBinding: json['faceBinding'] as bool?,
    );
  }

  static String _extractAddress(dynamic coinData) {
    if (coinData is Map) {
      // Try to get address from baseInfo or direct
      if (coinData['baseInfo'] != null && coinData['baseInfo']['address'] != null) {
        return coinData['baseInfo']['address'].toString();
      }
    }
    return '';
  }

  /// Convert to legacy format for storage
  Map<String, dynamic> toLegacyJson() {
    return {
      'walletName': name,
      'mnemonic': mnemonic,
      'privateKey': privateKey,
      'timestamp': timestamp,
      'coinInfo': coinInfo,
      'coinSort': coinSort,
      'networkIndex': networkIndex,
      'faceBinding': faceBinding,
      'mainWallet': isMainWallet,
    };
  }

  WalletInfoData copyWith({
    String? address,
    String? name,
    String? chainType,
    String? mnemonic,
    String? privateKey,
    String? avatarUrl,
    bool? isMainWallet,
    DateTime? createdAt,
    String? timestamp,
    Map<String, dynamic>? coinInfo,
    Map<String, dynamic>? coinSort,
    int? networkIndex,
    bool? faceBinding,
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
      timestamp: timestamp ?? this.timestamp,
      coinInfo: coinInfo ?? this.coinInfo,
      coinSort: coinSort ?? this.coinSort,
      networkIndex: networkIndex ?? this.networkIndex,
      faceBinding: faceBinding ?? this.faceBinding,
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

/// SPUtil Provider
final spUtilProvider = Provider<SPUtil>((ref) => SPUtil());

/// Wallet List Provider (Async)
final walletListProvider =
    AsyncNotifierProvider<WalletListNotifier, List<WalletInfoData>>(() {
  return WalletListNotifier();
});

class WalletListNotifier extends AsyncNotifier<List<WalletInfoData>> {
  @override
  Future<List<WalletInfoData>> build() async {
    return await _loadWallets();
  }

  /// Load wallets from SPUtil storage
  Future<List<WalletInfoData>> _loadWallets() async {
    final spUtil = ref.read(spUtilProvider);
    final walletAll = await spUtil.getWalletInfo();

    if (walletAll == null) {
      return [];
    }

    // Get user UUID for wallet lookup
    final userUUID = AppGlobals.userInfo?.uuid ?? 'AstranetWallet';
    
    // Get user's wallet data
    Map<String, dynamic>? walletUser = walletAll[userUUID];
    
    // Fallback to default wallet if user wallet not found
    walletUser ??= walletAll['AstranetWallet'];

    if (walletUser == null) {
      return [];
    }

    // Parse wallet list
    final List<dynamic> walletInfos = walletUser['wallet'] ?? [];
    final List<WalletInfoData> wallets = [];

    for (final walletJson in walletInfos) {
      if (walletJson is Map<String, dynamic>) {
        wallets.add(WalletInfoData.fromLegacyJson(walletJson));
      }
    }

    return wallets;
  }

  /// Refresh wallet list from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadWallets());
  }

  /// Add a new wallet
  Future<void> addWallet(WalletInfoData wallet) async {
    final current = state.value ?? [];
    final updated = [...current, wallet];
    state = AsyncValue.data(updated);
    await _saveWallets(updated);
  }

  /// Remove a wallet by address
  Future<void> removeWallet(String address) async {
    final current = state.value ?? [];
    final updated = current.where((w) => w.address != address).toList();
    state = AsyncValue.data(updated);
    await _saveWallets(updated);
  }

  /// Update a wallet
  Future<void> updateWallet(WalletInfoData wallet) async {
    final current = state.value ?? [];
    final index = current.indexWhere((w) => w.timestamp == wallet.timestamp);
    if (index != -1) {
      final updated = [...current];
      updated[index] = wallet;
      state = AsyncValue.data(updated);
      await _saveWallets(updated);
    }
  }

  /// Save wallets to storage
  Future<void> _saveWallets(List<WalletInfoData> wallets) async {
    final spUtil = ref.read(spUtilProvider);
    final userUUID = AppGlobals.userInfo?.uuid ?? 'AstranetWallet';
    
    // Get current storage
    final walletAll = await spUtil.getWalletInfo() ?? {};
    
    // Get current index
    final currentIndex = ref.read(selectedWalletIndexProvider);
    final miningIndex = ref.read(miningWalletIndexProvider);
    
    // Update wallet data
    walletAll[userUUID] = {
      'index': currentIndex,
      'miningIndex': miningIndex,
      'wallet': wallets.map((w) => w.toLegacyJson()).toList(),
    };

    await spUtil.setWalletInfo(walletAll);
  }
}

/// Selected Wallet Index Provider
final selectedWalletIndexProvider =
    StateNotifierProvider<SelectedWalletIndexNotifier, int>((ref) {
  return SelectedWalletIndexNotifier(ref);
});

class SelectedWalletIndexNotifier extends StateNotifier<int> {
  final Ref _ref;
  
  SelectedWalletIndexNotifier(this._ref) : super(0) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final spUtil = _ref.read(spUtilProvider);
    final walletAll = await spUtil.getWalletInfo();
    
    if (walletAll != null) {
      final userUUID = AppGlobals.userInfo?.uuid ?? 'AstranetWallet';
      final walletUser = walletAll[userUUID] ?? walletAll['AstranetWallet'];
      if (walletUser != null) {
        state = walletUser['index'] ?? 0;
      }
    }
  }

  void select(int index) {
    state = index;
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final spUtil = _ref.read(spUtilProvider);
    final walletAll = await spUtil.getWalletInfo();
    
    if (walletAll != null) {
      final userUUID = AppGlobals.userInfo?.uuid ?? 'AstranetWallet';
      if (walletAll[userUUID] != null) {
        walletAll[userUUID]['index'] = state;
        await spUtil.setWalletInfo(walletAll);
      }
    }
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
///
/// Bridges the legacy WalletActionProvider balance total into Riverpod.
/// The actual per-coin balance fetching is still managed by the legacy provider;
/// this provider exposes the aggregated USD total for Riverpod consumers.
final walletBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final wallet = ref.watch(currentWalletProvider);
  if (wallet == null) return 0.0;

  // Read aggregated balance from the legacy WalletActionProvider
  return globalWapAdapter.balanceTotal;
});

/// Coin List Provider (Async)
final coinListProvider =
    AsyncNotifierProvider.autoDispose<CoinListNotifier, List<CoinBalanceData>>(() {
  return CoinListNotifier();
});

class CoinListNotifier extends AsyncNotifier<List<CoinBalanceData>> {
  @override
  Future<List<CoinBalanceData>> build() async {
    final wallet = ref.watch(currentWalletProvider);
    if (wallet == null) return [];

    // Build coin list from wallet's coinInfo
    final List<CoinBalanceData> coins = [];
    final coinInfo = wallet.coinInfo;
    
    if (coinInfo != null) {
      for (final entry in coinInfo.entries) {
        final coinKey = entry.key;
        final coinData = entry.value as Map<String, dynamic>?;
        
        if (coinData != null && coinData['baseInfo'] != null) {
          final baseInfo = coinData['baseInfo'] as Map<String, dynamic>;
          // Read balance from the legacy WalletActionProvider coin list
          double balance = 0.0;
          double balanceUsd = 0.0;
          double price = 0.0;
          double priceChange = 0.0;
          try {
            final legacyCoin = globalWapAdapter.coinModels
                .where((c) => c.coin['coinType'] == coinKey)
                .firstOrNull;
            if (legacyCoin != null) {
              balance = legacyCoin.balanceDoubleAll();
              price = legacyCoin.coinPrice;
              priceChange = legacyCoin.percentage;
              balanceUsd = legacyCoin.value;
            }
          } catch (_) {}
          coins.add(CoinBalanceData(
            symbol: coinKey,
            name: baseInfo['name']?.toString() ?? coinKey,
            iconUrl: baseInfo['icon']?.toString() ?? '',
            balance: balance,
            balanceUsd: balanceUsd,
            price: price,
            priceChange24h: priceChange,
            chainType: coinKey,
          ));
        }
      }
    }

    return coins;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> refreshCoin(String symbol) async {
    // Refresh specific coin balance
    // TODO: Implement
  }
}

/// Mining Wallet Index Provider
final miningWalletIndexProvider =
    StateNotifierProvider<MiningWalletIndexNotifier, int>((ref) {
  return MiningWalletIndexNotifier(ref);
});

class MiningWalletIndexNotifier extends StateNotifier<int> {
  final Ref _ref;
  
  MiningWalletIndexNotifier(this._ref) : super(0) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final spUtil = _ref.read(spUtilProvider);
    final walletAll = await spUtil.getWalletInfo();
    
    if (walletAll != null) {
      final userUUID = AppGlobals.userInfo?.uuid ?? 'AstranetWallet';
      final walletUser = walletAll[userUUID] ?? walletAll['AstranetWallet'];
      if (walletUser != null) {
        state = walletUser['miningIndex'] ?? walletUser['index'] ?? 0;
      }
    }
  }

  void select(int index) {
    state = index;
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final spUtil = _ref.read(spUtilProvider);
    final walletAll = await spUtil.getWalletInfo();
    
    if (walletAll != null) {
      final userUUID = AppGlobals.userInfo?.uuid ?? 'AstranetWallet';
      if (walletAll[userUUID] != null) {
        walletAll[userUUID]['miningIndex'] = state;
        await spUtil.setWalletInfo(walletAll);
      }
    }
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

/// Wallet Count Provider
final walletCountProvider = Provider<int>((ref) {
  final wallets = ref.watch(walletListProvider);
  return wallets.value?.length ?? 0;
});

/// Has Wallet Provider
final hasWalletProvider = Provider<bool>((ref) {
  final count = ref.watch(walletCountProvider);
  return count > 0;
});

// ============================================
// WAP Bridge Provider (Provider → Riverpod bridge)
// ============================================

/// Bridge provider that wraps the legacy WalletActionProvider as a Riverpod
/// ChangeNotifierProvider. This allows gradual migration of consumers from
/// `Provider.of<WalletActionProvider>(context)` to `ref.read(wapBridgeProvider)`.
///
/// The WAP instance is created in main() and stored in `globalWapAdapter`.
/// Both MultiProvider and this Riverpod provider reference the same instance.
///
/// Usage in widgets:
/// - `ref.read(wapBridgeProvider)` replaces `Provider.of<WAP>(context, listen: false)`
/// - `ref.watch(wapBridgeProvider)` replaces `Consumer<WAP>`
final wapBridgeProvider = ChangeNotifierProvider<WalletActionProvider>((ref) {
  return globalWapAdapter;
});
