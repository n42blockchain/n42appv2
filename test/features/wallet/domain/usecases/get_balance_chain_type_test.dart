import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42_wallet/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:n42_wallet/features/wallet/domain/usecases/get_balance.dart';

class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository(this.assets);

  final List<AssetEntity> assets;

  @override
  Future<Either<Failure, List<AssetEntity>>> getAssets({
    required String address,
    ChainType? chainType,
  }) async {
    return Right(assets);
  }

  @override
  Future<Either<Failure, WalletEntity>> createWallet({
    required String name,
    required String password,
    required ChainType chainType,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteWallet(String address) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String>> exportMnemonic({
    required String address,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> exportPrivateKey({
    required String address,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, WalletEntity?>> getWalletByAddress(
    String address,
  ) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<WalletEntity>>> getWallets() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, AssetEntity?>> getTokenBalance({
    required String address,
    required String tokenAddress,
    required ChainType chainType,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, WalletEntity>> importFromMnemonic({
    required String mnemonic,
    required String name,
    required String password,
    required ChainType chainType,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, WalletEntity>> importFromPrivateKey({
    required String privateKey,
    required String name,
    required String password,
    required ChainType chainType,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, WalletEntity>> updateWalletName({
    required String address,
    required String newName,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> verifyPassword({
    required String address,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> changePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  }) async => throw UnimplementedError();
}

void main() {
  group('GetBalance chain type mapping', () {
    test(
      'preserves per-asset chainType when params.chainType is null',
      () async {
        final useCase = GetBalance(
          FakeWalletRepository([
            AssetEntity(
              symbol: 'SOL',
              name: 'Solana',
              balance: BigInt.one,
              decimals: 9,
              chainType: 'solana',
              isNative: true,
            ),
            AssetEntity(
              symbol: 'ETH',
              name: 'Ethereum',
              balance: BigInt.one,
              decimals: 18,
              chainType: 'ethereum',
              isNative: true,
            ),
          ]),
        );

        final result = await useCase(const GetBalanceParams(address: '0xabc'));

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected success'), (assets) {
          expect(assets[0].chainType, 'solana');
          expect(assets[1].chainType, 'ethereum');
        });
      },
    );

    test(
      'uses requested chainType when params.chainType is provided',
      () async {
        final useCase = GetBalance(
          FakeWalletRepository([
            AssetEntity(
              symbol: 'ETH',
              name: 'Ethereum',
              balance: BigInt.one,
              decimals: 18,
              chainType: 'ignored-original',
              isNative: true,
            ),
          ]),
        );

        final result = await useCase(
          const GetBalanceParams(
            address: '0xabc',
            chainType: ChainType.ethereum,
          ),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('expected success'),
          (assets) => expect(assets.single.chainType, 'ethereum'),
        );
      },
    );
  });
}
