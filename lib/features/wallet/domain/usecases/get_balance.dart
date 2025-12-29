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

/// Get Balance Use Case
///
/// Retrieves the balance for all assets in a wallet.
@injectable
class GetBalance implements UseCase<List<AssetEntity>, GetBalanceParams> {
  final WalletRepository _repository;

  GetBalance(this._repository);

  @override
  Future<Either<Failure, List<AssetEntity>>> call(GetBalanceParams params) async {
    final result = await _repository.getAssets(
      address: params.address,
      chainType: params.chainType,
    );

    return result.map((assets) => assets.map((asset) => AssetEntity(
      symbol: asset.symbol,
      name: asset.name,
      balance: asset.balance,
      decimals: asset.decimals,
      chainType: params.chainType?.name ?? 'ethereum',
      contractAddress: asset.contractAddress,
      iconUrl: asset.iconUrl,
      isNative: asset.isNative,
      priceUsd: asset.priceUsd,
    )).toList());
  }
}

/// Parameters for GetBalance use case
class GetBalanceParams extends Equatable {
  /// Wallet address
  final String address;

  /// Optional chain type filter
  final ChainType? chainType;

  const GetBalanceParams({
    required this.address,
    this.chainType,
  });

  @override
  List<Object?> get props => [address, chainType];
}

