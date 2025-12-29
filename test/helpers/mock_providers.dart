// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/core/error/failures.dart';
import 'package:n42appv2/domain/entities/wallet.dart' as domain;
import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42appv2/features/wallet/domain/usecases/send_transaction.dart';

/// Simple Mock Wallet Repository for UseCase Testing
///
/// 为 UseCase 测试提供简单的 Mock 实现
class MockWalletRepository {
  bool shouldFail = false;
  Failure? failureToReturn;
  domain.Wallet? walletToReturn;
  List<domain.Asset>? assetsToReturn;

  void reset() {
    shouldFail = false;
    failureToReturn = null;
    walletToReturn = null;
    assetsToReturn = null;
  }

  Future<Either<Failure, domain.Wallet>> createWallet({
    required String name,
    required String password,
    required ChainType chainType,
  }) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(walletToReturn ?? _createMockWallet(name, _toDomainChainType(chainType)));
  }

  Future<Either<Failure, domain.Wallet>> importWallet({
    required String mnemonic,
    required String password,
    required ChainType chainType,
    String? name,
  }) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(walletToReturn ?? _createMockWallet(name ?? 'Imported', _toDomainChainType(chainType)));
  }

  Future<Either<Failure, List<domain.Asset>>> getAssets({
    required String address,
    ChainType? chainType,
  }) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(assetsToReturn ?? _createMockAssets());
  }

  Future<Either<Failure, domain.Wallet>> getWallet(String id) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(walletToReturn ?? _createMockWallet('Test', domain.ChainType.ethereum));
  }

  Future<Either<Failure, List<domain.Wallet>>> getWallets() async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right([walletToReturn ?? _createMockWallet('Test', domain.ChainType.ethereum)]);
  }

  Future<Either<Failure, Unit>> deleteWallet(String id) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return const Right(unit);
  }

  domain.ChainType _toDomainChainType(ChainType type) {
    switch (type) {
      case ChainType.ethereum:
        return domain.ChainType.ethereum;
      case ChainType.bitcoin:
        return domain.ChainType.bitcoin;
      case ChainType.solana:
        return domain.ChainType.solana;
      default:
        return domain.ChainType.ethereum;
    }
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

  List<domain.Asset> _createMockAssets() {
    return [
      domain.Asset(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.from(1000000000000000000), // 1 ETH
        decimals: 18,
        isNative: true,
      ),
      domain.Asset(
        symbol: 'USDT',
        name: 'Tether USD',
        balance: BigInt.from(100000000), // 100 USDT
        decimals: 6,
        contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
        isNative: false,
      ),
    ];
  }
}

/// Mock Transaction Repository
class MockTransactionRepository implements TransactionRepository {
  bool shouldFail = false;
  Failure? failureToReturn;
  TransactionEntity? transactionToReturn;
  BigInt? gasEstimateToReturn;

  void reset() {
    shouldFail = false;
    failureToReturn = null;
    transactionToReturn = null;
    gasEstimateToReturn = null;
  }

  @override
  Future<Either<Failure, TransactionEntity>> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required ChainType chainType,
    String? contractAddress,
    String? data,
    BigInt? gasLimit,
    BigInt? gasPrice,
  }) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(transactionToReturn ?? _createMockTransaction(fromAddress, toAddress, amount));
  }

  @override
  Future<Either<Failure, BigInt>> estimateGas({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required ChainType chainType,
    String? contractAddress,
    String? data,
  }) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(gasEstimateToReturn ?? BigInt.from(21000));
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(String txHash) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right(transactionToReturn ?? _createMockTransaction(
      '0x1234', '0x5678', BigInt.from(1000000000000000000),
    ));
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory({
    required String address,
    required ChainType chainType,
    int page = 1,
    int limit = 20,
  }) async {
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return Right([
      _createMockTransaction('0x1234', '0x5678', BigInt.from(1000000000000000000)),
    ]);
  }

  TransactionEntity _createMockTransaction(String from, String to, BigInt amount) {
    return TransactionEntity(
      hash: '0xabc123def456',
      fromAddress: from,
      toAddress: to,
      amount: amount,
      status: TransactionStatus.confirmed,
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

