// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import '../models/url_threat.dart';

/// URLhaus API datasource (abuse.ch — free, no key required).
///
/// API: https://urlhaus-api.abuse.ch/v1/
/// Uses POST requests to check URLs against the URLhaus malware database.
class UrlhausDatasource {
  static const String _base = 'https://urlhaus-api.abuse.ch/v1';
  static const String _source = 'URLhaus';

  // In-memory cache: URL → result
  static final Map<String, UrlThreat> _cache = {};
  static const _maxCacheSize = 500;

  /// Check if a [url] is in the URLhaus malware database.
  ///
  /// Returns [UrlThreat] with isMalicious=true if the URL is listed,
  /// or isMalicious=false (safe) if not found or on any error.
  static Future<UrlThreat> checkUrl(String url) async {
    if (url.isEmpty) return UrlThreat.safe(url);

    // Check cache
    final cached = _cache[url];
    if (cached != null) return cached;

    try {
      final raw = await ExternalHttp.post(
        '$_base/url/',
        data: 'url=${Uri.encodeComponent(url)}',
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (raw == null || raw is! Map) return UrlThreat.safe(url);

      final queryStatus = raw['query_status']?.toString();

      // "no_results" means URL not in database → safe
      if (queryStatus != 'ok') {
        final result = UrlThreat.safe(url);
        _addToCache(url, result);
        return result;
      }

      // URL found in URLhaus database → malicious
      final tags = <String>[];
      final rawTags = raw['tags'];
      if (rawTags is List) {
        for (final t in rawTags) {
          if (t is String && t.isNotEmpty) tags.add(t);
        }
      }

      final threat = raw['threat']?.toString();
      final result = UrlThreat(
        url: url,
        isMalicious: true,
        threatType: threat ?? 'malware',
        source: _source,
        tags: tags,
      );
      _addToCache(url, result);
      return result;
    } catch (e) {
      debugPrint('UrlhausDatasource.checkUrl error: $e');
      // Fail-open: return safe on error
      return UrlThreat.safe(url);
    }
  }

  /// Check a host/domain against URLhaus.
  static Future<UrlThreat> checkHost(String host) async {
    if (host.isEmpty) return UrlThreat.safe(host);

    final cached = _cache['host:$host'];
    if (cached != null) return cached;

    try {
      final raw = await ExternalHttp.post(
        '$_base/host/',
        data: 'host=${Uri.encodeComponent(host)}',
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (raw == null || raw is! Map) return UrlThreat.safe(host);

      final queryStatus = raw['query_status']?.toString();
      if (queryStatus != 'ok') {
        final result = UrlThreat.safe(host);
        _addToCache('host:$host', result);
        return result;
      }

      // Host has entries in URLhaus
      final urlCount = (raw['url_count'] as num?)?.toInt() ?? 0;
      if (urlCount == 0) {
        final result = UrlThreat.safe(host);
        _addToCache('host:$host', result);
        return result;
      }

      final result = UrlThreat(
        url: host,
        isMalicious: true,
        threatType: 'malware_host',
        source: _source,
        tags: ['urls_count:$urlCount'],
      );
      _addToCache('host:$host', result);
      return result;
    } catch (e) {
      debugPrint('UrlhausDatasource.checkHost error: $e');
      return UrlThreat.safe(host);
    }
  }

  static void _addToCache(String key, UrlThreat result) {
    if (_cache.length >= _maxCacheSize) {
      // Evict oldest entries
      final keysToRemove = _cache.keys.take(_maxCacheSize ~/ 4).toList();
      for (final k in keysToRemove) {
        _cache.remove(k);
      }
    }
    _cache[key] = result;
  }
}
