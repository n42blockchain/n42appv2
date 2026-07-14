/// N42 ID Hub contract models (manual JSON, snake_case keys) for the subset the
/// wallet app consumes. Mirrors the ID Hub OpenAPI.
library;

/// Login/refresh result: an N42 ID Token plus a rotating refresh token.
class IdHubTokenResponse {
  final String accessToken;
  final int expiresIn;
  final String? refreshToken;
  final String? scope;

  /// Root DID (so the client need not decode the JWT).
  final String? sub;
  final String? sid;

  const IdHubTokenResponse({
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
    this.scope,
    this.sub,
    this.sid,
  });

  factory IdHubTokenResponse.fromJson(Map<String, dynamic> json) =>
      IdHubTokenResponse(
        accessToken: json['access_token'] as String,
        expiresIn: (json['expires_in'] as num).toInt(),
        refreshToken: json['refresh_token'] as String?,
        scope: json['scope'] as String?,
        sub: json['sub'] as String?,
        sid: json['sid'] as String?,
      );
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

  factory StoredIdToken.fromToken(IdHubTokenResponse res, {String? fallbackSid}) =>
      StoredIdToken(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
        expiresAt: DateTime.now().millisecondsSinceEpoch + res.expiresIn * 1000,
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
