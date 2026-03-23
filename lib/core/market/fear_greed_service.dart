// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';

// ─── Level enum ────────────────────────────────────────────────────────────

enum FearGreedLevel {
  extremeFear,
  fear,
  neutral,
  greed,
  extremeGreed;

  String get emoji {
    switch (this) {
      case FearGreedLevel.extremeFear:
        return '😱';
      case FearGreedLevel.fear:
        return '😨';
      case FearGreedLevel.neutral:
        return '😐';
      case FearGreedLevel.greed:
        return '😏';
      case FearGreedLevel.extremeGreed:
        return '🤑';
    }
  }

  // Tailwind-inspired palette mapped to flutter Color ints
  int get colorValue {
    switch (this) {
      case FearGreedLevel.extremeFear:
        return 0xFFEF4444; // red-500
      case FearGreedLevel.fear:
        return 0xFFF97316; // orange-500
      case FearGreedLevel.neutral:
        return 0xFFEAB308; // yellow-500
      case FearGreedLevel.greed:
        return 0xFF84CC16; // lime-500
      case FearGreedLevel.extremeGreed:
        return 0xFF22C55E; // green-500
    }
  }
}

// ─── Model ─────────────────────────────────────────────────────────────────

class FearGreedData {
  final int value; // 0–100
  final String classification;
  final DateTime updatedAt;

  const FearGreedData({
    required this.value,
    required this.classification,
    required this.updatedAt,
  });

  factory FearGreedData.fromJson(Map<String, dynamic> json) {
    final v = int.tryParse(json['value']?.toString() ?? '') ?? 50;
    final ts = int.tryParse(json['timestamp']?.toString() ?? '') ?? 0;
    return FearGreedData(
      value: v.clamp(0, 100),
      classification: json['value_classification'] as String? ?? 'Neutral',
      updatedAt: ts > 0
          ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
          : DateTime.now(),
    );
  }

  /// Map numeric value to level bucket.
  /// Boundaries follow the alternative.me classification thresholds.
  FearGreedLevel get level {
    if (value <= 25) return FearGreedLevel.extremeFear;
    if (value <= 46) return FearGreedLevel.fear;
    if (value <= 54) return FearGreedLevel.neutral;
    if (value <= 75) return FearGreedLevel.greed;
    return FearGreedLevel.extremeGreed;
  }
}

// ─── Service ───────────────────────────────────────────────────────────────

/// Fetches the Crypto Fear & Greed Index from alternative.me.
///
/// API: https://api.alternative.me/fng/?limit=1
/// Free, no API key required. Updates once per day.
/// Cache: 1 hour in memory.
class FearGreedService {
  static const _url = 'https://api.alternative.me/fng/?limit=1';

  static FearGreedData? _cached;
  static DateTime? _cachedAt;
  static Future<FearGreedData?>? _inflight;

  static Future<FearGreedData?> fetch() async {
    final cachedAt = _cachedAt;
    if (_cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < const Duration(hours: 1)) {
      return _cached;
    }
    // Deduplicate concurrent requests
    return _inflight ??= _doFetch().whenComplete(() => _inflight = null);
  }

  static Future<FearGreedData?> _doFetch() async {
    try {
      final raw = await ExternalHttp.get(_url)
          .timeout(const Duration(seconds: 8));
      final result = parseResponse(raw, fallback: _cached);
      if (result != null) {
        _cached = result;
        _cachedAt = DateTime.now();
      }
      return result;
    } catch (e) {
      _debugLog('FearGreedService.fetch error: $e');
      return _cached;
    }
  }

  @visibleForTesting
  static FearGreedData? parseResponse(dynamic raw, {FearGreedData? fallback}) {
    if (raw == null || raw is! Map) return fallback;
    final data = raw['data'];
    if (data is! List || data.isEmpty) return fallback;
    final entry = data.first;
    if (entry is! Map) return fallback;
    return FearGreedData.fromJson(Map<String, dynamic>.from(entry));
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
