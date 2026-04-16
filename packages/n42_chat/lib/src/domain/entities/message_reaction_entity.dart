import 'package:equatable/equatable.dart';

/// 消息反应（Emoji）实体
class MessageReactionEntity extends Equatable {
  /// 反应的emoji
  final String emoji;

  /// 发送该反应的用户ID列表
  final List<String> userIds;

  /// 发送该反应的用户名称列表
  final List<String> userNames;

  /// 总数
  int get count => userIds.length;

  const MessageReactionEntity({
    required this.emoji,
    this.userIds = const [],
    this.userNames = const [],
  });

  /// 当前用户是否已添加此反应
  bool hasReacted(String userId) => userIds.contains(userId);

  /// 获取显示的用户名
  String get displayUsers {
    if (userNames.isEmpty) return '';
    if (userNames.length <= 3) {
      return userNames.join('、');
    }
    return '${userNames.take(3).join('、')} 等${userNames.length}人';
  }

  @override
  List<Object?> get props => [emoji, userIds, userNames];

  MessageReactionEntity copyWith({
    String? emoji,
    List<String>? userIds,
    List<String>? userNames,
  }) {
    return MessageReactionEntity(
      emoji: emoji ?? this.emoji,
      userIds: userIds ?? this.userIds,
      userNames: userNames ?? this.userNames,
    );
  }

  /// 添加用户反应
  MessageReactionEntity addUser(String userId, String userName) {
    if (userIds.contains(userId)) return this;
    return copyWith(
      userIds: [...userIds, userId],
      userNames: [...userNames, userName],
    );
  }

  /// 移除用户反应
  MessageReactionEntity removeUser(String userId) {
    final index = userIds.indexOf(userId);
    if (index == -1) return this;

    final newUserIds = [...userIds]..removeAt(index);
    final newUserNames = [...userNames];
    if (index < newUserNames.length) {
      newUserNames.removeAt(index);
    }

    return copyWith(
      userIds: newUserIds,
      userNames: newUserNames,
    );
  }
}

/// 常用emoji列表
class CommonEmojis {
  static const List<String> reactions = [
    '👍', // 赞
    '❤️', // 爱心
    '😄', // 笑
    '😮', // 惊讶
    '😢', // 难过
    '😠', // 愤怒
    '🎉', // 庆祝
    '🤔', // 思考
    '👎', // 踩
  ];

  static const List<String> extendedReactions = [
    '👍', '❤️', '😄', '😮', '😢', '😠', '🎉', '🤔',
    '👎', '🙏', '💯', '🔥', '👏', '😂', '🥰', '😎',
    '🤣', '😍', '😘', '😊', '😉', '🙄', '😴', '🤮',
    '💪', '✨', '⭐', '🌟', '💖', '💕', '💓', '💗',
  ];
}

