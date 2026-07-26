/// N42 ID Hub contract models (manual JSON, snake_case keys) for the subset the
/// wallet app consumes. Mirrors the ID Hub OpenAPI.
library;

import 'dart:convert';

/// Login/refresh result: an N42 ID Token plus a rotating refresh token.
class IdHubTokenResponse {
  final String accessToken;
  final int expiresIn;
  final String? refreshToken;
  final String? scope;

  /// Root DID (so the client need not decode the JWT).
  final String? sub;
  final String? sid;
  final int? jwtExpiresAt;

  const IdHubTokenResponse({
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
    this.scope,
    this.sub,
    this.sid,
    this.jwtExpiresAt,
  });

  factory IdHubTokenResponse.fromJson(
    Map<String, dynamic> json, {
    required String expectedAudience,
    String? expectedSubject,
  }) {
    final accessToken = json['access_token'];
    final expiresIn = json['expires_in'];
    if (accessToken is! String ||
        accessToken.isEmpty ||
        json['token_type'] != 'Bearer' ||
        expiresIn is! num ||
        expiresIn <= 0) {
      throw const FormatException('Invalid ID Hub token response');
    }
    final claims = _decodeJwtPayload(accessToken);
    final issuer = claims['iss'];
    final subject = claims['sub'];
    final audience = claims['aud'];
    final expiresAtSeconds = claims['exp'];
    final audiences = audience is List
        ? audience.whereType<String>().toList()
        : <String>[if (audience is String) audience];
    if (issuer != 'did:web:id.n42.ai' ||
        subject is! String ||
        !subject.startsWith('did:') ||
        !audiences.contains(expectedAudience) ||
        expiresAtSeconds is! num ||
        expiresAtSeconds * 1000 <= DateTime.now().millisecondsSinceEpoch ||
        (expectedSubject != null && subject != expectedSubject) ||
        (json['sub'] != null && json['sub'] != subject)) {
      throw const FormatException('Invalid ID Hub token claims');
    }
    return IdHubTokenResponse(
      accessToken: accessToken,
      expiresIn: expiresIn.toInt(),
      refreshToken: json['refresh_token'] as String?,
      scope: json['scope'] as String?,
      sub: subject,
      sid: json['sid'] as String?,
      jwtExpiresAt: expiresAtSeconds.toInt() * 1000,
    );
  }
}

/// A wallet login challenge: the exact message the wallet must personal_sign.
class IdHubChallenge {
  final String challengeId;
  final String message;
  final String expiresAt;

  const IdHubChallenge({
    required this.challengeId,
    required this.message,
    required this.expiresAt,
  });

  factory IdHubChallenge.fromJson(Map<String, dynamic> json) => IdHubChallenge(
    challengeId: json['challenge_id'] as String,
    message: json['message'] as String,
    expiresAt: json['expires_at'] as String,
  );
}

/// Result of a wallet login: the token plus whether a DID was just provisioned.
class IdHubWalletLoginResult {
  final IdHubTokenResponse token;

  /// True when this login minted a brand-new root DID for the wallet.
  final bool didCreated;

  const IdHubWalletLoginResult({required this.token, this.didCreated = false});
}

/// Locally persisted per-DID token bundle.
class StoredIdToken {
  final String accessToken;
  final String? refreshToken;

  /// Absolute expiry, epoch milliseconds.
  final int expiresAt;
  final String? sid;

  const StoredIdToken({
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
    this.sid,
  });

  factory StoredIdToken.fromToken(
    IdHubTokenResponse res, {
    String? fallbackSid,
  }) => StoredIdToken(
    accessToken: res.accessToken,
    refreshToken: res.refreshToken,
    expiresAt: res.jwtExpiresAt == null
        ? DateTime.now().millisecondsSinceEpoch + res.expiresIn * 1000
        : [
            DateTime.now().millisecondsSinceEpoch + res.expiresIn * 1000,
            res.jwtExpiresAt!,
          ].reduce((a, b) => a < b ? a : b),
    sid: res.sid ?? fallbackSid,
  );

  factory StoredIdToken.fromJson(Map<String, dynamic> json) => StoredIdToken(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String?,
    expiresAt: (json['expires_at'] as num).toInt(),
    sid: json['sid'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'access_token': accessToken,
    if (refreshToken != null) 'refresh_token': refreshToken,
    'expires_at': expiresAt,
    if (sid != null) 'sid': sid,
  };
}

/// A cross-device bind session as seen by the scanning wallet.
class IdHubBindSession {
  final String sessionId;

  /// `wallet-binding` or `login`.
  final String type;

  /// `pending`, `completed`, or `expired`.
  final String status;
  final String? message;
  final String? expiresAt;

  const IdHubBindSession({
    required this.sessionId,
    required this.type,
    required this.status,
    this.message,
    this.expiresAt,
  });

  factory IdHubBindSession.fromJson(Map<String, dynamic> json) =>
      IdHubBindSession(
        sessionId: json['session_id'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        message: json['message'] as String?,
        expiresAt: json['expires_at'] as String?,
      );
}

/// RFC 9457 problem+json error surfaced from the hub, carrying a stable code.
class IdHubException implements Exception {
  final String message;
  final int? statusCode;

  /// Problem `type` tail (e.g. `binding-conflict`, `challenge-expired`).
  final String? code;

  IdHubException(this.message, {this.statusCode, this.code});

  @override
  String toString() => 'IdHubException($statusCode $code): $message';
}

Map<String, dynamic> _decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw const FormatException('Invalid ID Hub access token');
  }
  try {
    final normalized = base64Url.normalize(parts[1]);
    final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid ID Hub access token');
    }
    return decoded;
  } catch (_) {
    throw const FormatException('Invalid ID Hub access token');
  }
}
