import 'package:equatable/equatable.dart';

/// 快捷回复实体
class QuickReplyEntity extends Equatable {
  /// 唯一标识符
  final String id;

  /// 回复内容
  final String content;

  /// 排序顺序
  final int order;

  /// 是否是系统预设
  final bool isSystem;

  /// 最后使用时间
  final DateTime? lastUsed;

  /// 创建时间
  final DateTime? createdAt;

  const QuickReplyEntity({
    required this.id,
    required this.content,
    this.order = 0,
    this.isSystem = false,
    this.lastUsed,
    this.createdAt,
  });

  /// 默认快捷回复列表
  static const List<String> defaultReplies = [
    '好的',
    '收到',
    '稍等',
    '在忙，稍后回复',
    '谢谢',
    '没问题',
  ];

  /// 创建默认快捷回复列表
  static List<QuickReplyEntity> createDefaultReplies() {
    return defaultReplies.asMap().entries.map((entry) {
      return QuickReplyEntity(
        id: 'default_${entry.key}',
        content: entry.value,
        order: entry.key,
        isSystem: true,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  /// 从JSON创建
  factory QuickReplyEntity.fromJson(Map<String, dynamic> json) {
    return QuickReplyEntity(
      id: json['id'] as String,
      content: json['content'] as String,
      order: json['order'] as int? ?? 0,
      isSystem: json['isSystem'] as bool? ?? false,
      lastUsed: json['lastUsed'] != null
          ? DateTime.tryParse(json['lastUsed'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'order': order,
      'isSystem': isSystem,
      'lastUsed': lastUsed?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 复制并修改
  QuickReplyEntity copyWith({
    String? id,
    String? content,
    int? order,
    bool? isSystem,
    DateTime? lastUsed,
    DateTime? createdAt,
  }) {
    return QuickReplyEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      order: order ?? this.order,
      isSystem: isSystem ?? this.isSystem,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, content, order, isSystem, lastUsed, createdAt];
}
