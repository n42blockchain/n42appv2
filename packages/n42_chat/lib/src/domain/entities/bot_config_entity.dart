import 'package:equatable/equatable.dart';

enum BotAutomationEventType {
  memberJoined('member_joined'),
  welcomeMessageSent('welcome_message_sent');

  final String wireValue;

  const BotAutomationEventType(this.wireValue);

  static BotAutomationEventType? fromWireValue(String? value) {
    for (final event in values) {
      if (event.wireValue == value) {
        return event;
      }
    }
    return null;
  }
}

/// Bot 配置实体
class BotConfig extends Equatable {
  /// 是否启用 Bot
  final bool enabled;

  /// 欢迎语模板（{name} 占位符替换为新成员名字）
  final String? welcomeMessage;

  /// Webhook 回调地址
  final String? webhookUrl;

  /// Webhook 签名密钥（可选）
  final String? webhookSecret;

  /// 启用的自动化事件
  final Set<BotAutomationEventType> webhookEvents;

  const BotConfig({
    this.enabled = false,
    this.welcomeMessage,
    this.webhookUrl,
    this.webhookSecret,
    this.webhookEvents = const {},
  });

  bool get hasWebhook => webhookUrl?.trim().isNotEmpty == true;

  bool get hasAutomation =>
      (welcomeMessage?.trim().isNotEmpty == true) ||
      (hasWebhook && webhookEvents.isNotEmpty);

  bool supportsWebhookEvent(BotAutomationEventType eventType) =>
      enabled && hasWebhook && webhookEvents.contains(eventType);

  factory BotConfig.fromJson(Map<String, dynamic> json) {
    final webhookUrl = (json['webhook_url'] as String?)?.trim();
    final parsedEvents =
        (json['webhook_events'] as List<dynamic>?)
            ?.map((e) => BotAutomationEventType.fromWireValue(e as String?))
            .whereType<BotAutomationEventType>()
            .toSet() ??
        <BotAutomationEventType>{};
    return BotConfig(
      enabled: json['enabled'] as bool? ?? false,
      welcomeMessage: json['welcome_message'] as String?,
      webhookUrl: webhookUrl?.isEmpty == true ? null : webhookUrl,
      webhookSecret: (json['webhook_secret'] as String?)?.trim(),
      webhookEvents: parsedEvents.isEmpty && webhookUrl != null
          ? {
              BotAutomationEventType.memberJoined,
              BotAutomationEventType.welcomeMessageSent,
            }
          : parsedEvents,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    if (welcomeMessage != null) 'welcome_message': welcomeMessage,
    if (webhookUrl != null && webhookUrl!.trim().isNotEmpty)
      'webhook_url': webhookUrl!.trim(),
    if (webhookEvents.isNotEmpty)
      'webhook_events': webhookEvents.map((e) => e.wireValue).toList(),
  };

  BotConfig copyWith({
    bool? enabled,
    String? welcomeMessage,
    String? webhookUrl,
    String? webhookSecret,
    Set<BotAutomationEventType>? webhookEvents,
    bool clearWelcomeMessage = false,
    bool clearWebhookUrl = false,
    bool clearWebhookSecret = false,
    bool clearWebhookEvents = false,
  }) {
    return BotConfig(
      enabled: enabled ?? this.enabled,
      welcomeMessage: clearWelcomeMessage
          ? null
          : (welcomeMessage ?? this.welcomeMessage),
      webhookUrl: clearWebhookUrl ? null : (webhookUrl ?? this.webhookUrl),
      webhookSecret: clearWebhookSecret
          ? null
          : (webhookSecret ?? this.webhookSecret),
      webhookEvents: clearWebhookEvents
          ? const {}
          : (webhookEvents ?? this.webhookEvents),
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    welcomeMessage,
    webhookUrl,
    webhookSecret,
    webhookEvents,
  ];
}
