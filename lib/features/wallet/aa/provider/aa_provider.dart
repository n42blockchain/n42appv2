// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/models/user_operation_receipt.dart';
import 'package:n42_wallet/features/wallet/aa/account/smart_account_factory.dart';
import 'package:n42_wallet/features/wallet/aa/bundler/bundler_client.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

/// Provider for Account Abstraction (ERC-4337) state management
///
/// Manages smart accounts, deployment status, and AA preferences.
/// Works in conjunction with WalletActionProvider.
class AAProvider extends ChangeNotifier {
  final WalletActionProvider _walletProvider;

  /// Bundler API key (optional)
  String? _bundlerApiKey;

  /// Cached bundler clients per chain
  final Map<String, BundlerClient> _bundlerClients = {};

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error state
  String? _error;
  String? get error => _error;

  /// Pending transactions (userOpHash -> chain)
  final Map<String, String> _pendingTransactions = {};

  AAProvider(this._walletProvider);

  /// Set bundler API key
  void setBundlerApiKey(String? apiKey) {
    _bundlerApiKey = apiKey;
    // Clear cached clients to use new key
    for (final client in _bundlerClients.values) {
      client.dispose();
    }
    _bundlerClients.clear();
  }

  /// Get current wallet info
  WalletInfo get _walletInfo => _walletProvider.walletInfo;

  /// Get AA account info
  AAAccountInfo? get aaAccountInfo => _walletInfo.aaAccountInfo;

  /// Check if AA is preferred
  bool get prefersAA => _walletInfo.prefersAA;

  /// Set AA preference
  Future<void> setPreferAA(bool prefer) async {
    _walletInfo.prefersAA = prefer;
    await _saveWalletInfo();
    notifyListeners();
  }

  /// Get smart accounts for a chain
  List<SmartAccount> getAccountsForChain(int chainId) {
    return _walletInfo.getSmartAccountsForChain(chainId);
  }

  /// Get primary smart account for a chain
  SmartAccount? getPrimaryAccount(int chainId) {
    return _walletInfo.getPrimarySmartAccount(chainId);
  }

  /// Get smart account by address
  SmartAccount? getAccountByAddress(String address) {
    return _walletInfo.findSmartAccount(address);
  }

  /// Check if chain supports AA
  bool isChainSupported(String chainSymbol) {
    return AAConfig.isChainSupported(chainSymbol);
  }

  /// Create a new smart account for a chain
  ///
  /// This calculates the counterfactual address but does NOT deploy.
  /// The account will be deployed on first use.
  Future<SmartAccount> createSmartAccount({
    required int chainId,
    String? label,
    BigInt? salt,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Get owner address (EOA)
      final ownerAddress = _getOwnerAddress(chainId);
      if (ownerAddress == null) {
        throw SmartAccountError(
          'No EOA address available for chain $chainId',
          type: SmartAccountErrorType.invalidOwner,
        );
      }

      // Create factory
      final factory = SmartAccountFactory(
        ownerAddress: ownerAddress,
        chainId: chainId,
      );

      // Calculate salt (use existing accounts count if not provided)
      final accountSalt =
          salt ??
          BigInt.from(_walletInfo.getSmartAccountsForChain(chainId).length);

      // Create account model
      final account = factory.createAccount(
        type: SmartAccountType.simpleAccount,
        salt: accountSalt,
        label: label,
      );

      // Check if already deployed
      final state = await _resolveDeploymentState(account.address, chainId);
      final updatedAccount = account.copyWith(state: state);

      // Save to wallet info
      _walletInfo.addSmartAccount(updatedAccount);
      await _saveWalletInfo();

      AppLogger.d(
        'AAProvider',
        'created smart account ${account.shortAddress} for chain $chainId',
      );
      notifyListeners();

      return updatedAccount;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh deployment status for all accounts
  Future<void> refreshDeploymentStatus() async {
    if (aaAccountInfo == null) return;

    _setLoading(true);
    _clearError();

    try {
      for (final entry in aaAccountInfo!.smartAccounts.entries) {
        final chainId = entry.key;
        for (final account in entry.value) {
          final newState = await _resolveDeploymentState(
            account.address,
            chainId,
          );
          if (account.state != newState) {
            _walletInfo.updateSmartAccountState(
              account.address,
              chainId,
              newState,
            );
          }
        }
      }

      await _saveWalletInfo();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Check deployment status for a specific account
  Future<bool> checkAccountDeployment(SmartAccount account) async {
    try {
      final newState = await _resolveDeploymentState(
        account.address,
        account.chainId,
      );
      final isDeployed = newState == SmartAccountState.deployed;

      if (isDeployed != account.isDeployed) {
        _walletInfo.updateSmartAccountState(
          account.address,
          account.chainId,
          newState,
        );
        await _saveWalletInfo();
        notifyListeners();
      }

      return isDeployed;
    } catch (e) {
      AppLogger.w('AAProvider', 'error checking deployment: $e');
      return false;
    }
  }

  /// Remove a smart account
  Future<bool> removeSmartAccount(String address, int chainId) async {
    final removed = _walletInfo.removeSmartAccount(address, chainId);
    if (removed) {
      await _saveWalletInfo();
      notifyListeners();
    }
    return removed;
  }

  /// Update account label
  Future<void> updateAccountLabel(
    String address,
    int chainId,
    String label,
  ) async {
    final accounts = aaAccountInfo?.smartAccounts[chainId];
    if (accounts == null) return;

    final index = accounts.indexWhere(
      (a) => a.address.toLowerCase() == address.toLowerCase(),
    );

    if (index >= 0) {
      accounts[index] = accounts[index].copyWith(label: label);
      await _saveWalletInfo();
      notifyListeners();
    }
  }

  /// Get bundler client for a chain
  BundlerClient getBundlerClient(String chainSymbol) {
    return _bundlerClients.putIfAbsent(
      chainSymbol,
      () => BundlerClient.forChain(chainSymbol, apiKey: _bundlerApiKey),
    );
  }

  /// Track a pending transaction
  void trackPendingTransaction(String userOpHash, String chainSymbol) {
    _pendingTransactions[userOpHash] = chainSymbol;
    notifyListeners();
  }

  /// Remove a completed/failed transaction from pending
  void completePendingTransaction(String userOpHash) {
    _pendingTransactions.remove(userOpHash);
    notifyListeners();
  }

  /// Get pending transactions
  Map<String, String> get pendingTransactions =>
      Map.unmodifiable(_pendingTransactions);

  /// Wait for a transaction receipt
  Future<UserOperationReceipt> waitForReceipt(
    String userOpHash,
    String chainSymbol, {
    Duration? timeout,
  }) async {
    trackPendingTransaction(userOpHash, chainSymbol);

    try {
      final client = getBundlerClient(chainSymbol);
      return await client.waitForReceipt(userOpHash, timeout: timeout);
    } finally {
      completePendingTransaction(userOpHash);
    }
  }

  /// Get all smart accounts across all chains
  List<SmartAccount> get allSmartAccounts {
    if (aaAccountInfo == null) return [];
    return aaAccountInfo!.smartAccounts.values.expand((a) => a).toList();
  }

  /// Get total count of smart accounts
  int get totalAccountCount => aaAccountInfo?.totalAccounts ?? 0;

  // ==================== Private Methods ====================

  String? _getOwnerAddress(int chainId) {
    final chainSymbol = _chainIdToSymbol(chainId);
    if (_walletProvider.walletMap[chainSymbol] == null) return null;

    final address = _walletProvider.getAddress(chainSymbol);
    if (address == null) return null;

    return address['legacy'] ?? address.toString();
  }

  /// Maps deployment check to a [SmartAccountState].
  Future<SmartAccountState> _resolveDeploymentState(
    String address,
    int chainId,
  ) async {
    final isDeployed = await _checkDeploymentStatus(address, chainId);
    return isDeployed
        ? SmartAccountState.deployed
        : SmartAccountState.notDeployed;
  }

  Future<bool> _checkDeploymentStatus(String address, int chainId) async {
    try {
      final chainSymbol = _chainIdToSymbol(chainId);
      final chainMap = _walletProvider.walletMap[chainSymbol];
      final rpcUrl = chainMap?['baseInfo']?['service'] as String? ?? '';

      if (rpcUrl.isEmpty) return false;

      final ethApi = EthAPI.init(chainSymbol, rpcUrl, '');
      final result = await ethApi.getCode(address);

      if (!result.error && result.data != null) {
        return SmartAccountFactory.isDeployed(result.data.toString());
      }
      return false;
    } catch (e) {
      AppLogger.w('AAProvider', 'error checking deployment status: $e');
      return false;
    }
  }

  String _chainIdToSymbol(int chainId) {
    final entry = AAConfig.chainIds.entries.firstWhere(
      (e) => e.value == chainId,
      orElse: () => const MapEntry('ETH', 1),
    );
    return entry.key;
  }

  Future<void> _saveWalletInfo() async {
    await _walletProvider.saveWalletInfo(
      _walletInfo,
      _walletProvider.walletIndex,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    for (final client in _bundlerClients.values) {
      client.dispose();
    }
    _bundlerClients.clear();
    super.dispose();
  }
}

/// Extension to WalletActionProvider for AA operations
extension AAWalletExtension on WalletActionProvider {
  /// Get smart account for a chain
  SmartAccount? getSmartAccount(int chainId) {
    return walletInfo.getPrimarySmartAccount(chainId);
  }

  /// Check if wallet has smart accounts
  bool get hasSmartAccounts => walletInfo.hasAAAccounts;

  /// Check if AA is preferred
  bool get prefersAA => walletInfo.prefersAA;
}
