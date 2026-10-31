import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    AppGlobals.userInfo = UserInfo(uuid: 'backup-owner');
  });
  tearDown(() => AppGlobals.userInfo = null);
  final wallet = WalletInfo(
    mnemonic: 'alpha beta gamma',
    password: 'synthetic-password',
  );
  testWidgets(
    'view verifies the selected wallet and cancellation keeps the phrase hidden',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(wrapForTest(BackupOne(wallet, 3)));
      await tester.pumpAndSettle();
      expect(find.text('alpha'), findsNothing);
      await tester.ensureVisible(find.text(S.current.g_key_wallet_c44));
      await tester.tap(find.text(S.current.g_key_wallet_c44));
      await tester.pumpAndSettle();
      final verification = tester.widget<WalletSecurityVerification>(
        find.byType(WalletSecurityVerification),
      );
      expect(verification.walletInfo, same(wallet));
      expect(verification.walletIndex, 3);
      expect(verification.title, S.current.g_key_wallet_c38);
      Navigator.of(tester.element(find.byType(WalletSecurityVerification)))
          .pop(false);
      await tester.pumpAndSettle();
      expect(find.text('alpha'), findsNothing);
    },
  );
  testWidgets(
    'account switch while verification is open cannot reveal the previous phrase',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(wrapForTest(BackupOne(wallet, 0)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(S.current.g_key_wallet_c44));
      await tester.tap(find.text(S.current.g_key_wallet_c44));
      await tester.pumpAndSettle();
      AppGlobals.userInfo = UserInfo(uuid: 'other-owner');
      Navigator.of(tester.element(find.byType(WalletSecurityVerification)))
          .pop(true);
      await tester.pumpAndSettle();
      expect(find.text('alpha'), findsNothing);
    },
  );
}
