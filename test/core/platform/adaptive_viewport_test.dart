import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/platform/adaptive_viewport.dart';
import 'package:n42_wallet/features/home/widgets/adaptive_home_layout.dart';

void main() {
  const channel = MethodChannel('ai.n42.www/viewport');
  const fieldKey = ValueKey('draft');

  Future<void> resize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    await tester.pump();
    await tester.pump();
  }

  Future<void> nativeRegions(
    WidgetTester tester,
    Size size,
    List<Map<String, Object>> regions,
  ) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('regionsChanged', {
          'width': size.width,
          'height': size.height,
          'regions': regions,
        }),
      ),
      (_) {},
    );
    await tester.pump();
  }

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => {'width': 0, 'height': 0, 'regions': []},
        );
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> host(WidgetTester tester, {required Widget home}) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AdaptiveViewport(
          child: AdaptiveScreenUtil(builder: (_, _) => MaterialApp(home: home)),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'fold, rotate and split view retain a pushed route and its draft',
    (tester) async {
      await host(
        tester,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: SafeArea(child: TextField(key: fieldKey)),
                  ),
                ),
              ),
              child: const Text('Compose'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Compose'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(fieldKey), 'pending transaction note');
      final state = tester.state(find.byKey(fieldKey));
      for (final size in [
        const Size(800, 720),
        const Size(720, 800),
        const Size(320, 720),
        const Size(844, 390),
        const Size(390, 844),
      ]) {
        await resize(tester, size);
        expect(tester.state(find.byKey(fieldKey)), same(state));
        expect(find.text('pending transaction note'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'active fold displaces controls and clears when flat without losing input',
    (tester) async {
      await host(
        tester,
        home: const Scaffold(body: TextField(key: fieldKey)),
      );
      await tester.enterText(find.byKey(fieldKey), 'unsent');
      final state = tester.state(find.byKey(fieldKey));
      await resize(tester, const Size(800, 720));
      await nativeRegions(tester, const Size(800, 720), [
        {
          'kind': 'division',
          'x': 390.0,
          'y': 0.0,
          'width': 20.0,
          'height': 720.0,
        },
      ]);
      expect(
        tester.getRect(find.byType(Scaffold)),
        const Rect.fromLTWH(410, 0, 390, 720),
      );
      expect(tester.state(find.byKey(fieldKey)), same(state));
      await nativeRegions(tester, const Size(800, 720), []);
      expect(tester.getSize(find.byType(Scaffold)), const Size(800, 720));
      expect(find.text('unsent'), findsOneWidget);
      await nativeRegions(tester, const Size(800, 720), [
        {
          'kind': 'division',
          'x': 0.0,
          'y': 350.0,
          'width': 800.0,
          'height': 20.0,
        },
      ]);
      expect(
        tester.getRect(find.byType(Scaffold)),
        const Rect.fromLTWH(0, 370, 800, 350),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(
        tester.getRect(find.byType(Scaffold)),
        const Rect.fromLTWH(0, 0, 800, 350),
      );
      expect(find.text('unsent'), findsOneWidget);
      tester.view.resetViewInsets();
      await resize(tester, const Size(390, 844));
      expect(tester.getSize(find.byType(Scaffold)), const Size(390, 844));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'control scale stays continuous at 600 and does not inflate in landscape',
    (tester) async {
      await host(
        tester,
        home: Builder(
          builder: (_) => Scaffold(
            body: SizedBox(
              key: const ValueKey('control'),
              width: 96.w,
              height: 96.h,
            ),
          ),
        ),
      );
      for (final size in [
        const Size(599, 720),
        const Size(600, 720),
        const Size(800, 720),
        const Size(844, 390),
      ]) {
        await resize(tester, size);
        expect(
          tester.getSize(find.byKey(const ValueKey('control'))),
          const Size(48, 48),
        );
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'side navigation changes by usable width and height while tab state survives',
    (tester) async {
      await host(
        tester,
        home: const Scaffold(
          body: AdaptiveHomeLayout(
            content: TextField(key: fieldKey),
            sideNavigation: Text('side'),
            bottomNavigation: Text('bottom'),
          ),
        ),
      );
      await tester.enterText(find.byKey(fieldKey), 'draft');
      final state = tester.state(find.byKey(fieldKey));
      expect(find.text('bottom'), findsOneWidget);
      await resize(tester, const Size(720, 800));
      expect(find.text('side'), findsOneWidget);
      expect(tester.state(find.byKey(fieldKey)), same(state));
      await resize(tester, const Size(844, 390));
      expect(find.text('bottom'), findsOneWidget);
      expect(tester.state(find.byKey(fieldKey)), same(state));
      expect(find.text('draft'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'asymmetric safe areas and keyboard remain local to the selected pane',
    (tester) async {
      await host(
        tester,
        home: const Scaffold(
          body: SafeArea(child: TextField(key: fieldKey)),
        ),
      );
      await resize(tester, const Size(800, 720));
      tester.view.viewPadding = const FakeViewPadding(
        left: 12,
        top: 24,
        right: 44,
        bottom: 18,
      );
      tester.view.padding = const FakeViewPadding(left: 12, top: 24, right: 44);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      addTearDown(tester.view.resetViewInsets);
      await nativeRegions(tester, const Size(800, 720), [
        {
          'kind': 'division',
          'x': 390.0,
          'y': 0.0,
          'width': 20.0,
          'height': 720.0,
        },
      ]);
      final rect = tester.getRect(find.byKey(fieldKey));
      expect(rect.left, 410);
      expect(rect.right, 756);
      expect(rect.top, 24);
      expect(rect.bottom, lessThanOrEqualTo(420));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
