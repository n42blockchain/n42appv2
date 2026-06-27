import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/auth/auth_methods_service.dart';

void main() {
  group('AuthMethodsService.parseSsoProviders', () {
    test('returns identity providers from Matrix login flows', () {
      final providers = AuthMethodsService.parseSsoProviders({
        'flows': [
          {'type': 'm.login.password'},
          {
            'type': 'm.login.sso',
            'identity_providers': [
              {
                'id': 'oidc-google',
                'name': 'Google',
                'icon': 'mxc://example/google',
                'brand': 'google',
              },
            ],
          },
        ],
      });

      expect(providers, hasLength(1));
      expect(providers.single.id, 'oidc-google');
      expect(providers.single.name, 'Google');
      expect(providers.single.icon, 'mxc://example/google');
      expect(providers.single.brand, 'google');
    });

    test('returns generic SSO provider when flow omits identity providers', () {
      final providers = AuthMethodsService.parseSsoProviders({
        'flows': [
          {'type': 'm.login.sso'},
        ],
      });

      expect(providers, hasLength(1));
      expect(providers.single.id, 'sso');
      expect(providers.single.name, 'SSO');
    });

    test('skips malformed or blank identity providers', () {
      final providers = AuthMethodsService.parseSsoProviders({
        'flows': [
          {
            'type': 'm.login.sso',
            'identity_providers': [
              'bad',
              {'id': '   ', 'name': 'Blank'},
              {'id': 'github', 'name': ''},
            ],
          },
        ],
      });

      expect(providers, hasLength(1));
      expect(providers.single.id, 'github');
      expect(providers.single.name, 'SSO');
    });
  });

  group('AuthMethodsService SSO URLs', () {
    test('normalizes homeserver base for generic SSO URL', () {
      final service = AuthMethodsService();

      expect(
        service.getSsoLoginUrl(
          homeserver: 'https://matrix.example/',
          redirectUrl: 'n42://auth/sso?homeserver=https://matrix.example',
        ),
        'https://matrix.example/_matrix/client/v3/login/sso/redirect'
        '?redirectUrl=n42%3A%2F%2Fauth%2Fsso%3Fhomeserver%3Dhttps%3A%2F%2Fmatrix.example',
      );
    });

    test('encodes provider id as a path segment', () {
      final service = AuthMethodsService();

      expect(
        service.getSsoProviderLoginUrl(
          homeserver: 'https://matrix.example',
          providerId: 'oidc/google',
          redirectUrl: 'n42://auth/sso',
        ),
        'https://matrix.example/_matrix/client/v3/login/sso/redirect/oidc%2Fgoogle'
        '?redirectUrl=n42%3A%2F%2Fauth%2Fsso',
      );
    });
  });
}
