import 'package:dio/dio.dart';

import '../../security/secure_storage.dart';

/// 认证拦截器
/// 
/// 自动添加 Token 到请求头，处理 Token 过期
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 获取存储的 Token
    final token = await _secureStorage.getToken();
    final uuid = await _secureStorage.getUuid();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Token'] = token;
    }
    
    if (uuid != null && uuid.isNotEmpty) {
      options.headers['Uuid'] = uuid;
    }
    
    // 添加通用 Header
    options.headers['Source'] = 'app';
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 处理 Token 过期（401/403）
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // 发送登出事件
      // eventBus.fire(TokenExpiredEvent());
    }
    
    handler.next(err);
  }
}

