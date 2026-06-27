import 'dart:convert';

import 'package:equatable/equatable.dart';

/// 智能过滤判定结果
enum NotificationFilterDecision {
  /// 命中优先规则：强制通知，绕过「仅提及/静音/免打扰」
  priority,

  /// 命中屏蔽规则：抑制通知
  muted,

  /// 未命中任何规则：按常规逻辑处理
  neutral,
}

/// 客户端智能通知过滤规则（优先关键词/屏蔽关键词/优先发送者）
///
/// 纯数据 + 纯判定，无 IO，便于单测。持久化由
/// `NotificationFilterStore` 负责。
class NotificationFilterRules extends Equatable {
  /// 优先关键词：消息正文命中即强制通知（即使会话设为仅提及/静音/免打扰）
  final List<String> priorityKeywords;

  /// 屏蔽关键词：消息正文命中即抑制通知
  final List<String> mutedKeywords;

  /// 优先发送者（Matrix userId）：其消息强制通知
  final List<String> prioritySenders;

  /// 关键词是否区分大小写（默认否）
  final bool caseSensitive;

  const NotificationFilterRules({
    this.priorityKeywords = const [],
    this.mutedKeywords = const [],
    this.prioritySenders = const [],
    this.caseSensitive = false,
  });

  static const NotificationFilterRules empty = NotificationFilterRules();

  /// 是否没有任何规则（用于快速跳过判定）
  bool get isEmpty =>
      !_hasAnyNonBlank(priorityKeywords) &&
      !_hasAnyNonBlank(mutedKeywords) &&
      !_hasAnyNonBlank(prioritySenders);

  /// 判定一条消息。优先规则高于屏蔽规则。
  ///
  /// [body] 消息正文，[senderId] 发送者 userId。
  NotificationFilterDecision evaluate({
    required String body,
    String? senderId,
  }) {
    if (isEmpty) return NotificationFilterDecision.neutral;

    // 优先发送者
    final normalizedSenderId = senderId?.trim();
    if (normalizedSenderId != null &&
        normalizedSenderId.isNotEmpty &&
        prioritySenders.any((sender) => sender.trim() == normalizedSenderId)) {
      return NotificationFilterDecision.priority;
    }

    final haystack = caseSensitive ? body : body.toLowerCase();

    bool matchesAny(List<String> keywords) {
      for (final raw in keywords) {
        final kw = raw.trim();
        if (kw.isEmpty) continue;
        final needle = caseSensitive ? kw : kw.toLowerCase();
        if (haystack.contains(needle)) return true;
      }
      return false;
    }

    if (matchesAny(priorityKeywords)) {
      return NotificationFilterDecision.priority;
    }
    if (matchesAny(mutedKeywords)) {
      return NotificationFilterDecision.muted;
    }
    return NotificationFilterDecision.neutral;
  }

  NotificationFilterRules copyWith({
    List<String>? priorityKeywords,
    List<String>? mutedKeywords,
    List<String>? prioritySenders,
    bool? caseSensitive,
  }) {
    return NotificationFilterRules(
      priorityKeywords: priorityKeywords ?? this.priorityKeywords,
      mutedKeywords: mutedKeywords ?? this.mutedKeywords,
      prioritySenders: prioritySenders ?? this.prioritySenders,
      caseSensitive: caseSensitive ?? this.caseSensitive,
    );
  }

  Map<String, dynamic> toJson() => {
    'priorityKeywords': priorityKeywords,
    'mutedKeywords': mutedKeywords,
    'prioritySenders': prioritySenders,
    'caseSensitive': caseSensitive,
  };

  factory NotificationFilterRules.fromJson(Map<String, dynamic> json) {
    List<String> readList(Object? value) {
      final seen = <String>{};
      final result = <String>[];
      final list = value is List<dynamic> ? value : const <dynamic>[];
      for (final item in list) {
        if (item is! String) continue;
        final trimmed = item.trim();
        if (trimmed.isEmpty || !seen.add(trimmed)) continue;
        result.add(trimmed);
      }
      return result;
    }

    return NotificationFilterRules(
      priorityKeywords: readList(json['priorityKeywords']),
      mutedKeywords: readList(json['mutedKeywords']),
      prioritySenders: readList(json['prioritySenders']),
      caseSensitive: json['caseSensitive'] as bool? ?? false,
    );
  }

  static bool _hasAnyNonBlank(List<String> values) =>
      values.any((value) => value.trim().isNotEmpty);

  String encode() => jsonEncode(toJson());

  static NotificationFilterRules decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return NotificationFilterRules.fromJson(decoded);
      }
    } catch (_) {
      // 损坏的存储 → 回退空规则
    }
    return empty;
  }

  @override
  List<Object?> get props => [
    priorityKeywords,
    mutedKeywords,
    prioritySenders,
    caseSensitive,
  ];
}
