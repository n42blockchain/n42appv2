// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/core/providers/core_providers.dart';

/// Legacy Adapter for WalletActionProvider
///
/// This adapter allows old code using Provider to access
/// the new Riverpod state. Use this during migration phase.
class WalletProviderAdapter extends ChangeNotifier {
  final ProviderContainer _container;
  final List<ProviderSubscription> _subscriptions = [];

  WalletProviderAdapter(this._container) {
    // Subscribe to wallet changes
    _subscriptions.add(
      _container.listen(
        walletListProvider,
        (_, _) => notifyListeners(),
      ),
    );

    _subscriptions.add(
      _container.listen(
        selectedWalletIndexProvider,
        (_, _) => notifyListeners(),
      ),
    );

    _subscriptions.add(
      _container.listen(
        coinListProvider,
        (_, _) => notifyListeners(),
      ),
    );
  }

  /// Get wallet list
  List<WalletInfoData> get walletInfoList {
    return _container.read(walletListProvider).valueOrNull ?? [];
  }

  /// Get current wallet index
  int get walletIndex => _container.read(selectedWalletIndexProvider);

  /// Get current wallet
  WalletInfoData? get walletInfo {
    return _container.read(currentWalletProvider);
  }

  /// Get wallet name
  String get walletName => walletInfo?.name ?? '';

  /// Get coin list
  List<CoinBalanceData> get coinList {
    return _container.read(coinListProvider).valueOrNull ?? [];
  }

  /// Get total balance
  double get balanceTotal {
    return _container.read(walletBalanceProvider).valueOrNull ?? 0.0;
  }

  /// Set wallet index
  Future<void> setWalletIndex(int index) async {
    _container.read(selectedWalletIndexProvider.notifier).select(index);
  }

  /// Refresh wallet data
  Future<void> refresh() async {
    await _container.read(walletListProvider.notifier).refresh();
  }

  /// Check if loading
  bool get isLoading {
    return _container.read(walletListProvider).isLoading;
  }

  /// Check if has error
  bool get hasError {
    return _container.read(walletListProvider).hasError;
  }

  /// Get error
  Object? get error {
    return _container.read(walletListProvider).error;
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.close();
    }
    super.dispose();
  }
}

/// Legacy Adapter for PublicProvider
class PublicProviderAdapter extends ChangeNotifier {
  final ProviderContainer _container;
  final List<ProviderSubscription> _subscriptions = [];

  PublicProviderAdapter(this._container) {
    _subscriptions.add(
      _container.listen(
        themeModeProvider,
        (_, _) => notifyListeners(),
      ),
    );

    _subscriptions.add(
      _container.listen(
        localeProvider,
        (_, _) => notifyListeners(),
      ),
    );

    _subscriptions.add(
      _container.listen(
        currentUserProvider,
        (_, _) => notifyListeners(),
      ),
    );
  }

  /// Get theme mode
  dynamic get themeMode => _container.read(themeModeProvider);

  /// Set theme mode
  void switchTheme(int type) {
    final notifier = _container.read(themeModeProvider.notifier);
    switch (type) {
      case 0:
        notifier.setTheme(ThemeMode.system);
        break;
      case 1:
        notifier.setTheme(ThemeMode.light);
        break;
      case 2:
        notifier.setTheme(ThemeMode.dark);
        break;
    }
  }

  /// Get locale
  dynamic get locale => _container.read(localeProvider);

  /// Set locale
  void switchLocale(String code) {
    _container.read(localeProvider.notifier).setLocale(code);
  }

  /// Get home tab index
  int get homeCurrentIndex => _container.read(homeTabIndexProvider);

  /// Set home tab index
  void setHomeCurrentIndex(int value) {
    _container.read(homeTabIndexProvider.notifier).state = value;
  }

  /// Get unread count
  int get messageNotReadCount => _container.read(unreadCountProvider);

  /// Set unread count
  void setMessageNotReadCount({int? value}) {
    final notifier = _container.read(unreadCountProvider.notifier);
    if (value == null) {
      notifier.state++;
    } else {
      notifier.state = value;
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.close();
    }
    super.dispose();
  }
}

