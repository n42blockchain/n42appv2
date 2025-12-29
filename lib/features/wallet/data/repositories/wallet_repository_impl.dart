// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:n42appv2/core/error/failures.dart';
import 'package:n42appv2/core/error/exceptions.dart';
import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42appv2/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:n42appv2/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:n42appv2/features/wallet/data/datasources/wallet_remote_datasource.dart';

/// Wallet Repository Implementation
///
/// Coordinates between local and remote data sources.
@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource _localDataSource;
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, WalletEntity>> createWallet({
    required String name,
    required String password,
    required ChainType chainType,
  }) async {
    try {
      final wallet = await _localDataSource.createWallet(
        name: name,
        password: password,
        chainType: chainType,
      );
      return Right(wallet);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> importFromMnemonic({
    required String mnemonic,
    required String name,
    required String password,
    required ChainType chainType,
  }) async {
    try {
      final wallet = await _localDataSource.importFromMnemonic(
        mnemonic: mnemonic,
        name: name,
        password: password,
        chainType: chainType,
      );
      return Right(wallet);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> importFromPrivateKey({
    required String privateKey,
    required String name,
    required String password,
    required ChainType chainType,
  }) async {
    try {
      final wallet = await _localDataSource.importFromPrivateKey(
        privateKey: privateKey,
        name: name,
        password: password,
        chainType: chainType,
      );
      return Right(wallet);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WalletEntity>>> getWallets() async {
    try {
      final wallets = await _localDataSource.getWallets();
      return Right(wallets);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity?>> getWalletByAddress(String address) async {
    try {
      final wallet = await _localDataSource.getWalletByAddress(address);
      return Right(wallet);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AssetEntity>>> getAssets({
    required String address,
    ChainType? chainType,
  }) async {
    try {
      final assets = await _remoteDataSource.getAssets(
        address: address,
        chainType: chainType,
      );
      return Right(assets);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssetEntity?>> getTokenBalance({
    required String address,
    required String tokenAddress,
    required ChainType chainType,
  }) async {
    try {
      final asset = await _remoteDataSource.getTokenBalance(
        address: address,
        tokenAddress: tokenAddress,
        chainType: chainType,
      );
      return Right(asset);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWallet(String address) async {
    try {
      await _localDataSource.deleteWallet(address);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> updateWalletName({
    required String address,
    required String newName,
  }) async {
    try {
      final wallet = await _localDataSource.updateWalletName(
        address: address,
        newName: newName,
      );
      return Right(wallet);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportMnemonic({
    required String address,
    required String password,
  }) async {
    try {
      final mnemonic = await _localDataSource.exportMnemonic(
        address: address,
        password: password,
      );
      return Right(mnemonic);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportPrivateKey({
    required String address,
    required String password,
  }) async {
    try {
      final privateKey = await _localDataSource.exportPrivateKey(
        address: address,
        password: password,
      );
      return Right(privateKey);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPassword({
    required String address,
    required String password,
  }) async {
    try {
      final isValid = await _localDataSource.verifyPassword(
        address: address,
        password: password,
      );
      return Right(isValid);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _localDataSource.changePassword(
        address: address,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

