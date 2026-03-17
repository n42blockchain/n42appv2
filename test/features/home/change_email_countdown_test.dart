import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/setting/change_email_page_logic.dart';

void main() {
  group('change email countdown helpers', () {
    test('clearChangeEmailCountdownState cancels timer and resets countdown', () {
      var timerCancelled = false;
      var countdown = 42;

      clearChangeEmailCountdownState(
        cancelTimer: () => timerCancelled = true,
        setCountdown: (value) => countdown = value,
      );

      expect(timerCancelled, isTrue);
      expect(countdown, 0);
    });

    test('canResendChangeEmailCode only allows resend when idle and zeroed', () {
      expect(
        canResendChangeEmailCode(countdown: 0, loading: false),
        isTrue,
      );
      expect(
        canResendChangeEmailCode(countdown: 12, loading: false),
        isFalse,
      );
      expect(
        canResendChangeEmailCode(countdown: 0, loading: true),
        isFalse,
      );
    });
  });
}
