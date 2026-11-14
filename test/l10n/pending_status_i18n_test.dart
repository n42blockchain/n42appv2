import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// The pending-transaction warnings guard against paying twice; every shipped
/// locale must carry its own text rather than silently falling back to English
/// (qps is the pseudo-locale and only checks that it was transformed).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  List<String> texts(S s) => [
    s.g_memo_pending_unknown_title,
    s.g_memo_pending_unknown_body,
    s.g_memo_pending_keep_waiting,
    s.g_memo_pending_dismiss,
    s.g_memo_pending_dismissed,
    s.g_tx_status_unconfirmed,
    s.g_tx_status_unconfirmed_hint,
  ];

  test('every locale translates the pending-status texts', () async {
    final english = texts(await S.load(const Locale('en')));
    for (final locale in S.delegate.supportedLocales) {
      if (locale.languageCode == 'en') continue;
      final local = texts(await S.load(locale));
      for (var i = 0; i < english.length; i++) {
        expect(local[i], isNotEmpty, reason: '$locale #$i');
        expect(local[i], isNot(english[i]), reason: '$locale #$i');
      }
    }
    await S.load(const Locale('en'));
  });
}
