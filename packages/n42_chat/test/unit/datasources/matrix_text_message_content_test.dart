import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_text_message_content.dart';

void main() {
  group('normalizeMatrixText', () {
    test('normalizes unicode and line endings while preserving emoji', () {
      const raw = 'Cafe\u0301\r\nمرحبا 👨‍👩‍👧‍👦';

      expect(normalizeMatrixText(raw), 'Café\nمرحبا 👨‍👩‍👧‍👦');
    });
  });

  group('buildTextMessageContent', () {
    test('builds safe formatted content for multilingual text', () {
      final content = buildTextMessageContent(
        '你好 <b>世界</b>\r\nCafe\u0301 👩🏽‍💻',
        selfDestructAfter: 30,
        mentionedUserIds: const ['@bob:server.test'],
        mentionsRoom: true,
        replySenderId: '@alice:server.test',
        currentUserId: '@me:server.test',
      );

      expect(content['body'], '你好 <b>世界</b>\nCafé 👩🏽‍💻');
      expect(content['format'], 'org.matrix.custom.html');
      expect(
        content['formatted_body'],
        '你好 &lt;b&gt;世界&lt;/b&gt;<br>Café 👩🏽‍💻',
      );
      expect((content['m.mentions'] as Map<String, dynamic>)['room'], isTrue);
      expect(
        ((content['m.mentions'] as Map<String, dynamic>)['user_ids']
                as List<dynamic>)
            .cast<String>()
            .toSet(),
        {'@alice:server.test', '@bob:server.test'},
      );
      expect(content['n42.self_destruct'], {'after': 30});
    });

    test(
      'renders markdown as safe Matrix HTML without passing raw html through',
      () {
        final content = buildTextMessageContent(
          '## Release Notes\n\n- **Done**\n- `dart test`\n\n<script>alert(1)</script>',
        );

        expect(
          content['formatted_body'],
          '<h2>Release Notes</h2>\n<ul>\n<li><strong>Done</strong></li>\n<li><code>dart test</code></li>\n</ul>\n<p>&lt;script&gt;alert(1)&lt;/script&gt;</p>',
        );
      },
    );
  });
}
