// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/pages/chat/message_item.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_input_bar.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_more_panel.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CHAT-E2EE renders missing keys as a neutral placeholder', (
    tester,
  ) async {
    final missingKeyMessage = MessageEntity(
      id: r'$missing-key',
      roomId: '!device-test:n42',
      senderId: '@me:n42',
      senderName: 'Me',
      content: '',
      timestamp: DateTime(2026, 8, 15, 23),
      type: MessageType.encrypted,
      status: MessageStatus.sent,
      isFromMe: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Encrypted conversation'),
                  subtitle: Text('Device recovery state'),
                ),
                Expanded(
                  child: Center(child: MessageItem(message: missingKeyMessage)),
                ),
                ChatInputBar(
                  showVoiceButton: false,
                  showQuickReplyButton: false,
                  showEmojiButton: false,
                  isMorePanelOpen: true,
                  onMorePressed: () {},
                ),
                _attachmentPanel(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(
      find.byKey(const ValueKey<String>('chat_encrypted_placeholder')),
      findsOneWidget,
    );
    expect(find.textContaining('session key'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('chat_more_panel')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('chat-e2ee-placeholder-ios');
  });
}

ChatMorePanel _attachmentPanel() {
  void noop() {}
  return ChatMorePanel(
    onPhotoPressed: noop,
    onCameraPressed: noop,
    onLocationPressed: noop,
    onContactCardPressed: noop,
    onFilePressed: noop,
    onPollPressed: noop,
    onEventPressed: noop,
    onMiniAppsPressed: noop,
  );
}
