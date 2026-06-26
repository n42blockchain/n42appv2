import '../../data/datasources/push_protocol/push_protocol_datasource.dart';
import '../../domain/entities/on_chain_notification_entity.dart';
import '../../domain/repositories/on_chain_notification_repository.dart';

/// 链上事件通知仓库实现
class OnChainNotificationRepositoryImpl
    implements IOnChainNotificationRepository {
  final PushProtocolDatasource _datasource;

  OnChainNotificationRepositoryImpl(this._datasource);

  @override
  Future<List<OnChainNotificationEntity>> fetchNotifications({
    required String walletAddress,
    int chainId = 1,
    int page = 1,
    int limit = 20,
  }) async {
    final rawList = await _datasource.fetchNotifications(
      walletAddress: walletAddress,
      chainId: chainId,
      page: page,
      limit: limit,
    );

    final readIds = await _datasource.getReadIds();

    return rawList.map((raw) {
      final entity = OnChainNotificationEntity.fromPushProtocol(raw);
      return entity.copyWith(isRead: readIds.contains(entity.id));
    }).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) =>
      _datasource.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead(List<String> notificationIds) =>
      _datasource.markAllAsRead(notificationIds);

  @override
  Future<Set<String>> getReadIds() => _datasource.getReadIds();

  @override
  Future<bool> isRead(String notificationId) async {
    final ids = await _datasource.getReadIds();
    return ids.contains(notificationId);
  }
}
