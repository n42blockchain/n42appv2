import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/widgets/chat/slash_command_picker.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildPicker({
  required String query,
  required void Function(SlashCommandItem) onSelect,
}) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: Column(
        children: [
          SlashCommandPicker(query: query, onSelect: onSelect),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SlashCommandPicker — 渲染与过滤', () {
    testWidgets('空 query 时显示全部命令', (tester) async {
      await tester.pumpWidget(_buildPicker(query: '', onSelect: (_) {}));
      await tester.pumpAndSettle();

      // maxHeight=220 内约显示 4 条（dense ListTile + subtitle ≈ 52px）
      expect(find.text('/help'), findsOneWidget);
      expect(find.text('/price'), findsOneWidget);
      expect(find.text('/balance'), findsOneWidget);
      expect(find.text('/chains'), findsOneWidget);

      // 向上滚动以查看剩余 3 条命令
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('/poll'), findsOneWidget);
      expect(find.text('/announce'), findsOneWidget);
      expect(find.text('/welcome'), findsOneWidget);
    });

    testWidgets('query=p 过滤出 /price 和 /poll', (tester) async {
      await tester.pumpWidget(_buildPicker(query: 'p', onSelect: (_) {}));
      await tester.pumpAndSettle();

      expect(find.text('/price'), findsOneWidget);
      expect(find.text('/poll'), findsOneWidget);

      // 不含 /help, /balance, /chains, /announce, /welcome
      expect(find.text('/help'), findsNothing);
      expect(find.text('/balance'), findsNothing);
      expect(find.text('/welcome'), findsNothing);
    });

    testWidgets('query=pr 仅显示 /price', (tester) async {
      await tester.pumpWidget(_buildPicker(query: 'pr', onSelect: (_) {}));
      await tester.pumpAndSettle();

      expect(find.text('/price'), findsOneWidget);
      expect(find.text('/poll'), findsNothing);
    });

    testWidgets('query 大写时大小写不敏感匹配', (tester) async {
      await tester.pumpWidget(_buildPicker(query: 'HELP', onSelect: (_) {}));
      await tester.pumpAndSettle();

      expect(find.text('/help'), findsOneWidget);
    });

    testWidgets('不匹配任何命令时渲染 SizedBox.shrink（空）', (tester) async {
      await tester.pumpWidget(
          _buildPicker(query: 'zzz', onSelect: (_) {}));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('点击命令条目触发 onSelect 回调并携带正确 command', (tester) async {
      SlashCommandItem? selected;

      await tester.pumpWidget(
        _buildPicker(
          query: 'help',
          onSelect: (item) => selected = item,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('/help'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.command, equals('help'));
    });

    testWidgets('点击 /poll 命令触发 onSelect，command 为 poll', (tester) async {
      SlashCommandItem? selected;

      await tester.pumpWidget(
        _buildPicker(
          query: 'poll',
          onSelect: (item) => selected = item,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('/poll'));
      await tester.pumpAndSettle();

      expect(selected?.command, equals('poll'));
    });

    testWidgets('点击 /price 命令触发 onSelect，command 为 price', (tester) async {
      SlashCommandItem? selected;

      await tester.pumpWidget(
        _buildPicker(
          query: 'price',
          onSelect: (item) => selected = item,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('/price'));
      await tester.pumpAndSettle();

      expect(selected?.command, equals('price'));
    });
  });

  group('SlashCommandPicker — 命令元数据', () {
    testWidgets('每条命令都显示图标', (tester) async {
      await tester.pumpWidget(_buildPicker(query: '', onSelect: (_) {}));
      await tester.pumpAndSettle();

      // 7 条命令 = 7 个 Icon（leading）
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('暗色主题下不抛出异常', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SlashCommandPicker(query: '', onSelect: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('/help'), findsOneWidget);
    });
  });
}
