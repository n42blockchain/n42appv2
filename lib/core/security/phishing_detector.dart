// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phishing URL Detection Service
///
/// Provides synchronous URL phishing checks with three-layer protection:
/// 1. Embedded seed blocklist — offline, immediate, no I/O
/// 2. SharedPreferences cache — survives app restarts
/// 3. MetaMask eth-phishing-detect remote refresh — every 6 hours
///
/// [checkUrl] is always synchronous (in-memory Set lookup, O(n) worst-case).
/// Call [initialize] once at app startup before the first URL is opened.
///
/// Session whitelist: URLs that the user explicitly approved via
/// "Proceed Anyway" are remembered for the duration of the app session.
class PhishingDetector {
  PhishingDetector._();

  static final PhishingDetector instance = PhishingDetector._();

  // SharedPreferences keys managed internally
  static const String _spCacheKey = 'phishing_blocklist_v1';
  static const String _spCacheTimeKey = 'phishing_blocklist_time_v1';
  static const Duration _cacheTtl = Duration(hours: 6);

  /// MetaMask community-maintained phishing blocklist.
  /// JSON format: { "blacklist": [...], "whitelist": [...], "fuzzylist": [...] }
  static const String _remoteUrl =
      'https://raw.githubusercontent.com/MetaMask/eth-phishing-detect/master/src/config.json';

  /// Seed blocklist — covers the most prevalent crypto phishing domains.
  /// Applied immediately on first launch before the remote list loads.
  static const List<String> _seedBlocklist = [
    'metamask-login.com',
    'metamask-wallet.com',
    'metamask-support.com',
    'metamask.io.live',
    'myetherwallet.xyz',
    'myetherwallet.us',
    'myetherwallet.info',
    'wallet-connect.live',
    'walletconnect.io.live',
    'walletconnect-app.com',
    'uniswap.exchange.live',
    'uniswap.org.live',
    'pancakeswap.finance.live',
    'pancakeswap-farm.com',
    'airdrop-claim.xyz',
    'crypto-airdrop.io',
    'claim-nft.xyz',
    'nft-claim.live',
    'nft-airdrop.xyz',
    'nft-free.xyz',
    'free-nft.live',
    'wallet-recovery.net',
    'coinbase-wallet.live',
    'trustwallet.live',
    'trustwallet-app.com',
    'opensea-io.live',
    'opensea.io.live',
    'etherscan.io.live',
    'connect-wallet.live',
    'connect-metamask.io',
    'claim-reward.live',
    'crypto-claim.xyz',
    'defi-airdrop.xyz',
    'aave.finance.live',
    'compound.finance.live',
    'yearn.finance.live',
    'metamask-io.com',
    'metamask-io.net',
    'metamaskwallet.io',
    'metamaskapp.com',
    'metamask-airdrop.com',
    'metamask-giveaway.com',
    'etherscanio.live',
    'claim-tokens.live',
    'token-airdrop.live',
    'receive-nft.com',
  ];

  final Set<String> _blocklist = Set<String>.from(_seedBlocklist);
  final Set<String> _whitelist = {};

  /// Per-session whitelist: cleared on every app restart.
  final Set<String> _sessionWhitelist = {};

  bool _initialized = false;
  SharedPreferences? _prefs;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Initialize the detector. Must be called once at app startup.
  ///
  /// Loads the cached blocklist from [prefs] into memory, then triggers
  /// a non-blocking background network refresh.
  Future<void> initialize(SharedPreferences prefs) async {
    if (_initialized) return;
    _prefs = prefs;
    _initialized = true;
    await _loadFromCache();
    // Fire-and-forget — do NOT await so we don't block startup
    unawaited(_refreshInBackground());
  }

  /// Synchronously check whether [rawUrl] is a phishing site.
  ///
  /// Fail-open: returns [PhishingCheckResult.safe] if not yet initialized.
  PhishingCheckResult checkUrl(String rawUrl) {
    if (!_initialized) return PhishingCheckResult.safe;

    final host = _extractHost(rawUrl);
    if (host == null || host.isEmpty) return PhishingCheckResult.safe;

    // User chose "Proceed Anyway" for this host — respect for this session
    if (_sessionWhitelist.contains(host)) return PhishingCheckResult.safe;

    // Explicit remote whitelist always overrides blocklist
    if (_isWhitelisted(host)) return PhishingCheckResult.safe;

    if (_isBlocked(host)) return PhishingCheckResult.phishing;

    return PhishingCheckResult.safe;
  }

  /// Whitelist a URL for the current app session (user clicked "Proceed Anyway").
  ///
  /// The host extracted from [rawUrl] is stored in the session whitelist only;
  /// it is NOT persisted and does NOT modify the shared blocklist.
  void allowForSession(String rawUrl) {
    final host = _extractHost(rawUrl);
    if (host != null && host.isNotEmpty) {
      _sessionWhitelist.add(host);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  String? _extractHost(String rawUrl) {
    try {
      return Uri.parse(rawUrl).host.toLowerCase();
    } catch (_) {
      return null;
    }
  }

  bool _isBlocked(String host) {
    if (_blocklist.contains(host)) return true;
    for (final b in _blocklist) {
      if (host.endsWith('.$b')) return true;
    }
    return false;
  }

  bool _isWhitelisted(String host) {
    if (_whitelist.contains(host)) return true;
    for (final w in _whitelist) {
      if (host == w || host.endsWith('.$w')) return true;
    }
    return false;
  }

  Future<void> _loadFromCache() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final cachedJson = prefs.getString(_spCacheKey);
    if (cachedJson == null) return;

    try {
      final map = jsonDecode(cachedJson) as Map<String, dynamic>;
      final blacklist = (map['blacklist'] as List<dynamic>? ?? []).cast<String>();
      final whitelist = (map['whitelist'] as List<dynamic>? ?? []).cast<String>();
      _blocklist.addAll(blacklist);
      _whitelist.addAll(whitelist);
      debugPrint(
        '[PhishingDetector] Cache loaded: ${blacklist.length} blocked, '
        '${whitelist.length} whitelisted',
      );
    } catch (e) {
      debugPrint('[PhishingDetector] Cache parse error: $e');
    }
  }

  Future<void> _refreshInBackground() async {
    final prefs = _prefs;
    if (prefs == null) return;

    // Check cache freshness
    final lastFetchMs = prefs.getInt(_spCacheTimeKey) ?? 0;
    final ageMs = DateTime.now().millisecondsSinceEpoch - lastFetchMs;
    if (lastFetchMs > 0 && ageMs < _cacheTtl.inMilliseconds) {
      debugPrint('[PhishingDetector] Cache still fresh, skipping refresh');
      return;
    }

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse(_remoteUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        client.close();
        debugPrint('[PhishingDetector] Remote returned ${response.statusCode}');
        return;
      }

      final body = await response.transform(utf8.decoder).join();
      client.close();

      final map = jsonDecode(body) as Map<String, dynamic>;
      final blacklist = (map['blacklist'] as List<dynamic>? ?? []).cast<String>();
      final whitelist = (map['whitelist'] as List<dynamic>? ?? []).cast<String>();

      _blocklist.addAll(blacklist);
      _whitelist.addAll(whitelist);

      // Persist only blacklist + whitelist (skip fuzzylist for now)
      await prefs.setString(
        _spCacheKey,
        jsonEncode({'blacklist': blacklist, 'whitelist': whitelist}),
      );
      await prefs.setInt(_spCacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint(
        '[PhishingDetector] Remote refresh done: '
        '${blacklist.length} blocked, ${whitelist.length} whitelisted',
      );
    } catch (e) {
      // Non-fatal: seed list + cached list continue to protect the user
      debugPrint('[PhishingDetector] Background refresh failed: $e');
    }
  }
}

/// Result of [PhishingDetector.checkUrl].
enum PhishingCheckResult {
  /// URL appears safe — allow navigation.
  safe,

  /// URL is on the phishing blocklist — block and warn user.
  phishing,
}
