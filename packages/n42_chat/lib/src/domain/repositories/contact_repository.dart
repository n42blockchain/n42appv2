import '../entities/contact_entity.dart';

/// 联系人仓库接口
abstract class IContactRepository {
  /// 获取所有联系人
  Future<List<ContactEntity>> getContacts();

  /// 监听联系人列表变化
  Stream<List<ContactEntity>> watchContacts();

  /// 根据ID获取联系人
  Future<ContactEntity?> getContactById(String userId);

  /// 搜索联系人
  Future<List<ContactEntity>> searchContacts(String query);

  /// 搜索用户（全局搜索）
  Future<List<ContactEntity>> searchUsers(String query, {int limit = 20});

  /// 获取或创建与用户的私聊
  Future<String> startDirectChat(String userId);

  /// 获取与用户的私聊房间ID
  String? getDirectChatRoomId(String userId);

  /// 忽略用户
  Future<void> ignoreUser(String userId);

  /// 取消忽略用户
  Future<void> unignoreUser(String userId);

  /// 检查用户是否被忽略
  bool isUserIgnored(String userId);

  /// 获取被忽略的用户列表
  Future<List<ContactEntity>> getIgnoredUsers();

  /// 获取待处理的好友请求
  Future<List<FriendRequest>> getPendingFriendRequests();

  /// 接受好友请求
  Future<void> acceptFriendRequest(String requestId);

  /// 拒绝好友请求
  Future<void> rejectFriendRequest(String requestId);

  /// 获取用户在线状态
  bool isUserOnline(String userId);

  /// 获取用户最后活动时间
  DateTime? getLastActiveTime(String userId);

  /// 监听用户在线状态变化
  Stream<Map<String, bool>> watchOnlineStatus();

  /// 获取用户状态消息
  Future<String?> getUserStatusMessage(String userId);

  /// 设置当前用户的状态消息
  Future<void> setMyStatus(String? statusMessage, {Duration? expiresIn});

  /// 获取当前用户的状态消息
  Future<String?> getMyStatus();

  /// 设置联系人备注
  Future<void> setContactRemark(String userId, String? remark);

  /// 获取联系人备注
  Future<String?> getContactRemark(String userId);

  /// 获取所有联系人备注
  Future<Map<String, String>> getContactRemarks();

  /// 删除联系人
  Future<void> deleteContact(String userId);
}

/// 好友请求
class FriendRequest {
  /// 请求ID（房间ID）
  final String id;

  /// 请求者用户ID
  final String userId;

  /// 请求者名称
  final String userName;

  /// 请求者头像
  final String? userAvatarUrl;

  /// 请求时间
  final DateTime? requestTime;

  /// 请求消息
  final String? message;

  const FriendRequest({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.requestTime,
    this.message,
  });
}
