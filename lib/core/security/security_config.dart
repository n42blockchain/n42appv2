// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// 安全配置
///
/// 统一管理应用安全相关的配置和工具
class SecurityConfig {
  SecurityConfig._();

  /// Legacy fingerprint metadata, retained for compatibility.
  ///
  /// HttpClient validates certificate chains and hostnames using the platform
  /// trust store. Its bad-certificate callback cannot enforce pinning on valid
  /// connections, and must never accept an invalid certificate in production.
  /// These legacy fingerprints are not an active certificate-pinning policy.
  static const List<String> allowedCertFingerprints = [
    // N42 API 服务器证书指纹 (主证书)
    // PLACEHOLDER - Replace with actual certificate fingerprint before production
    'sha256/47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=',
    // N42 API 服务器证书指纹 (备用证书)
    // PLACEHOLDER - Replace with actual certificate fingerprint before production
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

  /// 敏感数据关键字（用于日志脱敏）
  static const List<String> sensitiveKeys = [
    // 认证相关
    'token', 'authorization', 'password', 'secret', 'api_key', 'apikey',
    'access_token', 'refresh_token', 'bearer',
    // 钱包相关
    'mnemonic', 'private_key', 'privatekey', 'pk', 'seed', 'keystore',
    // 用户相关
    'email', 'phone', 'ssn', 'credit_card', 'cvv',
  ];

  /// Check if certificate pinning is properly configured
  ///
  /// Returns false if still using placeholder values
  static bool get isCertPinningConfigured {
    const placeholderPattern = 'sha256/47DEQpj8HBSa';
    return !allowedCertFingerprints.any(
      (fp) => fp.contains(placeholderPattern),
    );
  }

  /// The callback is invoked only after normal TLS validation has failed.
  static bool verifySslCertificate(
    X509Certificate cert,
    String host,
    int port,
  ) {
    if (kDebugMode) return true;
    return rejectUntrustedCertificate(cert, host, port);
  }

  /// Production callback: a fingerprint must not override an expired chain,
  /// a hostname mismatch or an unknown certificate authority.
  static bool rejectUntrustedCertificate(
    X509Certificate cert,
    String host,
    int port,
  ) => false;

  /// Check certificate expiry
  ///
  /// Returns the number of days until certificate expires, or -1 if unknown
  static int getCertificateExpiryDays(X509Certificate cert) {
    try {
      return cert.endValidity.difference(DateTime.now()).inDays;
    } catch (e) {
      return -1;
    }
  }

  /// Check if certificate is expiring soon
  static bool isCertificateExpiringSoon(X509Certificate cert) {
    final days = getCertificateExpiryDays(cert);
    return days >= 0 && days <= certExpiryWarningDays;
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
    return isSensitiveKey(key) ? '******' : (value?.toString() ?? 'null');
  }

  /// 深度脱敏 Map 数据
  static Map<String, dynamic> maskSensitiveMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (isSensitiveKey(key)) {
        return MapEntry(key, '******');
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, maskSensitiveMap(value));
      } else if (value is List) {
        return MapEntry(key, _maskSensitiveList(value));
      }
      return MapEntry(key, value);
    });
  }

  /// 深度脱敏 List 数据
  static List _maskSensitiveList(List data) {
    return data.map((item) {
      if (item is Map<String, dynamic>) return maskSensitiveMap(item);
      if (item is List) return _maskSensitiveList(item);
      return item;
    }).toList();
  }

  /// 安全日志输出
  ///
  /// 仅在 Debug 模式下输出，并自动脱敏
  static void secureLog(String message, {Map<String, dynamic>? data}) {
    if (!kDebugMode) return;
    if (data != null) {
      debugPrint('$message: ${jsonEncode(maskSensitiveMap(data))}');
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
    client.badCertificateCallback = SecurityConfig.verifySslCertificate;
    return client;
  }
}
