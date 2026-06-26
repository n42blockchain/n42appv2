import 'package:equatable/equatable.dart';

/// 隐私设置实体
///
/// 管理用户的隐私偏好设置
class PrivacySettingsEntity extends Equatable {
  /// 是否显示在线状态
  ///
  /// 如果为 false，其他用户将看不到你的在线状态
  final bool showOnlineStatus;

  /// 是否发送已读回执
  ///
  /// 如果为 false，发送者将不知道你是否已读消息
  final bool sendReadReceipts;

  /// 是否发送正在输入状态
  ///
  /// 如果为 false，其他用户将看不到你正在输入
  final bool sendTypingIndicator;

  /// 是否显示最后上线时间
  ///
  /// 如果为 false，其他用户将看不到你的最后上线时间
  final bool showLastSeenTime;

  /// 谁可以看到我的头像
  final PrivacyLevel avatarVisibility;

  /// 谁可以看到我的个人资料
  final PrivacyLevel profileVisibility;

  /// 谁可以给我发消息
  final PrivacyLevel messagePermission;

  /// 谁可以把我加入群组
  final PrivacyLevel groupInvitePermission;

  /// 谁可以给我打电话
  final PrivacyLevel callPermission;

  /// 是否屏蔽陌生人消息
  final bool blockStrangerMessages;

  /// 是否允许通过手机号/邮箱搜索到我
  final bool allowSearchByContact;

  /// 是否允许通过用户名搜索到我
  final bool allowSearchByUsername;

  const PrivacySettingsEntity({
    this.showOnlineStatus = true,
    this.sendReadReceipts = true,
    this.sendTypingIndicator = true,
    this.showLastSeenTime = true,
    this.avatarVisibility = PrivacyLevel.everyone,
    this.profileVisibility = PrivacyLevel.everyone,
    this.messagePermission = PrivacyLevel.everyone,
    this.groupInvitePermission = PrivacyLevel.everyone,
    this.callPermission = PrivacyLevel.everyone,
    this.blockStrangerMessages = false,
    this.allowSearchByContact = true,
    this.allowSearchByUsername = true,
  });

  /// 默认设置（全部公开）
  static const PrivacySettingsEntity defaultSettings = PrivacySettingsEntity();

  /// 高隐私设置
  static const PrivacySettingsEntity highPrivacy = PrivacySettingsEntity(
    showOnlineStatus: false,
    sendReadReceipts: false,
    sendTypingIndicator: false,
    showLastSeenTime: false,
    avatarVisibility: PrivacyLevel.contacts,
    profileVisibility: PrivacyLevel.contacts,
    messagePermission: PrivacyLevel.contacts,
    groupInvitePermission: PrivacyLevel.contacts,
    callPermission: PrivacyLevel.contacts,
    blockStrangerMessages: true,
    allowSearchByContact: false,
    allowSearchByUsername: false,
  );

  /// 中等隐私设置
  static const PrivacySettingsEntity mediumPrivacy = PrivacySettingsEntity(
    showOnlineStatus: true,
    sendReadReceipts: true,
    sendTypingIndicator: false,
    showLastSeenTime: false,
    avatarVisibility: PrivacyLevel.everyone,
    profileVisibility: PrivacyLevel.contacts,
    messagePermission: PrivacyLevel.everyone,
    groupInvitePermission: PrivacyLevel.contacts,
    callPermission: PrivacyLevel.contacts,
    blockStrangerMessages: false,
    allowSearchByContact: true,
    allowSearchByUsername: true,
  );

  /// 是否完全隐私模式（所有可见性都关闭）
  bool get isFullyPrivate =>
      !showOnlineStatus &&
      !sendReadReceipts &&
      !sendTypingIndicator &&
      !showLastSeenTime;

  /// 是否完全公开模式（所有可见性都开启）
  bool get isFullyPublic =>
      showOnlineStatus &&
      sendReadReceipts &&
      sendTypingIndicator &&
      showLastSeenTime;

  @override
  List<Object?> get props => [
        showOnlineStatus,
        sendReadReceipts,
        sendTypingIndicator,
        showLastSeenTime,
        avatarVisibility,
        profileVisibility,
        messagePermission,
        groupInvitePermission,
        callPermission,
        blockStrangerMessages,
        allowSearchByContact,
        allowSearchByUsername,
      ];

  PrivacySettingsEntity copyWith({
    bool? showOnlineStatus,
    bool? sendReadReceipts,
    bool? sendTypingIndicator,
    bool? showLastSeenTime,
    PrivacyLevel? avatarVisibility,
    PrivacyLevel? profileVisibility,
    PrivacyLevel? messagePermission,
    PrivacyLevel? groupInvitePermission,
    PrivacyLevel? callPermission,
    bool? blockStrangerMessages,
    bool? allowSearchByContact,
    bool? allowSearchByUsername,
  }) {
    return PrivacySettingsEntity(
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      sendReadReceipts: sendReadReceipts ?? this.sendReadReceipts,
      sendTypingIndicator: sendTypingIndicator ?? this.sendTypingIndicator,
      showLastSeenTime: showLastSeenTime ?? this.showLastSeenTime,
      avatarVisibility: avatarVisibility ?? this.avatarVisibility,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      messagePermission: messagePermission ?? this.messagePermission,
      groupInvitePermission: groupInvitePermission ?? this.groupInvitePermission,
      callPermission: callPermission ?? this.callPermission,
      blockStrangerMessages: blockStrangerMessages ?? this.blockStrangerMessages,
      allowSearchByContact: allowSearchByContact ?? this.allowSearchByContact,
      allowSearchByUsername: allowSearchByUsername ?? this.allowSearchByUsername,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'showOnlineStatus': showOnlineStatus,
      'sendReadReceipts': sendReadReceipts,
      'sendTypingIndicator': sendTypingIndicator,
      'showLastSeenTime': showLastSeenTime,
      'avatarVisibility': avatarVisibility.name,
      'profileVisibility': profileVisibility.name,
      'messagePermission': messagePermission.name,
      'groupInvitePermission': groupInvitePermission.name,
      'callPermission': callPermission.name,
      'blockStrangerMessages': blockStrangerMessages,
      'allowSearchByContact': allowSearchByContact,
      'allowSearchByUsername': allowSearchByUsername,
    };
  }

  /// 从 Map 创建
  factory PrivacySettingsEntity.fromMap(Map<String, dynamic> map) {
    return PrivacySettingsEntity(
      showOnlineStatus: map['showOnlineStatus'] as bool? ?? true,
      sendReadReceipts: map['sendReadReceipts'] as bool? ?? true,
      sendTypingIndicator: map['sendTypingIndicator'] as bool? ?? true,
      showLastSeenTime: map['showLastSeenTime'] as bool? ?? true,
      avatarVisibility: _parsePrivacyLevel(map['avatarVisibility']),
      profileVisibility: _parsePrivacyLevel(map['profileVisibility']),
      messagePermission: _parsePrivacyLevel(map['messagePermission']),
      groupInvitePermission: _parsePrivacyLevel(map['groupInvitePermission']),
      callPermission: _parsePrivacyLevel(map['callPermission']),
      blockStrangerMessages: map['blockStrangerMessages'] as bool? ?? false,
      allowSearchByContact: map['allowSearchByContact'] as bool? ?? true,
      allowSearchByUsername: map['allowSearchByUsername'] as bool? ?? true,
    );
  }

  static PrivacyLevel _parsePrivacyLevel(dynamic value) {
    if (value == null) return PrivacyLevel.everyone;
    if (value is PrivacyLevel) return value;
    if (value is String) {
      return PrivacyLevel.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PrivacyLevel.everyone,
      );
    }
    return PrivacyLevel.everyone;
  }
}

/// 隐私级别
enum PrivacyLevel {
  /// 所有人可见
  everyone,

  /// 仅联系人可见
  contacts,

  /// 仅自己可见
  nobody,
}

/// 隐私级别扩展
extension PrivacyLevelExtension on PrivacyLevel {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case PrivacyLevel.everyone:
        return '所有人';
      case PrivacyLevel.contacts:
        return '仅联系人';
      case PrivacyLevel.nobody:
        return '仅自己';
    }
  }

  /// 获取描述
  String get description {
    switch (this) {
      case PrivacyLevel.everyone:
        return '任何人都可以看到';
      case PrivacyLevel.contacts:
        return '只有你的联系人可以看到';
      case PrivacyLevel.nobody:
        return '没有人可以看到';
    }
  }

  /// 检查指定用户是否有权限（需要传入是否是联系人）
  bool hasAccess({required bool isContact}) {
    switch (this) {
      case PrivacyLevel.everyone:
        return true;
      case PrivacyLevel.contacts:
        return isContact;
      case PrivacyLevel.nobody:
        return false;
    }
  }
}
