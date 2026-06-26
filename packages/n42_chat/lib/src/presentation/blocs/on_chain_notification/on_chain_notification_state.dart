import 'package:equatable/equatable.dart';

import '../../../domain/entities/on_chain_notification_entity.dart';

enum OnChainNotificationStatus {
  initial,
  loading,
  refreshing,
  loadingMore,
  success,
  failure,
}

class OnChainNotificationState extends Equatable {
  final List<OnChainNotificationEntity> notifications;
  final OnChainNotificationStatus status;

  /// 是否还有更多页（分页）
  final bool hasMore;

  /// 当前已加载的页码
  final int currentPage;

  /// 错误信息
  final String? errorMessage;

  const OnChainNotificationState({
    this.notifications = const [],
    this.status = OnChainNotificationStatus.initial,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  /// 未读通知数量
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  bool get isLoading => status == OnChainNotificationStatus.loading;
  bool get isRefreshing => status == OnChainNotificationStatus.refreshing;
  bool get isLoadingMore => status == OnChainNotificationStatus.loadingMore;

  OnChainNotificationState copyWith({
    List<OnChainNotificationEntity>? notifications,
    OnChainNotificationStatus? status,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnChainNotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const OnChainNotificationState initial = OnChainNotificationState();

  @override
  List<Object?> get props =>
      [notifications, status, hasMore, currentPage, errorMessage];
}
