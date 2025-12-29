import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';

/// 认证仓库接口
/// 
/// 定义所有认证相关的操作
abstract class AuthRepository {
  /// 使用邮箱密码登录
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// 使用验证码登录
  Future<Either<Failure, User>> loginWithCode({
    required String email,
    required String code,
  });

  /// 注册新用户
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? inviteCode,
  });

  /// 发送验证码
  Future<Either<Failure, void>> sendVerificationCode({
    required String email,
    required VerificationCodeType type,
  });

  /// 验证邮箱
  Future<Either<Failure, void>> verifyEmail({
    required String email,
    required String code,
  });

  /// 重置密码
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// 获取当前用户
  Future<Either<Failure, User?>> getCurrentUser();

  /// 刷新用户信息
  Future<Either<Failure, User>> refreshUserInfo();

  /// 更新用户信息
  Future<Either<Failure, User>> updateUserInfo({
    String? name,
    String? description,
    String? avatar,
  });

  /// 登出
  Future<Either<Failure, void>> logout();

  /// 检查是否已登录
  Future<bool> isLoggedIn();

  /// 绑定 Google 认证
  Future<Either<Failure, void>> bindGoogleAuth({
    required String secret,
    required String code,
  });

  /// 解绑 Google 认证
  Future<Either<Failure, void>> unbindGoogleAuth({
    required String code,
  });
}

/// 验证码类型
enum VerificationCodeType {
  /// 登录
  login,
  
  /// 注册
  register,
  
  /// 重置密码
  resetPassword,
  
  /// 绑定邮箱
  bindEmail,
}

