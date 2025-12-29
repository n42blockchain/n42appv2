// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/core/utils/event_bus.dart';

/// Legacy Wallet Action Provider Adapter
///
/// This adapter bridges the old WalletActionProvider (ChangeNotifier) with
/// the new Riverpod wallet providers. It allows existing UI code to continue
/// working while gradually migrating to Riverpod.
///
/// Key Migration Strategy:
/// 1. New Riverpod providers are the source of truth for wallet data
/// 2. The adapter syncs state between old and new systems
/// 3. Operations go through Riverpod, then notify legacy listeners
/// 
/// Usage:
/// - In the app's MultiProvider, replace WalletActionProvider with this adapter
/// - Pass a ProviderContainer to the adapter
class LegacyWalletActionProviderAdapter extends WalletActionProvider {
  final ProviderContainer _container;
  
  // Subscriptions to Riverpod providers
  late final ProviderSubscription<AsyncValue<List<WalletInfoData>>> _walletListSubscription;
  late final ProviderSubscription<int> _selectedIndexSubscription;
  late final ProviderSubscription<int> _miningIndexSubscription;

  LegacyWalletActionProviderAdapter(this._container) {
    _initSubscriptions();
    _syncFromRiverpod();
  }

  void _initSubscriptions() {
    // Subscribe to wallet list changes
    _walletListSubscription = _container.listen<AsyncValue<List<WalletInfoData>>>(
      walletListProvider,
      (_, next) {
        next.whenData((wallets) {
          _syncWalletList(wallets);
        });
      },
    );

    // Subscribe to selected index changes
    _selectedIndexSubscription = _container.listen<int>(
      selectedWalletIndexProvider,
      (_, next) {
        if (walletIndex != next) {
          walletIndex = next;
          notifyListeners();
        }
      },
    );

    // Subscribe to mining index changes
    _miningIndexSubscription = _container.listen<int>(
      miningWalletIndexProvider,
      (_, next) {
        if (walletMiningIndex != next) {
          walletMiningIndex = next;
          notifyListeners();
        }
      },
    );
  }

  Future<void> _syncFromRiverpod() async {
    // Initial sync from Riverpod state
    final wallets = _container.read(walletListProvider);
    wallets.whenData((list) {
      _syncWalletList(list);
    });
    
    walletIndex = _container.read(selectedWalletIndexProvider);
    walletMiningIndex = _container.read(miningWalletIndexProvider);
    notifyListeners();
  }

  void _syncWalletList(List<WalletInfoData> riverpodWallets) {
    // Convert WalletInfoData to WalletInfo
    // Note: This is a shallow sync - full wallet data is in WalletActionProvider.walletInfoLsit
    // The riverpod data is used for indexing and basic info
    
    // Notify listeners if wallet count changed
    if (walletInfoLsit.length != riverpodWallets.length) {
      notifyListeners();
    }
  }

  // ============================================
  // Override Methods to Route Through Riverpod
  // ============================================

  @override
  Future<void> setWalletIndex(int index) async {
    await super.setWalletIndex(index);
    // Sync to Riverpod
    _container.read(selectedWalletIndexProvider.notifier).select(index);
  }

  @override
  Future<void> setWalletMiningIndex(int index) async {
    await super.setWalletMiningIndex(index);
    // Sync to Riverpod
    _container.read(miningWalletIndexProvider.notifier).select(index);
    // Fire event for other listeners
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet, intValue: index));
  }

  /// Refresh wallet list from Riverpod
  Future<void> refreshFromRiverpod() async {
    await _container.read(walletListProvider.notifier).refresh();
  }

  /// Sync current wallet data to Riverpod
  /// Call this after wallet modifications in legacy code
  Future<void> syncToRiverpod() async {
    // Force refresh Riverpod wallet list
    await _container.read(walletListProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _walletListSubscription.close();
    _selectedIndexSubscription.close();
    _miningIndexSubscription.close();
    super.dispose();
  }
}

/// Extension to make it easier to use the adapter
extension WalletActionProviderAdapterExtension on LegacyWalletActionProviderAdapter {
  /// Get Riverpod wallet list
  AsyncValue<List<WalletInfoData>> get riverpodWalletList => 
      _container.read(walletListProvider);

  /// Get current wallet from Riverpod
  WalletInfoData? get currentRiverpodWallet =>
      _container.read(currentWalletProvider);

  /// Get mining wallet from Riverpod
  WalletInfoData? get miningRiverpodWallet =>
      _container.read(miningWalletProvider);
}

