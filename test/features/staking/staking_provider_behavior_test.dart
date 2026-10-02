// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw const SocketException('Network disabled in staking provider test');
}

void main() {
  group('StakingProvider behavior', () {
    test('starts empty and notifies when selection changes', () {
      final provider = StakingProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      expect(provider.state, StakingState.initial);
      expect(provider.supportedProtocols, StakingProtocols.all);
      expect(provider.activePositions, isEmpty);
      expect(provider.unbondingPositions, isEmpty);
      expect(provider.totalStakedValue, BigInt.zero);
      expect(provider.totalPendingRewards, BigInt.zero);
      expect(provider.getStats().averageApy, 0);

      provider.selectProtocol(StakingProtocols.solNative);
      expect(provider.selectedProtocol, StakingProtocols.solNative);
      expect(provider.currentApy, 7.0);
      provider.selectValidator(_validator('sol-validator'));
      expect(provider.selectedValidator?.address, 'sol-validator');
      provider.clearSelection();
      expect(provider.selectedProtocol, isNull);
      expect(provider.selectedValidator, isNull);
      expect(provider.validators, isEmpty);
      expect(notifications, 3);
    });

    test('loadValidators without a selected protocol is a no-op', () async {
      final provider = StakingProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.loadValidators();

      expect(provider.state, StakingState.initial);
      expect(notifications, 0);
    });

    test('unsupported Polkadot loads report error state', () async {
      final provider = StakingProvider();
      provider.selectProtocol(StakingProtocols.dotNative);

      await provider.loadValidators();

      expect(provider.state, StakingState.error);
      expect(
        provider.errorMessage,
        contains('DOT staking is not yet supported'),
      );

      await provider.loadUserPositions(
        'dot-address',
        StakingChainType.polkadot,
      );
      expect(provider.state, StakingState.error);
      expect(
        provider.errorMessage,
        contains('DOT staking is not yet supported'),
      );
    });

    test(
      'multi-chain load skips empty addresses and unsupported Polkadot',
      () async {
        final provider = StakingProvider();

        await provider.loadAllUserPositions({
          StakingChainType.ethereum: '',
          StakingChainType.polkadot: 'dot-address',
        });

        expect(provider.state, StakingState.loaded);
        expect(provider.positions, isEmpty);
        expect(provider.errorMessage, isNull);
      },
    );

    test(
      'supported chain loaders keep API failures isolated per request',
      () async {
        final previousOverrides = HttpOverrides.current;
        HttpOverrides.global = _OfflineHttpOverrides();
        try {
          final provider = StakingProvider();
          for (final protocol in [
            StakingProtocols.ethLido,
            StakingProtocols.solNative,
            StakingProtocols.atomNative,
          ]) {
            provider.selectProtocol(protocol);
            await provider.loadValidators();
            expect(provider.state, StakingState.loaded);
          }

          for (final chain in [
            StakingChainType.ethereum,
            StakingChainType.solana,
            StakingChainType.cosmos,
          ]) {
            await provider.loadUserPositions('offline-address', chain);
            expect(provider.state, StakingState.loaded);
          }

          await provider.loadAllUserPositions({
            StakingChainType.ethereum: 'offline-eth',
            StakingChainType.solana: 'offline-sol',
            StakingChainType.cosmos: 'offline-atom',
          });
          expect(provider.state, StakingState.loaded);
        } finally {
          HttpOverrides.global = previousOverrides;
        }
      },
    );

    test('successful retry clears the previous load error', () async {
      final provider = StakingProvider();
      provider.selectProtocol(StakingProtocols.dotNative);
      await provider.loadValidators();
      expect(provider.errorMessage, isNotNull);

      final previousOverrides = HttpOverrides.current;
      HttpOverrides.global = _OfflineHttpOverrides();
      try {
        provider.selectProtocol(StakingProtocols.ethLido);
        await provider.loadValidators();
      } finally {
        HttpOverrides.global = previousOverrides;
      }

      expect(provider.state, StakingState.loaded);
      expect(provider.errorMessage, isNull);
      expect(provider.currentApy, 4.0);
    });

    test(
      'transaction builders return chain-specific validation errors',
      () async {
        final provider = StakingProvider();
        final amount = BigInt.one;
        final noProtocol = await provider.buildStakeTransaction(
          fromAddress: 'address',
          amount: amount,
        );
        expect(noProtocol?.error, 'No protocol selected');

        provider.selectProtocol(StakingProtocols.solNative);
        expect(
          (await provider.buildStakeTransaction(
            fromAddress: 'address',
            amount: amount,
          ))?.error,
          'No validator selected',
        );

        final solPosition = _position(
          id: 'stake-account',
          protocol: StakingProtocols.solNative,
          amount: 1,
        );
        final solUnstake = await provider.buildUnstakeTransaction(
          position: solPosition,
          amount: amount,
          fromAddress: 'address',
        );
        expect(solUnstake?.success, isTrue);
        expect(
          (await provider.buildClaimRewardsTransaction(
            position: solPosition,
            fromAddress: 'address',
          ))?.error,
          'Solana staking rewards are auto-added to stake balance',
        );

        final ethPosition = _position(
          id: 'eth-position',
          protocol: StakingProtocols.ethLido,
          amount: 1,
        );
        expect(
          (await provider.buildUnstakeTransaction(
            position: ethPosition,
            amount: amount,
            fromAddress: 'address',
          ))?.error,
          contains('stETH can be traded directly'),
        );
        expect(
          (await provider.buildClaimRewardsTransaction(
            position: ethPosition,
            fromAddress: 'address',
          ))?.error,
          contains('auto-compounded'),
        );

        final atomPosition = _position(
          id: 'atom-position',
          protocol: StakingProtocols.atomNative,
          amount: 1,
        );
        expect(
          (await provider.buildUnstakeTransaction(
            position: atomPosition,
            amount: amount,
            fromAddress: 'address',
          ))?.error,
          'No validator in position',
        );
        expect(
          (await provider.buildClaimRewardsTransaction(
            position: atomPosition,
            fromAddress: 'address',
          ))?.error,
          'No validator in position',
        );

        provider.selectProtocol(StakingProtocols.dotNative);
        expect(
          (await provider.buildStakeTransaction(
            fromAddress: 'address',
            amount: amount,
          ))?.error,
          'DOT staking not yet implemented',
        );
        final dotPosition = _position(
          id: 'dot',
          protocol: StakingProtocols.dotNative,
          amount: 1,
        );
        expect(
          (await provider.buildUnstakeTransaction(
            position: dotPosition,
            amount: amount,
            fromAddress: 'address',
          ))?.error,
          'DOT unstaking not yet implemented',
        );
        expect(
          (await provider.buildClaimRewardsTransaction(
            position: dotPosition,
            fromAddress: 'address',
          ))?.error,
          'DOT claim not yet implemented',
        );
      },
    );

    test('reset clears all state and notifies listeners', () {
      final provider = StakingProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);
      provider
        ..selectProtocol(StakingProtocols.solNative)
        ..selectValidator(_validator('sol-validator'))
        ..reset();

      expect(provider.state, StakingState.initial);
      expect(provider.errorMessage, isNull);
      expect(provider.selectedProtocol, isNull);
      expect(provider.selectedValidator, isNull);
      expect(provider.validators, isEmpty);
      expect(provider.positions, isEmpty);
      expect(provider.currentApy, 0);
      expect(notifications, 3);
    });
  });
}

Validator _validator(String address) => Validator(
  address: address,
  name: 'Test validator',
  description: '',
  logoUri: '',
  commission: 5,
  apy: 7,
  totalStaked: BigInt.zero,
  delegatorCount: 0,
  isActive: true,
  uptime: 100,
);

StakingPosition _position({
  required String id,
  required StakingProtocol protocol,
  required int amount,
  int rewards = 0,
  StakingPositionStatus status = StakingPositionStatus.active,
}) => StakingPosition(
  id: id,
  protocol: protocol,
  stakedAmount: BigInt.from(amount),
  rewardsEarned: BigInt.zero,
  pendingRewards: BigInt.from(rewards),
  stakedAt: DateTime.utc(2025),
  status: status,
);
