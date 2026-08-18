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

  testWidgets('self-destruct image hides save and OCR actions defensively', (
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
          onSave: () {},
          onExtractText: () {},
          onTranslateImage: () {},
        ),
      ),
    );

    expect(find.text('Save'), findsNothing);
    expect(find.text('Extract text'), findsNothing);
    expect(find.text('Translate image'), findsNothing);
  });

  testWidgets('self-destruct text message hides copy/forward/favorite/quote', (
    tester,
  ) async {
    MessageEntity textMsg({int? selfDestructAfter}) => MessageEntity(
      id: 'text-event',
      roomId: 'room',
      senderId: 'alice',
      senderName: 'Alice',
      content: 'secret',
      type: MessageType.text,
      timestamp: DateTime(2026),
      selfDestructAfter: selfDestructAfter,
    );

    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget menu(MessageEntity m) => MaterialApp(
      home: WeChatMessageMenu(
        message: m,
        position: const Offset(100, 600),
        messageSize: const Size(160, 60),
        onDismiss: () {},
        onCopy: () {},
        onForward: () {},
        onFavorite: () {},
        onQuote: () {},
      ),
    );

    // Normal text messages retain all outbound actions.
    await tester.pumpWidget(menu(textMsg()));
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Forward'), findsOneWidget);
    expect(find.text('Fav'), findsOneWidget);
    expect(find.text('Quote'), findsOneWidget);

    // Self-destruct text messages expose no outbound actions.
    await tester.pumpWidget(menu(textMsg(selfDestructAfter: 30)));
    expect(find.text('Copy'), findsNothing);
    expect(find.text('Forward'), findsNothing);
    expect(find.text('Fav'), findsNothing);
    expect(find.text('Quote'), findsNothing);
  });
}
