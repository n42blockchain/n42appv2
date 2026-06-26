import 'dart:typed_data';

import '../entities/stored_account_entity.dart';
import '../entities/user_entity.dart';

/// 认证仓库接口
///
/// 定义认证相关的所有操作，由 Data 层实现
abstract class IAuthRepository {
  /// 是否已登录
  bool get isLoggedIn;

  /// 当前用户
  UserEntity? get currentUser;

  /// 登录状态流
  Stream<bool> get loginStateStream;

  /// 使用用户名密码登录
  ///
  /// [homeserver] Matrix服务器地址
  /// [username] 用户名
  /// [password] 密码
  /// [rememberMe] 是否记住登录状态（保存凭据用于自动登录）
  ///
  /// 返回登录结果
  Future<AuthResult> login({
    required String homeserver,
    required String username,
    required String password,
    bool rememberMe = true,
  });

  /// 使用Token恢复登录
  Future<AuthResult> loginWithToken({
    required String homeserver,
    required String accessToken,
    required String userId,
    required String deviceId,
  });

  /// 自动恢复会话
  ///
  /// 从本地存储恢复上次的登录状态
  Future<AuthResult> restoreSession();

  /// 登出
  Future<void> logout();

  /// 注册新用户
  ///
  /// [registrationToken] 注册邀请码（某些服务器需要）
  Future<AuthResult> register({
    required String homeserver,
    required String username,
    required String password,
    String? email,
    String? registrationToken,
  });

  /// 匿名注册（不绑定手机号/邮箱，自动生成用户名）
  Future<AuthResult> registerAnonymously({
    required String homeserver,
    required String password,
    String? registrationToken,
  });

  /// 检查Homeserver是否有效
  Future<HomeserverInfo> checkHomeserver(String homeserver);

  /// 检查用户名是否可用
  Future<bool> isUsernameAvailable(String homeserver, String username);

  /// 获取当前用户资料
  Future<UserEntity?> getCurrentUserProfile();

  /// 更新用户资料
  Future<void> updateProfile({String? displayName, String? avatarPath});

  /// 更新头像
  ///
  /// [avatarBytes] 头像图片二进制数据
  /// [filename] 文件名
  ///
  /// 返回是否成功
  Future<bool> updateAvatar(Uint8List avatarBytes, String filename);

  /// 更新显示名
  ///
  /// [displayName] 新的显示名
  ///
  /// 返回是否成功
  Future<bool> updateDisplayName(String displayName);

  /// 更新用户自定义资料
  ///
  /// 使用 Matrix 账户数据存储自定义字段
  Future<bool> updateUserProfileData({
    String? gender,
    String? region,
    String? signature,
    String? pokeText,
    String? ringtone,
    String? avatarDecorationPreset,
    String? nftContractAddress,
    int? nftTokenId,
    int? nftChainId,
    String? nftImageUrl,
    bool clearNftAvatar = false,
  });

  /// 获取用户自定义资料数据
  Future<Map<String, dynamic>?> getUserProfileData();

  // ============================================
  // 密码管理
  // ============================================

  /// 请求发送密码重置验证码
  ///
  /// [homeserver] Matrix 服务器地址
  /// [email] 注册时绑定的邮箱
  ///
  /// 返回是否成功发送
  Future<bool> requestPasswordReset({
    required String homeserver,
    required String email,
  });

  /// 确认重置密码
  ///
  /// [homeserver] Matrix 服务器地址
  /// [email] 注册时绑定的邮箱
  /// [code] 验证码
  /// [newPassword] 新密码
  ///
  /// 返回是否成功重置
  Future<bool> confirmPasswordReset({
    required String homeserver,
    required String email,
    required String code,
    required String newPassword,
  });

  /// 修改密码
  ///
  /// [oldPassword] 当前密码
  /// [newPassword] 新密码
  ///
  /// 返回是否成功修改
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  // ============================================
  // 第三方登录
  // ============================================

  /// 使用第三方社交登录 Token 登录
  ///
  /// [homeserver] Matrix 服务器地址
  /// [provider] 登录提供商 (google, apple, etc.)
  /// [idToken] 第三方提供的 ID Token
  /// [accessToken] 第三方提供的 Access Token
  /// [email] 用户邮箱
  /// [displayName] 用户显示名
  Future<AuthResult> loginWithSocialToken({
    required String homeserver,
    required String provider,
    String? idToken,
    String? accessToken,
    String? email,
    String? displayName,
    Map<String, dynamic>? extra,
  });

  /// 使用 Matrix SSO 回调返回的 login token 登录
  Future<AuthResult> loginWithLoginToken({
    required String homeserver,
    required String loginToken,
  });

  /// 启动 SSO 登录
  ///
  /// [homeserver] Matrix 服务器地址
  /// [providerId] SSO 提供商 ID（可选）
  Future<AuthResult> startSsoLogin({
    required String homeserver,
    String? providerId,
  });

  // ============================================
  // 邮箱管理
  // ============================================

  /// 修改绑定邮箱
  ///
  /// [password] 当前密码（用于验证身份）
  /// [newEmail] 新邮箱地址
  ///
  /// 返回是否成功发送验证码
  Future<bool> requestChangeEmail({
    required String password,
    required String newEmail,
  });

  /// 确认修改邮箱
  ///
  /// [newEmail] 新邮箱地址
  /// [code] 验证码
  ///
  /// 返回是否成功修改
  Future<bool> confirmChangeEmail({
    required String newEmail,
    required String code,
  });

  /// 获取当前绑定的邮箱
  Future<String?> getBoundEmail();

  /// 获取当前绑定的手机号
  Future<String?> getBoundPhone();

  /// 获取当前设备已保存的账号列表
  Future<List<StoredAccountEntity>> getStoredAccounts();

  /// 切换到本机已保存的另一个账号
  Future<AuthResult> switchStoredAccount(String userId);
}

/// 认证结果
class AuthResult {
  final bool success;
  final UserEntity? user;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthResult._({
    required this.success,
    this.user,
    this.errorMessage,
    this.errorType,
  });

  /// 创建成功结果
  factory AuthResult.success(UserEntity user) =>
      AuthResult._(success: true, user: user);

  /// 创建失败结果
  factory AuthResult.failure(
    String message, {
    AuthErrorType type = AuthErrorType.unknown,
  }) => AuthResult._(success: false, errorMessage: message, errorType: type);

  /// 未登录
  factory AuthResult.notLoggedIn() => const AuthResult._(
    success: false,
    errorMessage: '未登录',
    errorType: AuthErrorType.notLoggedIn,
  );

  @override
  String toString() => success
      ? 'AuthResult.success(${user?.userId})'
      : 'AuthResult.failure($errorMessage)';
}

/// 认证错误类型
enum AuthErrorType {
  /// 未知错误
  unknown,

  /// 未登录
  notLoggedIn,

  /// 服务器无效
  invalidHomeserver,

  /// 用户名或密码错误
  invalidCredentials,

  /// 用户名已存在
  usernameExists,

  /// 用户名不可用
  usernameUnavailable,

  /// 网络错误
  networkError,

  /// 服务器错误
  serverError,

  /// Token过期
  tokenExpired,

  /// 设备验证失败
  deviceVerificationFailed,

  /// 需要额外验证
  additionalAuthRequired,

  /// 速率限制
  rateLimited,
}

/// Homeserver信息
class HomeserverInfo {
  final String serverName;
  final String serverVersion;
  final List<String> supportedLoginTypes;
  final bool supportsRegistration;

  const HomeserverInfo({
    required this.serverName,
    required this.serverVersion,
    required this.supportedLoginTypes,
    this.supportsRegistration = false,
  });

  /// 是否支持密码登录
  bool get supportsPasswordLogin =>
      supportedLoginTypes.contains('m.login.password');

  /// 是否支持SSO登录
  bool get supportsSsoLogin => supportedLoginTypes.contains('m.login.sso');

  @override
  String toString() =>
      'HomeserverInfo($serverName, v$serverVersion, types: $supportedLoginTypes)';
}
