import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Verifies advisory verdicts; never authorizes or signs a transaction.
/// Issuer keys must come from host configuration, not the response.
class SignedRiskAssessment {
  final String issuer;
  final String transactionDigest;
  final String verdict;
  final DateTime issuedAt;
  final DateTime expiresAt;
  const SignedRiskAssessment._(
    this.issuer,
    this.transactionDigest,
    this.verdict,
    this.issuedAt,
    this.expiresAt,
  );

  static Future<SignedRiskAssessment> verify({
    required Map<String, dynamic> envelope,
    required Map<String, List<int>> trustedKeys,
    required String expectedTransactionDigest,
    required String audience,
    required DateTime now,
  }) async {
    final issuer = envelope['issuer'];
    final payload = envelope['payload'];
    final signature = envelope['signature'];
    if (issuer is! String ||
        payload is! String ||
        signature is! String ||
        payload.length > 16384 ||
        signature.length > 128 ||
        trustedKeys[issuer]?.length != 32) {
      throw const FormatException('Invalid risk assessment envelope');
    }
    final bytes = base64Url.decode(base64Url.normalize(payload));
    final signedBytes = utf8.encode('N42-RISK-V1\n$issuer\n$payload');
    final valid = await Ed25519().verify(
      signedBytes,
      signature: Signature(
        base64Url.decode(base64Url.normalize(signature)),
        publicKey: SimplePublicKey(
          trustedKeys[issuer]!,
          type: KeyPairType.ed25519,
        ),
      ),
    );
    if (!valid) {
      throw const FormatException('Invalid risk assessment signature');
    }
    final claims = jsonDecode(utf8.decode(bytes));
    if (claims is! Map ||
        claims['version'] != 1 ||
        claims['audience'] != audience ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(expectedTransactionDigest) ||
        claims['transactionDigest'] != expectedTransactionDigest ||
        !{'clear', 'warning', 'danger'}.contains(claims['verdict']) ||
        claims['issuedAt'] is! int ||
        claims['expiresAt'] is! int) {
      throw const FormatException(
        'Risk assessment does not match this request',
      );
    }
    final issued = DateTime.fromMillisecondsSinceEpoch(
      claims['issuedAt'] as int,
      isUtc: true,
    );
    final expires = DateTime.fromMillisecondsSinceEpoch(
      claims['expiresAt'] as int,
      isUtc: true,
    );
    if (issued.isAfter(now) ||
        !expires.isAfter(now) ||
        expires.difference(issued) > const Duration(minutes: 5) ||
        !expires.isAfter(issued)) {
      throw const FormatException(
        'Risk assessment expired or invalid lifetime',
      );
    }
    return SignedRiskAssessment._(
      issuer,
      expectedTransactionDigest,
      claims['verdict'] as String,
      issued,
      expires,
    );
  }
}
