import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';

/// 认证状态
enum AuthStatus {
  /// 初始状态
  initial,

  /// 检查中
  checking,

  /// 加载中
  loading,

  /// 已认证
  authenticated,

  /// 未认证
  unauthenticated,

  /// 错误
  error,
}

/// Homeserver检查状态
enum HomeserverStatus {
  /// 未检查
  unknown,

  /// 检查中
  checking,

  /// 有效
  valid,

  /// 无效
  invalid,
}

/// 密码重置状态
enum PasswordResetStatus {
  /// 初始状态
  initial,

  /// 发送验证码中
  sendingCode,

  /// 验证码已发送
  codeSent,

  /// 重置中
  resetting,

  /// 重置成功
  success,

  /// 重置失败
  failed,
}

/// 密码修改状态
enum ChangePasswordStatus {
  /// 初始状态
  initial,

  /// 修改中
  changing,

  /// 修改成功
  success,

  /// 修改失败
  failed,
}

/// 邮箱修改状态
enum ChangeEmailStatus {
  /// 初始状态
  initial,

  /// 发送验证码中
  sendingCode,

  /// 验证码已发送
  codeSent,

  /// 确认中
  confirming,

  /// 修改成功
  success,

  /// 修改失败
  failed,
}

/// 认证状态
class AuthState extends Equatable {
  /// 认证状态
  final AuthStatus status;

  /// 当前用户
  final UserEntity? user;

  /// 错误消息
  final String? errorMessage;

  /// 错误类型
  final AuthErrorType? errorType;

  /// Homeserver检查状态
  final HomeserverStatus homeserverStatus;

  /// Homeserver信息
  final HomeserverInfo? homeserverInfo;

  /// 上次检查的Homeserver
  final String? lastCheckedHomeserver;

  /// 密码重置状态
  final PasswordResetStatus passwordResetStatus;

  /// 密码修改状态
  final ChangePasswordStatus changePasswordStatus;

  /// 邮箱修改状态
  final ChangeEmailStatus changeEmailStatus;

  /// 绑定的邮箱
  final String? boundEmail;

  /// 生物识别是否可用（设备支持）
  final bool isBiometricAvailable;

  /// 生物识别是否已启用（用户设置）
  final bool isBiometricEnabled;

  /// 生物识别类型描述（Face ID / Touch ID / Fingerprint）
  final String? biometricTypeDescription;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.errorType,
    this.homeserverStatus = HomeserverStatus.unknown,
    this.homeserverInfo,
    this.lastCheckedHomeserver,
    this.passwordResetStatus = PasswordResetStatus.initial,
    this.changePasswordStatus = ChangePasswordStatus.initial,
    this.changeEmailStatus = ChangeEmailStatus.initial,
    this.boundEmail,
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
    this.biometricTypeDescription,
  });

  /// 初始状态
  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null,
        errorType = null,
        homeserverStatus = HomeserverStatus.unknown,
        homeserverInfo = null,
        lastCheckedHomeserver = null,
        passwordResetStatus = PasswordResetStatus.initial,
        changePasswordStatus = ChangePasswordStatus.initial,
        changeEmailStatus = ChangeEmailStatus.initial,
        boundEmail = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        biometricTypeDescription = null;

  /// 是否正在加载
  bool get isLoading =>
      status == AuthStatus.loading || status == AuthStatus.checking;

  /// 是否已登录（loading 状态下如果有 user 也算已登录）
  bool get isAuthenticated => 
      status == AuthStatus.authenticated || 
      (status == AuthStatus.loading && user != null) ||
      (status == AuthStatus.error && user != null);

  /// 是否有错误
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  /// Homeserver是否有效
  bool get isHomeserverValid => homeserverStatus == HomeserverStatus.valid;

  /// 是否正在检查Homeserver
  bool get isCheckingHomeserver => homeserverStatus == HomeserverStatus.checking;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    AuthErrorType? errorType,
    HomeserverStatus? homeserverStatus,
    HomeserverInfo? homeserverInfo,
    String? lastCheckedHomeserver,
    PasswordResetStatus? passwordResetStatus,
    ChangePasswordStatus? changePasswordStatus,
    ChangeEmailStatus? changeEmailStatus,
    String? boundEmail,
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
    String? biometricTypeDescription,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      errorType: errorType,
      homeserverStatus: homeserverStatus ?? this.homeserverStatus,
      homeserverInfo: homeserverInfo ?? this.homeserverInfo,
      lastCheckedHomeserver:
          lastCheckedHomeserver ?? this.lastCheckedHomeserver,
      passwordResetStatus: passwordResetStatus ?? this.passwordResetStatus,
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      changeEmailStatus: changeEmailStatus ?? this.changeEmailStatus,
      boundEmail: boundEmail ?? this.boundEmail,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      biometricTypeDescription: biometricTypeDescription ?? this.biometricTypeDescription,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        errorType,
        homeserverStatus,
        homeserverInfo,
        lastCheckedHomeserver,
        passwordResetStatus,
        changePasswordStatus,
        changeEmailStatus,
        boundEmail,
        isBiometricAvailable,
        isBiometricEnabled,
        biometricTypeDescription,
      ];

  @override
  String toString() => 'AuthState(status: $status, user: ${user?.userId})';
}

