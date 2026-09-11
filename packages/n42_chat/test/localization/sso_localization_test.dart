import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';

void main() {
  for (final code in ['ar', 'bn', 'hi', 'pl', 'ru', 'tr', 'ur']) {
    test('SSO configuration warning is localized in $code', () async {
      final translated = await S.delegate.load(Locale(code));
      final english = await S.delegate.load(const Locale('en'));
      expect(translated.authSsoNotConfigured.trim(), isNotEmpty);
      expect(
        translated.authSsoNotConfigured,
        isNot(english.authSsoNotConfigured),
      );
      expect(translated.authSsoNotConfigured, contains('SSO'));
    });
  }
  test('all locales preserve sender, feature and comment arguments', () async {
    for (final locale in S.supportedLocales) {
      final translated = await S.delegate.load(locale);
      expect(
        translated.commonFromSender('fixture-sender'),
        contains('fixture-sender'),
        reason: '$locale',
      );
      expect(
        translated.commonFeatureInDevelopment('fixture-feature'),
        contains('fixture-feature'),
        reason: '$locale',
      );
      expect(
        translated.momentCommentsCount(7),
        contains('7'),
        reason: '$locale',
      );
      // This must remain a String label, not a function interpolated as Closure.
      final String total = translated.redPacketStatsTotal;
      expect(total.trim(), isNotEmpty, reason: '$locale');
      expect(total, isNot(contains('Closure')), reason: '$locale');
    }
  });
}
