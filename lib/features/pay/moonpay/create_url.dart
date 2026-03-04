import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/network/base_http.dart';

/// Moonpay URL 签名服务
///
/// 签名通过服务端代理完成，客户端不持有 Secret Key。
class MoonpayService {
  /// 已弃用：密钥已迁移至服务端。
  @Deprecated('Keys moved to server proxy. Use createUrl() instead.')
  static void configure({String? productionKey, String? testKey}) {}

  @Deprecated('Keys moved to server proxy.')
  static void clearKeys() {}
}

/// 通过服务端代理创建 Moonpay URL 签名
///
/// [url] 原始 URL
/// [mode] 环境模式 ('prod' 或 'test')
/// 返回 HMAC-SHA256 签名的 Base64 编码字符串
Future<String> createUrl(String url, String mode) async {
  try {
    final response = await BaseHttp().dio.post<Map<String, dynamic>>(
      ProxyConfig.moonpaySign,
      data: {'url': url, 'mode': mode},
    );

    final data = response.data;
    if (data != null && data['signature'] is String) {
      return data['signature'] as String;
    }
    throw StateError('Invalid signature response from proxy');
  } catch (e) {
    if (kDebugMode) {
      debugPrint('MoonPay sign error: $e');
    }
    rethrow;
  }
}
