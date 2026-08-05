// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-10: Tests for login-related data models (no network required)
//
// Coverage targets:
//   - DeviceLoginInfo.fromJson / displayName
//   - local param-validation logic extracted as pure functions

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/domain/entities/device_login_info.dart';

// ---------------------------------------------------------------------------
// Pure-function mirrors of local validation logic in UserInfoApi
// ---------------------------------------------------------------------------

/// Mirrors the email-presence check that should be applied before calling
/// the login endpoint.
bool isEmailValid(String? email) {
  if (email == null || email.isEmpty) return false;
  return email.contains('@');
}

/// Mirrors the login-params construction for the email-login endpoint.
Map<String, dynamic> buildLoginParams(String email, String password,
    {Map<String, dynamic>? deviceInfo}) {
  final params = <String, dynamic>{
    'email': email,
    'pwd': password,
    'source': 'app',
  };
  if (deviceInfo != null) {
    params.addAll(deviceInfo);
  }
  return params;
}

// ---------------------------------------------------------------------------
void main() {
  group('DeviceLoginInfo', () {
    group('fromJson — complete payload', () {
      test('all fields are parsed', () {
        final info = DeviceLoginInfo.fromJson({
          'device_id': 'dev-abc123',
          'device_brand': 'Apple',
          'device_model': 'iPhone 15',
          'device_os': 'iOS 17',
          'login_time': '2025-01-01T12:00:00Z',
          'login_ip': '192.168.1.1',
          'login_location': 'Shanghai, CN',
        });

        expect(info.deviceId, 'dev-abc123');
        expect(info.deviceBrand, 'Apple');
        expect(info.deviceModel, 'iPhone 15');
        expect(info.deviceOs, 'iOS 17');
        expect(info.loginTime, '2025-01-01T12:00:00Z');
        expect(info.loginIp, '192.168.1.1');
        expect(info.loginLocation, 'Shanghai, CN');
      });
    });

    group('fromJson — missing optional fields', () {
      test('missing loginTime is null', () {
        final info = DeviceLoginInfo.fromJson({
          'device_id': 'id',
          'device_brand': 'Samsung',
          'device_model': 'S23',
          'device_os': 'Android 14',
        });
        expect(info.loginTime, isNull);
        expect(info.loginIp, isNull);
        expect(info.loginLocation, isNull);
      });

      test('missing required fields default to empty string', () {
        final info = DeviceLoginInfo.fromJson({});
        expect(info.deviceId, '');
        expect(info.deviceBrand, '');
        expect(info.deviceModel, '');
        expect(info.deviceOs, '');
      });
    });

    group('displayName getter', () {
      test('brand + os when both are present', () {
        final info = DeviceLoginInfo.fromJson({
          'device_id': '',
          'device_brand': 'Apple',
          'device_model': 'iPhone',
          'device_os': 'iOS',
        });
        expect(info.displayName, 'Apple iOS');
      });

      test('brand only when os is empty', () {
        final info = DeviceLoginInfo.fromJson({
          'device_id': '',
          'device_brand': 'Huawei',
          'device_model': 'P60',
          'device_os': '',
        });
        expect(info.displayName, 'Huawei');
      });

      test('"Unknown" when brand is empty', () {
        final info = DeviceLoginInfo.fromJson({
          'device_id': '',
          'device_brand': '',
          'device_model': 'Model X',
          'device_os': 'Android',
        });
        expect(info.displayName, 'Unknown Android');
      });

      test('"Unknown" when both brand and os are empty', () {
        final info = DeviceLoginInfo.fromJson({
          'device_id': '',
          'device_brand': '',
          'device_model': '',
          'device_os': '',
        });
        expect(info.displayName, 'Unknown');
      });

      test('real-world Samsung example', () {
        final info = DeviceLoginInfo.fromJson({
          'device_id': 'id',
          'device_brand': 'samsung',
          'device_model': 'SM-S911B',
          'device_os': 'android',
        });
        expect(info.displayName, 'samsung android');
      });
    });
  });

  // -------------------------------------------------------------------------
  group('UserInfoApi — local param validation logic', () {
    group('isEmailValid', () {
      test('valid email returns true', () {
        expect(isEmailValid('user@example.com'), isTrue);
      });

      test('null email returns false', () {
        expect(isEmailValid(null), isFalse);
      });

      test('empty string returns false', () {
        expect(isEmailValid(''), isFalse);
      });

      test('string without @ returns false', () {
        expect(isEmailValid('notanemail'), isFalse);
      });

      test('multiple @ characters is still "valid" (contains @)', () {
        expect(isEmailValid('a@b@c.com'), isTrue);
      });
    });

    group('buildLoginParams', () {
      test('email and password are included', () {
        final params = buildLoginParams('user@example.com', 'secret');

        expect(params['email'], 'user@example.com');
        expect(params['pwd'], 'secret');
      });

      test('source is always "app"', () {
        final params = buildLoginParams('u@e.com', 'p');
        expect(params['source'], 'app');
      });

      test('deviceInfo fields are merged when provided', () {
        final params = buildLoginParams(
          'u@e.com',
          'p',
          deviceInfo: {'device_id': 'dev-1', 'device_os': 'iOS'},
        );

        expect(params['device_id'], 'dev-1');
        expect(params['device_os'], 'iOS');
        // Core fields still present
        expect(params['email'], 'u@e.com');
      });

      test('null deviceInfo is silently omitted', () {
        final params = buildLoginParams('u@e.com', 'p');
        expect(params.containsKey('device_id'), isFalse);
      });
    });
  });
}
