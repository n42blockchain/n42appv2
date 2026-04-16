import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/encryption/e2ee_manager.dart';
import 'package:n42_chat/src/core/encryption/key_backup_service.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';
import 'package:n42_chat/src/presentation/helpers/privacy_security_summary_helper.dart';

void main() {
  group('PrivacySecuritySummaryHelper', () {
    test('builds network summary for tor privacy mode', () {
      const settings = PrivacySettings(useTor: true, protectIpAddress: true);

      final summary = PrivacySecuritySummaryHelper.networkSummary(settings);

      expect(summary, 'Tor / Privoxy via 127.0.0.1:8118');
    });

    test('flags invalid custom proxy configuration', () {
      const settings = PrivacySettings(
        proxyEnabled: true,
        proxyUrl: 'socks5://127.0.0.1',
      );

      final summary = PrivacySecuritySummaryHelper.networkSummary(settings);

      expect(summary, 'Custom proxy enabled, but endpoint is invalid');
      expect(
        PrivacySecuritySummaryHelper.validateCustomProxyUrl(
          'socks5://127.0.0.1',
        ),
        isNotNull,
      );
    });

    test('notes when link previews are disabled', () {
      const settings = PrivacySettings(showLinkPreviews: false);

      final summary = PrivacySecuritySummaryHelper.networkSummary(settings);

      expect(summary, 'Direct network path · Link previews off');
    });

    test('builds encryption summary for configured backup', () {
      final summary = PrivacySecuritySummaryHelper.encryptionSummary(
        status: E2EEStatus.ready,
        backupInfo: KeyBackupInfo(
          version: '1',
          algorithm: 'm.megolm_backup.v1.curve25519-aes-sha2',
          count: 24,
          etag: 'etag-1',
        ),
      );

      expect(summary, 'E2EE ready · 24 keys backed up');
    });

    test('builds identity summary with username and hidden phone', () {
      const settings = PrivacySettings(hidePhoneNumber: true);

      final summary = PrivacySecuritySummaryHelper.identitySummary(
        settings: settings,
        username: 'n42alice',
      );

      expect(summary, '@n42alice for public contact · phone masked locally');
    });
  });
}
