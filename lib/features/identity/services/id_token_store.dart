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
  final Map<String, int> _generations = {};
  final Set<String> _revoking = {};

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
      final stored = StoredIdToken.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (stored.accessToken.isEmpty || stored.expiresAt <= 0) {
        await _storage.deleteIdHubToken(did);
        return null;
      }
      return stored;
    } catch (_) {
      await _storage.deleteIdHubToken(did);
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
    if (refreshToken == null || _revoking.contains(did)) return null;
    final generation = _generations[did] ?? 0;
    try {
      final res = await _api.refresh(refreshToken, expectedDid: did);
      final next = StoredIdToken.fromToken(res, fallbackSid: stored.sid);
      if (_revoking.contains(did) || (_generations[did] ?? 0) != generation) {
        return null;
      }
      await _storage.saveIdHubToken(did, jsonEncode(next.toJson()));
      return next.accessToken;
    } on IdHubException catch (e) {
      // A rejected refresh is terminal: clear so the next call re-logs-in rather
      // than replaying a dead refresh (replaying a rotated token revokes the
      // whole session family server-side). OAuth-style token endpoints report
      // this as 400 invalid_grant as well as 401/403.
      if (e.statusCode == 400 || e.statusCode == 401 || e.statusCode == 403) {
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
    if (_revoking.contains(did)) return;
    _revoking.add(did);
    final stored = await _read(did);
    _generations[did] = (_generations[did] ?? 0) + 1;
    final pending = _inflight[did];
    try {
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
      if (pending != null) await pending;
      await _storage.deleteIdHubToken(did);
    } finally {
      _revoking.remove(did);
    }
  }
}
