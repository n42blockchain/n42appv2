import 'package:equatable/equatable.dart';

/// 失败基类
///
/// 使用 Failure 而非直接抛出异常，便于函数式错误处理
/// 配合 dartz 的 `Either<Failure, T>` 使用
abstract class Failure extends Equatable {
  /// 失败消息
  final String message;

  /// 失败代码
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// 服务器失败
class ServerFailure extends Failure {
  /// HTTP 状态码
  final int? statusCode;

  const ServerFailure({super.message = '服务器错误', super.code, this.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// 网络失败
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = '网络连接失败',
    super.code = 'NETWORK_ERROR',
  });
}

/// 超时失败
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = '请求超时', super.code = 'TIMEOUT'});
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure({super.message = '缓存操作失败', super.code = 'CACHE_ERROR'});
}

/// 认证失败
class AuthFailure extends Failure {
  const AuthFailure({super.message = '认证失败', super.code = 'AUTH_ERROR'});
}

/// Token 过期失败
class TokenExpiredFailure extends AuthFailure {
  const TokenExpiredFailure({
    super.message = '登录已过期',
    super.code = 'TOKEN_EXPIRED',
  });
}

/// 权限失败
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = '没有操作权限',
    super.code = 'PERMISSION_DENIED',
  });
}

/// 验证失败
class ValidationFailure extends Failure {
  /// 验证错误详情
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    super.message = '数据验证失败',
    super.code = 'VALIDATION_ERROR',
    this.errors,
  });

  @override
  List<Object?> get props => [message, code, errors];
}

/// 业务逻辑失败
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.code = 'BUSINESS_ERROR',
  });
}

/// 钱包操作失败
class WalletFailure extends Failure {
  const WalletFailure({required super.message, super.code = 'WALLET_ERROR'});
}

/// 交易失败
class TransactionFailure extends Failure {
  const TransactionFailure({
    required super.message,
    super.code = 'TRANSACTION_ERROR',
  });
}

/// 生物识别失败
class BiometricFailure extends Failure {
  const BiometricFailure({
    super.message = '生物识别验证失败',
    super.code = 'BIOMETRIC_ERROR',
  });
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = '未知错误', super.code = 'UNKNOWN_ERROR'});
}

/// 意外失败（用于捕获未预期的异常）
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code = 'UNEXPECTED_ERROR',
  });
}
