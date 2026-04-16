import '../../domain/entities/red_packet_entity.dart';

/// 红包服务接口
///
/// 管理红包的创建、领取、状态查询和历史记录。
/// 当前使用本地实现作为过渡方案，最终需要后端/智能合约支持。
abstract class IRedPacketService {
  /// 创建红包
  Future<RedPacketEntity> createRedPacket({
    required String roomId,
    required double totalAmount,
    required int totalCount,
    required String token,
    required RedPacketType type,
    required String greeting,
    required String senderId,
    required String senderName,
    String? senderAvatar,
  });

  /// 领取红包
  ///
  /// 返回领取结果（包含金额），已领取或已过期返回 null。
  Future<RedPacketClaim?> claimRedPacket({
    required String redPacketId,
    required String userId,
    required String userName,
    String? avatarUrl,
  });

  /// 查询红包状态
  Future<RedPacketEntity?> getRedPacketStatus(String redPacketId);

  /// 获取红包历史
  Future<List<RedPacketEntity>> getRedPacketHistory({
    String? roomId,
    String? userId,
    int limit = 50,
  });

  /// 检查用户是否已领取
  bool hasUserClaimed(RedPacketEntity redPacket, String userId) {
    return redPacket.claims.any((c) => c.userId == userId);
  }
}
