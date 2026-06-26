import 'package:equatable/equatable.dart';

import 'message_entity.dart';

/// 子频道实体（群话题频道）
class ChannelEntity extends Equatable {
  /// 频道房间 ID
  final String roomId;

  /// 父群组 ID
  final String parentRoomId;

  /// 频道名称
  final String name;

  /// 频道话题（可选）
  final String? topic;

  /// 频道分类（可选）
  final String? category;

  /// 排序序号（越小越靠前）
  final int order;

  /// 未读消息数
  final int unreadCount;

  /// 最后一条消息（用于列表预览）
  final MessageEntity? lastMessage;

  const ChannelEntity({
    required this.roomId,
    required this.parentRoomId,
    required this.name,
    this.topic,
    this.category,
    this.order = 0,
    this.unreadCount = 0,
    this.lastMessage,
  });

  ChannelEntity copyWith({
    String? roomId,
    String? parentRoomId,
    String? name,
    String? topic,
    Object? category = _unset,
    int? order,
    int? unreadCount,
    MessageEntity? lastMessage,
  }) {
    return ChannelEntity(
      roomId: roomId ?? this.roomId,
      parentRoomId: parentRoomId ?? this.parentRoomId,
      name: name ?? this.name,
      topic: topic ?? this.topic,
      category: identical(category, _unset)
          ? this.category
          : category as String?,
      order: order ?? this.order,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  /// 创建代表主房间的 "General" 合成频道
  factory ChannelEntity.general(String roomId) {
    return ChannelEntity(
      roomId: roomId,
      parentRoomId: roomId,
      name: 'General',
      topic: null,
      order: -1,
    );
  }

  @override
  List<Object?> get props => [
    roomId,
    parentRoomId,
    name,
    topic,
    category,
    order,
    unreadCount,
    lastMessage,
  ];

  static const Object _unset = Object();
}
