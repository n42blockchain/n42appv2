import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/a11y_l10n.dart';

/// 锁定无障碍标签的多语言行为 —— Roadmap #33 l10n 化。
void main() {
  group('A11yL10n static strings', () {
    test('simplified Chinese', () {
      const a = A11yL10n('zh');
      expect(a.sending, '发送中');
      expect(a.failedToSendTapResend, '发送失败，点按重发');
      expect(a.muted, '已静音');
      expect(a.unreadCount(3), '3 条未读');
      expect(a.voiceMessageDuration(5), '语音消息，5 秒');
    });

    test('traditional Chinese', () {
      const a = A11yL10n('zh_TW');
      expect(a.sending, '傳送中');
      expect(a.tabSticker, '貼圖');
      expect(a.unreadCount(3), '3 則未讀');
      expect(a.file('a.pdf'), '檔案，a.pdf');
    });

    test('english fallback', () {
      const a = A11yL10n('en');
      expect(a.sending, 'Sending');
      expect(a.unreadCount(3), '3 unread');
      expect(a.pollOption('Yes', 2), 'Yes, 2 votes');
    });

    test('live-region announcements', () {
      expect(const A11yL10n('zh').newMessageFrom('Bob'), 'Bob 发来新消息');
      expect(const A11yL10n('zh_TW').userTyping('Bob'), 'Bob 正在輸入');
      expect(const A11yL10n('en').newMessageFromWithText('Bob', 'hi'),
          'New message from Bob: hi');
      expect(const A11yL10n('en').peopleTyping(3), '3 people typing');
    });

    test('settings form labels', () {
      expect(const A11yL10n('zh').solidColor, '纯色背景');
      expect(const A11yL10n('zh_TW').gradient, '漸層背景');
      expect(const A11yL10n('en').showPassword, 'Show password');
      expect(const A11yL10n('zh').hidePassword, '隐藏密码');
    });
  });

  group('A11yL10n.of locale normalization', () {
    A11yL10n resolveFor(Locale locale) {
      late A11yL10n result;
      runApp(
        Localizations(
          locale: locale,
          delegates: const [
            DefaultWidgetsLocalizations.delegate,
          ],
          child: Builder(
            builder: (context) {
              result = A11yL10n.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('zh -> simplified, zh_TW -> traditional, others -> en', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox());

      expect(resolveFor(const Locale('zh')).sending, '发送中');
      expect(
        resolveFor(const Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'))
            .sending,
        '傳送中',
      );
      expect(
        resolveFor(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'))
            .sending,
        '傳送中',
      );
      expect(resolveFor(const Locale('en')).sending, 'Sending');
      expect(resolveFor(const Locale('fr')).sending, 'Sending');
    });
  });
}
