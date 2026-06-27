import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/sso_brand.dart';

void main() {
  group('SsoBrandClassifier.classify', () {
    test('recognizes major providers by id/name', () {
      expect(SsoBrandClassifier.classify('oidc-google'), SsoBrand.google);
      expect(SsoBrandClassifier.classify('Sign in with Apple'), SsoBrand.apple);
      expect(SsoBrandClassifier.classify('azure-ad'), SsoBrand.microsoft);
      expect(
        SsoBrandClassifier.classify('Microsoft Entra'),
        SsoBrand.microsoft,
      );
      expect(SsoBrandClassifier.classify('github'), SsoBrand.github);
      expect(SsoBrandClassifier.classify('gitlab.com'), SsoBrand.gitlab);
      expect(SsoBrandClassifier.classify('facebook'), SsoBrand.facebook);
      expect(SsoBrandClassifier.classify('Sign in with X'), SsoBrand.twitter);
      expect(SsoBrandClassifier.classify('discord'), SsoBrand.discord);
      expect(SsoBrandClassifier.classify('LinkedIn'), SsoBrand.linkedin);
      expect(SsoBrandClassifier.classify('telegram'), SsoBrand.telegram);
      expect(SsoBrandClassifier.classify('微信'), SsoBrand.wechat);
    });

    test('is case-insensitive', () {
      expect(SsoBrandClassifier.classify('GitHub'), SsoBrand.github);
      expect(SsoBrandClassifier.classify('GOOGLE'), SsoBrand.google);
    });

    test('falls back to generic for unknown', () {
      expect(SsoBrandClassifier.classify('keycloak-corp'), SsoBrand.generic);
      expect(SsoBrandClassifier.classify('saml'), SsoBrand.generic);
      expect(SsoBrandClassifier.classify('box enterprise'), SsoBrand.generic);
    });
  });
}
