import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/code_block_message_widget.dart';

void main() {
  for (final raw in [
    'hello\nworld',
    '```dart\nfinal n = 42;\n```',
    List.generate(30, (i) => 'line $i 中文内容').join('\n'),
  ]) {
    testWidgets('renders code content ${raw.length} at narrow width', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 220,
                child: CodeBlockMessageWidget(raw: raw),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final parsed = CodeBlockMessageWidget.parse(raw);
      final rich = tester.widgetList<RichText>(find.byType(RichText));
      expect(rich.any((r) => r.text.toPlainText() == parsed.code), isTrue);
      expect(find.byType(ErrorWidget), findsNothing);
    });
  }
}
