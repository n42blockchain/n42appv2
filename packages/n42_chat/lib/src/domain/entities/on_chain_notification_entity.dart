import 'package:equatable/equatable.dart';

/// 链上事件通知类型
enum OnChainNotificationType {
  transfer, // 代币转账
  nft, // NFT 铸造/转移
  defi, // DeFi 操作（清算、流动性等）
  governance, // 治理提案/投票
  security, // 安全警告
  general, // 通用公告
}

/// 链上事件通知实体
///
/// 对应 Push Protocol 通知条目，额外附带本地已读状态。
class OnChainNotificationEntity extends Equatable {
  /// 通知唯一 ID（来自 Push Protocol payload_id）
  final String id;

  /// 通知标题（从 notification.title 或 data.asub 提取）
  final String title;

  /// 通知正文（从 notification.body 或 data.amsg 提取）
  final String body;

  /// 通知图片 URL（data.aimg）
  final String? imageUrl;

  /// 操作跳转 URL（data.acta）
  final String? ctaUrl;

  /// 发送方频道地址（Push Protocol channel）
  final String channelAddress;

  /// 频道显示名称（从 notification.title 的 "Channel - Subject" 格式提取）
  final String channelName;

  /// 通知时间戳
  final DateTime timestamp;

  /// 通知分类
  final OnChainNotificationType type;

  /// 是否已读（本地状态，存储在 SharedPreferences）
  final bool isRead;

  /// 来源链标识（e.g. "ETH_MAINNET", "POLYGON_MAINNET"）
  final String source;

  const OnChainNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.ctaUrl,
    required this.channelAddress,
    required this.channelName,
    required this.timestamp,
    this.type = OnChainNotificationType.general,
    this.isRead = false,
    this.source = '',
  });

  OnChainNotificationEntity copyWith({bool? isRead}) {
    return OnChainNotificationEntity(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      ctaUrl: ctaUrl,
      channelAddress: channelAddress,
      channelName: channelName,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
      source: source,
    );
  }

  /// 从 Push Protocol API 响应条目构建
  factory OnChainNotificationEntity.fromPushProtocol(
    Map<String, dynamic> json,
  ) {
    final sender = json['sender']?.toString() ?? '';
    final epochStr = json['epoch']?.toString() ?? '';
    final payload = json['payload'] as Map<String, dynamic>? ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? {};
    final notification = payload['notification'] as Map<String, dynamic>? ?? {};
    final source = json['source']?.toString() ?? '';

    // 解析时间戳
    final timestamp = DateTime.tryParse(epochStr) ?? DateTime.now();

    // 标题优先用 notification.title，回退到 data.asub
    final notifTitle = (notification['title'] as String? ?? '').trim();
    final sub = (data['asub'] as String? ?? '').trim();
    final title = notifTitle.isNotEmpty ? notifTitle : sub;

    // 正文优先用 notification.body，回退到 data.amsg
    final notifBody = (notification['body'] as String? ?? '').trim();
    final amsg = (data['amsg'] as String? ?? '').trim();
    final body = notifBody.isNotEmpty ? notifBody : amsg;
    final payloadId =
        (json['payload_id'] ?? json['payloadId'])?.toString() ?? '';
    final fallbackId = '$sender|$epochStr|$title|$body';

    // CTA URL
    final acta = (data['acta'] as String? ?? '').trim();
    final ctaUrl = acta.isNotEmpty && acta != 'dapp' ? acta : null;

    // Image URL
    final aimg = (data['aimg'] as String? ?? '').trim();
    final imageUrl = aimg.isNotEmpty ? aimg : null;

    // 从 "Channel - Subject" 格式提取频道名
    String channelName = sender;
    if (notifTitle.contains(' - ')) {
      channelName = notifTitle.split(' - ').first.trim();
    }

    return OnChainNotificationEntity(
      id: payloadId.isNotEmpty ? payloadId : fallbackId,
      title: title.isEmpty ? 'On-chain Notification' : title,
      body: body,
      imageUrl: imageUrl,
      ctaUrl: ctaUrl,
      channelAddress: sender,
      channelName: channelName.isEmpty ? sender : channelName,
      timestamp: timestamp,
      type: _inferType(title, body),
      source: source,
    );
  }

  static OnChainNotificationType _inferType(String title, String body) {
    final text = '$title $body'.toLowerCase();
    if (text.contains('transfer') ||
        text.contains('sent') ||
        text.contains('received') ||
        text.contains('transaction')) {
      return OnChainNotificationType.transfer;
    }
    if (text.contains('nft') ||
        text.contains('mint') ||
        text.contains('collectible') ||
        text.contains('token id')) {
      return OnChainNotificationType.nft;
    }
    if (text.contains('liquidat') ||
        text.contains('yield') ||
        text.contains('liquidity') ||
        text.contains('defi') ||
        text.contains('swap') ||
        text.contains('borrow') ||
        text.contains('lend')) {
      return OnChainNotificationType.defi;
    }
    if (text.contains('governance') ||
        text.contains('vote') ||
        text.contains('proposal') ||
        text.contains('dao')) {
      return OnChainNotificationType.governance;
    }
    if (text.contains('security') ||
        text.contains('warning') ||
        text.contains('alert') ||
        text.contains('suspicious') ||
        text.contains('hack')) {
      return OnChainNotificationType.security;
    }
    return OnChainNotificationType.general;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    channelAddress,
    timestamp,
    isRead,
  ];
}
