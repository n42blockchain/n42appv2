import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42_wallet/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:n42_wallet/features/wallet/domain/usecases/create_wallet.dart';

class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository(this.wallet);

  final WalletEntity wallet;
  String? lastName;
  String? lastPassword;
  ChainType? lastChainType;

  @override
  Future<Either<Failure, WalletEntity>> createWallet({
    required String name,
    required String password,
    required ChainType chainType,
  }) async {
    lastName = name;
    lastPassword = password;
    lastChainType = chainType;
    return Right(wallet);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
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
  Future<Either<Failure, List<AssetEntity>>> getAssets({
    required String address,
    ChainType? chainType,
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
}

void main() {
  group('CreateWallet use case', () {
    late WalletEntity wallet;
    late FakeWalletRepository repository;
    late CreateWallet useCase;

    setUp(() {
      wallet = WalletEntity(
        id: 'wallet-1',
        name: 'Primary',
        address: '0x123',
        chainType: 'solana',
        createdAt: DateTime(2026, 3, 16),
      );
      repository = FakeWalletRepository(wallet);
      useCase = CreateWallet(repository);
    });

    test('passes validated params to wallet feature repository', () async {
      final result = await useCase(
        const CreateWalletParams(
          name: 'Primary',
          password: 'password123',
          chainType: ChainType.solana,
        ),
      );

      expect(result.isRight(), isTrue);
      expect(repository.lastName, 'Primary');
      expect(repository.lastPassword, 'password123');
      expect(repository.lastChainType, ChainType.solana);
      result.fold((_) => fail('expected success'), (value) {
        expect(value, same(wallet));
        expect(value.chainType, 'solana');
      });
    });

    test('rejects empty wallet name before repository call', () async {
      final result = await useCase(
        const CreateWalletParams(name: '', password: 'password123'),
      );

      expect(
        result,
        const Left(ValidationFailure(message: 'Wallet name cannot be empty')),
      );
      expect(repository.lastName, isNull);
    });

    test('rejects wallet names longer than 12 chars', () async {
      final result = await useCase(
        const CreateWalletParams(
          name: 'VeryLongWallet',
          password: 'password123',
        ),
      );

      expect(
        result,
        const Left(
          ValidationFailure(message: 'Wallet name cannot exceed 12 characters'),
        ),
      );
      expect(repository.lastName, isNull);
    });

    test('rejects passwords shorter than 8 chars', () async {
      final result = await useCase(
        const CreateWalletParams(name: 'Primary', password: 'pass123'),
      );

      expect(
        result,
        const Left(
          ValidationFailure(message: 'Password must be at least 8 characters'),
        ),
      );
      expect(repository.lastName, isNull);
    });
  });
}
