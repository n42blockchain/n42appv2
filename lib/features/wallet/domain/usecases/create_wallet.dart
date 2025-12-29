// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../domain/repositories/wallet_repository.dart';
import '../entities/wallet_entity.dart';

// Re-export ChainType for convenience
export '../entities/wallet_entity.dart' show ChainType;

/// Create Wallet Use Case
///
/// Creates a new HD wallet with the given parameters.
/// Returns the created wallet entity or a failure.
@injectable
class CreateWallet implements UseCase<WalletEntity, CreateWalletParams> {
  final WalletRepository _repository;

  CreateWallet(this._repository);

  @override
  Future<Either<Failure, WalletEntity>> call(CreateWalletParams params) async {
    // Validate wallet name
    if (params.name.isEmpty) {
      return const Left(ValidationFailure(message: 'Wallet name cannot be empty'));
    }

    if (params.name.length > 12) {
      return const Left(ValidationFailure(message: 'Wallet name cannot exceed 12 characters'));
    }

    // Validate password
    if (params.password.length < 8) {
      return const Left(ValidationFailure(message: 'Password must be at least 8 characters'));
    }

    // Create wallet through repository
    final result = await _repository.createWallet(
      name: params.name,
      password: params.password,
      chainType: params.chainType,
    );

    return result.map((wallet) => WalletEntity(
      id: wallet.id,
      name: wallet.name,
      address: wallet.address,
      chainType: wallet.chainType.name,
      createdAt: wallet.createdAt,
      isHD: wallet.isHD,
      derivationPath: wallet.derivationPath,
      index: wallet.index,
    ));
  }
}

/// Parameters for CreateWallet use case
class CreateWalletParams extends Equatable {
  /// Wallet name
  final String name;

  /// Wallet password for encryption
  final String password;

  /// Chain type to create wallet for
  final ChainType chainType;

  const CreateWalletParams({
    required this.name,
    required this.password,
    this.chainType = ChainType.ethereum,
  });

  @override
  List<Object?> get props => [name, password, chainType];
}

