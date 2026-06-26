import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/points_repository.dart';
import 'points_event.dart';
import 'points_state.dart';

/// BLoC that manages points / rewards state.
///
/// Delegates all data operations to [IPointsRepository] and maps
/// events to states following the standard loading / loaded / error
/// lifecycle.
class PointsBloc extends Bloc<PointsEvent, PointsState> {
  final IPointsRepository _repository;

  PointsBloc({required IPointsRepository repository})
      : _repository = repository,
        super(const PointsState()) {
    on<PointsLoadBalance>(_onLoadBalance);
    on<PointsLoadTransactions>(_onLoadTransactions);
    on<PointsLoadLeaderboard>(_onLoadLeaderboard);
    on<PointsLoadConfig>(_onLoadConfig);
    on<PointsUpdateConfig>(_onUpdateConfig);
    on<PointsLoadRedemptionItems>(_onLoadRedemptionItems);
    on<PointsRedeemItem>(_onRedeemItem);
    on<PointsClearRedemptionFeedback>(_onClearRedemptionFeedback);
  }

  Future<void> _onLoadBalance(
    PointsLoadBalance event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(
      balanceStatus: PointsLoadStatus.loading,
      balanceErrorMessage: null,
    ));
    try {
      final balance = await _repository.getBalance(
        event.userId,
        event.roomId,
      );
      emit(state.copyWith(
        balance: balance,
        balanceStatus: PointsLoadStatus.loaded,
        balanceErrorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        balanceStatus: PointsLoadStatus.error,
        balanceErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTransactions(
    PointsLoadTransactions event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(
      transactionsStatus: PointsLoadStatus.loading,
      transactionsErrorMessage: null,
    ));
    try {
      final transactions = await _repository.getTransactions(
        event.userId,
        event.roomId,
      );
      emit(state.copyWith(
        transactions: transactions,
        transactionsStatus: PointsLoadStatus.loaded,
        transactionsErrorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        transactionsStatus: PointsLoadStatus.error,
        transactionsErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadLeaderboard(
    PointsLoadLeaderboard event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(
      leaderboardStatus: PointsLoadStatus.loading,
      leaderboardErrorMessage: null,
    ));
    try {
      final leaderboard = await _repository.getLeaderboard(event.roomId);
      emit(state.copyWith(
        leaderboard: leaderboard,
        leaderboardStatus: PointsLoadStatus.loaded,
        leaderboardErrorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        leaderboardStatus: PointsLoadStatus.error,
        leaderboardErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadConfig(
    PointsLoadConfig event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(status: PointsStatus.loading));
    try {
      final config = await _repository.getConfig(event.roomId);
      emit(state.copyWith(
        status: PointsStatus.loaded,
        config: config,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PointsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateConfig(
    PointsUpdateConfig event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(status: PointsStatus.loading));
    try {
      await _repository.updateConfig(event.config);
      emit(state.copyWith(
        status: PointsStatus.loaded,
        config: event.config,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PointsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadRedemptionItems(
    PointsLoadRedemptionItems event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(
      redemptionItemsStatus: PointsLoadStatus.loading,
      redemptionItemsErrorMessage: null,
    ));
    try {
      final items = await _repository.getRedemptionItems(event.roomId);
      emit(state.copyWith(
        redemptionItems: items,
        redemptionItemsStatus: PointsLoadStatus.loaded,
        redemptionItemsErrorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        redemptionItemsStatus: PointsLoadStatus.error,
        redemptionItemsErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRedeemItem(
    PointsRedeemItem event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(
      redemptionStatus: PointsRedemptionStatus.inProgress,
      redeemingItemId: event.itemId,
      redemptionErrorMessage: null,
    ));
    try {
      await _repository.redeemItem(
        userId: event.userId,
        roomId: event.roomId,
        itemId: event.itemId,
      );
    } catch (e) {
      emit(state.copyWith(
        redemptionStatus: PointsRedemptionStatus.failed,
        redeemingItemId: null,
        redemptionErrorMessage: e.toString(),
      ));
      return;
    }

    var balance = state.balance;
    var transactions = state.transactions;
    var items = state.redemptionItems;
    var balanceRefreshSucceeded = false;
    var transactionsRefreshSucceeded = false;
    var itemsRefreshSucceeded = false;

    try {
      balance = await _repository.getBalance(event.userId, event.roomId);
      balanceRefreshSucceeded = true;
    } catch (_) {}

    try {
      transactions = await _repository.getTransactions(
        event.userId,
        event.roomId,
      );
      transactionsRefreshSucceeded = true;
    } catch (_) {}

    try {
      items = await _repository.getRedemptionItems(event.roomId);
      itemsRefreshSucceeded = true;
    } catch (_) {}

    emit(state.copyWith(
      status: PointsStatus.loaded,
      balance: balance,
      balanceStatus: balanceRefreshSucceeded
          ? PointsLoadStatus.loaded
          : state.balanceStatus,
      balanceErrorMessage:
          balanceRefreshSucceeded ? null : state.balanceErrorMessage,
      transactions: transactions,
      transactionsStatus: transactionsRefreshSucceeded
          ? PointsLoadStatus.loaded
          : state.transactionsStatus,
      transactionsErrorMessage:
          transactionsRefreshSucceeded ? null : state.transactionsErrorMessage,
      redemptionItems: items,
      redemptionItemsStatus: itemsRefreshSucceeded
          ? PointsLoadStatus.loaded
          : state.redemptionItemsStatus,
      redemptionItemsErrorMessage: itemsRefreshSucceeded
          ? null
          : state.redemptionItemsErrorMessage,
      redemptionStatus: PointsRedemptionStatus.succeeded,
      redeemingItemId: null,
      redemptionErrorMessage: null,
    ));
  }

  Future<void> _onClearRedemptionFeedback(
    PointsClearRedemptionFeedback event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(
      redemptionStatus: PointsRedemptionStatus.idle,
      redeemingItemId: null,
      redemptionErrorMessage: null,
    ));
  }
}
