import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// 认证事件基类
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 检查认证状态
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// 登录请求
class AuthLoginRequested extends AuthEvent {
  final String homeserver;
  final String username;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.homeserver,
    required this.username,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [homeserver, username, rememberMe];
}

/// 登出请求
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// 注册请求
class AuthRegisterRequested extends AuthEvent {
  final String homeserver;
  final String username;
  final String password;
  final String? email;
  final String? registrationToken;

  const AuthRegisterRequested({
    required this.homeserver,
    required this.username,
    required this.password,
    this.email,
    this.registrationToken,
  });

  @override
  List<Object?> get props => [homeserver, username, email, registrationToken];
}

/// 匿名注册请求
class AuthAnonymousRegisterRequested extends AuthEvent {
  final String homeserver;
  final String password;
  final String? registrationToken;

  const AuthAnonymousRegisterRequested({
    required this.homeserver,
    required this.password,
    this.registrationToken,
  });

  @override
  List<Object?> get props => [homeserver, registrationToken];
}

/// 钱包/DID 登录：用钱包对固定消息的签名派生 Matrix 用户名+密码，
/// 先尝试登录，账号不存在则注册（凭据派生见 WalletLoginCredentials）。
class AuthWalletAuthRequested extends AuthEvent {
  final String homeserver;
  final String address;
  final String signature;

  const AuthWalletAuthRequested({
    required this.homeserver,
    required this.address,
    required this.signature,
  });

  @override
  List<Object?> get props => [homeserver, address];
}

/// 检查Homeserver
class AuthHomeserverCheckRequested extends AuthEvent {
  final String homeserver;

  const AuthHomeserverCheckRequested(this.homeserver);

  @override
  List<Object?> get props => [homeserver];
}

/// 恢复会话请求
class AuthRestoreSessionRequested extends AuthEvent {
  const AuthRestoreSessionRequested();
}

/// Token登录请求
class AuthTokenLoginRequested extends AuthEvent {
  final String homeserver;
  final String accessToken;
  final String userId;
  final String deviceId;

  const AuthTokenLoginRequested({
    required this.homeserver,
    required this.accessToken,
    required this.userId,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [homeserver, accessToken, userId, deviceId];
}

/// 切换到本机已保存账号
class AuthSwitchStoredAccountRequested extends AuthEvent {
  final String userId;

  const AuthSwitchStoredAccountRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Matrix login token 登录请求（SSO/OIDC 回调）
class AuthLoginTokenLoginRequested extends AuthEvent {
  final String homeserver;
  final String loginToken;

  const AuthLoginTokenLoginRequested({
    required this.homeserver,
    required this.loginToken,
  });

  @override
  List<Object?> get props => [homeserver, loginToken];
}

/// 清除错误
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}

/// 更新头像
class UpdateAvatar extends AuthEvent {
  final Uint8List avatarBytes;
  final String filename;

  const UpdateAvatar({required this.avatarBytes, required this.filename});

  @override
  List<Object?> get props => [avatarBytes, filename];
}

/// 更新显示名
class UpdateDisplayName extends AuthEvent {
  final String displayName;

  const UpdateDisplayName(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

/// 更新用户资料
class UpdateUserProfile extends AuthEvent {
  final String? displayName;
  final String? signature;
  final String? gender;
  final String? region;
  final String? pokeText;
  final String? ringtone;
  final String? avatarDecorationPreset;
  final String? nftContractAddress;
  final int? nftTokenId;
  final int? nftChainId;
  final String? nftImageUrl;
  final bool clearNftAvatar;

  const UpdateUserProfile({
    this.displayName,
    this.signature,
    this.gender,
    this.region,
    this.pokeText,
    this.ringtone,
    this.avatarDecorationPreset,
    this.nftContractAddress,
    this.nftTokenId,
    this.nftChainId,
    this.nftImageUrl,
    this.clearNftAvatar = false,
  });

  @override
  List<Object?> get props => [
    displayName,
    signature,
    gender,
    region,
    pokeText,
    ringtone,
    avatarDecorationPreset,
    nftContractAddress,
    nftTokenId,
    nftChainId,
    nftImageUrl,
    clearNftAvatar,
  ];
}

/// 加载用户资料数据
class LoadUserProfileData extends AuthEvent {
  const LoadUserProfileData();
}

// ============================================
// 多种登录方式事件
// ============================================

/// Google 登录请求
class AuthGoogleLoginRequested extends AuthEvent {
  final String homeserver;

  const AuthGoogleLoginRequested({required this.homeserver});

  @override
  List<Object?> get props => [homeserver];
}

/// Apple 登录请求
class AuthAppleLoginRequested extends AuthEvent {
  final String homeserver;

  const AuthAppleLoginRequested({required this.homeserver});

  @override
  List<Object?> get props => [homeserver];
}

/// SSO 登录请求
class AuthSsoLoginRequested extends AuthEvent {
  final String homeserver;
  final String? providerId;

  const AuthSsoLoginRequested({required this.homeserver, this.providerId});

  @override
  List<Object?> get props => [homeserver, providerId];
}

/// Facebook 登录请求
class AuthFacebookLoginRequested extends AuthEvent {
  final String homeserver;

  const AuthFacebookLoginRequested({required this.homeserver});

  @override
  List<Object?> get props => [homeserver];
}

/// Twitter 登录请求
class AuthTwitterLoginRequested extends AuthEvent {
  final String homeserver;

  const AuthTwitterLoginRequested({required this.homeserver});

  @override
  List<Object?> get props => [homeserver];
}

/// 微信登录请求
class AuthWeChatLoginRequested extends AuthEvent {
  final String homeserver;

  const AuthWeChatLoginRequested({required this.homeserver});

  @override
  List<Object?> get props => [homeserver];
}

// ============================================
// 密码管理事件
// ============================================

/// 请求重置密码验证码
class AuthRequestPasswordResetRequested extends AuthEvent {
  final String homeserver;
  final String email;

  const AuthRequestPasswordResetRequested({
    required this.homeserver,
    required this.email,
  });

  @override
  List<Object?> get props => [homeserver, email];
}

/// 确认重置密码
class AuthConfirmPasswordResetRequested extends AuthEvent {
  final String homeserver;
  final String email;
  final String code;
  final String newPassword;

  const AuthConfirmPasswordResetRequested({
    required this.homeserver,
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [homeserver, email, code];
}

/// 修改密码请求
class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  // 每个实例唯一 ID，防止 Equatable 去重丢弃连续的密码修改事件
  // （密码本身不入 props，避免在内存中持久化敏感数据）
  final int _id;

  AuthChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  }) : _id = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [_id];
}

// ============================================
// 邮箱管理事件
// ============================================

/// 请求修改绑定邮箱
class AuthRequestChangeEmailRequested extends AuthEvent {
  final String password;
  final String newEmail;

  const AuthRequestChangeEmailRequested({
    required this.password,
    required this.newEmail,
  });

  @override
  List<Object?> get props => [newEmail];
}

/// 确认修改绑定邮箱
class AuthConfirmChangeEmailRequested extends AuthEvent {
  final String newEmail;
  final String code;

  const AuthConfirmChangeEmailRequested({
    required this.newEmail,
    required this.code,
  });

  @override
  List<Object?> get props => [newEmail, code];
}

/// 获取绑定邮箱
class AuthGetBoundEmailRequested extends AuthEvent {
  const AuthGetBoundEmailRequested();
}

// ============================================
// 生物识别登录事件
// ============================================

/// 生物识别登录请求
class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested();
}

/// 检查生物识别可用性
class AuthCheckBiometricAvailability extends AuthEvent {
  const AuthCheckBiometricAvailability();
}

/// 启用生物识别登录
class AuthEnableBiometricLogin extends AuthEvent {
  const AuthEnableBiometricLogin();
}

/// 禁用生物识别登录
class AuthDisableBiometricLogin extends AuthEvent {
  const AuthDisableBiometricLogin();
}
