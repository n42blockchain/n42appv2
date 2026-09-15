import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/encryption/e2ee_manager.dart';
import 'package:n42_chat/src/core/encryption/key_backup_service.dart';
import 'package:n42_chat/src/presentation/pages/settings/security_settings_page.dart';

class _Manager extends Mock implements E2EEManager {}

class _Backup extends Mock implements KeyBackupService {}

class _Client extends Mock implements Client {}

void main() {
  late _Manager manager;
  late _Backup backup;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    manager = _Manager();
    backup = _Backup();
    when(() => manager.client).thenReturn(_Client());
    when(() => manager.status).thenReturn(E2EEStatus.ready);
    when(() => manager.isCrossSigningEnabled).thenReturn(false);
    when(() => backup.getBackupInfo()).thenAnswer((_) async => null);
  });

  Future<S> open(WidgetTester tester, {bool restore = true}) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'TW'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: SecuritySettingsPage(
          e2eeManager: manager,
          keyBackupService: backup,
          restoreKeysOnOpen: restore,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return S.of(tester.element(find.byType(SecuritySettingsPage)))!;
  }

  for (final recovery in [false, true]) {
    for (final count in [0, 2]) {
      testWidgets('restore reports actual count $count (recovery: $recovery)', (
        tester,
      ) async {
        when(
          () => manager.unlockWithRecoveryKey(any()),
        ).thenAnswer((_) async => count);
        when(
          () => manager.unlockWithPassphrase(any()),
        ).thenAnswer((_) async => count);
        final l10n = await open(tester);
        if (!recovery) {
          await tester.tap(
            find.widgetWithText(ChoiceChip, l10n.settingsPassword),
          );
          await tester.pumpAndSettle();
        }
        await tester.enterText(find.byType(TextField), 'fixture');
        await tester.tap(find.widgetWithText(TextButton, l10n.settingsRestore));
        await tester.pumpAndSettle();
        expect(
          find.text(
            count == 0
                ? l10n.settingsRestoreEmpty
                : l10n.settingsRestoreSessions(count),
          ),
          findsOneWidget,
        );
        expect(find.text(l10n.settingsRestoreSuccess), findsNothing);
        verifyNever(() => backup.restoreFromRecoveryKey(any()));
        verifyNever(() => backup.restoreFromPassword(any()));
        if (recovery) {
          verify(() => manager.unlockWithRecoveryKey('fixture')).called(1);
        } else {
          verify(() => manager.unlockWithPassphrase('fixture')).called(1);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('restore failure never reports success', (tester) async {
    when(
      () => manager.unlockWithRecoveryKey(any()),
    ).thenThrow(E2EEException('backup unavailable'));
    final l10n = await open(tester);
    await tester.enterText(find.byType(TextField), 'fixture');
    await tester.tap(find.widgetWithText(TextButton, l10n.settingsRestore));
    await tester.pumpAndSettle();
    expect(find.textContaining(l10n.settingsRestoreFailed), findsOneWidget);
    expect(find.text(l10n.settingsRestoreSuccess), findsNothing);
    expect(find.text(l10n.settingsRestoreEmpty), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backup metadata survives an independent device-list failure', (
    tester,
  ) async {
    when(() => backup.getBackupInfo()).thenAnswer(
      (_) async => KeyBackupInfo(
        version: 'v1',
        algorithm: 'fixture',
        count: 3,
        etag: 'etag',
      ),
    );
    final l10n = await open(tester, restore: false);
    await tester.scrollUntilVisible(
      find.text(l10n.settingsKeysBackedUp(3)),
      200,
    );
    expect(find.text(l10n.settingsKeysBackedUp(3)), findsOneWidget);
    expect(find.text(l10n.settingsBackupNotSet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
