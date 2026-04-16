import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/stored_account_entity.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';
import 'package:n42_chat/src/presentation/helpers/system_account_summary_helper.dart';

void main() {
  group('SystemAccountSummaryHelper', () {
    test('builds account summary for saved and active accounts', () {
      final summary = SystemAccountSummaryHelper.accountSummary(const [
        StoredAccountEntity(
          userId: '@alice:example.com',
          homeserver: 'example.com',
          isCurrent: true,
        ),
        StoredAccountEntity(
          userId: '@bob:example.com',
          homeserver: 'example.com',
        ),
      ]);

      expect(summary, '2 saved on this device · 1 active now');
    });

    test('builds focus-hours notification summary when dnd is enabled', () {
      const settings = NotificationSettings(
        enabled: true,
        doNotDisturb: true,
        doNotDisturbStart: '21:30',
        doNotDisturbEnd: '08:00',
      );

      final summary = SystemAccountSummaryHelper.notificationSummary(settings);

      expect(summary, 'Focus hours 21:30-08:00');
    });

    test('builds username summary for public handles', () {
      final summary = SystemAccountSummaryHelper.usernameSummary('n42alice');

      expect(summary, '@n42alice · public handle for direct contact');
    });

    test('compacts current device identifier in device summary', () {
      final summary = SystemAccountSummaryHelper.deviceSummary(
        deviceCount: 3,
        currentDeviceId: 'ABCDEFGH12345678',
      );

      expect(summary, '3 signed-in devices · current ABCD...5678');
    });
  });
}
