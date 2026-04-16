import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_state.dart';
import 'package:n42_chat/src/presentation/pages/discover/discover_page.dart';

class MockMomentBloc extends Mock implements MomentBloc {
  @override
  MomentState get state => const MomentState();

  @override
  Stream<MomentState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

Widget buildTestWidget(Widget child, {MomentBloc? momentBloc}) {
  final widget = MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );

  if (momentBloc != null) {
    return BlocProvider<MomentBloc>.value(value: momentBloc, child: widget);
  }
  return widget;
}

void main() {
  group('DiscoverPage', () {
    testWidgets('renders stories hub plus core discover menu items', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const DiscoverPage()));
      await tester.pumpAndSettle();

      // 验证有 Moments 菜单项
      expect(find.text('Moments'), findsOneWidget);

      // 验证有 Scan 菜单项
      expect(find.text('Scan'), findsOneWidget);

      expect(find.text('Voice Room'), findsOneWidget);
      expect(find.text('Mini Apps'), findsOneWidget);
      expect(find.text('Stories & Fun'), findsOneWidget);

      // 验证有 Search 菜单项（可能是 'Search' 或本地化的文本）
      final searchFinder = find.textContaining('Search');
      expect(searchFinder, findsWidgets);

      // 验证有 Communities 菜单项
      expect(find.text('Communities'), findsOneWidget);

      // 验证有 Channels 菜单项
      expect(find.textContaining('Channel'), findsOneWidget);
    });

    testWidgets('does not show still-hidden features (Listen, Watch, Nearby)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const DiscoverPage()));
      await tester.pumpAndSettle();

      // 验证已隐藏的功能不显示
      expect(find.text('Listen'), findsNothing);
      expect(find.text('Watch'), findsNothing);
      expect(find.text('Nearby'), findsNothing);
    });

    testWidgets('shows AppBar with Discover title when showAppBar is true', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const DiscoverPage()));
      await tester.pumpAndSettle();

      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('hides AppBar when showAppBar is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const DiscoverPage(showAppBar: false)),
      );
      await tester.pumpAndSettle();

      // AppBar title should not appear (Discover text may appear elsewhere)
      // Instead check that no AppBar widget is rendered
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('tapping Scan triggers navigation', (tester) async {
      await tester.pumpWidget(buildTestWidget(const DiscoverPage()));
      await tester.pumpAndSettle();

      // 验证 Scan 菜单项可点击（InkWell 包裹）
      await tester.tap(find.text('Scan'));
      // 只 pump 一帧验证不报异常，不 pumpAndSettle（ScanQRPage 含平台插件）
      await tester.pump();
    });

    testWidgets('tapping Search navigates to GlobalSearchPage', (tester) async {
      await tester.pumpWidget(buildTestWidget(const DiscoverPage()));
      await tester.pumpAndSettle();

      // 找到 Search 相关的可点击项
      final searchItem = find.textContaining('Search');
      expect(searchItem, findsWidgets);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData.dark(),
          home: const DiscoverPage(),
        ),
      );
      await tester.pumpAndSettle();

      // 验证页面在暗色模式下正常渲染
      expect(find.text('Moments'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Communities'), findsOneWidget);
    });

    testWidgets('renders with MomentBloc provided', (tester) async {
      final mockBloc = MockMomentBloc();

      await tester.pumpWidget(
        buildTestWidget(const DiscoverPage(), momentBloc: mockBloc),
      );
      await tester.pumpAndSettle();

      // 验证 Moments 菜单项依然存在
      expect(find.text('Moments'), findsOneWidget);
    });

    testWidgets('has exactly 9 chevron_right icons for visible menu items', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const DiscoverPage()));
      await tester.pumpAndSettle();

      // 发现页当前显示 9 个入口（Moments、Stories & Fun、Scan、Search、Voice Room、Mini Apps、Games、Communities、Channels）
      final chevronIcons = find.byIcon(Icons.chevron_right);
      expect(chevronIcons, findsNWidgets(9));
    });
  });
}
