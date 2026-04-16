import 'package:equatable/equatable.dart';

/// 订阅计划
class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.token,
    required this.intervalSeconds,
    this.description,
    this.creatorId,
    this.roomId,
    this.maxSubscribers,
    this.benefits = const [],
  });

  final String id;
  final String name;
  final String amount;
  final String token;

  /// 付款间隔（秒）。0 表示一次性；86400 = 日付；2592000 ≈ 月付。
  final int intervalSeconds;
  final String? description;
  final String? creatorId;
  final String? roomId;
  final int? maxSubscribers;
  final List<String> benefits;

  bool get isRecurring => intervalSeconds > 0;

  String get intervalLabel {
    if (intervalSeconds <= 0) return '一次性';
    if (intervalSeconds <= 86400) return '每日';
    if (intervalSeconds <= 604800) return '每周';
    if (intervalSeconds <= 2592000) return '每月';
    return '每年';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'token': token,
        'interval_seconds': intervalSeconds,
        'description': description,
        'creator_id': creatorId,
        'room_id': roomId,
        'max_subscribers': maxSubscribers,
        'benefits': benefits,
      };

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        amount: json['amount'] as String? ?? '0',
        token: json['token'] as String? ?? 'ETH',
        intervalSeconds: json['interval_seconds'] as int? ?? 0,
        description: json['description'] as String?,
        creatorId: json['creator_id'] as String?,
        roomId: json['room_id'] as String?,
        maxSubscribers: json['max_subscribers'] as int?,
        benefits: (json['benefits'] as List?)?.cast<String>() ?? const [],
      );

  @override
  List<Object?> get props => [
        id, name, amount, token, intervalSeconds,
        description, creatorId, roomId, maxSubscribers, benefits,
      ];
}

/// 用户订阅记录
class UserSubscription extends Equatable {
  const UserSubscription({
    required this.id,
    required this.planId,
    required this.subscriberId,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    this.streamContractAddress,
    this.cancelledAt,
    this.txHash,
  });

  final String id;
  final String planId;
  final String subscriberId;
  final SubscriptionStatus status;
  final DateTime startedAt;
  final DateTime? expiresAt;

  /// Superfluid/Sablier 流式合约地址（链上订阅专用）。
  final String? streamContractAddress;
  final DateTime? cancelledAt;
  final String? txHash;

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_id': planId,
        'subscriber_id': subscriberId,
        'status': status.name,
        'started_at': startedAt.millisecondsSinceEpoch,
        'expires_at': expiresAt?.millisecondsSinceEpoch,
        'stream_contract_address': streamContractAddress,
        'cancelled_at': cancelledAt?.millisecondsSinceEpoch,
        'tx_hash': txHash,
      };

  factory UserSubscription.fromJson(Map<String, dynamic> json) =>
      UserSubscription(
        id: json['id'] as String,
        planId: json['plan_id'] as String,
        subscriberId: json['subscriber_id'] as String,
        status: SubscriptionStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SubscriptionStatus.pending,
        ),
        startedAt: DateTime.fromMillisecondsSinceEpoch(
            json['started_at'] as int),
        expiresAt: json['expires_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int)
            : null,
        streamContractAddress: json['stream_contract_address'] as String?,
        cancelledAt: json['cancelled_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json['cancelled_at'] as int)
            : null,
        txHash: json['tx_hash'] as String?,
      );

  @override
  List<Object?> get props => [
        id, planId, subscriberId, status, startedAt,
        expiresAt, streamContractAddress, cancelledAt, txHash,
      ];
}

enum SubscriptionStatus {
  pending,
  active,
  paused,
  cancelled,
  expired,
}
