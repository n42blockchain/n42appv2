import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/widgets/chat/wechat_message_menu.dart';

void main() {
  testWidgets('image menu exposes separate extract and translate actions', (
    tester,
  ) async {
    var extracted = false;
    var translated = false;
    final message = MessageEntity(
      id: 'image-event',
      roomId: 'room',
      senderId: 'alice',
      senderName: 'Alice',
      content: 'image.png',
      type: MessageType.image,
      timestamp: DateTime(2026),
    );

    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WeChatMessageMenu(
          message: message,
          position: const Offset(100, 600),
          messageSize: const Size(160, 120),
          onDismiss: () {},
          onExtractText: () => extracted = true,
          onTranslateImage: () => translated = true,
        ),
      ),
    );

    expect(find.text('Extract text'), findsOneWidget);
    expect(find.text('Translate image'), findsOneWidget);

    await tester.tap(find.text('Extract text'));
    expect(extracted, isTrue);
    await tester.tap(find.text('Translate image'));
    expect(translated, isTrue);
  });

  testWidgets('image OCR actions are absent when callbacks are withheld', (
    tester,
  ) async {
    final message = MessageEntity(
      id: 'protected-image-event',
      roomId: 'room',
      senderId: 'alice',
      senderName: 'Alice',
      content: 'image.png',
      type: MessageType.image,
      timestamp: DateTime(2026),
      selfDestructAfter: 30,
    );

    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WeChatMessageMenu(
          message: message,
          position: const Offset(100, 600),
          messageSize: const Size(160, 120),
          onDismiss: () {},
        ),
      ),
    );

    expect(find.text('Extract text'), findsNothing);
    expect(find.text('Translate image'), findsNothing);
  });
}
