// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show chainUrlMap, getPathWithIndex;

/// Implementation of IWalletService using Riverpod
///
/// This implementation bridges the Riverpod state with the
/// interface-based service layer for cross-feature communication.
@LazySingleton(as: IWalletService)
class WalletServiceImpl implements IWalletService {
  final ProviderContainer _container;
  final StreamController<SharedWalletInfo?> _walletStreamController =
      StreamController<SharedWalletInfo?>.broadcast();
  ProviderSubscription? _walletListSubscription;
  ProviderSubscription? _walletIndexSubscription;

  WalletServiceImpl(this._container) {
    // Listen to wallet changes and broadcast
    _walletListSubscription = _container
        .listen<AsyncValue<List<WalletInfoData>>>(walletListProvider, (
          _,
          next,
        ) {
          final wallet = getCurrentWallet();
          _walletStreamController.add(wallet);
        });

    _walletIndexSubscription = _container.listen<int>(
      selectedWalletIndexProvider,
      (_, _) {
        final wallet = getCurrentWallet();
        _walletStreamController.add(wallet);
      },
    );
  }

  /// Get all wallets data
  List<WalletInfoData> _getAllWalletsData() {
    final wallets = _container.read(walletListProvider);
    return wallets.whenOrNull(data: (list) => list) ?? [];
  }

  @override
  SharedWalletInfo? getCurrentWallet() {
    final wallets = _container.read(walletListProvider);
    final index = _container.read(selectedWalletIndexProvider);

    return wallets.whenOrNull(
      data: (list) {
        if (index < 0 || index >= list.length) return null;
        final wallet = list[index];
        return SharedWalletInfo(
          address: wallet.address,
          name: wallet.name,
          chainType: wallet.chainType,
          avatarUrl: wallet.avatarUrl,
        );
      },
    );
  }

  @override
  SharedWalletInfo? getMainWallet() {
    final wallets = _getAllWalletsData();
    final mainWallet = wallets.where((w) => w.isMainWallet).firstOrNull;
    if (mainWallet == null) {
      return wallets.isNotEmpty ? _toSharedInfo(wallets.first) : null;
    }
    return _toSharedInfo(mainWallet);
  }

  @override
  SharedWalletInfo? getWalletByAddress(String address) {
    final wallets = _container.read(walletListProvider);

    return wallets.whenOrNull(
      data: (list) {
        final wallet = list.where((w) => w.address == address).firstOrNull;
        if (wallet == null) return null;
        return _toSharedInfo(wallet);
      },
    );
  }

  @override
  List<SharedWalletInfo> getAllWallets() {
    final wallets = _getAllWalletsData();
    return wallets.map((w) => _toSharedInfo(w)).toList();
  }

  @override
  int get walletCount => _getAllWalletsData().length;

  @override
  SharedWalletInfo? getMiningWallet() {
    final wallets = _getAllWalletsData();
    final miningIndex = _container.read(miningWalletIndexProvider);
    if (miningIndex < 0 || miningIndex >= wallets.length) return null;
    return _toSharedInfo(wallets[miningIndex]);
  }

  @override
  int get miningWalletIndex => _container.read(miningWalletIndexProvider);

  @override
  bool walletExists(String address) {
    return getWalletByAddress(address) != null;
  }

  @override
  Stream<SharedWalletInfo?> get currentWalletStream =>
      _walletStreamController.stream;

  @override
  Future<String?> getChainAddress(String walletId, String chainType) async {
    // Find wallet by ID (using timestamp or address as ID)
    final wallets = _getAllWalletsData();
    final wallet = wallets
        .where((w) => w.timestamp == walletId || w.address == walletId)
        .firstOrNull;
    if (wallet == null) return null;

    final coinInfo = wallet.coinInfo?[chainType];
    if (coinInfo == null) return null;

    return coinInfo['baseInfo']?['address']?.toString();
  }

  @override
  Map<String, dynamic>? getCoinInfoForWallet(int walletIndex) {
    final wallets = _getAllWalletsData();
    if (walletIndex < 0 || walletIndex >= wallets.length) return null;
    return wallets[walletIndex].coinInfo;
  }

  @override
  Future<String?> getPrivateKeyForWallet(int walletIndex) async {
    final wallets = _getAllWalletsData();
    if (walletIndex < 0 || walletIndex >= wallets.length) return null;

    final wallet = wallets[walletIndex];

    // Return stored private key if available
    if (wallet.privateKey != null && wallet.privateKey!.isNotEmpty) {
      return wallet.privateKey;
    }

    // Generate from mnemonic if no private key stored
    if (wallet.mnemonic != null && wallet.mnemonic!.isNotEmpty) {
      final coinInfo = wallet.coinInfo?[CoinType.N.name];
      if (coinInfo == null) return null;

      final pathMap = coinInfo['baseInfo']?['path'] as Map<String, dynamic>?;
      if (pathMap == null) return null;

      final addrType = coinInfo['addrType'] ?? 'legacy';
      final pathIndex = coinInfo['pathIndex'] ?? 0;
      final path = getPathWithIndex(pathMap[addrType], pathIndex);

      return await Trustdart().getPrivateKey(
        wallet.mnemonic!,
        CoinType.N.name,
        path,
      );
    }

    return null;
  }

  @override
  Future<String?> getMnemonicForWallet(int walletIndex) async {
    final wallets = _getAllWalletsData();
    if (walletIndex < 0 || walletIndex >= wallets.length) return null;
    return wallets[walletIndex].mnemonic;
  }

  @override
  Future<WalletBalanceInfo?> getBalance(String address, String coinType) async {
    try {
      final wallet = getWalletByAddress(address);
      if (wallet == null) return null;

      // Derive blockchain type from coinType via chain config, since wallet.chainType is 'multi'
      final chainConfig = chainUrlMap[coinType];
      final chainType =
          chainConfig?['baseInfo']?['blockchainType'] as String? ?? 'Ethereum';
      final result = await TokenViewApi().getBalance(
        chainType,
        coinType,
        address,
      );
      if (result == null || result.error) {
        return WalletBalanceInfo(
          address: address,
          coinType: coinType,
          balance: 0.0,
          lastUpdated: DateTime.now(),
        );
      }

      final balanceValue = result.data is num
          ? (result.data as num).toDouble()
          : double.tryParse(result.data?.toString() ?? '0') ?? 0.0;

      return WalletBalanceInfo(
        address: address,
        coinType: coinType,
        balance: balanceValue,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refreshWallets() async {
    // Refresh the wallet list from storage
    await _container.read(walletListProvider.notifier).refresh();
  }

  SharedWalletInfo _toSharedInfo(WalletInfoData wallet) {
    return SharedWalletInfo(
      address: wallet.address,
      name: wallet.name,
      chainType: wallet.chainType,
      avatarUrl: wallet.avatarUrl,
    );
  }

  void dispose() {
    _walletListSubscription?.close();
    _walletIndexSubscription?.close();
    _walletStreamController.close();
  }
}

/// Provider for IWalletService
final walletServiceProvider = Provider<IWalletService>((ref) {
  final registered = ServiceLocatorSetup.walletService;
  if (registered != null) {
    return registered;
  }

  final container = ProviderContainer();
  final service = WalletServiceImpl(container);
  ref.onDispose(() {
    service.dispose();
    container.dispose();
  });
  return service;
});
