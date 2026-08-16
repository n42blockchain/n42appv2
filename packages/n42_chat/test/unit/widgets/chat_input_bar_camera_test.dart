import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_input_bar.dart';

void main() {
  testWidgets('空输入时显示相机快捷入口，输入文字后切换为发送', (tester) async {
    var cameraTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            showVoiceButton: false,
            showQuickReplyButton: false,
            showEmojiButton: false,
            onCameraPressed: () => cameraTaps++,
            onMorePressed: () {},
            onSendText: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.camera_alt_outlined));
    expect(cameraTaps, 1);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}
