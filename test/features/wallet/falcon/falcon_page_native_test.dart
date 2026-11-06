import 'dart:convert';
import 'dart:ffi' show DynamicLibrary;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_crypto.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_page.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_vault.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_transaction.dart';
import 'package:web3dart/web3dart.dart' show hexToBytes;

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
  testWidgets('offline signing needs no RPC and still requires confirmation', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final crypto = FalconCrypto(DynamicLibrary.open(path));
    final vault = FalconVault(crypto, 'offline-owner');
    await tester.runAsync(vault.create);
    final originalAuth = LocalAuthPlatform.instance;
    LocalAuthPlatform.instance = _Auth();
    addTearDown(() => LocalAuthPlatform.instance = originalAuth);
    await tester.binding.setSurfaceSize(const Size(900, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: FalconPage(
          walletScope: 'offline-owner',
          isOwnerCurrent: () => true,
          vaultFactory: (_) => vault,
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final entry in {
      'rpc': '',
      'recipient': '0x2222222222222222222222222222222222222222',
      'valueWei': '1',
      'nonce': '0',
      'tipCap': '1',
      'feeCap': '2',
    }.entries) {
      final field = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == entry.key,
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
    }
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Review and sign offline'));
    await tester.tap(find.text('Review and sign offline'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm offline signature'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Copy result'), findsNothing);
    await tester.tap(find.text('Review and sign offline'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Copy result'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    final encoded = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .map((w) => w.data)
        .whereType<String>()
        .singleWhere((s) => s.startsWith('{'));
    final result = jsonDecode(encoded) as Map<String, dynamic>;
    expect(result['format'], 'n42-pq-offline-signature-v1');
    final key = await tester.runAsync(vault.publicKey);
    final tx = FalconTransaction(
      chainId: BigInt.from(94),
      nonce: BigInt.zero,
      recipient: '0x2222222222222222222222222222222222222222',
      value: BigInt.one,
      gas: BigInt.from(21000),
      tipCap: BigInt.one,
      feeCap: BigInt.two,
      publicKey: key!,
    );
    expect(
      crypto.verify(key, tx.digest, hexToBytes(result['signature'] as String)),
      isTrue,
    );
    expect(
      hexToBytes(result['rawTransaction'] as String),
      tx.encodeSigned(hexToBytes(result['signature'] as String)),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });
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
