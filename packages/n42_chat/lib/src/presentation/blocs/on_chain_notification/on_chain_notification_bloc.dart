import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/on_chain_notification_repository.dart';
import '../../../integration/wallet_bridge.dart';
import 'on_chain_notification_event.dart';
import 'on_chain_notification_state.dart';

/// 链上事件通知 BLoC
///
/// 负责从 Push Protocol 加载、分页和标记已读。
/// 需要 [IWalletBridge] 提供当前钱包地址。
class OnChainNotificationBloc
    extends Bloc<OnChainNotificationEvent, OnChainNotificationState> {
  final IOnChainNotificationRepository _repository;
  final IWalletBridge _walletBridge;
  final int _chainId;

  static const int _pageSize = 20;

  OnChainNotificationBloc({
    required IOnChainNotificationRepository repository,
    required IWalletBridge walletBridge,
    int chainId = 1,
  })  : _repository = repository,
        _walletBridge = walletBridge,
        _chainId = chainId,
        super(OnChainNotificationState.initial) {
    on<LoadOnChainNotifications>(_onLoad);
    on<RefreshOnChainNotifications>(_onRefresh);
    on<LoadMoreOnChainNotifications>(_onLoadMore);
    on<MarkOnChainNotificationRead>(_onMarkRead);
    on<MarkAllOnChainNotificationsRead>(_onMarkAllRead);
  }

  String? get _walletAddress => _walletBridge.walletAddress;

  Future<void> _onLoad(
    LoadOnChainNotifications event,
    Emitter<OnChainNotificationState> emit,
  ) async {
    if (_walletAddress == null) {
      emit(state.copyWith(
        status: OnChainNotificationStatus.failure,
        errorMessage: 'Wallet not connected',
      ));
      return;
    }

    emit(state.copyWith(status: OnChainNotificationStatus.loading, clearError: true));
    try {
      final notifications = await _repository.fetchNotifications(
        walletAddress: _walletAddress!,
        chainId: _chainId,
        page: 1,
        limit: _pageSize,
      );
      emit(state.copyWith(
        status: OnChainNotificationStatus.success,
        notifications: notifications,
        currentPage: 1,
        hasMore: notifications.length >= _pageSize,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OnChainNotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefresh(
    RefreshOnChainNotifications event,
    Emitter<OnChainNotificationState> emit,
  ) async {
    if (_walletAddress == null) return;

    emit(state.copyWith(status: OnChainNotificationStatus.refreshing));
    try {
      final notifications = await _repository.fetchNotifications(
        walletAddress: _walletAddress!,
        chainId: _chainId,
        page: 1,
        limit: _pageSize,
      );
      emit(state.copyWith(
        status: OnChainNotificationStatus.success,
        notifications: notifications,
        currentPage: 1,
        hasMore: notifications.length >= _pageSize,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OnChainNotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreOnChainNotifications event,
    Emitter<OnChainNotificationState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore || _walletAddress == null) return;

    emit(state.copyWith(status: OnChainNotificationStatus.loadingMore));
    try {
      final nextPage = state.currentPage + 1;
      final more = await _repository.fetchNotifications(
        walletAddress: _walletAddress!,
        chainId: _chainId,
        page: nextPage,
        limit: _pageSize,
      );
      emit(state.copyWith(
        status: OnChainNotificationStatus.success,
        notifications: [...state.notifications, ...more],
        currentPage: nextPage,
        hasMore: more.length >= _pageSize,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OnChainNotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMarkRead(
    MarkOnChainNotificationRead event,
    Emitter<OnChainNotificationState> emit,
  ) async {
    await _repository.markAsRead(event.notificationId);
    final updated = state.notifications.map((n) {
      return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(state.copyWith(notifications: updated));
  }

  Future<void> _onMarkAllRead(
    MarkAllOnChainNotificationsRead event,
    Emitter<OnChainNotificationState> emit,
  ) async {
    final unreadIds =
        state.notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    await _repository.markAllAsRead(unreadIds);
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updated));
  }
}
