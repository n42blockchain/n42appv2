import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_more_panel.dart';

/// 回归：「+」面板历史上按三个手工"逻辑页"组织，而每页只渲染前 8 项——
/// 第一页实际 11 项、第二页 9 项，超出的 Contact/Code/Tip/View Once 被
/// 静默丢弃，用户彻底点不到（被感知为"功能消失"）。修复后按 8 项/页
/// 自动分页，本测试锁定：所有条目（含曾丢失的四项）滑页后都能找到。
void main() {
  final thumbnail = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

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

  testWidgets('曾被静默丢弃的四项（Contact/Code/Tip/View Once）可达', (tester) async {
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
      'Photos',
      'Camera',
      'Video Call',
      'Location',
      'Red Packet',
      'Transfer',
      'Apps',
      'File',
      'Contact',
      'Code',
      'Tip',
      'Favorites',
      'Music',
      'Receive',
      'Shop',
      'Poll',
      'Event',
      'GIF',
      'Stickers',
      'View Once',
      'Face Blur',
      'Live Location',
      'Timer',
      'Scheduled',
      'Whiteboard',
      'Video note',
      'AI',
    ];
    final missing = all.where((l) => !labels.contains(l)).toList();
    expect(missing, isEmpty, reason: '以下条目在任何页都找不到（被分页逻辑丢弃）：$missing');
  });

  testWidgets('首屏优先展示通用分享动作', (tester) async {
    await tester.pumpWidget(wrap(fullPanel()));
    await tester.pumpAndSettle();

    for (final label in [
      'Photos',
      'Camera',
      'Location',
      'Contact',
      'File',
      'Poll',
      'Event',
      'Apps',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label 应固定在首屏');
    }
    expect(find.text('Video Call'), findsNothing);
  });

  testWidgets('最近媒体按选择顺序发送并显示序号', (tester) async {
    List<String>? sentIds;
    final panel = ChatMorePanel(
      onPhotoPressed: () {},
      recentMediaLoader: () async => ChatRecentMediaSnapshot(
        access: ChatRecentMediaAccess.available,
        items: [
          ChatRecentMediaItem(id: 'a', thumbnailBytes: thumbnail),
          ChatRecentMediaItem(
            id: 'b',
            thumbnailBytes: thumbnail,
            isVideo: true,
            duration: const Duration(seconds: 65),
          ),
        ],
      ),
      onRecentMediaSend: (ids) async => sentIds = ids,
    );

    await tester.pumpWidget(wrap(panel));
    await tester.pumpAndSettle();
    final tiles = find.bySemanticsLabel(RegExp('Recent (photo|video)'));
    expect(tiles, findsNWidgets(2));

    await tester.tap(tiles.at(1));
    await tester.tap(tiles.at(0));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1:05'), findsOneWidget);

    await tester.tap(find.textContaining('(2)'));
    await tester.pumpAndSettle();
    expect(sentIds, ['b', 'a']);
  });

  testWidgets('最近媒体遵守最大选择数量', (tester) async {
    final panel = ChatMorePanel(
      recentMediaLoader: () async => ChatRecentMediaSnapshot(
        access: ChatRecentMediaAccess.available,
        items: [
          ChatRecentMediaItem(id: 'a', thumbnailBytes: thumbnail),
          ChatRecentMediaItem(id: 'b', thumbnailBytes: thumbnail),
        ],
      ),
      onRecentMediaSend: (_) async {},
      maxRecentMediaSelection: 1,
    );
    await tester.pumpWidget(wrap(panel));
    await tester.pumpAndSettle();

    final tiles = find.bySemanticsLabel('Recent photo');
    await tester.tap(tiles.at(0));
    await tester.tap(tiles.at(1));
    await tester.pump();

    expect(find.textContaining('(1)'), findsOneWidget);
    expect(find.text('Select up to 1 items'), findsOneWidget);
  });

  testWidgets('窄屏有限授权且已选择媒体时顶栏不溢出', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final panel = ChatMorePanel(
      onPhotoPressed: () {},
      recentMediaLoader: () async => ChatRecentMediaSnapshot(
        access: ChatRecentMediaAccess.limited,
        items: [ChatRecentMediaItem(id: 'a', thumbnailBytes: thumbnail)],
      ),
      onRecentMediaSend: (_) async {},
      onManageRecentMediaAccess: () async {},
    );

    await tester.pumpWidget(wrap(panel));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Recent photo'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Send (1)'), findsOneWidget);
  });

  testWidgets('窄屏拒绝相册权限时提供系统相册与设置降级入口', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var photosOpened = 0;
    var settingsOpened = 0;
    final panel = ChatMorePanel(
      onPhotoPressed: () => photosOpened++,
      recentMediaLoader: () async =>
          const ChatRecentMediaSnapshot(access: ChatRecentMediaAccess.denied),
      onManageRecentMediaAccess: () async => settingsOpened++,
    );

    await tester.pumpWidget(wrap(panel));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Photo access is needed to show recent media'), findsOne);

    await tester.tap(find.text('Open Photos'));
    await tester.tap(find.text('Settings'));
    expect(photosOpened, 1);
    expect(settingsOpened, 1);
  });
}
