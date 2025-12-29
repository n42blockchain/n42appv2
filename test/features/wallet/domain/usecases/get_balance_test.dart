// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/error/failures.dart';
import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42appv2/features/wallet/domain/usecases/get_balance.dart';

import '../../../../helpers/mock_providers.dart';

void main() {
  late GetBalance useCase;
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
    useCase = GetBalance(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('GetBalance UseCase', () {
    const testAddress = '0x1234567890abcdef1234567890abcdef12345678';

    group('Success Cases', () {
      test('should return list of assets for valid address', () async {
        // Arrange
        const params = GetBalanceParams(address: testAddress);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (assets) {
            expect(assets, isA<List<AssetEntity>>());
            expect(assets.isNotEmpty, true);
          },
        );
      });

      test('should return assets with correct properties', () async {
        // Arrange
        const params = GetBalanceParams(address: testAddress);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (assets) {
            final ethAsset = assets.firstWhere((a) => a.symbol == 'ETH');
            expect(ethAsset.name, 'Ethereum');
            expect(ethAsset.decimals, 18);
            expect(ethAsset.isNative, true);
          },
        );
      });

      test('should filter by chain type when provided', () async {
        // Arrange
        const params = GetBalanceParams(
          address: testAddress,
          chainType: ChainType.ethereum,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (assets) {
            expect(assets.every((a) => a.chainType == 'ethereum'), true);
          },
        );
      });

      test('should return both native and token assets', () async {
        // Arrange
        const params = GetBalanceParams(address: testAddress);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (assets) {
            final hasNative = assets.any((a) => a.isNative);
            final hasToken = assets.any((a) => !a.isNative);
            expect(hasNative, true);
            expect(hasToken, true);
          },
        );
      });

      test('should return token with contract address', () async {
        // Arrange
        const params = GetBalanceParams(address: testAddress);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (assets) {
            final usdtAsset = assets.firstWhere((a) => a.symbol == 'USDT');
            expect(usdtAsset.contractAddress, isNotNull);
            expect(usdtAsset.contractAddress, isNotEmpty);
          },
        );
      });
    });

    group('Failure Cases', () {
      test('should return ServerFailure when repository fails', () async {
        // Arrange
        mockRepository.shouldFail = true;
        mockRepository.failureToReturn = const ServerFailure(message: 'Server error');
        const params = GetBalanceParams(address: testAddress);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return NetworkFailure when network error occurs', () async {
        // Arrange
        mockRepository.shouldFail = true;
        mockRepository.failureToReturn = const NetworkFailure();
        const params = GetBalanceParams(address: testAddress);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('GetBalanceParams', () {
      test('should have correct equality', () {
        // Arrange
        const params1 = GetBalanceParams(address: testAddress);
        const params2 = GetBalanceParams(address: testAddress);
        const params3 = GetBalanceParams(address: '0xdifferent');

        // Assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
      });

      test('should include chainType in equality', () {
        // Arrange
        const params1 = GetBalanceParams(
          address: testAddress,
          chainType: ChainType.ethereum,
        );
        const params2 = GetBalanceParams(
          address: testAddress,
          chainType: ChainType.bitcoin,
        );

        // Assert
        expect(params1, isNot(equals(params2)));
      });

      test('should handle null chainType', () {
        // Arrange
        const params = GetBalanceParams(address: testAddress);

        // Assert
        expect(params.chainType, isNull);
        expect(params.props, contains(null));
      });
    });
  });
}

