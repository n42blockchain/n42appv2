import 'package:equatable/equatable.dart';

/// 订阅周期
enum SubscriptionPeriod { monthly, yearly }

extension SubscriptionPeriodX on SubscriptionPeriod {
  Duration get duration => this == SubscriptionPeriod.yearly
      ? const Duration(days: 365)
      : const Duration(days: 30);

  String get label =>
      this == SubscriptionPeriod.yearly ? 'Yearly' : 'Monthly';
}

/// 订阅状态
enum SubscriptionStatus { active, expired, cancelled }

/// 创作者订阅计划
class SubscriptionPlan extends Equatable {
  final String id;

  /// 计划名称
  final String name;

  /// 计划描述
  final String? description;

  /// 价格（字符串，配合 [token]）
  final String price;

  /// 计价代币
  final String token;

  /// 周期
  final SubscriptionPeriod period;

  /// 创作者标识（房间/用户 id）
  final String creatorId;

  /// 创作者名称
  final String creatorName;

  /// 权益清单
  final List<String> benefits;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.token = 'USDT',
    this.period = SubscriptionPeriod.monthly,
    required this.creatorId,
    required this.creatorName,
    this.benefits = const [],
  });

  String get priceLabel => '$price $token / ${period.label}';

  SubscriptionPlan copyWith({
    String? name,
    String? description,
    String? price,
    String? token,
    SubscriptionPeriod? period,
    List<String>? benefits,
  }) {
    return SubscriptionPlan(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      token: token ?? this.token,
      period: period ?? this.period,
      creatorId: creatorId,
      creatorName: creatorName,
      benefits: benefits ?? this.benefits,
    );
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price']?.toString() ?? '0',
      token: json['token'] as String? ?? 'USDT',
      period: SubscriptionPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => SubscriptionPeriod.monthly,
      ),
      creatorId: json['creator_id'] as String? ?? '',
      creatorName: json['creator_name'] as String? ?? '',
      benefits: (json['benefits'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'token': token,
        'period': period.name,
        'creator_id': creatorId,
        'creator_name': creatorName,
        'benefits': benefits,
      };

  @override
  List<Object?> get props =>
      [id, name, description, price, token, period, creatorId, creatorName, benefits];
}

/// 用户的一条订阅记录
class UserSubscription extends Equatable {
  final String id;

  /// 订阅的计划（内嵌快照）
  final SubscriptionPlan plan;

  final DateTime subscribedAt;

  final DateTime expiresAt;

  /// 是否自动续订
  final bool autoRenew;

  /// 是否已主动取消（到期不续）
  final bool cancelled;

  /// 链上支付交易哈希（经钱包桥支付时记录，可空）
  final String? txHash;

  const UserSubscription({
    required this.id,
    required this.plan,
    required this.subscribedAt,
    required this.expiresAt,
    this.autoRenew = false,
    this.cancelled = false,
    this.txHash,
  });

  SubscriptionStatus get status {
    if (cancelled && DateTime.now().isAfter(expiresAt)) {
      return SubscriptionStatus.cancelled;
    }
    if (DateTime.now().isAfter(expiresAt)) return SubscriptionStatus.expired;
    return SubscriptionStatus.active;
  }

  bool get isActive => status == SubscriptionStatus.active;

  int get daysLeft => expiresAt.difference(DateTime.now()).inDays;

  UserSubscription copyWith({
    DateTime? expiresAt,
    bool? autoRenew,
    bool? cancelled,
    String? txHash,
  }) {
    return UserSubscription(
      id: id,
      plan: plan,
      subscribedAt: subscribedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
      cancelled: cancelled ?? this.cancelled,
      txHash: txHash ?? this.txHash,
    );
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as String,
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
      subscribedAt:
          DateTime.fromMillisecondsSinceEpoch(json['subscribed_at'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int),
      autoRenew: json['auto_renew'] as bool? ?? false,
      cancelled: json['cancelled'] as bool? ?? false,
      txHash: json['tx_hash'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan': plan.toJson(),
        'subscribed_at': subscribedAt.millisecondsSinceEpoch,
        'expires_at': expiresAt.millisecondsSinceEpoch,
        'auto_renew': autoRenew,
        'cancelled': cancelled,
        'tx_hash': txHash,
      };

  @override
  List<Object?> get props =>
      [id, plan, subscribedAt, expiresAt, autoRenew, cancelled, txHash];
}
