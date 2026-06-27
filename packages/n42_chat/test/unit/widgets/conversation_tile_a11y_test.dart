import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/presentation/pages/conversation/conversation_tile.dart';

/// 无障碍（Semantics）回归测试 —— Roadmap #33 会话列表面。
///
/// 会话项以前把名称、图标、消息、时间拆成多段零碎播报。本用例锁定整条
/// 会话被合并为「单个可点按语义节点」并组合播报关键信息。
/// 用群聊 entity 以绕开 RemarkService（群聊名称直取 conversation.name）。
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('conversation tile merges into one labeled button', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ConversationTile(
          conversation: ConversationEntity(
            id: '!room:server',
            name: 'Design Team',
            type: ConversationType.group,
            lastMessage: 'See you tomorrow',
            unreadCount: 3,
            memberCount: 5,
          ),
        ),
      ),
    );

    // 名称、最后消息、未读数都进入同一（合并后的）语义标签节点。
    expect(find.bySemanticsLabel(RegExp('Design Team')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('See you tomorrow')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('3 unread')), findsOneWidget);
  });
}
