// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
export 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';

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
              int.tryParse(json['timestamp'].toString()) ?? 0,
            )
          : DateTime.now(),
      timestamp: json['timestamp'] as String?,
      coinInfo: coinInfo,
      coinSort:
          (json['coinSort'] as Map<String, dynamic>?) ??
          {"assets": 0, "name": -1},
      networkIndex: json['networkIndex'] as int? ?? -1,
      faceBinding: json['faceBinding'] as bool?,
    );
  }

  static String _extractAddress(dynamic coinData) {
    if (coinData is Map) {
      // Try to get address from baseInfo or direct
      if (coinData['baseInfo'] != null &&
          coinData['baseInfo']['address'] != null) {
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
    return walletInfos
        .whereType<Map<String, dynamic>>()
        .map(WalletInfoData.fromLegacyJson)
        .toList();
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

/// Base class for wallet-index state notifiers with storage persistence.
///
/// Subclasses specify [storageKey] to read/write the correct field.
abstract class _WalletIndexNotifier extends StateNotifier<int> {
  final Ref _ref;

  /// JSON key inside the user's wallet map (e.g. 'index', 'miningIndex').
  String get storageKey;

  /// Fallback key when [storageKey] is missing (null = no fallback).
  String? get fallbackKey => null;

  _WalletIndexNotifier(this._ref) : super(0) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final walletUser = await _getUserWalletMap();
    if (walletUser != null) {
      state =
          walletUser[storageKey] ??
          (fallbackKey != null ? walletUser[fallbackKey] : null) ??
          0;
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
        walletAll[userUUID][storageKey] = state;
        await spUtil.setWalletInfo(walletAll);
      }
    }
  }

  Future<Map<String, dynamic>?> _getUserWalletMap() async {
    final spUtil = _ref.read(spUtilProvider);
    final walletAll = await spUtil.getWalletInfo();
    if (walletAll == null) return null;
    final userUUID = AppGlobals.userInfo?.uuid ?? 'AstranetWallet';
    return walletAll[userUUID] ?? walletAll['AstranetWallet'];
  }
}

/// Selected Wallet Index Provider
final selectedWalletIndexProvider =
    StateNotifierProvider<SelectedWalletIndexNotifier, int>((ref) {
      return SelectedWalletIndexNotifier(ref);
    });

class SelectedWalletIndexNotifier extends _WalletIndexNotifier {
  SelectedWalletIndexNotifier(super.ref);

  @override
  String get storageKey => 'index';
}

/// Derive a wallet by index from the wallet list.
WalletInfoData? _walletAtIndex(
  AsyncValue<List<WalletInfoData>> wallets,
  int index,
) {
  return wallets.whenOrNull(
    data: (list) => (index >= 0 && index < list.length) ? list[index] : null,
  );
}

/// Current Wallet Provider (Derived)
final currentWalletProvider = Provider<WalletInfoData?>((ref) {
  return _walletAtIndex(
    ref.watch(walletListProvider),
    ref.watch(selectedWalletIndexProvider),
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
  try {
    return globalWapAdapter.balanceTotal;
  } catch (_) {
    return 0.0;
  }
});

/// Coin List Provider (Async)
final coinListProvider =
    AsyncNotifierProvider.autoDispose<CoinListNotifier, List<CoinBalanceData>>(
      () {
        return CoinListNotifier();
      },
    );

class CoinListNotifier extends AsyncNotifier<List<CoinBalanceData>> {
  @override
  Future<List<CoinBalanceData>> build() async {
    final wallet = ref.watch(currentWalletProvider);
    if (wallet == null) return [];

    // Build coin list from wallet's coinInfo
    final coinInfo = wallet.coinInfo;
    if (coinInfo == null) return [];

    // Build O(1) lookup map from legacy coin models (O-1 optimisation + A-4 guard)
    Map<String, dynamic> modelMap = {};
    try {
      modelMap = {
        for (final c in globalWapAdapter.coinModels)
          (c.coin['coinType'] as String? ?? ''): c,
      };
    } catch (_) {}

    return coinInfo.entries
        .where((e) {
          final data = e.value as Map<String, dynamic>?;
          return data != null && data['baseInfo'] != null;
        })
        .map((e) {
          final coinKey = e.key;
          final baseInfo =
              (e.value as Map<String, dynamic>)['baseInfo']
                  as Map<String, dynamic>;
          final legacyCoin = modelMap[coinKey];
          return CoinBalanceData(
            symbol: coinKey,
            name: baseInfo['name']?.toString() ?? coinKey,
            iconUrl: baseInfo['icon']?.toString() ?? '',
            balance: legacyCoin?.balanceDoubleAll() ?? 0.0,
            balanceUsd: legacyCoin?.value ?? 0.0,
            price: legacyCoin?.coinPrice ?? 0.0,
            priceChange24h: legacyCoin?.percentage ?? 0.0,
            chainType: coinKey,
          );
        })
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> refreshCoin(String symbol) async => refresh();
}

/// Mining Wallet Index Provider
final miningWalletIndexProvider =
    StateNotifierProvider<MiningWalletIndexNotifier, int>((ref) {
      return MiningWalletIndexNotifier(ref);
    });

class MiningWalletIndexNotifier extends _WalletIndexNotifier {
  MiningWalletIndexNotifier(super.ref);

  @override
  String get storageKey => 'miningIndex';

  @override
  String? get fallbackKey => 'index';
}

/// Mining Wallet Provider (Derived)
final miningWalletProvider = Provider<WalletInfoData?>((ref) {
  return _walletAtIndex(
    ref.watch(walletListProvider),
    ref.watch(miningWalletIndexProvider),
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
