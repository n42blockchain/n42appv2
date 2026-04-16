import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/biometric_service.dart';

class MockLocalAuthentication extends Mock
    implements local_auth.LocalAuthentication {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication localAuth;
  late BiometricService service;

  setUp(() {
    localAuth = MockLocalAuthentication();
    service = BiometricService(localAuth: localAuth);
  });

  group('isAvailable', () {
    test(
      'returns false when device support exists but no biometrics are enrolled',
      () async {
        when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);

        final result = await service.isAvailable();

        expect(result, isFalse);
      },
    );

    test(
      'returns true only when biometrics are both supported and enrolled',
      () async {
        when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);

        final result = await service.isAvailable();

        expect(result, isTrue);
      },
    );
  });

  group('authenticate', () {
    test('maps NotSupported exceptions to notSupported', () async {
      when(
        () => localAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(
        PlatformException(code: 'NotSupported', message: 'Unsupported'),
      );

      final result = await service.authenticate(reason: 'Unlock');

      expect(result.success, isFalse);
      expect(result.errorCode, BiometricErrorCode.notSupported);
    });

    test('maps user cancellation variants to userCanceled', () async {
      when(
        () => localAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(PlatformException(code: 'userCanceled', message: 'Canceled'));

      final result = await service.authenticate(reason: 'Unlock');

      expect(result.success, isFalse);
      expect(result.errorCode, BiometricErrorCode.userCanceled);
    });
  });
}
