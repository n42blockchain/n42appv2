import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

/// 生物识别类型
enum BiometricType {
  /// 指纹
  fingerprint,
  
  /// 面部识别
  face,
  
  /// 虹膜
  iris,
  
  /// 其他强认证
  strong,
  
  /// 弱认证
  weak,
}

/// 生物识别结果
class BiometricResult {
  final bool success;
  final String? errorMessage;
  final BiometricErrorCode? errorCode;

  const BiometricResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
  });

  factory BiometricResult.success() => const BiometricResult(success: true);

  factory BiometricResult.failure({
    required String message,
    BiometricErrorCode? code,
  }) => BiometricResult(
    success: false,
    errorMessage: message,
    errorCode: code,
  );
}

/// 生物识别错误代码
enum BiometricErrorCode {
  /// 不支持生物识别
  notAvailable,
  
  /// 未设置生物识别
  notEnrolled,
  
  /// 设备不支持
  notSupported,
  
  /// 用户取消
  userCanceled,
  
  /// 尝试次数过多
  lockedOut,
  
  /// 永久锁定
  permanentlyLockedOut,
  
  /// 其他错误
  unknown,
}

/// 生物识别服务
/// 
/// 封装 local_auth 插件，提供统一的生物识别接口
/// 确保 Android 和 iOS 行为一致
@singleton
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService() : _localAuth = LocalAuthentication();

  /// 检查设备是否支持生物识别
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.map(_mapBiometricType).toList();
    } on PlatformException {
      return [];
    }
  }

  /// 执行生物识别认证
  /// 
  /// [reason] 显示给用户的认证原因
  /// [useErrorDialogs] 是否使用系统错误对话框
  /// [stickyAuth] 是否保持认证状态
  Future<BiometricResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = true,
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      if (authenticated) {
        return BiometricResult.success();
      } else {
        return BiometricResult.failure(
          message: '认证失败',
          code: BiometricErrorCode.userCanceled,
        );
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    }
  }

  /// 取消认证
  Future<bool> cancelAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } on PlatformException {
      return false;
    }
  }

  /// 处理平台异常
  BiometricResult _handlePlatformException(PlatformException e) {
    BiometricErrorCode code;
    String message;

    switch (e.code) {
      case 'NotAvailable':
        code = BiometricErrorCode.notAvailable;
        message = '生物识别不可用';
        break;
      case 'NotEnrolled':
        code = BiometricErrorCode.notEnrolled;
        message = '未设置生物识别';
        break;
      case 'LockedOut':
        code = BiometricErrorCode.lockedOut;
        message = '尝试次数过多，请稍后再试';
        break;
      case 'PermanentlyLockedOut':
        code = BiometricErrorCode.permanentlyLockedOut;
        message = '生物识别已被锁定，请使用其他方式';
        break;
      default:
        code = BiometricErrorCode.unknown;
        message = e.message ?? '未知错误';
    }

    return BiometricResult.failure(
      message: message,
      code: code,
    );
  }

  /// 映射生物识别类型
  BiometricType _mapBiometricType(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return BiometricType.fingerprint;
      case BiometricType.face:
        return BiometricType.face;
      case BiometricType.iris:
        return BiometricType.iris;
      case BiometricType.strong:
        return BiometricType.strong;
      case BiometricType.weak:
        return BiometricType.weak;
    }
  }
}

