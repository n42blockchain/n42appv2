import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:n42_wallet/features/wallet/domain/usecases/send_transaction.dart';

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository(this.transaction);

  final TransactionEntity transaction;
  String? lastFromAddress;
  String? lastToAddress;
  BigInt? lastAmount;
  ChainType? lastChainType;
  String? lastContractAddress;
  String? lastData;
  BigInt? lastGasLimit;
  BigInt? lastGasPrice;
  String? gasEstimateFromAddress;
  String? gasEstimateToAddress;
  BigInt? gasEstimateAmount;
  ChainType? gasEstimateChainType;

  @override
  Future<Either<Failure, BigInt>> estimateGas({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required ChainType chainType,
    String? contractAddress,
    String? data,
  }) async {
    gasEstimateFromAddress = fromAddress;
    gasEstimateToAddress = toAddress;
    gasEstimateAmount = amount;
    gasEstimateChainType = chainType;
    return Right(BigInt.from(21000));
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(
    String txHash,
  ) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory({
    required String address,
    required ChainType chainType,
    int page = 1,
    int limit = 20,
  }) async => throw UnimplementedError();

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
    lastFromAddress = fromAddress;
    lastToAddress = toAddress;
    lastAmount = amount;
    lastChainType = chainType;
    lastContractAddress = contractAddress;
    lastData = data;
    lastGasLimit = gasLimit;
    lastGasPrice = gasPrice;
    return Right(transaction);
  }
}

void main() {
  group('SendTransaction use case', () {
    late TransactionEntity transaction;
    late FakeTransactionRepository repository;
    late SendTransaction useCase;

    setUp(() {
      transaction = TransactionEntity(
        hash: '0xtx',
        from: '0xfrom',
        to: '0xto',
        value: BigInt.one,
        timestamp: DateTime(2026, 3, 16),
        status: TransactionStatus.pending,
      );
      repository = FakeTransactionRepository(transaction);
      useCase = SendTransaction(repository);
    });

    test('rejects empty sender address before repository call', () async {
      final result = await useCase(
        SendTransactionParams(
          fromAddress: '',
          toAddress: '0xto',
          amount: BigInt.one,
          chainType: ChainType.ethereum,
        ),
      );

      expect(
        result,
        const Left(ValidationFailure(message: 'Sender address is required')),
      );
      expect(repository.lastFromAddress, isNull);
    });

    test('passes validated transaction params to repository', () async {
      final result = await useCase(
        SendTransactionParams(
          fromAddress: '0xfrom',
          toAddress: '0xto',
          amount: BigInt.from(42),
          chainType: ChainType.solana,
          contractAddress: '0xcontract',
          data: '0xdeadbeef',
          gasLimit: BigInt.from(65000),
          gasPrice: BigInt.from(20),
        ),
      );

      expect(result.isRight(), isTrue);
      expect(repository.lastFromAddress, '0xfrom');
      expect(repository.lastToAddress, '0xto');
      expect(repository.lastAmount, BigInt.from(42));
      expect(repository.lastChainType, ChainType.solana);
      expect(repository.lastContractAddress, '0xcontract');
      expect(repository.lastData, '0xdeadbeef');
      expect(repository.lastGasLimit, BigInt.from(65000));
      expect(repository.lastGasPrice, BigInt.from(20));
      result.fold((_) => fail('expected success'), (value) {
        expect(value, same(transaction));
      });
    });
  });

  group('EstimateGas use case', () {
    test('passes params to repository unchanged', () async {
      final repository = FakeTransactionRepository(
        TransactionEntity(
          hash: '0xtx',
          from: '0xfrom',
          to: '0xto',
          value: BigInt.one,
          timestamp: DateTime(2026, 3, 16),
          status: TransactionStatus.pending,
        ),
      );
      final useCase = EstimateGas(repository);

      final result = await useCase(
        EstimateGasParams(
          fromAddress: '0xfrom',
          toAddress: '0xto',
          amount: BigInt.from(7),
          chainType: ChainType.tron,
          contractAddress: 'TContract',
          data: '0x01',
        ),
      );

      expect(result, Right(BigInt.from(21000)));
      expect(repository.gasEstimateFromAddress, '0xfrom');
      expect(repository.gasEstimateToAddress, '0xto');
      expect(repository.gasEstimateAmount, BigInt.from(7));
      expect(repository.gasEstimateChainType, ChainType.tron);
    });
  });
}
