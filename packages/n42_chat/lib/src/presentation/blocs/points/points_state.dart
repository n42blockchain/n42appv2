import 'package:equatable/equatable.dart';

import '../../../domain/entities/points/points_balance.dart';
import '../../../domain/entities/points/points_config.dart';
import '../../../domain/entities/points/points_transaction.dart';
import '../../../domain/entities/points/redemption_item.dart';

/// The loading lifecycle of the points feature.
enum PointsStatus {
  /// No data has been requested yet.
  initial,

  /// A request is in flight.
  loading,

  /// Data has been successfully loaded.
  loaded,

  /// An error occurred during the last request.
  error,

  /// A redemption is being processed.
  redeeming,

  /// A redemption completed successfully.
  redeemed,
}

/// Slice loading lifecycle for independent points views.
enum PointsLoadStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Action lifecycle for a redemption request.
enum PointsRedemptionStatus {
  idle,
  inProgress,
  succeeded,
  failed,
}

const _pointsUnset = Object();

/// Immutable state for the [PointsBloc].
class PointsState extends Equatable {
  /// Current loading status.
  final PointsStatus status;

  /// The user's points balance in the current room.
  final PointsBalance? balance;

  /// Load state for the current user's balance.
  final PointsLoadStatus balanceStatus;

  /// Balance-specific error message.
  final String? balanceErrorMessage;

  /// Recent transaction history.
  final List<PointsTransaction> transactions;

  /// Load state for the current user's transaction list.
  final PointsLoadStatus transactionsStatus;

  /// Transaction-specific error message.
  final String? transactionsErrorMessage;

  /// Room leaderboard entries.
  final List<PointsBalance> leaderboard;

  /// Load state for leaderboard data.
  final PointsLoadStatus leaderboardStatus;

  /// Leaderboard-specific error message.
  final String? leaderboardErrorMessage;

  /// Points system configuration for the room.
  final PointsConfig? config;

  /// Available redemption items.
  final List<RedemptionItem> redemptionItems;

  /// Load state for redemption catalog data.
  final PointsLoadStatus redemptionItemsStatus;

  /// Redemption-catalog specific error message.
  final String? redemptionItemsErrorMessage;

  /// Human-readable error message when [status] is [PointsStatus.error].
  final String? errorMessage;

  /// One-shot state for redemption feedback.
  final PointsRedemptionStatus redemptionStatus;

  /// The item currently being redeemed.
  final String? redeemingItemId;

  /// Human-readable redemption failure message.
  final String? redemptionErrorMessage;

  const PointsState({
    this.status = PointsStatus.initial,
    this.balance,
    this.balanceStatus = PointsLoadStatus.initial,
    this.balanceErrorMessage,
    this.transactions = const [],
    this.transactionsStatus = PointsLoadStatus.initial,
    this.transactionsErrorMessage,
    this.leaderboard = const [],
    this.leaderboardStatus = PointsLoadStatus.initial,
    this.leaderboardErrorMessage,
    this.config,
    this.redemptionItems = const [],
    this.redemptionItemsStatus = PointsLoadStatus.initial,
    this.redemptionItemsErrorMessage,
    this.errorMessage,
    this.redemptionStatus = PointsRedemptionStatus.idle,
    this.redeemingItemId,
    this.redemptionErrorMessage,
  });

  /// Convenience getter for checking loading state.
  bool get isLoading => status == PointsStatus.loading;

  PointsState copyWith({
    PointsStatus? status,
    PointsBalance? balance,
    PointsLoadStatus? balanceStatus,
    Object? balanceErrorMessage = _pointsUnset,
    List<PointsTransaction>? transactions,
    PointsLoadStatus? transactionsStatus,
    Object? transactionsErrorMessage = _pointsUnset,
    List<PointsBalance>? leaderboard,
    PointsLoadStatus? leaderboardStatus,
    Object? leaderboardErrorMessage = _pointsUnset,
    PointsConfig? config,
    List<RedemptionItem>? redemptionItems,
    PointsLoadStatus? redemptionItemsStatus,
    Object? redemptionItemsErrorMessage = _pointsUnset,
    String? errorMessage,
    PointsRedemptionStatus? redemptionStatus,
    Object? redeemingItemId = _pointsUnset,
    Object? redemptionErrorMessage = _pointsUnset,
  }) {
    return PointsState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      balanceErrorMessage: balanceErrorMessage == _pointsUnset
          ? this.balanceErrorMessage
          : balanceErrorMessage as String?,
      transactions: transactions ?? this.transactions,
      transactionsStatus: transactionsStatus ?? this.transactionsStatus,
      transactionsErrorMessage: transactionsErrorMessage == _pointsUnset
          ? this.transactionsErrorMessage
          : transactionsErrorMessage as String?,
      leaderboard: leaderboard ?? this.leaderboard,
      leaderboardStatus: leaderboardStatus ?? this.leaderboardStatus,
      leaderboardErrorMessage: leaderboardErrorMessage == _pointsUnset
          ? this.leaderboardErrorMessage
          : leaderboardErrorMessage as String?,
      config: config ?? this.config,
      redemptionItems: redemptionItems ?? this.redemptionItems,
      redemptionItemsStatus: redemptionItemsStatus ?? this.redemptionItemsStatus,
      redemptionItemsErrorMessage: redemptionItemsErrorMessage == _pointsUnset
          ? this.redemptionItemsErrorMessage
          : redemptionItemsErrorMessage as String?,
      errorMessage: errorMessage,
      redemptionStatus: redemptionStatus ?? this.redemptionStatus,
      redeemingItemId: redeemingItemId == _pointsUnset
          ? this.redeemingItemId
          : redeemingItemId as String?,
      redemptionErrorMessage: redemptionErrorMessage == _pointsUnset
          ? this.redemptionErrorMessage
          : redemptionErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        balance,
        balanceStatus,
        balanceErrorMessage,
        transactions,
        transactionsStatus,
        transactionsErrorMessage,
        leaderboard,
        leaderboardStatus,
        leaderboardErrorMessage,
        config,
        redemptionItems,
        redemptionItemsStatus,
        redemptionItemsErrorMessage,
        errorMessage,
        redemptionStatus,
        redeemingItemId,
        redemptionErrorMessage,
      ];
}
