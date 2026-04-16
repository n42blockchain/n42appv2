import 'package:equatable/equatable.dart';

/// 联系人事件基类
abstract class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

/// 加载联系人列表
class LoadContacts extends ContactEvent {
  const LoadContacts();
}

/// 刷新联系人列表
class RefreshContacts extends ContactEvent {
  const RefreshContacts();
}

/// 搜索联系人
class SearchContacts extends ContactEvent {
  final String query;

  const SearchContacts(this.query);

  @override
  List<Object?> get props => [query];
}

/// 搜索用户（全局搜索）
class SearchUsers extends ContactEvent {
  final String query;
  final int limit;

  const SearchUsers(this.query, {this.limit = 20});

  @override
  List<Object?> get props => [query, limit];
}

/// 清除搜索
class ClearSearch extends ContactEvent {
  const ClearSearch();
}

/// 开始与用户聊天
class StartChat extends ContactEvent {
  final String userId;

  const StartChat(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 忽略用户
class IgnoreUser extends ContactEvent {
  final String userId;

  const IgnoreUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 取消忽略用户
class UnignoreUser extends ContactEvent {
  final String userId;

  const UnignoreUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 加载好友请求
class LoadFriendRequests extends ContactEvent {
  const LoadFriendRequests();
}

/// 接受好友请求
class AcceptFriendRequest extends ContactEvent {
  final String requestId;

  const AcceptFriendRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// 拒绝好友请求
class RejectFriendRequest extends ContactEvent {
  final String requestId;

  const RejectFriendRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// 联系人列表更新
class ContactsUpdated extends ContactEvent {
  const ContactsUpdated();
}

/// 在线状态更新
class OnlineStatusUpdated extends ContactEvent {
  final Map<String, bool> statusMap;

  const OnlineStatusUpdated(this.statusMap);

  @override
  List<Object?> get props => [statusMap];
}

/// 设置联系人备注
class SetContactRemark extends ContactEvent {
  final String userId;
  final String? remark;

  const SetContactRemark(this.userId, this.remark);

  @override
  List<Object?> get props => [userId, remark];
}

/// 删除联系人
class DeleteContact extends ContactEvent {
  final String userId;

  const DeleteContact(this.userId);

  @override
  List<Object?> get props => [userId];
}

