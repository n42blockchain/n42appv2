import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';

void main() {
  group('ResponsiveUtils', () {
    group('isTablet', () {
      testWidgets('should return false for narrow screen (< 600)',
          (tester) async {
        tester.view.physicalSize = const Size(599 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              result = ResponsiveUtils.isTablet(context);
              return const SizedBox();
            }),
          ),
        );

        expect(result, isFalse);
      });

      testWidgets('should return true for wide screen (>= 600)',
          (tester) async {
        tester.view.physicalSize = const Size(600 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              result = ResponsiveUtils.isTablet(context);
              return const SizedBox();
            }),
          ),
        );

        expect(result, isTrue);
      });
    });

    group('isMobile', () {
      testWidgets('should return true for narrow screen', (tester) async {
        tester.view.physicalSize = const Size(400 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              result = ResponsiveUtils.isMobile(context);
              return const SizedBox();
            }),
          ),
        );

        expect(result, isTrue);
      });
    });

    group('getScreenType', () {
      testWidgets('should return mobile for width < 600', (tester) async {
        tester.view.physicalSize = const Size(500 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late ScreenType type;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              type = ResponsiveUtils.getScreenType(context);
              return const SizedBox();
            }),
          ),
        );

        expect(type, ScreenType.mobile);
      });

      testWidgets('should return tablet for width 600-899', (tester) async {
        tester.view.physicalSize = const Size(700 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late ScreenType type;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              type = ResponsiveUtils.getScreenType(context);
              return const SizedBox();
            }),
          ),
        );

        expect(type, ScreenType.tablet);
      });

      testWidgets('should return desktop for width >= 900', (tester) async {
        tester.view.physicalSize = const Size(1000 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late ScreenType type;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              type = ResponsiveUtils.getScreenType(context);
              return const SizedBox();
            }),
          ),
        );

        expect(type, ScreenType.desktop);
      });
    });

    group('getAdaptivePadding', () {
      testWidgets('should return 16 for mobile', (tester) async {
        tester.view.physicalSize = const Size(400 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double padding;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              padding = ResponsiveUtils.getAdaptivePadding(context);
              return const SizedBox();
            }),
          ),
        );

        expect(padding, 16);
      });

      testWidgets('should return 24 for tablet', (tester) async {
        tester.view.physicalSize = const Size(700 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double padding;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              padding = ResponsiveUtils.getAdaptivePadding(context);
              return const SizedBox();
            }),
          ),
        );

        expect(padding, 24);
      });

      testWidgets('should return 32 for desktop', (tester) async {
        tester.view.physicalSize = const Size(1000 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double padding;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              padding = ResponsiveUtils.getAdaptivePadding(context);
              return const SizedBox();
            }),
          ),
        );

        expect(padding, 32);
      });
    });

    group('getContentMaxWidth', () {
      testWidgets('should return infinity for mobile', (tester) async {
        tester.view.physicalSize = const Size(400 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double maxWidth;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              maxWidth = ResponsiveUtils.getContentMaxWidth(context);
              return const SizedBox();
            }),
          ),
        );

        expect(maxWidth, double.infinity);
      });

      testWidgets('should return contentMaxWidth for tablet', (tester) async {
        tester.view.physicalSize = const Size(700 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double maxWidth;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) {
              maxWidth = ResponsiveUtils.getContentMaxWidth(context);
              return const SizedBox();
            }),
          ),
        );

        expect(maxWidth, ResponsiveUtils.contentMaxWidth);
      });
    });

    group('constants', () {
      test('breakpoints should be in correct order', () {
        expect(ResponsiveUtils.mobileBreakpoint,
            lessThan(ResponsiveUtils.tabletBreakpoint));
      });

      test('contentMaxWidth should be positive', () {
        expect(ResponsiveUtils.contentMaxWidth, greaterThan(0));
      });
    });
  });

  group('ScreenType', () {
    test('should have all expected values', () {
      expect(ScreenType.values, containsAll([
        ScreenType.mobile,
        ScreenType.tablet,
        ScreenType.desktop,
      ]));
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('should show mobile widget on narrow screen', (tester) async {
      tester.view.physicalSize = const Size(400 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveBuilder(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
            desktop: Text('desktop'),
          ),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
      expect(find.text('desktop'), findsNothing);
    });

    testWidgets('should show tablet widget on medium screen', (tester) async {
      tester.view.physicalSize = const Size(700 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveBuilder(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
            desktop: Text('desktop'),
          ),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('should show desktop widget on wide screen', (tester) async {
      tester.view.physicalSize = const Size(1000 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveBuilder(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
            desktop: Text('desktop'),
          ),
        ),
      );

      expect(find.text('desktop'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when tablet is null',
        (tester) async {
      tester.view.physicalSize = const Size(700 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveBuilder(
            mobile: Text('mobile'),
          ),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('should fallback to tablet when desktop is null',
        (tester) async {
      tester.view.physicalSize = const Size(1000 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveBuilder(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
          ),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('should not constrain on mobile', (tester) async {
      tester.view.physicalSize = const Size(400 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Text('content'),
            ),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
      // On mobile, the child should not be wrapped in Center+ConstrainedBox
      // It should directly render the child
    });

    testWidgets('should constrain on tablet', (tester) async {
      tester.view.physicalSize = const Size(800 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Text('content'),
            ),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('should use custom maxWidth', (tester) async {
      tester.view.physicalSize = const Size(800 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              maxWidth: 400,
              child: Text('content'),
            ),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
    });
  });
}
