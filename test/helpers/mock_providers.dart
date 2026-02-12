// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:n42appv2/core/error/failures.dart';
import 'package:n42appv2/domain/entities/wallet.dart' as domain;

/// Simple Mock Wallet Repository for UseCase Testing
///
/// 为 UseCase 测试提供简单的 Mock 实现
class MockWalletRepository {
  bool shouldFail = false;
  Failure? failureToReturn;
  domain.Wallet? walletToReturn;

  void reset() {
    shouldFail = false;
    failureToReturn = null;
    walletToReturn = null;
  }

  Future<Either<Failure, domain.Wallet>> createWallet({
    required String name,
    required String password,
    required domain.ChainType chainType,
  }) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(walletToReturn ?? _createMockWallet(name, chainType));
  }

  Future<Either<Failure, domain.Wallet>> importWallet({
    required String mnemonic,
    required String password,
    required domain.ChainType chainType,
    String? name,
  }) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(
        walletToReturn ?? _createMockWallet(name ?? 'Imported', chainType));
  }

  Future<Either<Failure, domain.Wallet>> getWallet(String id) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(
        walletToReturn ?? _createMockWallet('Test', domain.ChainType.ethereum));
  }

  Future<Either<Failure, List<domain.Wallet>>> getWallets() async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right([
      walletToReturn ?? _createMockWallet('Test', domain.ChainType.ethereum)
    ]);
  }

  Future<Either<Failure, Unit>> deleteWallet(String id) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return const Right(unit);
  }

  domain.Wallet _createMockWallet(String name, domain.ChainType chainType) {
    return domain.Wallet(
      id: 'mock-id-123',
      name: name,
      address: '0x1234567890abcdef1234567890abcdef12345678',
      chainType: chainType,
      createdAt: DateTime.now(),
      isHD: true,
      derivationPath: "m/44'/60'/0'/0/0",
      index: 0,
    );
  }
}

/// Mock Transaction Entity
class MockTransactionEntity {
  final String hash;
  final String fromAddress;
  final String toAddress;
  final BigInt amount;
  final String status;
  final DateTime timestamp;
  final BigInt gasUsed;
  final BigInt gasPrice;

  MockTransactionEntity({
    required this.hash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.status,
    required this.timestamp,
    required this.gasUsed,
    required this.gasPrice,
  });
}

/// Mock Transaction Repository
class MockTransactionRepository {
  bool shouldFail = false;
  Failure? failureToReturn;
  MockTransactionEntity? transactionToReturn;
  BigInt? gasEstimateToReturn;

  void reset() {
    shouldFail = false;
    failureToReturn = null;
    transactionToReturn = null;
    gasEstimateToReturn = null;
  }

  Future<Either<Failure, MockTransactionEntity>> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required domain.ChainType chainType,
    String? contractAddress,
    String? data,
    BigInt? gasLimit,
    BigInt? gasPrice,
  }) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(transactionToReturn ??
        _createMockTransaction(fromAddress, toAddress, amount));
  }

  Future<Either<Failure, BigInt>> estimateGas({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required domain.ChainType chainType,
    String? contractAddress,
    String? data,
  }) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(gasEstimateToReturn ?? BigInt.from(21000));
  }

  Future<Either<Failure, MockTransactionEntity>> getTransaction(
      String txHash) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(transactionToReturn ??
        _createMockTransaction(
          '0x1234',
          '0x5678',
          BigInt.from(1000000000000000000),
        ));
  }

  Future<Either<Failure, List<MockTransactionEntity>>> getTransactionHistory({
    required String address,
    required domain.ChainType chainType,
    int page = 1,
    int limit = 20,
  }) async {
    if (shouldFail) {
      return Left(
          failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right([
      _createMockTransaction(
          '0x1234', '0x5678', BigInt.from(1000000000000000000)),
    ]);
  }

  MockTransactionEntity _createMockTransaction(
      String from, String to, BigInt amount) {
    return MockTransactionEntity(
      hash: '0xabc123def456',
      fromAddress: from,
      toAddress: to,
      amount: amount,
      status: 'confirmed',
      timestamp: DateTime.now(),
      gasUsed: BigInt.from(21000),
      gasPrice: BigInt.from(20000000000),
    );
  }
}

/// Create a test ProviderContainer with mocked dependencies
ProviderContainer createMockProviderContainer({
  List<Override>? overrides,
}) {
  return ProviderContainer(
    overrides: overrides ?? [],
  );
}
