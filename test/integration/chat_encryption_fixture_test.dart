import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart' as chat;

import '../../integration_test/chat_e2ee_placeholder_device_test.dart'
    as scenario;

void main() {
  for (final locale in ['en', 'ar']) {
    testWidgets('native encrypted placeholder fixture localizes in $locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        scenario.encryptedPlaceholderFixture(locale: Locale(locale)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final placeholder = find.byKey(
        const ValueKey<String>('chat_encrypted_placeholder'),
      );
      expect(placeholder, findsOneWidget);
      final strings = chat.S.of(tester.element(placeholder))!;
      expect(find.text(strings.chatMessageUnavailable), findsOneWidget);
      expect(find.textContaining('session key'), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('chat_more_panel')),
        findsOneWidget,
      );
    });
  }
}
