import 'dart:io';
import 'package:n42appv2/core/security/security_config.dart';

/// 自定义 HttpOverrides
/// 
/// ⚠️ 此类已使用 SecurityConfig 进行安全配置
/// - Debug 模式: 允许自签名证书
/// - Release 模式: 启用 SSL Pinning
@Deprecated('Use SecureHttpOverrides from security_config.dart instead')
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // 使用统一的安全配置验证证书
        return SecurityConfig.verifySslCertificate(cert, host, port);
      };
  }
}