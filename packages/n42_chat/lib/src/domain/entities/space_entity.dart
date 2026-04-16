import 'package:equatable/equatable.dart';

/// Space 类型
enum SpaceType {
  /// 公开社区
  public,
  /// 私有社区
  private,
}

/// Space 子房间类型
enum SpaceChildType {
  /// 频道（群聊）
  channel,
  /// 子 Space
  subSpace,
}

/// Space（社区）实体
///
/// 映射 Matrix Spaces 协议 (m.space)
/// 一个 Space 可以包含多个频道/房间和子 Space
class SpaceEntity extends Equatable {
  /// Space 的 Matrix 房间 ID
  final String id;

  /// 社区名称
  final String name;

  /// 社区描述
  final String? description;

  /// 社区头像 URL
  final String? avatarUrl;

  /// 社区类型
  final SpaceType type;

  /// 社区创建者 ID
  final String creatorId;

  /// 成员数量
  final int memberCount;

  /// 子房间列表
  final List<SpaceChild> children;

  /// 是否已加入
  final bool isJoined;

  /// 社区主题/标签
  final List<String> topics;

  /// 创建时间
  final DateTime createdAt;

  /// 父 Space ID（如果是子 Space）
  final String? parentSpaceId;

  const SpaceEntity({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.type = SpaceType.public,
    required this.creatorId,
    this.memberCount = 0,
    this.children = const [],
    this.isJoined = false,
    this.topics = const [],
    required this.createdAt,
    this.parentSpaceId,
  });

  /// 频道数量
  int get channelCount => children.where((c) => c.type == SpaceChildType.channel).length;

  /// 子 Space 数量
  int get subSpaceCount => children.where((c) => c.type == SpaceChildType.subSpace).length;

  /// 是否是子 Space
  bool get isSubSpace => parentSpaceId != null;

  SpaceEntity copyWith({
    String? name,
    String? description,
    String? avatarUrl,
    SpaceType? type,
    int? memberCount,
    List<SpaceChild>? children,
    bool? isJoined,
    List<String>? topics,
  }) {
    return SpaceEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
      creatorId: creatorId,
      memberCount: memberCount ?? this.memberCount,
      children: children ?? this.children,
      isJoined: isJoined ?? this.isJoined,
      topics: topics ?? this.topics,
      createdAt: createdAt,
      parentSpaceId: parentSpaceId,
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, avatarUrl, type,
        creatorId, memberCount, children, isJoined,
        topics, createdAt, parentSpaceId,
      ];
}

/// Space 子元素（频道或子 Space）
class SpaceChild extends Equatable {
  /// 房间/Space 的 Matrix ID
  final String roomId;

  /// 名称
  final String name;

  /// 头像 URL
  final String? avatarUrl;

  /// 类型
  final SpaceChildType type;

  /// 描述
  final String? description;

  /// 成员数
  final int memberCount;

  /// 排序权重
  final int order;

  /// 是否建议加入（recommended）
  final bool isSuggested;

  const SpaceChild({
    required this.roomId,
    required this.name,
    this.avatarUrl,
    required this.type,
    this.description,
    this.memberCount = 0,
    this.order = 0,
    this.isSuggested = false,
  });

  @override
  List<Object?> get props => [
        roomId, name, avatarUrl, type,
        description, memberCount, order, isSuggested,
      ];
}
