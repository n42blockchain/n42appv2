import 'dart:async';
import 'dart:convert';

import '../../../core/security/secure_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../api/id_hub_api.dart';
import '../models/id_hub_models.dart';

/// Manages N42 ID Tokens per root DID: caches them in SecureStorage, refreshes
/// ahead of expiry with rotating refresh tokens, and clears on logout.
///
/// Rotating refresh means replaying a stale refresh revokes the whole session
/// family, so refreshes for one DID are single-flighted (concurrent callers
/// share one in-flight future) to avoid self-inflicted revocation.
class IdTokenStore {
  final IdHubApi _api;
  final SecureStorage _storage;

  /// Refresh this many seconds before the token actually expires.
  static const int _refreshSkewSeconds = 60;

  final Map<String, Future<String?>> _inflight = {};

  IdTokenStore({IdHubApi? api, SecureStorage? storage})
    : _api = api ?? IdHubApi(),
      _storage = storage ?? SecureStorage();

  /// Persist a freshly issued token bundle under its DID.
  Future<void> save(String did, IdHubTokenResponse res) async {
    final stored = StoredIdToken.fromToken(res);
    await _storage.saveIdHubToken(did, jsonEncode(stored.toJson()));
  }

  Future<StoredIdToken?> _read(String did) async {
    final raw = await _storage.getIdHubToken(did);
    if (raw == null || raw.isEmpty) return null;
    try {
      return StoredIdToken.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool _isFresh(StoredIdToken t) =>
      t.expiresAt - _refreshSkewSeconds * 1000 >
      DateTime.now().millisecondsSinceEpoch;

  /// Return a valid access token for [did], refreshing if within the skew
  /// window. Null if nothing is cached or the refresh failed (caller re-logs-in).
  Future<String?> getValidToken(String did) async {
    final stored = await _read(did);
    if (stored == null) return null;
    if (_isFresh(stored)) return stored.accessToken;

    final existing = _inflight[did];
    if (existing != null) return existing;

    // NOTE: statement body, not `=> _inflight.remove(did)`. Map.remove returns
    // the stored future, and an arrow whenComplete would treat that as a future
    // to await - i.e. the future awaiting itself, a deadlock.
    final future = _refresh(did, stored).whenComplete(() {
      _inflight.remove(did);
    });
    _inflight[did] = future;
    return future;
  }

  Future<String?> _refresh(String did, StoredIdToken stored) async {
    final refreshToken = stored.refreshToken;
    if (refreshToken == null) return null;
    try {
      final res = await _api.refresh(refreshToken);
      final next = StoredIdToken.fromToken(res, fallbackSid: stored.sid);
      await _storage.saveIdHubToken(did, jsonEncode(next.toJson()));
      return next.accessToken;
    } on IdHubException catch (e) {
      // A revoked/invalid refresh is terminal: clear so the next call re-logs-in
      // rather than looping on a dead refresh.
      if (e.statusCode == 401) {
        await _storage.deleteIdHubToken(did);
        return null;
      }
      AppLogger.w('IdTokenStore', 'refresh failed: $e');
      return null;
    } catch (e) {
      AppLogger.w('IdTokenStore', 'refresh error: $e');
      return null;
    }
  }

  /// Revoke the session server-side (best effort) and drop the local token.
  Future<void> revokeAndClear(String did) async {
    final stored = await _read(did);
    if (stored != null) {
      try {
        await _api.revoke(
          accessToken: stored.accessToken,
          refreshToken: stored.refreshToken,
        );
      } catch (e) {
        AppLogger.w('IdTokenStore', 'revoke failed: $e');
      }
    }
    await _storage.deleteIdHubToken(did);
  }
}
