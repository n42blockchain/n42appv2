import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';
import 'package:n42_wallet/features/home/home_draw_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpDrawer(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final wallet = WalletActionProvider();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
        child: ScreenUtilInit(
          designSize: const Size(750, 1334),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: Scaffold(
              drawer: const Drawer(child: HomeDrawPage()),
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('iOS drawer opens Earn from the Other section', (tester) async {
    await tester.runOnIOS(() => pumpDrawer(tester));

    final earnEntry = find.byKey(const ValueKey<String>('drawer_earn'));
    await tester.scrollUntilVisible(
      earnEntry,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(earnEntry, findsOneWidget);
    await tester.tap(earnEntry);
    await tester.pumpAndSettle();
    expect(find.byType(EarnPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android keeps Earn in the main navigation only', (tester) async {
    await tester.runOnAndroid(() => pumpDrawer(tester));

    expect(find.byKey(const ValueKey<String>('drawer_earn')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
