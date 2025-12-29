// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';

/// Implementation of IWalletService using Riverpod
///
/// This implementation bridges the Riverpod state with the
/// interface-based service layer for cross-feature communication.
@LazySingleton(as: IWalletService)
class WalletServiceImpl implements IWalletService {
  final ProviderContainer _container;
  final StreamController<SharedWalletInfo?> _walletStreamController =
      StreamController<SharedWalletInfo?>.broadcast();

  WalletServiceImpl(this._container) {
    // Listen to wallet changes and broadcast
    _container.listen<AsyncValue<List<WalletInfoData>>>(
      walletListProvider,
      (_, next) {
        final wallet = getCurrentWallet();
        _walletStreamController.add(wallet);
      },
    );
    
    _container.listen<int>(
      selectedWalletIndexProvider,
      (_, __) {
        final wallet = getCurrentWallet();
        _walletStreamController.add(wallet);
      },
    );
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
  SharedWalletInfo? getWalletByAddress(String address) {
    final wallets = _container.read(walletListProvider);

    return wallets.whenOrNull(
      data: (list) {
        final wallet = list.where((w) => w.address == address).firstOrNull;
        if (wallet == null) return null;
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
  List<SharedWalletInfo> getAllWallets() {
    final wallets = _container.read(walletListProvider);

    return wallets.whenOrNull(
          data: (list) => list
              .map((w) => SharedWalletInfo(
                    address: w.address,
                    name: w.name,
                    chainType: w.chainType,
                    avatarUrl: w.avatarUrl,
                  ))
              .toList(),
        ) ??
        [];
  }

  @override
  bool walletExists(String address) {
    return getWalletByAddress(address) != null;
  }

  @override
  Stream<SharedWalletInfo?> get currentWalletStream =>
      _walletStreamController.stream;

  void dispose() {
    _walletStreamController.close();
  }
}

/// Provider for IWalletService
final walletServiceProvider = Provider<IWalletService>((ref) {
  final container = ProviderContainer();
  final service = WalletServiceImpl(container);
  ref.onDispose(() {
    service.dispose();
    container.dispose();
  });
  return service;
});
