// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 安全配置
/// 
/// 统一管理应用安全相关的配置和工具
class SecurityConfig {
  SecurityConfig._();

  /// SSL 证书配置
  ///
  /// IMPORTANT: 在生产环境部署前，必须执行以下步骤：
  ///
  /// 1. 获取服务器证书指纹：
  ///    ```bash
  ///    openssl s_client -connect api.n42.ai:443 2>/dev/null | \
  ///      openssl x509 -pubkey -noout | \
  ///      openssl rsa -pubin -outform der 2>/dev/null | \
  ///      openssl dgst -sha256 -binary | base64
  ///    ```
  ///
  /// 2. 或使用在线工具: https://www.ssllabs.com/ssltest/
  ///
  /// 3. 将获取的指纹替换下面的占位符值
  ///
  /// 4. 设置证书轮换提醒（证书到期前30天添加新证书）
  ///
  /// 证书轮换流程：
  /// 1. 在证书到期前30天，将新证书指纹添加到 backupCertFingerprints
  /// 2. 发布包含新证书的应用更新
  /// 3. 等待大部分用户更新后，切换服务器证书
  /// 4. 在下一个版本中，将新证书移到 allowedCertFingerprints，删除旧证书

  /// 允许的 SSL 证书指纹列表
  ///
  /// TODO: 在生产部署前替换这些占位符指纹
  static const List<String> allowedCertFingerprints = [
    // N42 API 服务器证书指纹 (主证书)
    // PLACEHOLDER - Replace with actual certificate fingerprint
    'sha256/47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=',
    // N42 API 服务器证书指纹 (备用证书)
    // PLACEHOLDER - Replace with actual certificate fingerprint
    'sha256/C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=',
    // Let's Encrypt Root CA (ISRG Root X1)
    // This is a real fingerprint for Let's Encrypt
    'sha256/C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=',
    // DigiCert Global Root CA
    'sha256/r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=',
  ];

  /// 允许的主机列表（用于 SSL Pinning）
  static const List<String> pinnedHosts = [
    'api.n42.ai',
    'api.n42.network',
    'ipfs.n42.network',
    'auth.n42.network',
    'ws.n42.network',
    'cdn.n42.network',
  ];

  /// 备用证书指纹（证书即将过期时切换）
  ///
  /// 在证书轮换期间，将新证书指纹添加到此列表
  /// 这允许应用同时接受新旧证书
  static const List<String> backupCertFingerprints = [
    // Add backup certificate fingerprints here before certificate rotation
  ];

  /// Certificate expiry warning threshold in days
  static const int certExpiryWarningDays = 30;

  /// Check if certificate pinning is properly configured
  ///
  /// Returns false if still using placeholder values
  static bool get isCertPinningConfigured {
    // Check if fingerprints have been replaced from placeholders
    // The placeholder value starts with a known pattern
    const placeholderPattern = 'sha256/47DEQpj8HBSa';
    return !allowedCertFingerprints.any((fp) => fp.contains(placeholderPattern)) ||
           kDebugMode; // Allow in debug mode
  }

  /// 敏感数据关键字（用于日志脱敏）
  static const List<String> sensitiveKeys = [
    // 认证相关
    'token',
    'authorization',
    'password',
    'secret',
    'api_key',
    'apikey',
    'access_token',
    'refresh_token',
    'bearer',
    // 钱包相关
    'mnemonic',
    'private_key',
    'privatekey',
    'pk',
    'seed',
    'keystore',
    // 用户相关
    'email',
    'phone',
    'ssn',
    'credit_card',
    'cvv',
  ];

  /// 检查是否为 Release 模式
  static bool get isRelease => kReleaseMode;

  /// 检查是否为 Debug 模式
  static bool get isDebug => kDebugMode;

  /// 检查是否为 Profile 模式
  static bool get isProfile => kProfileMode;

  /// 检查是否应启用日志
  /// 
  /// 仅在 Debug 模式下启用
  static bool get shouldEnableLogging => kDebugMode;

  /// 检查是否应启用 SSL Pinning
  /// 
  /// 仅在 Release 模式下强制启用
  static bool get shouldEnableSslPinning => kReleaseMode;

  /// 验证 SSL 证书
  ///
  /// 在 Release 模式下进行严格验证
  static bool verifySslCertificate(X509Certificate cert, String host, int port) {
    // Debug 模式下允许自签名证书
    if (kDebugMode) {
      return true;
    }

    // 检查是否为需要 Pinning 的主机
    final isPinnedHost = pinnedHosts.any(
      (pinnedHost) => host.endsWith(pinnedHost),
    );

    if (!isPinnedHost) {
      // 非 Pinning 主机使用系统默认验证
      return true;
    }

    // Check if certificate pinning is properly configured
    if (!isCertPinningConfigured) {
      debugPrint('⚠️ WARNING: SSL Pinning not configured for $host. '
                 'Update allowedCertFingerprints with real certificate fingerprints.');
      // In release mode without proper configuration, fail secure
      return false;
    }

    // 验证证书指纹
    if (allowedCertFingerprints.isEmpty && backupCertFingerprints.isEmpty) {
      debugPrint('⚠️ WARNING: No certificate fingerprints configured for $host');
      return false;
    }

    try {
      final fingerprint = _getCertFingerprint(cert);

      // Check against primary fingerprints
      if (allowedCertFingerprints.contains(fingerprint)) {
        return true;
      }

      // Check against backup fingerprints (for certificate rotation)
      if (backupCertFingerprints.contains(fingerprint)) {
        debugPrint('ℹ️ INFO: Using backup certificate for $host');
        return true;
      }

      debugPrint('❌ Certificate fingerprint mismatch for $host');
      debugPrint('   Expected one of: ${allowedCertFingerprints.join(", ")}');
      debugPrint('   Got: $fingerprint');
      return false;
    } catch (e) {
      debugPrint('SSL certificate verification failed: $e');
      return false;
    }
  }

  /// Check certificate expiry
  ///
  /// Returns the number of days until certificate expires, or -1 if unknown
  static int getCertificateExpiryDays(X509Certificate cert) {
    try {
      final endDate = cert.endValidity;
      final now = DateTime.now();
      return endDate.difference(now).inDays;
    } catch (e) {
      return -1;
    }
  }

  /// Check if certificate is expiring soon
  static bool isCertificateExpiringSoon(X509Certificate cert) {
    final daysUntilExpiry = getCertificateExpiryDays(cert);
    return daysUntilExpiry >= 0 && daysUntilExpiry <= certExpiryWarningDays;
  }

  /// 获取证书 SHA-256 指纹
  static String _getCertFingerprint(X509Certificate cert) {
    final der = cert.der;
    final digest = sha256.convert(der);
    return 'sha256/${base64Encode(digest.bytes)}';
  }

  /// 检查字符串是否包含敏感关键字
  static bool isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    return sensitiveKeys.any((k) => lowerKey.contains(k));
  }

  /// 脱敏敏感数据
  /// 
  /// 将敏感数据替换为 ******
  static String maskSensitiveData(String key, dynamic value) {
    if (isSensitiveKey(key)) {
      return '******';
    }
    return value?.toString() ?? 'null';
  }

  /// 深度脱敏 Map 数据
  static Map<String, dynamic> maskSensitiveMap(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (entry.value is Map<String, dynamic>) {
        result[entry.key] = maskSensitiveMap(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        result[entry.key] = _maskSensitiveList(entry.value as List);
      } else if (isSensitiveKey(entry.key)) {
        result[entry.key] = '******';
      } else {
        result[entry.key] = entry.value;
      }
    }
    
    return result;
  }

  /// 深度脱敏 List 数据
  static List _maskSensitiveList(List data) {
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return maskSensitiveMap(item);
      } else if (item is List) {
        return _maskSensitiveList(item);
      }
      return item;
    }).toList();
  }

  /// 安全日志输出
  /// 
  /// 仅在 Debug 模式下输出，并自动脱敏
  static void secureLog(String message, {Map<String, dynamic>? data}) {
    if (!kDebugMode) return;

    if (data != null) {
      final maskedData = maskSensitiveMap(data);
      debugPrint('$message: ${jsonEncode(maskedData)}');
    } else {
      debugPrint(message);
    }
  }
}

/// 安全的 HttpOverrides
/// 
/// 仅在 Debug 模式下允许绕过 SSL 验证
class SecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    client.badCertificateCallback = (cert, host, port) {
      return SecurityConfig.verifySslCertificate(cert, host, port);
    };
    
    return client;
  }
}

