import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_mpc_wallet.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

void main() {
  testWidgets('shows all three providers without overflowing a small display', (
    tester,
  ) async {
    MpcProviderRegistry.instance.disposeAll();
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (_, child) => MaterialApp(
            theme: ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
            localizationsDelegates: const [S.delegate],
            supportedLocales: S.delegate.supportedLocales,
            home: const CreateMpcWallet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Google', 'Apple', 'Facebook']) {
      expect(find.text(label), findsOneWidget);
      final button = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(button.onPressed, isNull);
    }
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discord'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
