import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_three.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

class _ControlledSecureStoragePlatform
    extends TestFlutterSecureStoragePlatform {
  _ControlledSecureStoragePlatform(super.data);

  int walletInfoWrites = 0;
  bool failWalletInfoWrite = false;
  Completer<void>? walletInfoWriteGate;

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    if (key == 'walletInfo') {
      walletInfoWrites++;
      if (walletInfoWriteGate != null) {
        await walletInfoWriteGate!.future;
      }
      if (failWalletInfoWrite) {
        throw StateError('synthetic secure-storage failure');
      }
    }
    await super.write(key: key, value: value, options: options);
  }
}

class _RouteTracker {
  int returns = 0;
}

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  const storage = FlutterSecureStorage();
  late WalletActionProvider store;
  late _ControlledSecureStoragePlatform secureStorage;
  late List<String> toasts;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    app.globalProviderContainer = ProviderContainer();
    store = WalletActionProvider();
    secureStorage = _ControlledSecureStoragePlatform({});
    FlutterSecureStoragePlatform.instance = secureStorage;
    toasts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async {
          if (call.method == 'showToast') {
            toasts.add((call.arguments as Map)['msg'] as String);
          }
          return true;
        });
  });

  tearDown(() {
    app.globalProviderContainer.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  Future<_RouteTracker> openBackup(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final tracker = _RouteTracker();
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BackupThree(
                    WalletInfo(walletName: 'Synthetic backup fixture'),
                    0,
                  ),
                ),
              );
              tracker.returns++;
            },
            child: const Text('Open backup confirmation'),
          ),
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open backup confirmation'));
    await tester.pumpAndSettle();
    return tracker;
  }

  Future<void> fillPasswords(
    WidgetTester tester, {
    String password = 'Synthetic8!',
    String confirmation = 'Synthetic8!',
  }) async {
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), password);
    await tester.enterText(fields.at(1), confirmation);
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
  }

  Future<void> finishToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 8));
  }

  testWidgets('empty backup password never reaches secure storage', (
    tester,
  ) async {
    await openBackup(tester);

    await submit(tester);
    await finishToast(tester);

    expect(secureStorage.walletInfoWrites, 0);
    expect(toasts, contains(S.current.g_key_21));
    expect(find.byType(BackupThree), findsOneWidget);
  });

  test('legacy wallet save keeps swallowing storage errors', () async {
    secureStorage.failWalletInfoWrite = true;

    await store.saveWalletInfo(
      WalletInfo(walletName: 'Synthetic legacy save'),
      0,
    );

    expect(secureStorage.walletInfoWrites, 1);
    expect(await storage.read(key: 'walletInfo'), isNull);
  });

  testWidgets('invalid backup password is rejected before secure storage', (
    tester,
  ) async {
    await openBackup(tester);
    await fillPasswords(tester, password: 'short', confirmation: 'short');

    await submit(tester);
    await finishToast(tester);

    expect(secureStorage.walletInfoWrites, 0);
    expect(toasts, contains(S.current.rest_Choose_password));
    expect(find.byType(BackupThree), findsOneWidget);
  });

  testWidgets('mismatched password confirmation never reaches secure storage', (
    tester,
  ) async {
    await openBackup(tester);
    await fillPasswords(tester, confirmation: 'Different8!');

    await submit(tester);
    await finishToast(tester);

    expect(secureStorage.walletInfoWrites, 0);
    expect(toasts, contains(S.current.g_key_25));
    expect(find.byType(BackupThree), findsOneWidget);
  });

  testWidgets('secure-storage failure keeps the backup form available', (
    tester,
  ) async {
    final tracker = await openBackup(tester);
    secureStorage.failWalletInfoWrite = true;
    await fillPasswords(tester);

    await submit(tester);
    await tester.pumpAndSettle();
    await finishToast(tester);

    expect(secureStorage.walletInfoWrites, 1);
    expect(tracker.returns, 0);
    expect(find.byType(BackupThree), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(toasts, contains('Bad state: synthetic secure-storage failure'));

    secureStorage.failWalletInfoWrite = false;
    await submit(tester);
    await tester.pumpAndSettle();
    await finishToast(tester);

    expect(secureStorage.walletInfoWrites, 2);
    expect(tracker.returns, 1);
    expect(find.byType(BackupThree), findsNothing);
    final raw = await storage.read(key: 'walletInfo');
    final wallets =
        (jsonDecode(raw!) as Map<String, dynamic>).values.single
            as Map<String, dynamic>;
    expect((wallets['wallet'] as List).single['password'], 'Synthetic8!');
  });

  testWidgets('in-flight secure save cannot be triggered twice', (
    tester,
  ) async {
    final tracker = await openBackup(tester);
    secureStorage.walletInfoWriteGate = Completer<void>();
    await fillPasswords(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(secureStorage.walletInfoWrites, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(secureStorage.walletInfoWrites, 1);
    expect(tracker.returns, 0);

    secureStorage.walletInfoWriteGate!.complete();
    await tester.pumpAndSettle();
    await finishToast(tester);

    expect(secureStorage.walletInfoWrites, 1);
    expect(tracker.returns, 1);
    expect(find.byType(BackupThree), findsNothing);
  });
}
