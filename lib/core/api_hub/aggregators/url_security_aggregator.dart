// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import '../datasources/urlhaus_datasource.dart';
import '../models/url_threat.dart';

/// Multi-layer URL security aggregator.
///
/// Detection layers (checked in order):
/// 1. [PhishingDetector] — synchronous local blocklist (MetaMask + seeds)
/// 2. [UrlhausDatasource] — async remote malware URL check (optional)
///
/// Fail-closed: returns unknown (treated as suspicious) on any error.
class UrlSecurityAggregator {
  /// Check whether [url] is malicious.
  ///
  /// When [useRemote] is true (default), also queries URLhaus for
  /// malware URLs not covered by the phishing blocklist.
  /// Set [useRemote] to false for fast synchronous-only checks.
  static Future<UrlThreat> checkUrl(String url, {bool useRemote = true}) async {
    return checkUrlWithLookups(
      url,
      useRemote: useRemote,
      phishingLookup: PhishingDetector.instance.checkUrl,
      remoteUrlLookup: UrlhausDatasource.checkUrl,
      remoteHostLookup: UrlhausDatasource.checkHost,
    );
  }

  @visibleForTesting
  static Future<UrlThreat> checkUrlWithLookups(
    String url, {
    bool useRemote = true,
    required PhishingCheckResult Function(String url) phishingLookup,
    required Future<UrlThreat> Function(String url) remoteUrlLookup,
    required Future<UrlThreat> Function(String host) remoteHostLookup,
  }) async {
    if (url.isEmpty) return UrlThreat.safe(url);

    try {
      // Layer 1: Local phishing blocklist (synchronous)
      final phishingResult = phishingLookup(url);
      if (phishingResult == PhishingCheckResult.phishing) {
        return UrlThreat(
          url: url,
          isMalicious: true,
          threatType: 'phishing',
          source: 'PhishingDetector',
        );
      }

      // Layer 2: URLhaus remote check (async, optional)
      if (useRemote) {
        final urlhausResult = await remoteUrlLookup(url);
        if (urlhausResult.isMalicious) return urlhausResult;

        final host = Uri.tryParse(url)?.host;
        if (host != null && host.isNotEmpty) {
          final urlhausHostResult = await remoteHostLookup(host);
          if (urlhausHostResult.isMalicious) return urlhausHostResult;
        }
      }

      return UrlThreat.safe(url);
    } catch (e) {
      _debugLog('UrlSecurityAggregator.checkUrl error: $e');
      // Fail-closed: treat check failures as suspicious
      return UrlThreat(
        url: url,
        isMalicious: true,
        threatType: 'check_failed',
        source: 'UrlSecurityAggregator',
        tags: ['error:${e.runtimeType}'],
      );
    }
  }

  /// Quick synchronous-only check (no network calls).
  static bool isPhishing(String url) {
    return PhishingDetector.instance.checkUrl(url) ==
        PhishingCheckResult.phishing;
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
