import 'package:equatable/equatable.dart';

import 'avatar_decoration_preset.dart';

final _whitespaceRegExp = RegExp(r'\s+');

/// 用户实体
///
/// 表示Matrix用户的基本信息
class UserEntity extends Equatable {
  /// Matrix用户ID (格式: @user:server.com)
  final String userId;

  /// 显示名称
  final String displayName;

  /// 头像URL
  final String? avatarUrl;

  /// 状态消息
  final String? statusMessage;

  /// 是否当前登录用户
  final bool isCurrentUser;

  /// 性别 ('male', 'female', null)
  final String? gender;

  /// 地区
  final String? region;

  /// 签名
  final String? signature;

  /// 拍一拍文字
  final String? pokeText;

  /// 来电铃声
  final String? ringtone;

  /// N42 用户名（Signal 风格，如 @alice）
  final String? n42Username;

  /// 钱包地址
  final String? walletAddress;

  /// ENS 域名
  final String? ensName;

  /// 头像装饰样式
  final AvatarDecorationPreset avatarDecorationPreset;

  /// NFT 合约地址
  final String? nftContractAddress;

  /// NFT Token ID
  final int? nftTokenId;

  /// NFT 所在链 ID
  final int? nftChainId;

  /// NFT 头像图片 URL
  final String? nftImageUrl;

  const UserEntity({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.statusMessage,
    this.isCurrentUser = false,
    this.gender,
    this.region,
    this.signature,
    this.pokeText,
    this.ringtone,
    this.n42Username,
    this.walletAddress,
    this.ensName,
    this.avatarDecorationPreset = AvatarDecorationPreset.none,
    this.nftContractAddress,
    this.nftTokenId,
    this.nftChainId,
    this.nftImageUrl,
  });

  /// 当前是否正在使用 NFT 头像
  bool get hasNftAvatar =>
      nftContractAddress != null && nftTokenId != null && nftImageUrl != null;

  /// 获取用户名部分 (@user:server.com -> user)
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

  /// 获取服务器部分 (@user:server.com -> server.com)
  String get server {
    final colonIndex = userId.indexOf(':');
    if (colonIndex > 0 && colonIndex < userId.length - 1) {
      return userId.substring(colonIndex + 1);
    }
    return '';
  }

  /// 获取显示名称（如果为空则使用用户名）
  String get effectiveDisplayName {
    return displayName.isNotEmpty ? displayName : username;
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

  @override
  List<Object?> get props => [
    userId,
    displayName,
    avatarUrl,
    statusMessage,
    isCurrentUser,
    gender,
    region,
    signature,
    pokeText,
    ringtone,
    n42Username,
    walletAddress,
    ensName,
    avatarDecorationPreset,
    nftContractAddress,
    nftTokenId,
    nftChainId,
    nftImageUrl,
  ];

  UserEntity copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? statusMessage,
    bool? isCurrentUser,
    String? gender,
    String? region,
    String? signature,
    String? pokeText,
    String? ringtone,
    String? n42Username,
    String? walletAddress,
    String? ensName,
    AvatarDecorationPreset? avatarDecorationPreset,
    String? nftContractAddress,
    int? nftTokenId,
    int? nftChainId,
    String? nftImageUrl,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      gender: gender ?? this.gender,
      region: region ?? this.region,
      signature: signature ?? this.signature,
      pokeText: pokeText ?? this.pokeText,
      ringtone: ringtone ?? this.ringtone,
      n42Username: n42Username ?? this.n42Username,
      walletAddress: walletAddress ?? this.walletAddress,
      ensName: ensName ?? this.ensName,
      avatarDecorationPreset:
          avatarDecorationPreset ?? this.avatarDecorationPreset,
      nftContractAddress: nftContractAddress ?? this.nftContractAddress,
      nftTokenId: nftTokenId ?? this.nftTokenId,
      nftChainId: nftChainId ?? this.nftChainId,
      nftImageUrl: nftImageUrl ?? this.nftImageUrl,
    );
  }
}
