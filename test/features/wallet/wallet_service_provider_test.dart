import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';

class FakeWalletService implements IWalletService {
  @override
  Stream<SharedWalletInfo?> get currentWalletStream =>
      const Stream<SharedWalletInfo?>.empty();

  @override
  int get miningWalletIndex => 0;

  @override
  int get walletCount => 1;

  @override
  List<SharedWalletInfo> getAllWallets() => const [];

  @override
  Future<WalletBalanceInfo?> getBalance(
    String address,
    String coinType,
  ) async => null;

  @override
  Future<String?> getChainAddress(String walletId, String chainType) async =>
      null;

  @override
  Map<String, dynamic>? getCoinInfoForWallet(int walletIndex) => null;

  @override
  SharedWalletInfo? getCurrentWallet() => null;

  @override
  SharedWalletInfo? getMainWallet() => null;

  @override
  Future<String?> getMnemonicForWallet(int walletIndex) async => null;

  @override
  SharedWalletInfo? getMiningWallet() => null;

  @override
  Future<String?> getPrivateKeyForWallet(int walletIndex) async => null;

  @override
  SharedWalletInfo? getWalletByAddress(String address) => null;

  @override
  Future<void> refreshWallets() async {}

  @override
  bool walletExists(String address) => false;
}

void main() {
  tearDown(() async {
    await ServiceLocatorSetup.reset();
  });

  test(
    'walletServiceProvider reuses registered shared wallet service',
    () async {
      await ServiceLocatorSetup.initialize();
      final fake = FakeWalletService();
      ServiceLocatorSetup.registerWalletService(fake);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(walletServiceProvider);

      expect(service, same(fake));
    },
  );
}
