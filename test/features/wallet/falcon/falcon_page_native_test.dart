import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_crypto.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_page.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_vault.dart';

class _Auth extends LocalAuthPlatform {
  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final path = Platform.environment['N42_PQ_LIBRARY'];
  if (path == null) {
    test(
      'native Falcon page requires host library',
      () {},
      skip: 'Set N42_PQ_LIBRARY',
    );
    return;
  }
  testWidgets('copy rechecks owner before a stale page can export its result', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final vault = FalconVault(
      FalconCrypto(DynamicLibrary.open(path)),
      'copy-owner',
    );
    await tester.runAsync(vault.create);
    var ownerCurrent = true;
    final originalAuth = LocalAuthPlatform.instance;
    LocalAuthPlatform.instance = _Auth();
    addTearDown(() => LocalAuthPlatform.instance = originalAuth);
    var clipboardWrites = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') clipboardWrites++;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: FalconPage(
          walletScope: 'copy-owner',
          isOwnerCurrent: () => ownerCurrent,
          vaultFactory: (_) => vault,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.obscureText,
      ),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.obscureText,
      ),
      'long-test-password',
    );
    tester.testTextInput.hide();
    await tester.scrollUntilVisible(
      find.text('Export encrypted backup'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Export encrypted backup'));
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (find.text('Copy result').evaluate().isEmpty) {
        if (DateTime.now().isAfter(deadline)) {
          fail('Backup export did not finish');
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
        // Build offscreen lazy children while the real KDF finishes.
        await tester.pump();
        final scroll = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
      }
    });
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Copy result'));
    await tester.tap(find.text('Copy result'));
    expect(clipboardWrites, 1);
    // No frame/rebuild between identity change and tapping the old control.
    ownerCurrent = false;
    await tester.tap(find.text('Copy result'));
    expect(clipboardWrites, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
