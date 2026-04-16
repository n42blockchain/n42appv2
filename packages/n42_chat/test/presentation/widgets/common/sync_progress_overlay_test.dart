import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/widgets/common/sync_progress_overlay.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildOverlay() {
  return const MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: Locale('en'),
    home: Scaffold(
      body: Stack(
        children: [
          Placeholder(),
          SyncProgressOverlay(),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SyncProgressOverlay', () {
    testWidgets(
      'Matrix 客户端未初始化时组件不可见（SizedBox.shrink）',
      (tester) async {
        // 测试环境中 MatrixClientManager.instance 的 onSyncStatus 为 null
        // _checkSyncState() 早返回，_visible = false
        await tester.pumpWidget(_buildOverlay());
        await tester.pump();

        // 覆盖层不显示，不含进度指示器也不含同步文本
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.textContaining('Sync'), findsNothing);
      },
    );

    testWidgets('组件本身不抛出异常', (tester) async {
      // 只要组件能正常 build / dispose 即可
      await tester.pumpWidget(_buildOverlay());
      await tester.pumpAndSettle();
      // 无 FlutterError
    });

    testWidgets('暗色主题下组件不抛出异常', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: Stack(
              children: [
                Placeholder(),
                SyncProgressOverlay(),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // 暗色主题下也应安全渲染
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('dispose 时正确释放 AnimationController 无报错', (tester) async {
      await tester.pumpWidget(_buildOverlay());
      await tester.pumpAndSettle();

      // 从 widget tree 移除，触发 dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
      // 没有 AnimationController 相关的 FlutterError
    });
  });
}
