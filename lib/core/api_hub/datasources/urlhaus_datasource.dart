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
  static const Set<String> _definitiveSafeStatuses = {'no_results'};

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
      ).timeout(const Duration(seconds: 8));

      final parsed = parseUrlResponse(url, raw);
      if (parsed.shouldCache) {
        _addToCache(url, parsed.threat);
      }
      return parsed.threat;
    } catch (e) {
      _debugLog('UrlhausDatasource.checkUrl error: $e');
      // Fail-closed: treat network/parse errors as suspicious
      return UrlThreat(
        url: url,
        isMalicious: true,
        threatType: 'check_failed',
        source: _source,
        tags: ['error:${e.runtimeType}'],
      );
    }
  }

  /// Check a host/domain against URLhaus.
  static Future<UrlThreat> checkHost(String host) async {
    final normalizedHost = host.trim().toLowerCase();
    if (normalizedHost.isEmpty) return UrlThreat.safe(host);

    final cacheKey = 'host:$normalizedHost';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    try {
      final raw = await ExternalHttp.post(
        '$_base/host/',
        data: 'host=${Uri.encodeComponent(normalizedHost)}',
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: 8));

      final parsed = parseHostResponse(normalizedHost, raw);
      if (parsed.shouldCache) {
        _addToCache(cacheKey, parsed.threat);
      }
      return parsed.threat;
    } catch (e) {
      _debugLog('UrlhausDatasource.checkHost error: $e');
      // Fail-closed: treat network/parse errors as suspicious
      return UrlThreat(
        url: normalizedHost,
        isMalicious: true,
        threatType: 'check_failed',
        source: _source,
        tags: ['error:${e.runtimeType}'],
      );
    }
  }

  @visibleForTesting
  static ({UrlThreat threat, bool shouldCache}) parseUrlResponse(
    String url,
    dynamic raw,
  ) {
    if (raw == null || raw is! Map) {
      return (threat: UrlThreat.safe(url), shouldCache: false);
    }

    final queryStatus = raw['query_status']?.toString();
    if (queryStatus != 'ok') {
      return (
        threat: UrlThreat.safe(url),
        shouldCache: _definitiveSafeStatuses.contains(queryStatus),
      );
    }

    final tags = <String>[];
    final rawTags = raw['tags'];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t is String && t.isNotEmpty) tags.add(t);
      }
    }

    final threat = raw['threat']?.toString();
    return (
      threat: UrlThreat(
        url: url,
        isMalicious: true,
        threatType: threat ?? 'malware',
        source: _source,
        tags: tags,
      ),
      shouldCache: true,
    );
  }

  @visibleForTesting
  static ({UrlThreat threat, bool shouldCache}) parseHostResponse(
    String host,
    dynamic raw,
  ) {
    if (raw == null || raw is! Map) {
      return (threat: UrlThreat.safe(host), shouldCache: false);
    }

    final queryStatus = raw['query_status']?.toString();
    if (queryStatus != 'ok') {
      return (
        threat: UrlThreat.safe(host),
        shouldCache: _definitiveSafeStatuses.contains(queryStatus),
      );
    }

    final urlCount = (raw['url_count'] as num?)?.toInt() ?? 0;
    if (urlCount <= 0) {
      return (threat: UrlThreat.safe(host), shouldCache: true);
    }

    return (
      threat: UrlThreat(
        url: host,
        isMalicious: true,
        threatType: 'malware_host',
        source: _source,
        tags: ['urls_count:$urlCount'],
      ),
      shouldCache: true,
    );
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

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
