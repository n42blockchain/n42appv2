import '../entities/on_chain_notification_entity.dart';

/// 链上事件通知仓库接口
abstract class IOnChainNotificationRepository {
  /// 从 Push Protocol 拉取钱包地址的通知列表
  ///
  /// [walletAddress] 钱包地址（EVM 格式，带 0x 前缀）
  /// [chainId] 链 ID（默认 1 = 以太坊主网）
  /// [page] 分页页码（从 1 开始）
  /// [limit] 每页条数（最大 20）
  Future<List<OnChainNotificationEntity>> fetchNotifications({
    required String walletAddress,
    int chainId = 1,
    int page = 1,
    int limit = 20,
  });

  /// 将指定通知标记为已读（本地持久化）
  Future<void> markAsRead(String notificationId);

  /// 批量标记为已读
  Future<void> markAllAsRead(List<String> notificationIds);

  /// 获取已读通知 ID 集合
  Future<Set<String>> getReadIds();

  /// 检查某条通知是否已读
  Future<bool> isRead(String notificationId);
}
