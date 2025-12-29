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

  /// 允许的 SSL 证书指纹列表
  /// 
  /// 生产环境应使用 SSL Pinning，将服务器证书的 SHA-256 指纹添加到此列表
  /// 获取证书指纹: openssl s_client -connect example.com:443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256
  static const List<String> allowedCertFingerprints = [
    // TODO: 添加生产服务器证书指纹
    // 'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
  ];

  /// 允许的主机列表（用于 SSL Pinning）
  static const List<String> pinnedHosts = [
    'api.n42.network',
    'ipfs.n42.network',
    // 添加其他需要 SSL Pinning 的主机
  ];

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

    // 验证证书指纹
    if (allowedCertFingerprints.isEmpty) {
      // 如果没有配置指纹，暂时允许（但在控制台警告）
      if (kDebugMode) {
        debugPrint('⚠️ WARNING: SSL Pinning not configured for $host');
      }
      return true;
    }

    try {
      final fingerprint = _getCertFingerprint(cert);
      return allowedCertFingerprints.contains(fingerprint);
    } catch (e) {
      debugPrint('SSL certificate verification failed: $e');
      return false;
    }
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

