import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/signed_risk_assessment.dart';

void main() {
  test(
    'verifies pinned issuer, transaction, audience, signature and expiry',
    () async {
      final algorithm = Ed25519();
      final key = await algorithm.newKeyPair();
      final public = await key.extractPublicKey();
      final now = DateTime.utc(2026, 10, 24);
      final digest = 'ab' * 32;
      final payload = base64Url.encode(
        utf8.encode(
          jsonEncode({
            'version': 1,
            'audience': 'n42-test',
            'transactionDigest': digest,
            'verdict': 'danger',
            'issuedAt': now.millisecondsSinceEpoch,
            'expiresAt': now
                .add(const Duration(minutes: 1))
                .millisecondsSinceEpoch,
          }),
        ),
      );
      final signature = await algorithm.sign(
        utf8.encode('N42-RISK-V1\nissuer\n$payload'),
        keyPair: key,
      );
      final envelope = <String, dynamic>{
        'issuer': 'issuer',
        'payload': payload,
        'signature': base64Url.encode(signature.bytes),
      };
      Future<SignedRiskAssessment> verify({
        String? tx,
        String audience = 'n42-test',
        DateTime? time,
        Map<String, dynamic>? input,
        bool trusted = true,
      }) => SignedRiskAssessment.verify(
        envelope: input ?? envelope,
        trustedKeys: trusted ? {'issuer': public.bytes} : {},
        expectedTransactionDigest: tx ?? digest,
        audience: audience,
        now: time ?? now,
      );
      expect((await verify()).verdict, 'danger');
      await expectLater(verify(tx: 'cd' * 32), throwsFormatException);
      await expectLater(verify(audience: 'other'), throwsFormatException);
      await expectLater(verify(trusted: false), throwsFormatException);
      await expectLater(
        verify(time: now.add(const Duration(minutes: 1))),
        throwsFormatException,
      );
      await expectLater(
        verify(
          input: {...envelope, 'payload': base64Url.encode(utf8.encode('{}'))},
        ),
        throwsFormatException,
      );
    },
  );
}
