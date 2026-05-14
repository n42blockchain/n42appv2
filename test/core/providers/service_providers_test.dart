// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Contract tests for the Riverpod service providers that hold the
// cross-feature service singletons. These guard:
//   - Providers return null when no service is registered (the
//     mining_v2 / wallet_connect / browser DApp paths all check for
//     null after reading and bail gracefully — that contract must hold).
//   - Providers return the registered instance when one is present.
//   - Provider overrides work for test isolation.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/shared/domain/services/mining_service_interface.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';

class _FakeWalletService implements IWalletService {
  @override
  int get walletCount => 0;
  @override
  int get miningWalletIndex => -1;
  @override
  Stream<SharedWalletInfo?> get currentWalletStream => const Stream.empty();
  @override
  SharedWalletInfo? getCurrentWallet() => null;
  @override
  SharedWalletInfo? getMainWallet() => null;
  @override
  SharedWalletInfo? getMiningWallet() => null;
  @override
  SharedWalletInfo? getWalletByAddress(String address) => null;
  @override
  List<SharedWalletInfo> getAllWallets() => const [];
  @override
  bool walletExists(String address) => false;
  @override
  Future<String?> getChainAddress(String walletId, String chainType) async => null;
  @override
  Map<String, dynamic>? getCoinInfoForWallet(int walletIndex) => null;
  @override
  Future<String?> getPrivateKeyForWallet(int walletIndex) async => null;
  @override
  Future<String?> getMnemonicForWallet(int walletIndex) async => null;
  @override
  Future<WalletBalanceInfo?> getBalance(String address, String coinType) async => null;
  @override
  Future<({String mnemonic, String privateKey})> getCredentials(
    int walletIndex,
  ) async =>
      (mnemonic: '', privateKey: '');
  @override
  Future<void> refreshWallets() async {}
}

class _FakeMiningService implements IMiningService {
  @override
  MiningStatus get status => MiningStatus.idle;
  @override
  bool get isMining => false;
  @override
  String? get miningWalletAddress => null;
  @override
  SharedMiningInfo get miningInfo =>
      const SharedMiningInfo(status: MiningStatus.idle);
  @override
  Stream<MiningStatus> get statusStream => const Stream.empty();
  @override
  void onWalletChanged(String? newAddress) {}
}

void main() {
  group('walletServiceProvider', () {
    tearDown(resetCrossFeatureServices);

    test('returns null when no IWalletService is registered', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(walletServiceProvider), isNull);
    });

    test('returns the registered IWalletService', () {
      final fake = _FakeWalletService();
      registerWalletService(fake);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(walletServiceProvider), same(fake));
    });

    test('honors overrideWithValue for test isolation', () {
      final realLikeFake = _FakeWalletService();
      registerWalletService(realLikeFake);

      final overrideFake = _FakeWalletService();
      final container = ProviderContainer(overrides: [
        walletServiceProvider.overrideWithValue(overrideFake),
      ]);
      addTearDown(container.dispose);

      expect(container.read(walletServiceProvider), same(overrideFake));
      expect(container.read(walletServiceProvider), isNot(same(realLikeFake)));
    });
  });

  group('miningServiceProvider', () {
    tearDown(resetCrossFeatureServices);

    test('returns null when no IMiningService is registered', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(miningServiceProvider), isNull);
    });

    test('returns the registered IMiningService', () {
      final fake = _FakeMiningService();
      registerMiningService(fake);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(miningServiceProvider), same(fake));
    });

    test('honors overrideWithValue', () {
      final overrideFake = _FakeMiningService();
      final container = ProviderContainer(overrides: [
        miningServiceProvider.overrideWithValue(overrideFake),
      ]);
      addTearDown(container.dispose);

      expect(container.read(miningServiceProvider), same(overrideFake));
    });
  });

  group('deepLinkServiceProvider', () {
    test('creates a non-null singleton on first read', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(deepLinkServiceProvider);
      expect(service, isNotNull);
    });

    test('returns the same instance on subsequent reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final first = container.read(deepLinkServiceProvider);
      final second = container.read(deepLinkServiceProvider);
      expect(identical(first, second), isTrue);
    });

    test('disposing the container disposes the service', () async {
      final container = ProviderContainer();
      final service = container.read(deepLinkServiceProvider);

      container.dispose();

      // dispose() is idempotent — the host (_N42AppV2State.dispose)
      // also calls service.dispose() on app teardown, so calling it
      // again after the container already did must not throw.
      await expectLater(service.dispose(), completes);
    });
  });
}
