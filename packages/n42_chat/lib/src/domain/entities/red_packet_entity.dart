/// Distribution strategy: equal split vs random amounts.
enum RedPacketType {
  normal, // Equal amount per packet
  lucky,  // Random amounts, total is fixed
}

/// Lifecycle state of a red packet.
enum RedPacketLifecycle {
  active,    // Still has unclaimed slots and not expired
  completed, // All packets claimed
  expired,   // 24-hour window passed with remaining packets (auto-refund)
}

/// A single red packet event sent in a chat room.
class RedPacketEntity {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String greeting;
  final RedPacketType type;
  final double totalAmount;
  final int totalCount;
  final String token;

  /// Hex color string for the packet cover, e.g. '#E64340'.
  final String coverColor;

  final List<RedPacketClaim> claims;
  final DateTime createdAt;

  /// Red packets auto-expire 24 h after creation; remaining amount is refunded.
  final DateTime expiresAt;

  const RedPacketEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.greeting,
    required this.type,
    required this.totalAmount,
    required this.totalCount,
    required this.token,
    this.coverColor = '#E64340',
    required this.claims,
    required this.createdAt,
    required this.expiresAt,
  });

  // ─── Computed properties ────────────────────────────────────────────────────

  double get claimedAmount => claims.fold(0.0, (s, c) => s + c.amount);
  int get claimedCount => claims.length;
  int get remainingCount => totalCount - claims.length;
  double get remainingAmount => totalAmount - claimedAmount;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isCompleted => remainingCount <= 0;

  RedPacketLifecycle get lifecycle {
    if (isCompleted) return RedPacketLifecycle.completed;
    if (isExpired) return RedPacketLifecycle.expired;
    return RedPacketLifecycle.active;
  }

  /// The claim with the highest amount — the social "best luck" winner.
  /// Only meaningful when there are at least 2 claims (lucky packets).
  RedPacketClaim? get bestLuckClaim {
    if (claims.length < 2) return null;
    return claims.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  /// Whether the given [userId] holds the best-luck position.
  bool isClaimBestLuck(String userId) {
    final best = bestLuckClaim;
    return best != null && best.userId == userId;
  }

  // ─── Serialization ──────────────────────────────────────────────────────────

  factory RedPacketEntity.fromJson(Map<String, dynamic> json) {
    return RedPacketEntity(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? '',
      senderAvatar: json['sender_avatar'] as String?,
      greeting: json['greeting'] as String? ?? '',
      type: (json['type'] as String?) == 'lucky'
          ? RedPacketType.lucky
          : RedPacketType.normal,
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalCount: json['total_count'] as int,
      token: json['token'] as String? ?? 'CNY',
      coverColor: json['cover_color'] as String? ?? '#E64340',
      claims: (json['claims'] as List<dynamic>? ?? [])
          .map((c) => RedPacketClaim.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ?? DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_avatar': senderAvatar,
        'greeting': greeting,
        'type': type.name,
        'total_amount': totalAmount,
        'total_count': totalCount,
        'token': token,
        'cover_color': coverColor,
        'claims': claims.map((c) => c.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      };
}

/// One user's claim record within a red packet.
class RedPacketClaim {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final double amount;
  final DateTime claimedAt;

  const RedPacketClaim({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.amount,
    required this.claimedAt,
  });

  factory RedPacketClaim.fromJson(Map<String, dynamic> json) {
    return RedPacketClaim(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      amount: (json['amount'] as num).toDouble(),
      claimedAt: DateTime.tryParse(json['claimed_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'avatar_url': avatarUrl,
        'amount': amount,
        'claimed_at': claimedAt.toIso8601String(),
      };
}
