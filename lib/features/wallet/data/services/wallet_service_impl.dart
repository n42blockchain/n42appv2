// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/shared/domain/entities/balance_info.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/shared/events/event_manager.dart';
import 'package:n42appv2/shared/events/cross_feature_events.dart';

/// Wallet Service Implementation
///
/// Implements IWalletService to provide wallet data to other features.
/// This allows Mining and other features to access wallet info without
/// directly depending on Wallet feature internals.
class WalletServiceImpl implements IWalletService {
  final StreamController<SharedWalletInfo?> _walletStreamController =
      StreamController<SharedWalletInfo?>.broadcast();

  List<SharedWalletInfo> _wallets = [];
  SharedWalletInfo? _currentWallet;

  WalletServiceImpl() {
    // Listen for wallet events from the legacy provider
    // This bridges the old system to the new interface
  }

  @override
  SharedWalletInfo? get currentWallet => _currentWallet;

  @override
  List<SharedWalletInfo> get wallets => List.unmodifiable(_wallets);

  @override
  SharedWalletInfo? getWalletByAddress(String address) {
    try {
      return _wallets.firstWhere((w) => w.address == address);
    } catch (_) {
      return null;
    }
  }

  @override
  SharedWalletInfo? getWalletByIndex(int index) {
    if (index < 0 || index >= _wallets.length) return null;
    return _wallets[index];
  }

  @override
  Future<SharedBalanceInfo?> getBalance(
    String address,
    String coinSymbol,
  ) async {
    // TODO: Implement by calling the actual wallet provider/API
    // This is a placeholder that should be connected to the real implementation
    return null;
  }

  @override
  Future<List<SharedBalanceInfo>> getAllBalances(String address) async {
    // TODO: Implement by calling the actual wallet provider/API
    return [];
  }

  @override
  bool hasWallet(String address) {
    return _wallets.any((w) => w.address == address);
  }

  @override
  int get walletCount => _wallets.length;

  @override
  Stream<SharedWalletInfo?> get currentWalletStream =>
      _walletStreamController.stream;

  // ============ Internal Update Methods ============

  /// Update wallet list from legacy provider
  void updateWallets(List<SharedWalletInfo> wallets) {
    _wallets = wallets;
  }

  /// Update current wallet selection
  void updateCurrentWallet(SharedWalletInfo? wallet) {
    _currentWallet = wallet;
    _walletStreamController.add(wallet);

    // Emit cross-feature event
    if (wallet != null) {
      eventManager.emitWalletSelected(wallet);
    }
  }

  /// Notify balance update
  void notifyBalanceUpdate({
    required String walletAddress,
    required String coinSymbol,
    required String newBalance,
  }) {
    eventManager.emitWalletBalanceUpdated(
      walletAddress: walletAddress,
      coinSymbol: coinSymbol,
      newBalance: newBalance,
    );
  }

  /// Notify transaction completion
  void notifyTransactionCompleted({
    required String walletAddress,
    required String txHash,
    required String amount,
    required String coinSymbol,
    required bool isSuccess,
  }) {
    eventManager.emitTransactionCompleted(
      walletAddress: walletAddress,
      txHash: txHash,
      amount: amount,
      coinSymbol: coinSymbol,
      isSuccess: isSuccess,
    );
  }

  /// Dispose resources
  void dispose() {
    _walletStreamController.close();
  }
}

