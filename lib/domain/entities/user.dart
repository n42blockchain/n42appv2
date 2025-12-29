import 'package:equatable/equatable.dart';

/// 用户实体
/// 
/// 领域层的核心实体，不包含任何框架依赖
class User extends Equatable {
  /// 用户 UUID
  final String uuid;
  
  /// 用户邮箱
  final String email;
  
  /// 用户名
  final String? name;
  
  /// 用户头像
  final String? avatar;
  
  /// 用户描述
  final String? description;
  
  /// 创建时间（时间戳）
  final int? createdAt;
  
  /// 是否绑定 Google 认证
  final bool? hasGoogleAuth;
  
  /// 邀请码
  final String? inviteCode;
  
  /// 钱包地址
  final String? walletAddress;
  
  /// 是否已创建钱包
  final bool hasWallet;

  const User({
    required this.uuid,
    required this.email,
    this.name,
    this.avatar,
    this.description,
    this.createdAt,
    this.hasGoogleAuth,
    this.inviteCode,
    this.walletAddress,
    this.hasWallet = false,
  });

  /// 获取显示名称
  String get displayName => name?.isNotEmpty == true ? name! : email.split('@').first;

  /// 是否有头像
  bool get hasAvatar => avatar?.isNotEmpty == true;

  /// 复制并修改
  User copyWith({
    String? uuid,
    String? email,
    String? name,
    String? avatar,
    String? description,
    int? createdAt,
    bool? hasGoogleAuth,
    String? inviteCode,
    String? walletAddress,
    bool? hasWallet,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      hasGoogleAuth: hasGoogleAuth ?? this.hasGoogleAuth,
      inviteCode: inviteCode ?? this.inviteCode,
      walletAddress: walletAddress ?? this.walletAddress,
      hasWallet: hasWallet ?? this.hasWallet,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    email,
    name,
    avatar,
    description,
    createdAt,
    hasGoogleAuth,
    inviteCode,
    walletAddress,
    hasWallet,
  ];
}

/// 用户凭证
/// 
/// 包含用于认证的敏感信息
class UserCredentials extends Equatable {
  /// 用户 UUID
  final String uuid;
  
  /// 认证 Token
  final String token;
  
  /// 用户邮箱
  final String email;

  const UserCredentials({
    required this.uuid,
    required this.token,
    required this.email,
  });

  @override
  List<Object?> get props => [uuid, token, email];
}

