// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_chat/src/presentation/pages/conversation/conversation_tile.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_input_bar.dart';
import 'package:n42_wallet/main.dart' as app;

const _chatUsername = String.fromEnvironment('N42_E2E_CHAT_USERNAME');
const _chatPassword = String.fromEnvironment('N42_E2E_CHAT_PASSWORD');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'CHAT-DEVICE opens a real conversation and the attachment panel',
    (tester) async {
      app.main();
      await _waitForKey(tester, 'home_page', const Duration(seconds: 60));

      await tester.tap(find.byKey(const ValueKey<String>('home_tab_chat')));
      await tester.pump(const Duration(seconds: 1));
      var chatState = await _waitForAnyKey(tester, const [
        'chat_welcome_page',
        'chat_login_page',
        'chat_main_page',
      ], const Duration(seconds: 90));
      if (chatState == 'chat_welcome_page') {
        await tester.tap(
          find.byKey(const ValueKey<String>('chat_welcome_login')),
        );
        await tester.pump(const Duration(seconds: 1));
        chatState = 'chat_login_page';
      }
      if (chatState == 'chat_login_page') {
        expect(
          _chatUsername,
          isNotEmpty,
          reason: 'Set N42_E2E_CHAT_USERNAME for an unauthenticated device.',
        );
        expect(
          _chatPassword,
          isNotEmpty,
          reason: 'Set N42_E2E_CHAT_PASSWORD for an unauthenticated device.',
        );
        await tester.enterText(
          find.byKey(const ValueKey<String>('chat_login_username')),
          _chatUsername,
        );
        await tester.enterText(
          find.byKey(const ValueKey<String>('chat_login_password')),
          _chatPassword,
        );
        await tester.tap(
          find.byKey(const ValueKey<String>('chat_login_submit')),
        );
        await tester.pump(const Duration(seconds: 1));
        await _waitForKey(
          tester,
          'chat_main_page',
          const Duration(seconds: 90),
        );
      }
      await _waitForKey(
        tester,
        'chat_content_messages',
        const Duration(seconds: 30),
      );

      final conversation = find.byType(ConversationTile).first;
      await _waitFor(tester, conversation, const Duration(seconds: 60));
      await tester.tap(conversation);
      await tester.pump(const Duration(seconds: 2));
      await _waitFor(
        tester,
        find.byType(ChatInputBar),
        const Duration(seconds: 30),
      );

      final attachmentToggle = find.byKey(
        const ValueKey<String>('chat_input_attachment_toggle'),
      );
      await _waitFor(tester, attachmentToggle, const Duration(seconds: 10));
      await tester.tap(attachmentToggle);
      await tester.pump(const Duration(seconds: 2));
      await _waitForKey(tester, 'chat_more_panel', const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 8));

      expect(tester.takeException(), isNull);
      await binding.takeScreenshot('chat-extension-ios');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

Future<void> _waitForKey(WidgetTester tester, String key, Duration timeout) =>
    _waitFor(tester, find.byKey(ValueKey<String>(key)), timeout);

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder,
  Duration timeout,
) async {
  final stopwatch = Stopwatch()..start();
  while (finder.evaluate().isEmpty && stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(finder, findsAtLeastNWidgets(1));
}

Future<String> _waitForAnyKey(
  WidgetTester tester,
  List<String> keys,
  Duration timeout,
) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    for (final key in keys) {
      if (find.byKey(ValueKey<String>(key)).evaluate().isNotEmpty) return key;
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
  fail('Timed out waiting for one of: ${keys.join(', ')}');
}
