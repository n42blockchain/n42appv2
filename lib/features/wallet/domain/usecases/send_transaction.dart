// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/core/usecase/usecase.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';

/// Transaction Repository Interface
abstract class TransactionRepository {
  Future<Either<Failure, TransactionEntity>> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required ChainType chainType,
    String? contractAddress,
    String? data,
    BigInt? gasLimit,
    BigInt? gasPrice,
  });

  Future<Either<Failure, BigInt>> estimateGas({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required ChainType chainType,
    String? contractAddress,
    String? data,
  });

  Future<Either<Failure, TransactionEntity>> getTransaction(String txHash);

  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory({
    required String address,
    required ChainType chainType,
    int page = 1,
    int limit = 20,
  });
}

/// Send Transaction Use Case
@injectable
class SendTransaction
    implements UseCase<TransactionEntity, SendTransactionParams> {
  final TransactionRepository _repository;

  SendTransaction(this._repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    SendTransactionParams params,
  ) async {
    if (params.fromAddress.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Sender address is required'),
      );
    }

    // Validate address
    if (params.toAddress.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Recipient address is required'),
      );
    }

    // Validate amount
    if (params.amount <= BigInt.zero) {
      return const Left(
        ValidationFailure(message: 'Amount must be greater than zero'),
      );
    }

    // Send transaction
    return await _repository.sendTransaction(
      fromAddress: params.fromAddress,
      toAddress: params.toAddress,
      amount: params.amount,
      chainType: params.chainType,
      contractAddress: params.contractAddress,
      data: params.data,
      gasLimit: params.gasLimit,
      gasPrice: params.gasPrice,
    );
  }
}

/// Parameters for SendTransaction use case
class SendTransactionParams extends Equatable {
  final String fromAddress;
  final String toAddress;
  final BigInt amount;
  final ChainType chainType;
  final String? contractAddress;
  final String? data;
  final BigInt? gasLimit;
  final BigInt? gasPrice;

  const SendTransactionParams({
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.chainType,
    this.contractAddress,
    this.data,
    this.gasLimit,
    this.gasPrice,
  });

  @override
  List<Object?> get props => [
    fromAddress,
    toAddress,
    amount,
    chainType,
    contractAddress,
    data,
    gasLimit,
    gasPrice,
  ];
}

/// Estimate Gas Use Case
@injectable
class EstimateGas implements UseCase<BigInt, EstimateGasParams> {
  final TransactionRepository _repository;

  EstimateGas(this._repository);

  @override
  Future<Either<Failure, BigInt>> call(EstimateGasParams params) async {
    return await _repository.estimateGas(
      fromAddress: params.fromAddress,
      toAddress: params.toAddress,
      amount: params.amount,
      chainType: params.chainType,
      contractAddress: params.contractAddress,
      data: params.data,
    );
  }
}

/// Parameters for EstimateGas use case
class EstimateGasParams extends Equatable {
  final String fromAddress;
  final String toAddress;
  final BigInt amount;
  final ChainType chainType;
  final String? contractAddress;
  final String? data;

  const EstimateGasParams({
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.chainType,
    this.contractAddress,
    this.data,
  });

  @override
  List<Object?> get props => [
    fromAddress,
    toAddress,
    amount,
    chainType,
    contractAddress,
    data,
  ];
}
