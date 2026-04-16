import 'package:equatable/equatable.dart';

/// 关键词过滤动作
enum FilterAction {
  /// 将匹配内容替换为 ***
  replace,

  /// 完全隐藏消息
  hide,
}

enum SensitiveDataType { email, phoneNumber, creditCard, walletAddress }

/// 关键词过滤配置
class ContentFilterConfig extends Equatable {
  /// 是否启用
  final bool enabled;

  /// 禁止词列表
  final List<String> forbiddenWords;

  /// 过滤动作
  final FilterAction action;

  /// 内置敏感信息检测类型
  final List<SensitiveDataType> sensitiveDataTypes;

  const ContentFilterConfig({
    this.enabled = false,
    this.forbiddenWords = const [],
    this.action = FilterAction.replace,
    this.sensitiveDataTypes = const [],
  });

  factory ContentFilterConfig.fromJson(Map<String, dynamic> json) {
    final actionStr = json['action'] as String? ?? 'replace';
    return ContentFilterConfig(
      enabled: json['enabled'] as bool? ?? false,
      forbiddenWords: (json['forbidden_words'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .map((word) => word.trim())
          .where((word) => word.isNotEmpty)
          .toList(),
      action: actionStr == 'hide' ? FilterAction.hide : FilterAction.replace,
      sensitiveDataTypes:
          (json['sensitive_data_types'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .map(_sensitiveDataTypeFromJson)
              .whereType<SensitiveDataType>()
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'forbidden_words': forbiddenWords,
    'action': action == FilterAction.hide ? 'hide' : 'replace',
    'sensitive_data_types': sensitiveDataTypes
        .map(_sensitiveDataTypeToJson)
        .toList(),
  };

  ContentFilterConfig copyWith({
    bool? enabled,
    List<String>? forbiddenWords,
    FilterAction? action,
    List<SensitiveDataType>? sensitiveDataTypes,
  }) {
    return ContentFilterConfig(
      enabled: enabled ?? this.enabled,
      forbiddenWords: forbiddenWords ?? this.forbiddenWords,
      action: action ?? this.action,
      sensitiveDataTypes: sensitiveDataTypes ?? this.sensitiveDataTypes,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    forbiddenWords,
    action,
    sensitiveDataTypes,
  ];
}

SensitiveDataType? _sensitiveDataTypeFromJson(String raw) {
  switch (raw) {
    case 'email':
      return SensitiveDataType.email;
    case 'phone_number':
      return SensitiveDataType.phoneNumber;
    case 'credit_card':
      return SensitiveDataType.creditCard;
    case 'wallet_address':
      return SensitiveDataType.walletAddress;
    default:
      return null;
  }
}

String _sensitiveDataTypeToJson(SensitiveDataType type) {
  switch (type) {
    case SensitiveDataType.email:
      return 'email';
    case SensitiveDataType.phoneNumber:
      return 'phone_number';
    case SensitiveDataType.creditCard:
      return 'credit_card';
    case SensitiveDataType.walletAddress:
      return 'wallet_address';
  }
}
