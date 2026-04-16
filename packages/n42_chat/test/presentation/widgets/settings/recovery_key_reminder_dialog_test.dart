import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/encryption/key_backup_service.dart'
    show KeyBackupService, KeyBackupInfo;
import 'package:n42_chat/src/presentation/widgets/settings/recovery_key_reminder_dialog.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockKeyBackupService extends Mock implements KeyBackupService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// 静默期 key，与 RecoveryKeyReminderBannerState 保持一致
const _dismissedKey = 'recovery_key_reminder_dismissed_until';

/// 构建被测 Banner，直接传入 mockKeyBackupService 跳过 getIt
Widget _buildBanner(KeyBackupService keyBackupService) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: Stack(
        children: [
          const Placeholder(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RecoveryKeyReminderBanner(
              keyBackupService: keyBackupService,
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockKeyBackupService mockKeyBackupService;

  setUp(() {
    mockKeyBackupService = MockKeyBackupService();
  });

  group('RecoveryKeyReminderBanner', () {
    testWidgets('初始构建时（异步未完成）不显示 banner', (tester) async {
      // 让 getBackupInfo 永不完成，模拟检查中状态
      when(() => mockKeyBackupService.getBackupInfo())
          .thenAnswer((_) => Completer<KeyBackupInfo?>().future);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(_buildBanner(mockKeyBackupService));
      await tester.pump(); // 仅推进一帧，异步未完成

      // _checked = false → SizedBox.shrink()
      expect(find.byIcon(Icons.shield_outlined), findsNothing);
    });

    testWidgets('已有备份时不显示 banner', (tester) async {
      when(() => mockKeyBackupService.getBackupInfo())
          .thenAnswer((_) async => KeyBackupInfo(
                version: '1',
                algorithm: 'm.megolm_backup.v1.curve25519-aes-sha2',
                count: 100,
                etag: 'abc123',
              ));
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(_buildBanner(mockKeyBackupService));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield_outlined), findsNothing);
    });

    testWidgets('在静默期内不显示 banner，且不调用 getBackupInfo', (tester) async {
      final futureMs = DateTime.now()
          .add(const Duration(days: 3))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({_dismissedKey: futureMs});

      await tester.pumpWidget(_buildBanner(mockKeyBackupService));
      await tester.pumpAndSettle();

      // 静默期内早返回，不调用 getBackupInfo
      verifyNever(() => mockKeyBackupService.getBackupInfo());
      expect(find.byIcon(Icons.shield_outlined), findsNothing);
    });

    testWidgets('无备份且不在静默期时显示 banner 及操作按钮', (tester) async {
      // 使用 initialShouldShow 跳过 SharedPreferences 异步检查，直接测试 UI 渲染
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Stack(
              children: [
                const Placeholder(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RecoveryKeyReminderBanner(
                    keyBackupService: mockKeyBackupService,
                    initialShouldShow: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.textContaining('Protect your messages'), findsOneWidget);
      // 英文 ARB: recoveryKeySetupNow = "Set up now"
      expect(find.textContaining('Set up'), findsOneWidget);
      // 英文 ARB: recoveryKeyRemindLater = "Remind me later"
      expect(find.textContaining('later'), findsOneWidget);
    });

    testWidgets('点击 Later 后 banner 消失，并写入 7 天静默期', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Stack(
              children: [
                const Placeholder(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RecoveryKeyReminderBanner(
                    keyBackupService: mockKeyBackupService,
                    initialShouldShow: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      // 英文 ARB: recoveryKeyRemindLater = "Remind me later"
      await tester.tap(find.textContaining('later'));
      await tester.pumpAndSettle();

      // banner 消失
      expect(find.byIcon(Icons.shield_outlined), findsNothing);

      // SharedPreferences 写入了静默截止时间（未来时间）
      final prefs = await SharedPreferences.getInstance();
      final dismissedUntil = prefs.getInt(_dismissedKey) ?? 0;
      expect(
        dismissedUntil,
        greaterThan(DateTime.now().millisecondsSinceEpoch),
        reason: '静默截止时间应设置在未来',
      );
    });

    testWidgets('KeyBackupService 抛出异常时 banner 不显示', (tester) async {
      when(() => mockKeyBackupService.getBackupInfo())
          .thenThrow(Exception('network error'));
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(_buildBanner(mockKeyBackupService));
      await tester.pumpAndSettle();

      // catch 分支：_checked = true, _shouldShow = false
      expect(find.byIcon(Icons.shield_outlined), findsNothing);
    });
  });
}
