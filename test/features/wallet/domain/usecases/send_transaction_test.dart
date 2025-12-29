// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/error/failures.dart';
import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42appv2/features/wallet/domain/usecases/send_transaction.dart';

import '../../../../helpers/mock_providers.dart';

void main() {
  late SendTransaction useCase;
  late EstimateGas estimateGasUseCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = SendTransaction(mockRepository);
    estimateGasUseCase = EstimateGas(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('SendTransaction UseCase', () {
    final validParams = SendTransactionParams(
      fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
      toAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
      amount: BigInt.from(1000000000000000000), // 1 ETH
      chainType: ChainType.ethereum,
    );

    group('Validation Tests', () {
      test('should return ValidationFailure when toAddress is empty', () async {
        // Arrange
        final params = SendTransactionParams(
          fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
          toAddress: '',
          amount: BigInt.from(1000000000000000000),
          chainType: ChainType.ethereum,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Recipient address is required');
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure when amount is zero', () async {
        // Arrange
        final params = SendTransactionParams(
          fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
          toAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
          amount: BigInt.zero,
          chainType: ChainType.ethereum,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Amount must be greater than zero');
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure when amount is negative', () async {
        // Arrange
        final params = SendTransactionParams(
          fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
          toAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
          amount: BigInt.from(-1),
          chainType: ChainType.ethereum,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('Success Cases', () {
      test('should send transaction successfully with valid parameters', () async {
        // Act
        final result = await useCase(validParams);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (transaction) {
            expect(transaction, isA<TransactionEntity>());
            expect(transaction.hash, isNotEmpty);
          },
        );
      });

      test('should return transaction with confirmed status', () async {
        // Act
        final result = await useCase(validParams);

        // Assert
        result.fold(
          (_) => fail('Expected success'),
          (transaction) {
            expect(transaction.status, TransactionStatus.confirmed);
          },
        );
      });

      test('should send transaction with custom gas parameters', () async {
        // Arrange
        final params = SendTransactionParams(
          fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
          toAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
          amount: BigInt.from(1000000000000000000),
          chainType: ChainType.ethereum,
          gasLimit: BigInt.from(50000),
          gasPrice: BigInt.from(30000000000),
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
      });

      test('should send token transaction with contract address', () async {
        // Arrange
        final params = SendTransactionParams(
          fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
          toAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
          amount: BigInt.from(100000000), // 100 USDT
          chainType: ChainType.ethereum,
          contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
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
          (failure) => expect(failure, isA<ServerFailure>()),
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

    group('SendTransactionParams', () {
      test('should have correct equality', () {
        // Arrange
        final params1 = SendTransactionParams(
          fromAddress: '0x1234',
          toAddress: '0x5678',
          amount: BigInt.from(1000),
          chainType: ChainType.ethereum,
        );
        final params2 = SendTransactionParams(
          fromAddress: '0x1234',
          toAddress: '0x5678',
          amount: BigInt.from(1000),
          chainType: ChainType.ethereum,
        );

        // Assert
        expect(params1, equals(params2));
      });

      test('should differ by amount', () {
        // Arrange
        final params1 = SendTransactionParams(
          fromAddress: '0x1234',
          toAddress: '0x5678',
          amount: BigInt.from(1000),
          chainType: ChainType.ethereum,
        );
        final params2 = SendTransactionParams(
          fromAddress: '0x1234',
          toAddress: '0x5678',
          amount: BigInt.from(2000),
          chainType: ChainType.ethereum,
        );

        // Assert
        expect(params1, isNot(equals(params2)));
      });
    });
  });

  group('EstimateGas UseCase', () {
    test('should estimate gas successfully', () async {
      // Arrange
      final params = EstimateGasParams(
        fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
        toAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
        amount: BigInt.from(1000000000000000000),
        chainType: ChainType.ethereum,
      );

      // Act
      final result = await estimateGasUseCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (gas) {
          expect(gas, isA<BigInt>());
          expect(gas > BigInt.zero, true);
        },
      );
    });

    test('should return default gas estimate', () async {
      // Arrange
      final params = EstimateGasParams(
        fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
        toAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
        amount: BigInt.from(1000000000000000000),
        chainType: ChainType.ethereum,
      );

      // Act
      final result = await estimateGasUseCase(params);

      // Assert
      result.fold(
        (_) => fail('Expected success'),
        (gas) {
          expect(gas, equals(BigInt.from(21000)));
        },
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      mockRepository.shouldFail = true;
      mockRepository.failureToReturn = const ServerFailure(message: 'Estimation failed');
      
      final params = EstimateGasParams(
        fromAddress: '0x1234',
        toAddress: '0x5678',
        amount: BigInt.from(1000),
        chainType: ChainType.ethereum,
      );

      // Act
      final result = await estimateGasUseCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}

