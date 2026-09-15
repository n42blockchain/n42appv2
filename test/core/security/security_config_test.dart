// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_wallet/core/security/security_config.dart';

class _UntrustedCertificate extends Mock implements X509Certificate {}

void main() {
  group('SecurityConfig', () {
    for (final host in [
      'third-party.test',
      'api.n42.ai',
      'evilapi.n42.ai',
      'localhost',
    ]) {
      test('production rejects a failed TLS validation for $host', () {
        final certificate = _UntrustedCertificate();
        expect(
          SecurityConfig.rejectUntrustedCertificate(certificate, host, 443),
          isFalse,
        );
        verifyZeroInteractions(certificate);
      });
    }

    test('sensitive containers are fully redacted without modifying input', () {
      final source = {
        'tokens': ['private-token'],
        'seed': {
          'words': ['private-seed'],
        },
        'authorization': {'value': 'private-auth'},
        'users': [
          {
            'name': 'Alice',
            'password': {'value': 'private-password'},
          },
        ],
      };
      final masked = SecurityConfig.maskSensitiveMap(source);
      expect(masked['tokens'], '******');
      expect(masked['seed'], '******');
      expect(masked['authorization'], '******');
      expect((masked['users'] as List).single, {
        'name': 'Alice',
        'password': '******',
      });
      expect(source['tokens'], ['private-token']);
      expect(masked.toString(), isNot(contains('private-')));
    });
    group('sensitiveKeys', () {
      test('should contain authentication related keys', () {
        expect(SecurityConfig.sensitiveKeys, contains('token'));
        expect(SecurityConfig.sensitiveKeys, contains('authorization'));
        expect(SecurityConfig.sensitiveKeys, contains('password'));
        expect(SecurityConfig.sensitiveKeys, contains('secret'));
      });

      test('should contain wallet related keys', () {
        expect(SecurityConfig.sensitiveKeys, contains('mnemonic'));
        expect(SecurityConfig.sensitiveKeys, contains('private_key'));
        expect(SecurityConfig.sensitiveKeys, contains('seed'));
        expect(SecurityConfig.sensitiveKeys, contains('keystore'));
      });

      test('should contain user related keys', () {
        expect(SecurityConfig.sensitiveKeys, contains('email'));
        expect(SecurityConfig.sensitiveKeys, contains('phone'));
        expect(SecurityConfig.sensitiveKeys, contains('ssn'));
        expect(SecurityConfig.sensitiveKeys, contains('credit_card'));
      });
    });

    group('pinnedHosts', () {
      test('should contain N42 API hosts', () {
        expect(SecurityConfig.pinnedHosts, contains('api.n42.network'));
        expect(SecurityConfig.pinnedHosts, contains('ipfs.n42.network'));
      });
    });

    group('allowedCertFingerprints', () {
      test('should have certificate fingerprints configured', () {
        expect(SecurityConfig.allowedCertFingerprints, isNotEmpty);
      });

      test('should have valid fingerprint format', () {
        for (final fingerprint in SecurityConfig.allowedCertFingerprints) {
          expect(fingerprint, startsWith('sha256/'));
          // Base64 encoded SHA-256 should be 44 characters
          final base64Part = fingerprint.substring(7);
          expect(base64Part.length, equals(44));
        }
      });
    });

    group('isSensitiveKey', () {
      test('should detect token as sensitive', () {
        expect(SecurityConfig.isSensitiveKey('token'), isTrue);
        expect(SecurityConfig.isSensitiveKey('Token'), isTrue);
        expect(SecurityConfig.isSensitiveKey('TOKEN'), isTrue);
        expect(SecurityConfig.isSensitiveKey('access_token'), isTrue);
      });

      test('should detect password as sensitive', () {
        expect(SecurityConfig.isSensitiveKey('password'), isTrue);
        expect(SecurityConfig.isSensitiveKey('Password'), isTrue);
        expect(SecurityConfig.isSensitiveKey('user_password'), isTrue);
      });

      test('should detect mnemonic as sensitive', () {
        expect(SecurityConfig.isSensitiveKey('mnemonic'), isTrue);
        expect(SecurityConfig.isSensitiveKey('wallet_mnemonic'), isTrue);
      });

      test('should not detect non-sensitive keys', () {
        expect(SecurityConfig.isSensitiveKey('name'), isFalse);
        expect(SecurityConfig.isSensitiveKey('address'), isFalse);
        expect(SecurityConfig.isSensitiveKey('balance'), isFalse);
        expect(SecurityConfig.isSensitiveKey('timestamp'), isFalse);
      });
    });

    group('maskSensitiveData', () {
      test('should mask sensitive values', () {
        expect(
          SecurityConfig.maskSensitiveData('token', 'abc123'),
          equals('******'),
        );
        expect(
          SecurityConfig.maskSensitiveData('password', 'secret123'),
          equals('******'),
        );
        expect(
          SecurityConfig.maskSensitiveData('mnemonic', 'word1 word2'),
          equals('******'),
        );
      });

      test('should not mask non-sensitive values', () {
        expect(
          SecurityConfig.maskSensitiveData('name', 'John'),
          equals('John'),
        );
        expect(
          SecurityConfig.maskSensitiveData('balance', '100.5'),
          equals('100.5'),
        );
      });

      test('should handle null values', () {
        expect(SecurityConfig.maskSensitiveData('name', null), equals('null'));
      });
    });

    group('maskSensitiveMap', () {
      test('should mask sensitive values in map', () {
        final data = {'name': 'John', 'token': 'abc123', 'password': 'secret'};

        final masked = SecurityConfig.maskSensitiveMap(data);

        expect(masked['name'], equals('John'));
        expect(masked['token'], equals('******'));
        expect(masked['password'], equals('******'));
      });

      test('should handle nested maps', () {
        final data = {
          'user': {
            'name': 'John',
            'credentials': {'password': 'secret'},
          },
        };

        final masked = SecurityConfig.maskSensitiveMap(data);

        expect((masked['user'] as Map)['name'], equals('John'));
        expect(
          ((masked['user'] as Map)['credentials'] as Map)['password'],
          equals('******'),
        );
      });

      test('should handle lists in maps', () {
        final data = {
          'tokens': ['token1', 'token2'],
          'users': [
            {'name': 'John', 'password': 'secret1'},
            {'name': 'Jane', 'password': 'secret2'},
          ],
        };

        final masked = SecurityConfig.maskSensitiveMap(data);

        expect((masked['users'] as List)[0]['name'], equals('John'));
        expect((masked['users'] as List)[0]['password'], equals('******'));
        expect((masked['users'] as List)[1]['password'], equals('******'));
      });
    });

    group('secureLog', () {
      test('should not throw in debug mode', () {
        expect(() => SecurityConfig.secureLog('Test message'), returnsNormally);
      });

      test('should handle data parameter', () {
        expect(
          () => SecurityConfig.secureLog(
            'Test',
            data: {'key': 'value', 'token': 'secret'},
          ),
          returnsNormally,
        );
      });
    });
  });
}
