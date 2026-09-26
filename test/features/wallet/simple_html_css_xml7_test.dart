import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_html_css/simple_html_css.dart';

void main() {
  Future<TextSpan> parse(
    WidgetTester tester,
    String html, {
    void Function(dynamic)? onLink,
  }) async {
    late TextSpan parsed;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            parsed = HTML.toTextSpan(context, html, linksCallback: onLink);
            return RichText(text: parsed);
          },
        ),
      ),
    );
    return parsed;
  }

  testWidgets('nested tags retain text and inherited styles', (tester) async {
    final span = await parse(tester, '<p>A <b>bold <i>and</i></b> tail</p>');
    expect(span.toPlainText(), contains('A bold and tail'));
    final textSpans = span.children!.cast<TextSpan>();
    expect(
      textSpans.firstWhere((item) => item.text == 'bold ').style?.fontWeight,
      FontWeight.bold,
    );
    expect(
      textSpans.firstWhere((item) => item.text == 'and').style?.fontStyle,
      FontStyle.italic,
    );
  });

  testWidgets('link entity decodes and callback keeps its URL', (tester) async {
    Object? tapped;
    final span = await parse(
      tester,
      '<a href="https://n42.ai/?a=1&amp;b=2">Open</a>',
      onLink: (value) => tapped = value,
    );
    final link = span.children!.cast<TextSpan>().single;
    expect(link.text, 'Open');
    (link.recognizer as TapGestureRecognizer).onTap!();
    expect(tapped, 'https://n42.ai/?a=1&b=2');
  });

  testWidgets('entities, br and self-closing tags keep visible text', (
    tester,
  ) async {
    final span = await parse(tester, '<p>A &amp; B<br/>C<img src="x"/></p>');
    expect(span.toPlainText(), 'A & B\nC');
  });

  testWidgets('malformed nesting yields no misleading partial text', (
    tester,
  ) async {
    final span = await parse(tester, '<p><b>secret</p></b>');
    expect(span.toPlainText(), isEmpty);
  });

  testWidgets('prefixed tags preserve content', (tester) async {
    final span = await parse(
      tester,
      '<x:p xmlns:x="urn:n42"><x:b>Notice</x:b></x:p>',
    );
    expect(span.toPlainText(), 'Notice');
  });
}
