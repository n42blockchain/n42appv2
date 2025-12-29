// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/error/failures.dart';
import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42appv2/features/wallet/domain/usecases/create_wallet.dart';

import '../../../../helpers/mock_providers.dart';

void main() {
  late CreateWallet useCase;
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
    useCase = CreateWallet(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('CreateWallet UseCase', () {
    const validParams = CreateWalletParams(
      name: 'MyWallet',
      password: 'password123',
      chainType: ChainType.ethereum,
    );

    group('Validation Tests', () {
      test('should return ValidationFailure when name is empty', () async {
        // Arrange
        const params = CreateWalletParams(
          name: '',
          password: 'password123',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Wallet name cannot be empty');
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure when name exceeds 12 characters', () async {
        // Arrange
        const params = CreateWalletParams(
          name: 'VeryLongWalletName',
          password: 'password123',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Wallet name cannot exceed 12 characters');
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure when password is less than 8 characters', () async {
        // Arrange
        const params = CreateWalletParams(
          name: 'MyWallet',
          password: 'short',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Password must be at least 8 characters');
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should accept name with exactly 12 characters', () async {
        // Arrange
        const params = CreateWalletParams(
          name: 'TwelveChars!',
          password: 'password123',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
      });

      test('should accept password with exactly 8 characters', () async {
        // Arrange
        const params = CreateWalletParams(
          name: 'MyWallet',
          password: '12345678',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
      });
    });

    group('Success Cases', () {
      test('should create wallet successfully with valid parameters', () async {
        // Act
        final result = await useCase(validParams);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (wallet) {
            expect(wallet, isA<WalletEntity>());
            expect(wallet.name, validParams.name);
          },
        );
      });

      test('should create ethereum wallet by default', () async {
        // Arrange
        const params = CreateWalletParams(
          name: 'MyWallet',
          password: 'password123',
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (wallet) {
            expect(wallet.chainType, 'ethereum');
          },
        );
      });

      test('should create wallet with specified chain type', () async {
        // Arrange
        const params = CreateWalletParams(
          name: 'BTCWallet',
          password: 'password123',
          chainType: ChainType.bitcoin,
        );

        // Act
        final result = await useCase(params);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (wallet) {
            expect(wallet.chainType, 'bitcoin');
          },
        );
      });

      test('should return wallet entity with all required fields', () async {
        // Act
        final result = await useCase(validParams);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (wallet) {
            expect(wallet.id, isNotEmpty);
            expect(wallet.name, isNotEmpty);
            expect(wallet.address, isNotEmpty);
            expect(wallet.chainType, isNotEmpty);
            expect(wallet.createdAt, isNotNull);
          },
        );
      });
    });

    group('Failure Cases', () {
      test('should return ServerFailure when repository fails', () async {
        // Arrange
        mockRepository.shouldFail = true;
        mockRepository.failureToReturn = const ServerFailure(message: 'Server error');

        // Act
        final result = await useCase(validParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).message, 'Server error');
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return NetworkFailure when network error occurs', () async {
        // Arrange
        mockRepository.shouldFail = true;
        mockRepository.failureToReturn = const NetworkFailure();

        // Act
        final result = await useCase(validParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('CreateWalletParams', () {
      test('should have correct equality', () {
        // Arrange
        const params1 = CreateWalletParams(
          name: 'Wallet1',
          password: 'password123',
        );
        const params2 = CreateWalletParams(
          name: 'Wallet1',
          password: 'password123',
        );
        const params3 = CreateWalletParams(
          name: 'Wallet2',
          password: 'password123',
        );

        // Assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
      });

      test('should include all props in equality', () {
        // Arrange
        const params1 = CreateWalletParams(
          name: 'Wallet',
          password: 'password123',
          chainType: ChainType.ethereum,
        );
        const params2 = CreateWalletParams(
          name: 'Wallet',
          password: 'password123',
          chainType: ChainType.bitcoin,
        );

        // Assert
        expect(params1, isNot(equals(params2)));
      });
    });
  });
}

