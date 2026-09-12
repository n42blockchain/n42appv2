import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/widgets/chat/wechat_message_menu.dart';

void main() {
  for (final locale in ['en', 'ar']) {
    testWidgets('$locale compact menu preserves every action under More', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var deleted = 0;
      var dismissed = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: Locale(locale),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              viewInsets: EdgeInsets.only(bottom: 280),
              textScaler: TextScaler.linear(1.5),
            ),
            child: WeChatMessageMenu(
              message: MessageEntity(
                id: 'event',
                roomId: 'room',
                senderId: 'alice',
                senderName: 'Alice',
                content: 'hello',
                type: MessageType.text,
                timestamp: DateTime(2026),
                isFromMe: true,
              ),
              position: const Offset(40, 240),
              messageSize: const Size(180, 44),
              onDismiss: () => dismissed++,
              onCopy: () {},
              onQuote: () {},
              onForward: () {},
              onFavorite: () {},
              onEdit: () {},
              onReplyInThread: () {},
              onMultiSelect: () {},
              onTranslate: () {},
              onSpeak: () {},
              onReadingMode: () {},
              onRecall: () {},
              onSearch: () {},
              onDelete: () => deleted++,
              onReaction: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('message-action-quote')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('message-action-delete')), findsNothing);
      final more = find.byKey(const ValueKey('message-action-more'));
      await tester.ensureVisible(more);
      await tester.tap(more);
      await tester.pumpAndSettle();
      expect(dismissed, 0);
      for (final id in [
        'copy',
        'quote',
        'forward',
        'favorite',
        'edit',
        'thread',
        'select',
        'translate',
        'speak',
        'reading',
        'recall',
        'search',
        'delete',
      ]) {
        expect(find.byKey(ValueKey('message-action-$id')), findsOneWidget);
      }
      final deletion = find.byKey(const ValueKey('message-action-delete'));
      await tester.ensureVisible(deletion);
      await tester.tap(deletion);
      expect(deleted, 1);
      expect(dismissed, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
