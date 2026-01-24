import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Moonpay URL 签名服务
///
/// 安全注意事项:
/// - API 密钥必须通过环境变量或安全配置注入
/// - 生产环境不得使用测试密钥
/// - 密钥不应出现在源代码或日志中
class MoonpayService {
  /// 获取 Moonpay 密钥
  ///
  /// 优先级:
  /// 1. 环境变量 MOONPAY_SECRET_KEY (生产) / MOONPAY_SECRET_KEY_TEST (测试)
  /// 2. 运行时注入的密钥
  /// 3. 抛出异常 (不允许没有密钥的情况)
  static String _getSecretKey(String mode) {
    final envKey = mode == 'prod'
        ? const String.fromEnvironment('MOONPAY_SECRET_KEY')
        : const String.fromEnvironment('MOONPAY_SECRET_KEY_TEST');

    if (envKey.isNotEmpty) {
      return envKey;
    }

    // 检查运行时注入的密钥
    final runtimeKey =
        mode == 'prod' ? _runtimeProdKey : _runtimeTestKey;
    if (runtimeKey != null && runtimeKey.isNotEmpty) {
      return runtimeKey;
    }

    // 在 Debug 模式下给出明确警告
    if (kDebugMode) {
      debugPrint(
        '⚠️ WARNING: Moonpay secret key not configured. '
        'Set MOONPAY_SECRET_KEY environment variable or call MoonpayService.configure()',
      );
    }

    throw StateError(
      'Moonpay secret key not configured. '
      'Please set environment variable or call MoonpayService.configure()',
    );
  }

  // 运行时密钥存储 (通过 configure 方法设置)
  static String? _runtimeProdKey;
  static String? _runtimeTestKey;

  /// 配置 Moonpay 密钥 (运行时注入)
  ///
  /// 建议在应用启动时从安全存储获取密钥并调用此方法
  /// 例如从 Firebase Remote Config, AWS Secrets Manager 等获取
  static void configure({
    String? productionKey,
    String? testKey,
  }) {
    _runtimeProdKey = productionKey;
    _runtimeTestKey = testKey;
  }

  /// 清除运行时密钥 (登出或应用销毁时调用)
  static void clearKeys() {
    _runtimeProdKey = null;
    _runtimeTestKey = null;
  }
}

/// 创建签名 URL
///
/// [coinType] 币种类型
/// [address] 钱包地址
/// [url] 原始 URL
/// [mode] 环境模式 ('prod' 或 'test')
String createUrl(String coinType, String address, String url, String mode) {
  final secretKey = MoonpayService._getSecretKey(mode);

  Uri uri = Uri.parse(url);
  String queryString = uri.query;

  // 计算 HMAC-SHA256 签名
  var hmac = Hmac(sha256, utf8.encode(secretKey));
  var digest = hmac.convert(utf8.encode('?$queryString'));
  String signature = base64Encode(digest.bytes);
  return signature;
}
