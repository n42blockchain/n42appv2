import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/points/points_balance.dart';
import 'package:n42_chat/src/domain/entities/points/points_transaction.dart';
import 'package:n42_chat/src/domain/entities/points/redemption_item.dart';
import 'package:n42_chat/src/domain/repositories/points_repository.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_event.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_state.dart';

class MockPointsRepository extends Mock implements IPointsRepository {}

void main() {
  late MockPointsRepository mockRepository;

  const staleBalance = PointsBalance(
    userId: '@alice:server',
    roomId: '!room:server',
    totalPoints: 120,
    availablePoints: 80,
    redeemedPoints: 40,
    rank: 2,
  );

  const staleItem = RedemptionItem(
    id: 'item-1',
    name: 'VIP Badge',
    description: 'A shiny badge',
    cost: 50,
  );

  final refreshedTransaction = PointsTransaction(
    id: 'tx-1',
    userId: '@alice:server',
    roomId: '!room:server',
    type: PointsTransactionType.redeemed,
    amount: 50,
    description: 'Redeemed VIP Badge',
    createdAt: DateTime(2026, 3, 15, 10),
  );

  setUp(() {
    mockRepository = MockPointsRepository();
  });

  group('PointsBloc', () {
    blocTest<PointsBloc, PointsState>(
      'redeem success keeps success feedback even if refresh calls fail',
      setUp: () {
        when(
          () => mockRepository.redeemItem(
            userId: '@alice:server',
            roomId: '!room:server',
            itemId: 'item-1',
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getBalance('@alice:server', '!room:server'),
        ).thenThrow(Exception('balance refresh failed'));
        when(
          () => mockRepository.getTransactions(
            '@alice:server',
            '!room:server',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [refreshedTransaction]);
        when(
          () => mockRepository.getRedemptionItems('!room:server'),
        ).thenThrow(Exception('items refresh failed'));
      },
      build: () => PointsBloc(repository: mockRepository),
      seed: () => const PointsState(
        status: PointsStatus.loaded,
        balance: staleBalance,
        redemptionItems: [staleItem],
      ),
      act: (bloc) => bloc.add(
        const PointsRedeemItem(
          userId: '@alice:server',
          roomId: '!room:server',
          itemId: 'item-1',
        ),
      ),
      expect: () => [
        isA<PointsState>()
            .having(
              (s) => s.redemptionStatus,
              'redemptionStatus',
              PointsRedemptionStatus.inProgress,
            )
            .having((s) => s.redeemingItemId, 'redeemingItemId', 'item-1'),
        isA<PointsState>()
            .having((s) => s.status, 'status', PointsStatus.loaded)
            .having(
              (s) => s.redemptionStatus,
              'redemptionStatus',
              PointsRedemptionStatus.succeeded,
            )
            .having((s) => s.balance, 'balance', staleBalance)
            .having(
              (s) => s.transactions,
              'transactions',
              [refreshedTransaction],
            )
            .having((s) => s.redemptionItems, 'items', const [staleItem])
            .having((s) => s.redeemingItemId, 'redeemingItemId', isNull),
      ],
    );

    blocTest<PointsBloc, PointsState>(
      'redeem failure reports action failure without flipping the page into a load error',
      setUp: () {
        when(
          () => mockRepository.redeemItem(
            userId: '@alice:server',
            roomId: '!room:server',
            itemId: 'item-1',
          ),
        ).thenThrow(Exception('redeem failed'));
      },
      build: () => PointsBloc(repository: mockRepository),
      seed: () => const PointsState(
        status: PointsStatus.loaded,
        balance: staleBalance,
        redemptionItems: [staleItem],
      ),
      act: (bloc) => bloc.add(
        const PointsRedeemItem(
          userId: '@alice:server',
          roomId: '!room:server',
          itemId: 'item-1',
        ),
      ),
      expect: () => [
        isA<PointsState>()
            .having(
              (s) => s.redemptionStatus,
              'redemptionStatus',
              PointsRedemptionStatus.inProgress,
            ),
        isA<PointsState>()
            .having((s) => s.status, 'status', PointsStatus.loaded)
            .having(
              (s) => s.redemptionStatus,
              'redemptionStatus',
              PointsRedemptionStatus.failed,
            )
            .having((s) => s.errorMessage, 'errorMessage', isNull)
            .having(
              (s) => s.redemptionErrorMessage,
              'redemptionErrorMessage',
              contains('redeem failed'),
            ),
      ],
    );
  });
}
