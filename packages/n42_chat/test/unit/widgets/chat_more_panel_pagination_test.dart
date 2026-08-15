import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_more_panel.dart';

/// 回归：「+」面板历史上按三个手工"逻辑页"组织，而每页只渲染前 8 项——
/// 第一页实际 11 项、第二页 9 项，超出的 Contact/Code/Tip/View Once 被
/// 静默丢弃，用户彻底点不到（被感知为"功能消失"）。修复后按 8 项/页
/// 自动分页，本测试锁定：所有条目（含曾丢失的四项）滑页后都能找到。
void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Align(alignment: Alignment.bottomCenter, child: child),
      ),
    );
  }

  ChatMorePanel fullPanel() {
    void noop() {}
    return ChatMorePanel(
      onPhotoPressed: noop,
      onCameraPressed: noop,
      onVideoCallPressed: noop,
      onLocationPressed: noop,
      onLiveLocationPressed: noop,
      onRedPacketPressed: noop,
      onTransferPressed: noop,
      onFilePressed: noop,
      onContactCardPressed: noop,
      onFavoritePressed: noop,
      onMusicPressed: noop,
      onReceivePressed: noop,
      onShopPressed: noop,
      onPollPressed: noop,
      onEventPressed: noop,
      onGifPressed: noop,
      onStickerPressed: noop,
      onViewOncePressed: noop,
      onFaceBlurPressed: noop,
      onAiAssistantPressed: noop,
      onSelfDestructTimerPressed: noop,
      onScheduledPressed: noop,
      onMiniAppsPressed: noop,
      onCodePressed: noop,
      onTipPressed: noop,
      onWhiteboardPressed: noop,
      onVideoNotePressed: noop,
    );
  }

  /// 逐页滑动 PageView，收集全程出现过的文本标签。
  Future<Set<String>> collectAllLabels(WidgetTester tester) async {
    final seen = <String>{};
    void snapshot() {
      for (final w in tester.widgetList<Text>(find.byType(Text))) {
        final data = w.data;
        if (data != null && data.isNotEmpty) seen.add(data);
      }
    }

    snapshot();
    // 最多滑 10 页（远超实际页数），页面内容不再变化即停。
    for (var i = 0; i < 10; i++) {
      final before = seen.length;
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      snapshot();
      if (seen.length == before) break;
    }
    return seen;
  }

  testWidgets('曾被静默丢弃的四项（Contact/Code/Tip/View Once）可达', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(fullPanel()));
    await tester.pumpAndSettle();

    final labels = await collectAllLabels(tester);
    for (final expected in ['Contact', 'Code', 'Tip', 'View Once']) {
      expect(
        labels,
        contains(expected),
        reason: '「$expected」应在某一页可达——历史 bug 会把每页第 9 项起静默丢弃',
      );
    }
  });

  testWidgets('全部 30 项条目滑页后均可达（未来加项也不会再丢）', (tester) async {
    await tester.pumpWidget(wrap(fullPanel()));
    await tester.pumpAndSettle();

    final labels = await collectAllLabels(tester);
    const all = [
      'Photos', 'Camera', 'Video Call', 'Location',
      'Red Packet', 'Transfer', 'Apps', 'File',
      'Contact', 'Code', 'Tip',
      'Favorites', 'Music', 'Receive', 'Shop', 'Poll', 'Event', 'GIF',
      'Stickers', 'View Once',
      'Face Blur', 'Live Location', 'Timer', 'Scheduled',
      'Whiteboard', 'Video note', 'AI',
    ];
    final missing = all.where((l) => !labels.contains(l)).toList();
    expect(
      missing,
      isEmpty,
      reason: '以下条目在任何页都找不到（被分页逻辑丢弃）：$missing',
    );
  });
}
