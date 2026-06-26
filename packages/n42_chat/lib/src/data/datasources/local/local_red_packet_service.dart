import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/red_packet_service.dart';
import '../../../domain/entities/red_packet_entity.dart';

/// 本地红包服务实现（过渡方案）
///
/// 使用 SharedPreferences 存储红包状态。
/// Lucky 红包使用二倍均值随机算法，Normal 红包等额拆分。
/// 24h 自动过期机制。
class LocalRedPacketService extends IRedPacketService {
  static const _storageKey = 'n42_red_packets';
  final _random = Random();

  @override
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
  }) async {
    final now = DateTime.now();
    final redPacket = RedPacketEntity(
      id: 'rp_${now.millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      greeting: greeting,
      type: type,
      totalAmount: totalAmount,
      totalCount: totalCount,
      token: token,
      claims: const [],
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );

    await _saveRedPacket(redPacket);
    return redPacket;
  }

  @override
  Future<RedPacketClaim?> claimRedPacket({
    required String redPacketId,
    required String userId,
    required String userName,
    String? avatarUrl,
  }) async {
    final redPacket = await getRedPacketStatus(redPacketId);
    if (redPacket == null) return null;

    // 检查是否已过期或已领完
    if (redPacket.isExpired || redPacket.isCompleted) return null;

    // 检查是否已领取过
    if (redPacket.claims.any((c) => c.userId == userId)) return null;

    // 计算领取金额
    final amount = _calculateClaimAmount(redPacket);

    final claim = RedPacketClaim(
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
      amount: amount,
      claimedAt: DateTime.now(),
    );

    // 更新红包状态
    final updatedClaims = [...redPacket.claims, claim];
    final updatedRedPacket = RedPacketEntity(
      id: redPacket.id,
      roomId: redPacket.roomId,
      senderId: redPacket.senderId,
      senderName: redPacket.senderName,
      senderAvatar: redPacket.senderAvatar,
      greeting: redPacket.greeting,
      type: redPacket.type,
      totalAmount: redPacket.totalAmount,
      totalCount: redPacket.totalCount,
      token: redPacket.token,
      coverColor: redPacket.coverColor,
      claims: updatedClaims,
      createdAt: redPacket.createdAt,
      expiresAt: redPacket.expiresAt,
    );

    await _saveRedPacket(updatedRedPacket);
    return claim;
  }

  /// 二倍均值随机算法（微信红包算法）
  ///
  /// 使用整数分（cents）计算避免浮点精度误差。
  /// 每次随机范围为 [1 cent, remainingCents / remainingCount * 2]
  double _calculateClaimAmount(RedPacketEntity redPacket) {
    if (redPacket.type == RedPacketType.normal) {
      // 等额拆分：用整数分计算后转回元
      final totalCents = (redPacket.totalAmount * 100).round();
      final perCents = totalCents ~/ redPacket.totalCount;
      return perCents / 100.0;
    }

    // Lucky 红包 - 二倍均值算法（整数分计算）
    final remainingCents = (redPacket.remainingAmount * 100).round();
    final remainingCount = redPacket.remainingCount;

    if (remainingCount == 1) {
      // 最后一个人拿走剩余
      return remainingCents / 100.0;
    }

    final maxCents = (remainingCents ~/ remainingCount) * 2;
    const minCents = 1; // 最少 0.01 元
    final amountCents = minCents + _random.nextInt(maxCents - minCents + 1);
    return amountCents / 100.0;
  }

  @override
  Future<RedPacketEntity?> getRedPacketStatus(String redPacketId) async {
    final all = await _loadAllRedPackets();
    return all[redPacketId];
  }

  @override
  Future<List<RedPacketEntity>> getRedPacketHistory({
    String? roomId,
    String? userId,
    int limit = 50,
  }) async {
    final all = await _loadAllRedPackets();
    var list = all.values.toList();

    if (roomId != null) {
      list = list.where((rp) => rp.roomId == roomId).toList();
    }
    if (userId != null) {
      list = list.where((rp) =>
        rp.senderId == userId ||
        rp.claims.any((c) => c.userId == userId),
      ).toList();
    }

    // 按创建时间倒序
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).toList();
  }

  // ─── Storage helpers ──────────────────────────────────────────────────────

  Future<Map<String, RedPacketEntity>> _loadAllRedPackets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return {};

    final map = json.decode(raw) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(
      key,
      RedPacketEntity.fromJson(value as Map<String, dynamic>),
    ));
  }

  Future<void> _saveRedPacket(RedPacketEntity redPacket) async {
    final all = await _loadAllRedPackets();
    all[redPacket.id] = redPacket;

    // 清理过期超过 7 天的红包
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    all.removeWhere((_, rp) => rp.expiresAt.isBefore(cutoff));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      json.encode(all.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }
}
