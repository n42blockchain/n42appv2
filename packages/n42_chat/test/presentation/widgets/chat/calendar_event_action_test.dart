import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/utils/event_message_data.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/pages/chat/message_item.dart';

void main() {
  testWidgets(
    'calendar action opens native editor with event fields and tolerates cancel',
    (tester) async {
      const channel = MethodChannel('n42.chat/calendar');
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        return false;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final data = EventMessageData(
        title: 'Team meeting',
        startsAt: DateTime.utc(2026, 10, 1, 10),
        endsAt: DateTime.utc(2026, 10, 1, 11),
        location: 'Office',
        description: 'Planning',
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: MessageItem(
              message: MessageEntity(
                id: 'event',
                roomId: '!room:test',
                senderId: '@sender:test',
                senderName: 'Sender',
                content: 'Team meeting',
                type: MessageType.event,
                timestamp: DateTime(2026),
                metadata: MessageMetadata(event: data),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to calendar'));
      await tester.pumpAndSettle();
      expect(calls.single.method, 'addEvent');
      expect(calls.single.arguments, data.toContent());
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
