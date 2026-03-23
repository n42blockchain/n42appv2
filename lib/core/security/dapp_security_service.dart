// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Security level enum ──────────────────────────────────────────────────

enum DAppSecurityLevel {
  /// In the curated trusted DApp list AND using HTTPS.
  verified,

  /// HTTPS, no suspicious pattern, not in blocklist.
  safe,

  /// HTTP or domain matches suspicious heuristics.
  caution,

  /// Matched the phishing blocklist.
  blocked;

  int get colorValue {
    switch (this) {
      case DAppSecurityLevel.verified:
        return 0xFF22C55E; // green-500
      case DAppSecurityLevel.safe:
        return 0xFF3B82F6; // blue-500
      case DAppSecurityLevel.caution:
        return 0xFFF97316; // orange-500
      case DAppSecurityLevel.blocked:
        return 0xFFEF4444; // red-500
    }
  }
}

// ─── Security info ────────────────────────────────────────────────────────

class DAppSecurityInfo {
  final DAppSecurityLevel level;

  /// Human-readable reason (for caution / blocked levels).
  final String? reason;

  const DAppSecurityInfo(this.level, [this.reason]);

  static const verified = DAppSecurityInfo(DAppSecurityLevel.verified);
  static const safe = DAppSecurityInfo(DAppSecurityLevel.safe);
}

// ─── DApp Security Service ────────────────────────────────────────────────

/// Computes a risk level for a DApp URL by combining:
/// 1. PhishingDetector blocklist (Layer 1 – most definitive)
/// 2. Curated trusted-domain list (upgraded to Verified when HTTPS)
/// 3. HTTPS enforcement (HTTP downgrades to Caution)
/// 4. Suspicious domain-name heuristics (keyword patterns / risky TLDs)
///
/// Results are cached in memory for 5 minutes per host.
class DAppSecurityService {
  // ── Trusted domains extracted from recommended_dapps.dart ───────────────
  static const Set<String> _trustedDomains = {
    // DEX
    'app.uniswap.org', 'uniswap.org',
    'pancakeswap.finance',
    'app.1inch.io', '1inch.io',
    'www.sushi.com', 'sushi.com',
    'curve.fi',
    // DeFi
    'app.aave.com', 'aave.com',
    'stake.lido.fi', 'lido.fi',
    'app.compound.finance', 'compound.finance',
    'yearn.fi',
    'app.eigenlayer.xyz', 'eigenlayer.xyz',
    // NFT
    'opensea.io',
    'blur.io',
    'zora.co',
    // Bridge
    'stargate.finance',
    'across.to',
    'www.orbiter.finance', 'orbiter.finance',
    // Tools
    'etherscan.io',
    'debank.com',
    'revoke.cash',
    'dune.com',
    // WalletConnect / Reown infra
    'walletconnect.com', 'reown.com',
  };

  // ── Suspicious keyword patterns ──────────────────────────────────────────
  static final List<RegExp> _suspiciousPatterns = [
    RegExp(r'metamask', caseSensitive: false),
    RegExp(r'wallet-connect', caseSensitive: false),
    RegExp(r'(?:^|[.-])wallet(?:[.-]|$)', caseSensitive: false),
    RegExp(r'(?:^|[.-])claim(?:[.-]|$)', caseSensitive: false),
    RegExp(r'airdrop', caseSensitive: false),
    RegExp(r'(?:^|[.-])login(?:[.-]|$)', caseSensitive: false),
    RegExp(r'(?:^|[.-])secure(?:[.-]|$)', caseSensitive: false),
    RegExp(r'(?:^|[.-])verify(?:[.-]|$)', caseSensitive: false),
    RegExp(r'(?:^|[.-])support(?:[.-]|$)', caseSensitive: false),
    RegExp(r'(?:^|[.-])recover(?:[.-]|$)', caseSensitive: false),
  ];

  // ── Risky TLD endings ────────────────────────────────────────────────────
  static final RegExp _riskyTld =
      RegExp(r'\.(xyz|live|click|monster|buzz|top|gq|ml|cf|ga|tk)$',
          caseSensitive: false);

  // ── 5-minute in-memory cache keyed by lowercase host ─────────────────────
  static final Map<String, _CacheEntry> _cache = {};

  /// Maximum number of cached entries to prevent unbounded memory growth.
  static const int _maxCacheSize = 200;

  /// Returns the security info for [url].
  /// Safe to call synchronously — no I/O after first [PhishingDetector.initialize].
  static DAppSecurityInfo check(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return const DAppSecurityInfo(DAppSecurityLevel.caution, 'Invalid URL');
    }

    final host = uri.host.toLowerCase();

    // Cache hit?
    final cached = _cache[host];
    if (cached != null && !cached.isExpired) return cached.info;

    // Evict expired entries and enforce size limit
    if (_cache.length >= _maxCacheSize) {
      _cache.removeWhere((_, entry) => entry.isExpired);
      // If still over limit after evicting expired, remove oldest entries
      if (_cache.length >= _maxCacheSize) {
        final keysToRemove = _cache.keys.take(_cache.length - _maxCacheSize + 1).toList();
        for (final key in keysToRemove) {
          _cache.remove(key);
        }
      }
    }

    DAppSecurityInfo result;

    // 1. Phishing blocklist
    if (PhishingDetector.instance.checkUrl(url) ==
        PhishingCheckResult.phishing) {
      result = const DAppSecurityInfo(
          DAppSecurityLevel.blocked, 'Known phishing site');
    }
    // 2. Trusted list + HTTPS → Verified
    else if (_isInTrustedList(host) && uri.isScheme('https')) {
      result = DAppSecurityInfo.verified;
    }
    // 3. Not HTTPS → Caution
    else if (!uri.isScheme('https')) {
      result = const DAppSecurityInfo(
          DAppSecurityLevel.caution, 'Not using HTTPS');
    }
    // 4. Suspicious patterns or risky TLD → Caution
    else if (_hasSuspiciousPattern(host) || _riskyTld.hasMatch(host)) {
      result = const DAppSecurityInfo(
          DAppSecurityLevel.caution, 'Suspicious domain name');
    }
    // 5. Safe
    else {
      result = DAppSecurityInfo.safe;
    }

    _cache[host] = _CacheEntry(result);
    return result;
  }

  static bool _isInTrustedList(String host) {
    if (_trustedDomains.contains(host)) return true;
    for (final trusted in _trustedDomains) {
      if (host.endsWith('.$trusted')) return true;
    }
    return false;
  }

  static bool _hasSuspiciousPattern(String host) =>
      _suspiciousPatterns.any((p) => p.hasMatch(host));
}

class _CacheEntry {
  final DAppSecurityInfo info;
  final DateTime _at = DateTime.now();
  _CacheEntry(this.info);
  bool get isExpired =>
      DateTime.now().difference(_at) > const Duration(minutes: 5);
}

// ─── DApp Permissions Tracker ─────────────────────────────────────────────

/// Records which JSON-RPC methods each DApp origin has invoked.
///
/// Only "significant" methods are tracked (signing, sending, switching chain).
/// Data is persisted in SharedPreferences so it survives app restarts.
/// Per-origin method list is capped at [_maxMethods] entries.
class DAppPermissionsTracker {
  static const _spKey = 'dapp_perms_v1';
  static const _maxMethods = 12;

  /// Only track user-visible / security-sensitive methods.
  static const _trackable = {
    'eth_sendTransaction',
    'eth_signTransaction',
    'personal_sign',
    'eth_sign',
    'eth_signTypedData',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
    'wallet_switchEthereumChain',
    'wallet_addEthereumChain',
    'eth_requestAccounts',
    'tron_signMessage',
    'tron_signTransaction',
  };

  // ── In-memory cache: origin → ordered method list ─────────────────────────
  static Map<String, List<String>>? _mem;

  /// Record that [origin] called [method].
  /// No-op if [method] is not trackable or [origin] is empty.
  static Future<void> record(String origin, String method) async {
    if (origin.isEmpty || !_trackable.contains(method)) return;
    try {
      final map = await _load();
      final list = List<String>.from(map[origin] ?? []);
      if (!list.contains(method)) {
        list.add(method);
        if (list.length > _maxMethods) list.removeAt(0);
      }
      map[origin] = list;
      _mem = map;
      await _save(map);
    } catch (e) {
      if (kDebugMode) debugPrint('DAppPermissionsTracker.record error: $e');
    }
  }

  /// Returns the tracked method list for [origin], newest last.
  static Future<List<String>> getForOrigin(String origin) async {
    if (origin.isEmpty) return [];
    final map = await _load();
    return List<String>.unmodifiable(map[origin] ?? []);
  }

  /// Returns the full map { origin → [methods] }.
  static Future<Map<String, List<String>>> getAll() async => _load();

  /// Remove permission record for [origin].
  static Future<void> clearForOrigin(String origin) async {
    final map = await _load();
    map.remove(origin);
    _mem = map;
    await _save(map);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<Map<String, List<String>>> _load() async {
    if (_mem != null) return Map.from(_mem!);
    try {
      final raw = (await _prefs()).getString(_spKey);
      if (raw == null) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as List).cast<String>()));
    } catch (e) {
      if (kDebugMode) debugPrint('DAppPermissionsTracker._load error: $e');
      return {};
    }
  }

  static Future<void> _save(Map<String, List<String>> map) async {
    try {
      await (await _prefs()).setString(_spKey, jsonEncode(map));
    } catch (e) {
      if (kDebugMode) debugPrint('DAppPermissionsTracker._save error: $e');
    }
  }
}
