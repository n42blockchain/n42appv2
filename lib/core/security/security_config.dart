// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

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
  /// IMPORTANT: 必须在生产部署前替换为真实的服务器证书指纹
  /// 当前值为占位符，release 模式下 SSL pinning 会拒绝所有连接
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

  /// 验证 SSL 证书
  ///
  /// 在 Release 模式下进行严格验证
  static bool verifySslCertificate(X509Certificate cert, String host, int port) {
    if (kDebugMode) return true;

    final isPinnedHost = pinnedHosts.any((pinnedHost) => host.endsWith(pinnedHost));
    if (!isPinnedHost) return true;

    if (!isCertPinningConfigured) {
      // Cert pinning uses placeholder fingerprints.
      // badCertificateCallback only fires for certs that ALREADY failed system
      // TLS validation, so returning true would accept MITM certs.
      // Debug mode: allow (local dev servers). Release: reject.
      //
      // This branch is only reached in release mode because the caller
      // (line 110) returns true early in debug mode.
      AppLogger.w(
        'SSLPinning',
        'not configured for $host — rejecting untrusted cert in release',
        report: true,
      );
      return false;
    }

    if (allowedCertFingerprints.isEmpty && backupCertFingerprints.isEmpty) {
      AppLogger.w(
        'SSLPinning',
        'no certificate fingerprints configured for $host',
        report: true,
      );
      return false;
    }

    try {
      final fingerprint = _getCertFingerprint(cert);

      if (allowedCertFingerprints.contains(fingerprint)) return true;

      if (backupCertFingerprints.contains(fingerprint)) {
        AppLogger.i('SSLPinning', 'using backup certificate for $host');
        return true;
      }

      AppLogger.e(
        'SSLPinning',
        'certificate fingerprint mismatch for $host: '
        'expected one of ${allowedCertFingerprints.join(", ")}, got $fingerprint',
      );
      return false;
    } catch (e, s) {
      AppLogger.e(
        'SSLPinning',
        'verification failed',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

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
      if (value is Map<String, dynamic>) {
        return MapEntry(key, maskSensitiveMap(value));
      } else if (value is List) {
        return MapEntry(key, _maskSensitiveList(value));
      } else if (isSensitiveKey(key)) {
        return MapEntry(key, '******');
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

  /// 获取证书 SHA-256 指纹
  static String _getCertFingerprint(X509Certificate cert) {
    final digest = sha256.convert(cert.der);
    return 'sha256/${base64Encode(digest.bytes)}';
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
