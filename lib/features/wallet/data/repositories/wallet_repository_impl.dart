// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/core/error/exceptions.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42_wallet/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:n42_wallet/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:n42_wallet/features/wallet/data/datasources/wallet_remote_datasource.dart';

/// Wallet Repository Implementation
///
/// Coordinates between local and remote data sources.
class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource _localDataSource;
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._localDataSource, this._remoteDataSource);

  // ─── Error-handling guards ──────────────────────────────────────────────────

  /// Local operations that may throw [CacheException].
  Future<Either<Failure, T>> _guardCache<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  /// Local operations that may throw [CacheException] or [AuthException].
  Future<Either<Failure, T>> _guardCacheAuth<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  /// Remote operations that may throw [ServerException] or [NetworkException].
  Future<Either<Failure, T>> _guardRemote<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // ─── Wallet CRUD ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, WalletEntity>> createWallet({
    required String name,
    required String password,
    required ChainType chainType,
  }) =>
      _guardCache(() => _localDataSource.createWallet(
            name: name, password: password, chainType: chainType));

  @override
  Future<Either<Failure, WalletEntity>> importFromMnemonic({
    required String mnemonic,
    required String name,
    required String password,
    required ChainType chainType,
  }) =>
      _guardCache(() => _localDataSource.importFromMnemonic(
            mnemonic: mnemonic, name: name, password: password, chainType: chainType));

  @override
  Future<Either<Failure, WalletEntity>> importFromPrivateKey({
    required String privateKey,
    required String name,
    required String password,
    required ChainType chainType,
  }) =>
      _guardCache(() => _localDataSource.importFromPrivateKey(
            privateKey: privateKey, name: name, password: password, chainType: chainType));

  @override
  Future<Either<Failure, List<WalletEntity>>> getWallets() =>
      _guardCache(() => _localDataSource.getWallets());

  @override
  Future<Either<Failure, WalletEntity?>> getWalletByAddress(String address) =>
      _guardCache(() => _localDataSource.getWalletByAddress(address));

  @override
  Future<Either<Failure, void>> deleteWallet(String address) =>
      _guardCache(() => _localDataSource.deleteWallet(address));

  @override
  Future<Either<Failure, WalletEntity>> updateWalletName({
    required String address,
    required String newName,
  }) =>
      _guardCache(() => _localDataSource.updateWalletName(
            address: address, newName: newName));

  @override
  Future<Either<Failure, bool>> verifyPassword({
    required String address,
    required String password,
  }) =>
      _guardCache(() => _localDataSource.verifyPassword(
            address: address, password: password));

  // ─── Asset queries (remote) ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<AssetEntity>>> getAssets({
    required String address,
    ChainType? chainType,
  }) =>
      _guardRemote(() => _remoteDataSource.getAssets(
            address: address, chainType: chainType));

  @override
  Future<Either<Failure, AssetEntity?>> getTokenBalance({
    required String address,
    required String tokenAddress,
    required ChainType chainType,
  }) =>
      _guardRemote(() => _remoteDataSource.getTokenBalance(
            address: address, tokenAddress: tokenAddress, chainType: chainType));

  // ─── Auth-sensitive operations ──────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> exportMnemonic({
    required String address,
    required String password,
  }) =>
      _guardCacheAuth(() => _localDataSource.exportMnemonic(
            address: address, password: password));

  @override
  Future<Either<Failure, String>> exportPrivateKey({
    required String address,
    required String password,
  }) =>
      _guardCacheAuth(() => _localDataSource.exportPrivateKey(
            address: address, password: password));

  @override
  Future<Either<Failure, void>> changePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  }) =>
      _guardCacheAuth(() => _localDataSource.changePassword(
            address: address, oldPassword: oldPassword, newPassword: newPassword));
}

