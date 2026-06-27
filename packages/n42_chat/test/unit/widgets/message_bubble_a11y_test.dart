import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/message_bubble.dart';
import 'package:n42_chat/src/presentation/widgets/chat/message_status_indicator.dart';

/// 无障碍（Semantics）回归测试 —— Roadmap #33。
///
/// 历史上 chat 仓 `Semantics()` 全仓 0 命中，屏幕阅读器无法播报头像发送者
/// 与消息发送状态。这些用例锁定本次补齐的语义标签，防止回归。
void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  testWidgets('avatar exposes sender name to screen readers', (tester) async {
    await tester.pumpWidget(
      wrap(
        const MessageBubble(
          isSelf: false,
          avatarName: 'Alice',
          child: Text('hi'),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Alice'), findsOneWidget);
  });

  testWidgets('sending status is announced', (tester) async {
    await tester.pumpWidget(
      wrap(
        const MessageBubble(
          isSelf: true,
          status: MessageStatus.sending,
          showAvatar: false,
          child: Text('hi'),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Sending'), findsOneWidget);
  });

  testWidgets('failed status announces resend affordance', (tester) async {
    await tester.pumpWidget(
      wrap(
        const MessageBubble(
          isSelf: true,
          status: MessageStatus.failed,
          showAvatar: false,
          child: Text('hi'),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Failed to send, tap to resend'),
      findsOneWidget,
    );
  });
}
