import 'package:equatable/equatable.dart';

abstract class OnChainNotificationEvent extends Equatable {
  const OnChainNotificationEvent();
}

/// 加载第一页通知
class LoadOnChainNotifications extends OnChainNotificationEvent {
  const LoadOnChainNotifications();

  @override
  List<Object?> get props => [];
}

/// 下拉刷新（重新加载第一页）
class RefreshOnChainNotifications extends OnChainNotificationEvent {
  const RefreshOnChainNotifications();

  @override
  List<Object?> get props => [];
}

/// 加载下一页（分页）
class LoadMoreOnChainNotifications extends OnChainNotificationEvent {
  const LoadMoreOnChainNotifications();

  @override
  List<Object?> get props => [];
}

/// 标记单条通知为已读
class MarkOnChainNotificationRead extends OnChainNotificationEvent {
  final String notificationId;

  const MarkOnChainNotificationRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// 标记全部通知为已读
class MarkAllOnChainNotificationsRead extends OnChainNotificationEvent {
  const MarkAllOnChainNotificationsRead();

  @override
  List<Object?> get props => [];
}
