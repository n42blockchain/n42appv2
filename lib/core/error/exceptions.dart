/// 应用异常基类
abstract class AppException implements Exception {
  /// 异常消息
  final String message;
  
  /// 异常代码（可选）
  final String? code;
  
  /// 原始错误（可选）
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// 服务器异常
/// 
/// 当 API 返回错误状态码时抛出
class ServerException extends AppException {
  /// HTTP 状态码
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode, code: $code)';
}

/// 网络异常
/// 
/// 当网络连接失败时抛出
class NetworkException extends AppException {
  const NetworkException({
    super.message = '网络连接失败，请检查网络设置',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// 超时异常
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = '请求超时，请稍后重试',
    super.code = 'TIMEOUT',
    super.originalError,
  });
}

/// 缓存异常
/// 
/// 当本地缓存操作失败时抛出
class CacheException extends AppException {
  const CacheException({
    super.message = '缓存操作失败',
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

/// 认证异常
/// 
/// 当用户认证失败或 Token 过期时抛出
class AuthException extends AppException {
  const AuthException({
    super.message = '认证失败，请重新登录',
    super.code = 'AUTH_ERROR',
    super.originalError,
  });
}

/// Token 过期异常
class TokenExpiredException extends AuthException {
  const TokenExpiredException({
    super.message = '登录已过期，请重新登录',
    super.code = 'TOKEN_EXPIRED',
    super.originalError,
  });
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException({
    super.message = '没有操作权限',
    super.code = 'PERMISSION_DENIED',
    super.originalError,
  });
}

/// 验证异常
/// 
/// 当输入数据验证失败时抛出
class ValidationException extends AppException {
  /// 验证错误详情
  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = '数据验证失败',
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    this.errors,
  });
}

/// 业务逻辑异常
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    super.code = 'BUSINESS_ERROR',
    super.originalError,
  });
}

/// 钱包异常
class WalletException extends AppException {
  const WalletException({
    required super.message,
    super.code = 'WALLET_ERROR',
    super.originalError,
  });
}

/// 交易异常
class TransactionException extends AppException {
  const TransactionException({
    required super.message,
    super.code = 'TRANSACTION_ERROR',
    super.originalError,
  });
}

/// 生物识别异常
class BiometricException extends AppException {
  const BiometricException({
    super.message = '生物识别验证失败',
    super.code = 'BIOMETRIC_ERROR',
    super.originalError,
  });
}

