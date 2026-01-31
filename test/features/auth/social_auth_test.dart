import 'package:flutter_test/flutter_test.dart';

/// Social Authentication Tests
/// Tests for Google Sign-In, Apple Sign-In, OIDC, and SAML support
void main() {
  group('SocialAuthResult', () {
    test('success result should have correct properties', () {
      final result = _createSuccessResult(
        provider: 'google',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(result.success, true);
      expect(result.provider, 'google');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Test User');
      expect(result.error, isNull);
    });

    test('failure result should have error message', () {
      final result = _createFailureResult('Sign-in cancelled');

      expect(result.success, false);
      expect(result.error, 'Sign-in cancelled');
      expect(result.provider, isNull);
    });

    test('toJson should serialize all fields', () {
      final result = _createSuccessResult(
        provider: 'apple',
        email: 'user@icloud.com',
        userId: 'apple_user_123',
      );

      final json = result.toJson();

      expect(json['success'], true);
      expect(json['provider'], 'apple');
      expect(json['email'], 'user@icloud.com');
      expect(json['userId'], 'apple_user_123');
    });
  });

  group('Social Login API Parameters', () {
    test('Google login params should have required fields', () {
      final params = _buildGoogleLoginParams(
        idToken: 'google_id_token_123',
        accessToken: 'google_access_token_456',
      );

      expect(params.containsKey('provider'), true);
      expect(params.containsKey('id_token'), true);
      expect(params.containsKey('source'), true);
      expect(params['provider'], 'google');
      expect(params['id_token'], 'google_id_token_123');
      expect(params['source'], 'app');
    });

    test('Apple login params should have required fields', () {
      final params = _buildAppleLoginParams(
        idToken: 'apple_identity_token',
        authorizationCode: 'apple_auth_code',
      );

      expect(params.containsKey('provider'), true);
      expect(params.containsKey('id_token'), true);
      expect(params.containsKey('authorization_code'), true);
      expect(params['provider'], 'apple');
    });

    test('Bind social account params should include user info', () {
      final params = _buildBindSocialParams(
        uuid: 'user_uuid',
        token: 'user_token',
        provider: 'google',
        idToken: 'social_id_token',
      );

      expect(params['uuid'], 'user_uuid');
      expect(params['token'], 'user_token');
      expect(params['provider'], 'google');
      expect(params['id_token'], 'social_id_token');
    });
  });

  group('OIDC Configuration', () {
    test('valid config should pass validation', () {
      final config = _OIDCConfig(
        issuer: 'https://auth.example.com',
        clientId: 'client_123',
        redirectUri: 'myapp://callback',
        scopes: ['openid', 'profile', 'email'],
      );

      expect(config.validate(), true);
    });

    test('empty issuer should fail validation', () {
      final config = _OIDCConfig(
        issuer: '',
        clientId: 'client_123',
        redirectUri: 'myapp://callback',
      );

      expect(config.validate(), false);
    });

    test('empty clientId should fail validation', () {
      final config = _OIDCConfig(
        issuer: 'https://auth.example.com',
        clientId: '',
        redirectUri: 'myapp://callback',
      );

      expect(config.validate(), false);
    });

    test('discovery URL should be correctly formed', () {
      final config = _OIDCConfig(
        issuer: 'https://auth.example.com',
        clientId: 'client_123',
        redirectUri: 'myapp://callback',
      );

      expect(
        config.discoveryUrl,
        'https://auth.example.com/.well-known/openid-configuration',
      );
    });
  });

  group('SAML Configuration', () {
    test('valid config should pass validation', () {
      final config = _SAMLConfig(
        idpEntityId: 'https://idp.example.com/entity',
        idpSsoUrl: 'https://idp.example.com/sso',
        idpCertificate: 'CERTIFICATE_DATA',
        spEntityId: 'https://app.example.com/sp',
        acsUrl: 'https://app.example.com/acs',
      );

      expect(config.validate(), true);
    });

    test('missing IdP SSO URL should fail validation', () {
      final config = _SAMLConfig(
        idpEntityId: 'https://idp.example.com/entity',
        idpSsoUrl: '',
        idpCertificate: 'CERTIFICATE_DATA',
        spEntityId: 'https://app.example.com/sp',
        acsUrl: 'https://app.example.com/acs',
      );

      expect(config.validate(), false);
    });

    test('missing certificate should fail validation', () {
      final config = _SAMLConfig(
        idpEntityId: 'https://idp.example.com/entity',
        idpSsoUrl: 'https://idp.example.com/sso',
        idpCertificate: '',
        spEntityId: 'https://app.example.com/sp',
        acsUrl: 'https://app.example.com/acs',
      );

      expect(config.validate(), false);
    });
  });

  group('Provider Support', () {
    test('supported providers list should include Google and Apple', () {
      final providers = _SupportedProviders.values;

      expect(providers.contains(_SupportedProviders.google), true);
      expect(providers.contains(_SupportedProviders.apple), true);
    });

    test('Google provider should have correct identifier', () {
      expect(_SupportedProviders.google.identifier, 'google');
    });

    test('Apple provider should have correct identifier', () {
      expect(_SupportedProviders.apple.identifier, 'apple');
    });
  });

  group('Token Validation', () {
    test('valid JWT structure should pass basic validation', () {
      // A mock JWT with 3 parts separated by dots
      const validToken = 'header.payload.signature';
      expect(_isValidJwtStructure(validToken), true);
    });

    test('invalid JWT structure should fail validation', () {
      expect(_isValidJwtStructure('not_a_jwt'), false);
      expect(_isValidJwtStructure('only.two'), false);
      expect(_isValidJwtStructure(''), false);
    });

    test('empty token should fail validation', () {
      expect(_isValidJwtStructure(''), false);
      expect(_isValidJwtStructure('   '), false);
    });
  });

  group('Social Account Linking', () {
    test('link request should have all required params', () {
      final params = _buildLinkAccountParams(
        uuid: 'user_123',
        token: 'session_token',
        provider: 'google',
        providerToken: 'google_token',
      );

      expect(params['uuid'], isNotEmpty);
      expect(params['token'], isNotEmpty);
      expect(params['provider'], isNotEmpty);
    });

    test('unlink request should have provider and user info', () {
      final params = _buildUnlinkAccountParams(
        uuid: 'user_123',
        token: 'session_token',
        provider: 'apple',
      );

      expect(params['provider'], 'apple');
      expect(params['uuid'], 'user_123');
    });
  });

  group('Error Handling', () {
    test('network error should be properly formatted', () {
      final error = _formatSocialAuthError('network_error', 'Connection failed');
      expect(error, contains('network_error'));
      expect(error, contains('Connection failed'));
    });

    test('user cancelled error should be recognized', () {
      expect(_isUserCancelledError('sign_in_canceled'), true);
      expect(_isUserCancelledError('user_cancelled'), true);
      expect(_isUserCancelledError('cancelled'), true);
      expect(_isUserCancelledError('network_error'), false);
    });

    test('provider errors should map to user-friendly messages', () {
      expect(
        _getErrorMessage('sign_in_canceled'),
        'Sign-in was cancelled',
      );
      expect(
        _getErrorMessage('network_error'),
        'Network error. Please check your connection.',
      );
      expect(
        _getErrorMessage('unknown_error'),
        'An unexpected error occurred',
      );
    });
  });
}

// Test helper classes and functions

class _SocialAuthResult {
  final bool success;
  final String? provider;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? userId;
  final String? error;

  _SocialAuthResult({
    required this.success,
    this.provider,
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.userId,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'provider': provider,
    'idToken': idToken,
    'accessToken': accessToken,
    'email': email,
    'displayName': displayName,
    'userId': userId,
    'error': error,
  };
}

_SocialAuthResult _createSuccessResult({
  required String provider,
  String? email,
  String? displayName,
  String? userId,
}) {
  return _SocialAuthResult(
    success: true,
    provider: provider,
    email: email,
    displayName: displayName,
    userId: userId,
    idToken: 'mock_id_token',
    accessToken: 'mock_access_token',
  );
}

_SocialAuthResult _createFailureResult(String error) {
  return _SocialAuthResult(success: false, error: error);
}

Map<String, dynamic> _buildGoogleLoginParams({
  required String idToken,
  String? accessToken,
}) {
  final params = <String, dynamic>{
    'provider': 'google',
    'id_token': idToken,
    'source': 'app',
  };
  if (accessToken != null) {
    params['access_token'] = accessToken;
  }
  return params;
}

Map<String, dynamic> _buildAppleLoginParams({
  required String idToken,
  required String authorizationCode,
}) {
  return {
    'provider': 'apple',
    'id_token': idToken,
    'authorization_code': authorizationCode,
    'source': 'app',
  };
}

Map<String, dynamic> _buildBindSocialParams({
  required String uuid,
  required String token,
  required String provider,
  required String idToken,
}) {
  return {
    'uuid': uuid,
    'token': token,
    'source': 'app',
    'provider': provider,
    'id_token': idToken,
  };
}

class _OIDCConfig {
  final String issuer;
  final String clientId;
  final String redirectUri;
  final List<String> scopes;

  _OIDCConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    this.scopes = const ['openid', 'profile', 'email'],
  });

  bool validate() {
    return issuer.isNotEmpty &&
           clientId.isNotEmpty &&
           redirectUri.isNotEmpty;
  }

  String get discoveryUrl => '$issuer/.well-known/openid-configuration';
}

class _SAMLConfig {
  final String idpEntityId;
  final String idpSsoUrl;
  final String idpCertificate;
  final String spEntityId;
  final String acsUrl;

  _SAMLConfig({
    required this.idpEntityId,
    required this.idpSsoUrl,
    required this.idpCertificate,
    required this.spEntityId,
    required this.acsUrl,
  });

  bool validate() {
    return idpEntityId.isNotEmpty &&
           idpSsoUrl.isNotEmpty &&
           idpCertificate.isNotEmpty &&
           spEntityId.isNotEmpty &&
           acsUrl.isNotEmpty;
  }
}

enum _SupportedProviders {
  google('google'),
  apple('apple');

  final String identifier;
  const _SupportedProviders(this.identifier);
}

bool _isValidJwtStructure(String token) {
  if (token.trim().isEmpty) return false;
  final parts = token.split('.');
  return parts.length == 3 && parts.every((p) => p.isNotEmpty);
}

Map<String, dynamic> _buildLinkAccountParams({
  required String uuid,
  required String token,
  required String provider,
  required String providerToken,
}) {
  return {
    'uuid': uuid,
    'token': token,
    'source': 'app',
    'provider': provider,
    'provider_token': providerToken,
  };
}

Map<String, dynamic> _buildUnlinkAccountParams({
  required String uuid,
  required String token,
  required String provider,
}) {
  return {
    'uuid': uuid,
    'token': token,
    'source': 'app',
    'provider': provider,
  };
}

String _formatSocialAuthError(String code, String message) {
  return '[$code] $message';
}

bool _isUserCancelledError(String error) {
  final cancelPatterns = [
    'cancel',
    'cancelled',
    'canceled',
  ];
  return cancelPatterns.any((p) => error.toLowerCase().contains(p));
}

String _getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'sign_in_canceled':
    case 'user_cancelled':
      return 'Sign-in was cancelled';
    case 'network_error':
      return 'Network error. Please check your connection.';
    case 'invalid_credential':
      return 'Invalid credentials. Please try again.';
    default:
      return 'An unexpected error occurred';
  }
}
