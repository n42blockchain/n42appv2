import 'package:equatable/equatable.dart';

/// 在线状态
enum PresenceStatus {
  /// 在线
  online,
  /// 离线
  offline,
  /// 忙碌
  unavailable,
}

final _whitespaceRegExp = RegExp(r'\s+');
final _upperLetterRegExp = RegExp(r'[A-Z]');

/// 联系人实体
///
/// 表示通讯录中的一个联系人
class ContactEntity extends Equatable {
  /// Matrix用户ID
  final String userId;

  /// 显示名称
  final String displayName;

  /// 头像URL
  final String? avatarUrl;

  /// 在线状态
  final PresenceStatus presence;

  /// 最后活跃时间
  final DateTime? lastActiveTime;

  /// 状态消息
  final String? statusMessage;

  /// 备注名称
  final String? remark;

  /// 是否已屏蔽
  final bool isBlocked;

  /// 是否是好友（有私聊房间）
  final bool isFriend;

  /// 私聊房间ID
  final String? directRoomId;

  /// 标签列表
  final List<String> tags;

  /// N42 用户名
  final String? n42Username;

  /// 钱包地址
  final String? walletAddress;

  /// ENS 域名
  final String? ensName;

  const ContactEntity({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.presence = PresenceStatus.offline,
    this.lastActiveTime,
    this.statusMessage,
    this.remark,
    this.isBlocked = false,
    this.isFriend = false,
    this.directRoomId,
    this.tags = const [],
    this.n42Username,
    this.walletAddress,
    this.ensName,
  });

  /// 获取用户名部分
  String get username {
    if (userId.startsWith('@')) {
      final colonIndex = userId.indexOf(':');
      if (colonIndex > 1) {
        return userId.substring(1, colonIndex);
      }
      return userId.substring(1);
    }
    return userId;
  }

  /// 获取服务器部分
  String get server {
    final colonIndex = userId.indexOf(':');
    if (colonIndex > 0 && colonIndex < userId.length - 1) {
      return userId.substring(colonIndex + 1);
    }
    return '';
  }

  /// 获取显示名称（优先使用备注）
  String get effectiveDisplayName {
    if (remark != null && remark!.isNotEmpty) {
      return remark!;
    }
    if (displayName.isNotEmpty) {
      return displayName;
    }
    return username;
  }

  /// 获取名称首字母（用于头像）
  String get initials {
    final name = effectiveDisplayName;
    if (name.isEmpty) return '?';

    final words = name.trim().split(_whitespaceRegExp);
    if (words.length == 1) {
      return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    }

    return words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  /// 获取索引字母（用于通讯录分组）
  ///
  /// 基于显示名称的首字母
  String get indexLetter {
    final name = effectiveDisplayName;
    if (name.isEmpty) return '#';

    final first = name[0].toUpperCase();
    if (_upperLetterRegExp.hasMatch(first)) {
      return first;
    }

    // 中文或其他字符，返回#
    // 实际应用中应该使用拼音库转换
    return '#';
  }

  /// 排序键（用于联系人列表排序）
  ///
  /// 返回小写的有效显示名称，用于字母排序
  String get sortKey {
    return effectiveDisplayName.toLowerCase();
  }

  /// 是否在线
  bool get isOnline => presence == PresenceStatus.online;

  /// 格式化最后活跃时间
  String get formattedLastActive {
    if (lastActiveTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastActiveTime!);

    if (difference.inMinutes < 5) {
      return '刚刚活跃';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前活跃';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前活跃';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前活跃';
    } else {
      return '';
    }
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        presence,
        lastActiveTime,
        statusMessage,
        remark,
        isBlocked,
        isFriend,
        directRoomId,
        tags,
        n42Username,
        walletAddress,
        ensName,
      ];

  ContactEntity copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    PresenceStatus? presence,
    DateTime? lastActiveTime,
    String? statusMessage,
    String? remark,
    bool? isBlocked,
    bool? isFriend,
    String? directRoomId,
    List<String>? tags,
    String? n42Username,
    String? walletAddress,
    String? ensName,
  }) {
    return ContactEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      presence: presence ?? this.presence,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      statusMessage: statusMessage ?? this.statusMessage,
      remark: remark ?? this.remark,
      isBlocked: isBlocked ?? this.isBlocked,
      isFriend: isFriend ?? this.isFriend,
      directRoomId: directRoomId ?? this.directRoomId,
      tags: tags ?? this.tags,
      n42Username: n42Username ?? this.n42Username,
      walletAddress: walletAddress ?? this.walletAddress,
      ensName: ensName ?? this.ensName,
    );
  }
}

