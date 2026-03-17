import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/setting/security/security_google_vedification.dart';

void main() {
  group('advanceSecurityEmailCountdown', () {
    test('decrements active countdown values', () {
      final nextState = advanceSecurityEmailCountdown(10);

      expect(nextState.nextCount, 9);
      expect(nextState.keepWaiting, isTrue);
    });

    test('resets wait state when countdown reaches terminal tick', () {
      final nextState = advanceSecurityEmailCountdown(1);

      expect(nextState.nextCount, 60);
      expect(nextState.keepWaiting, isFalse);
    });
  });
}
