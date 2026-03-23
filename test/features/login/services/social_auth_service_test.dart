import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/login/services/social_auth_service.dart';

void main() {
  group('SocialAuthResult.hasUsableIdToken', () {
    test('returns true when id token is present', () {
      final result = SocialAuthResult(
        success: true,
        provider: 'google',
        idToken: 'header.payload.signature',
      );

      expect(result.hasUsableIdToken, isTrue);
    });

    test('returns false when id token is null or empty', () {
      expect(
        SocialAuthResult(success: true, provider: 'google').hasUsableIdToken,
        isFalse,
      );
      expect(
        SocialAuthResult(
          success: true,
          provider: 'apple',
          idToken: '',
        ).hasUsableIdToken,
        isFalse,
      );
    });
  });
}
