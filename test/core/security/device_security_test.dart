// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/security/device_security.dart';

void main() {
  group('DeviceSecurityService', () {
    late DeviceSecurityService service;

    setUp(() {
      service = DeviceSecurityService.instance;
    });

    group('isDeviceCompromised', () {
      test('should return false in debug mode', () async {
        // 在调试模式下应返回 false
        final result = await service.isDeviceCompromised();
        expect(result, isFalse);
      });
    });

    group('isRunningOnEmulator', () {
      test('should return false in debug mode', () async {
        final result = await service.isRunningOnEmulator();
        expect(result, isFalse);
      });
    });

    group('isDebuggerAttached', () {
      test('should detect debug mode', () async {
        final result = await service.isDebuggerAttached();
        // 在测试环境中应为 true（因为 assert 有效）
        expect(result, isTrue);
      });
    });

    group('getSecurityStatus', () {
      test('should return complete security status', () async {
        final status = await service.getSecurityStatus();
        
        expect(status, isA<DeviceSecurityStatus>());
        expect(status.isRootedOrJailbroken, isFalse);
        expect(status.isEmulator, isFalse);
      });

      test('should have toString implementation', () async {
        final status = await service.getSecurityStatus();
        final string = status.toString();
        
        expect(string, contains('DeviceSecurityStatus'));
        expect(string, contains('isRootedOrJailbroken'));
        expect(string, contains('isEmulator'));
        expect(string, contains('isDebuggerAttached'));
        expect(string, contains('isSecure'));
      });
    });
  });

  group('DeviceSecurityStatus', () {
    test('should create with all fields', () {
      const status = DeviceSecurityStatus(
        isRootedOrJailbroken: false,
        isEmulator: false,
        isDebuggerAttached: false,
        isSecure: true,
      );

      expect(status.isRootedOrJailbroken, isFalse);
      expect(status.isEmulator, isFalse);
      expect(status.isDebuggerAttached, isFalse);
      expect(status.isSecure, isTrue);
    });

    test('should be insecure when rooted', () {
      const status = DeviceSecurityStatus(
        isRootedOrJailbroken: true,
        isEmulator: false,
        isDebuggerAttached: false,
        isSecure: false,
      );

      expect(status.isSecure, isFalse);
    });

    test('should be insecure when on emulator', () {
      const status = DeviceSecurityStatus(
        isRootedOrJailbroken: false,
        isEmulator: true,
        isDebuggerAttached: false,
        isSecure: false,
      );

      expect(status.isSecure, isFalse);
    });
  });

  group('SecurityPolicyConfig', () {
    test('should have production config', () {
      const config = SecurityPolicyConfig.production;
      
      expect(config.onRootDetected, SecurityViolationAction.restrictFeatures);
      expect(config.onEmulatorDetected, SecurityViolationAction.blockApp);
      expect(config.onDebuggerDetected, SecurityViolationAction.blockApp);
    });

    test('should have development config', () {
      const config = SecurityPolicyConfig.development;
      
      expect(config.onRootDetected, SecurityViolationAction.warnAndContinue);
      expect(config.onEmulatorDetected, SecurityViolationAction.warnAndContinue);
      expect(config.onDebuggerDetected, SecurityViolationAction.warnAndContinue);
    });

    test('should allow custom config', () {
      const config = SecurityPolicyConfig(
        onRootDetected: SecurityViolationAction.blockApp,
        onEmulatorDetected: SecurityViolationAction.warnAndContinue,
        onDebuggerDetected: SecurityViolationAction.restrictFeatures,
      );

      expect(config.onRootDetected, SecurityViolationAction.blockApp);
      expect(config.onEmulatorDetected, SecurityViolationAction.warnAndContinue);
      expect(config.onDebuggerDetected, SecurityViolationAction.restrictFeatures);
    });
  });

  group('SecurityViolationAction', () {
    test('should have all expected values', () {
      expect(SecurityViolationAction.values, contains(SecurityViolationAction.warnAndContinue));
      expect(SecurityViolationAction.values, contains(SecurityViolationAction.restrictFeatures));
      expect(SecurityViolationAction.values, contains(SecurityViolationAction.blockApp));
    });
  });
}

