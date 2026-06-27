import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/custom_emoji_text.dart';
import 'package:n42_chat/src/presentation/widgets/chat/markdown_message_widget.dart';

void main() {
  testWidgets('renders custom emoji inside markdown messages', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MarkdownMessageWidget(text: '**Bold** :fire:', isSelf: false),
        ),
      ),
    );

    expect(find.byType(CustomEmojiInline), findsOneWidget);
  });

  testWidgets('keeps unknown shortcode as markdown text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MarkdownMessageWidget(
            text: '**Bold** :unknown_code:',
            isSelf: false,
          ),
        ),
      ),
    );

    expect(find.byType(CustomEmojiInline), findsNothing);
    expect(find.textContaining(':unknown_code:'), findsOneWidget);
  });
}
