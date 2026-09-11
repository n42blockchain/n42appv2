import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/csv_import_page.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/export_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helpers/test_current_user.dart';
import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> mount(WidgetTester tester, Widget page, String language) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.3)),
            child: page,
          ),
        ),
        locale: Locale(language),
        overrides: [
          currentUserProvider.overrideWith((ref) => TestCurrentUser()),
          wapBridgeProvider.overrideWith((ref) {
            final wallet = WalletActionProvider()..walletIndex = 0;
            wallet.walletInfoList.add(
              WalletInfo()..timestamp = 'localization-fixture',
            );
            return wallet;
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final language in ['en', 'ar', 'de', 'ur', 'sw']) {
    testWidgets('$language backup validates a short password before sharing', (
      tester,
    ) async {
      await mount(tester, const ExportCloudBackup(), language);
      final s = S.of(tester.element(find.byType(ExportCloudBackup)));
      expect(find.text(s.g_ui_backup_warning), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'short');
      await tester.tap(find.text(s.g_ui_backup_create_save));
      await tester.pumpAndSettle();
      expect(find.text(s.g_ui_backup_password_min), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$language import explains encryption and preserves password input',
      (tester) async {
        await mount(tester, const ImportCloudBackup(), language);
        final s = S.of(tester.element(find.byType(ImportCloudBackup)));
        expect(find.text(s.g_ui_backup_encryption_hint), findsOneWidget);
        expect(find.text(s.g_ui_backup_no_file), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'fixture-password');
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'fixture-password',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$language CSV exposes localized validation for malformed rows',
      (tester) async {
        await mount(
          tester,
          const CsvImportPage(tokenSymbol: 'ETH', decimals: 18),
          language,
        );
        final s = S.of(tester.element(find.byType(CsvImportPage)));
        await tester.enterText(
          find.byType(TextField),
          'address,amount\n0xINVALID,1',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(s.g_ui_import_valid(1)));
        await tester.pumpAndSettle();
        expect(find.text(s.g_ui_validation_issues), findsOneWidget);
        expect(find.text(s.g_key_batch_invalid_address(2)), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
