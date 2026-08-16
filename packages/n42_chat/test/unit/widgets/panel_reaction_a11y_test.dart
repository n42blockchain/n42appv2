import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_more_panel.dart';
import 'package:n42_chat/src/presentation/widgets/chat/message_reaction_bar.dart';

/// 无障碍（Semantics）回归测试 —— Roadmap #33 面板/选择器面。
///
/// 这些图标网格/表情按钮以前对屏幕阅读器只播报"按钮"无描述。本用例锁定
/// 它们被标注为带标签的可点按语义节点。两个 widget 均无 DI 依赖。
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('attachment grid items are labeled buttons', (tester) async {
    await tester.pumpWidget(wrap(ChatMorePanel(onPhotoPressed: () {})));

    // 'Photos'（contactPhotos 的英文兜底）是首页第一格、无条件渲染，
    // 稳定可断言。（原断言 'Transfer' 在面板重构后已不在首页第一行。）
    final node = tester.getSemantics(find.bySemanticsLabel('Photos'));
    expect(node.flagsCollection.isButton, isTrue);
  });

  testWidgets('quick reaction emojis are labeled buttons', (tester) async {
    await tester.pumpWidget(
      wrap(QuickReactionPicker(onReactionSelected: (_) {})),
    );

    // 每个反应 emoji 都被包成 Semantics(button: true)。
    final reactionButtons = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.button == true,
    );
    expect(reactionButtons, findsWidgets);
  });
}
