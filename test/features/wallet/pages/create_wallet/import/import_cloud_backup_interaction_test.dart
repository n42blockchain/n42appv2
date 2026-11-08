import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../../helpers/widget_test_helpers.dart';

class _RestoreStore extends WalletActionProvider {
  String owner = 'restore-A';
  @override
  String get userUUID => owner;
}

void main() {
  testWidgets('stops restoration when account changes during decryption', (
    tester,
  ) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (_) async => true,
    );
    addTearDown(
      () => messenger.setMockMethodCallHandler(
        const MethodChannel('PonnamKarthik/fluttertoast'),
        null,
      ),
    );
    final writes = <MethodCall>[];
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'write') {
          writes.add(call);
          throw PlatformException(code: 'synthetic-write-blocked');
        }
        return null;
      },
    );
    addTearDown(
      () => messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        null,
      ),
    );
    final original = FilePickerPlatform.instance;
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('n42-owned-restore-'),
    ))!;
    addTearDown(() async {
      FilePickerPlatform.instance = original;
      await directory.delete(recursive: true);
    });
    final file = File('${directory.path}/restore.n42backup');
    await tester.runAsync(() async {
      await file.writeAsString(
        await _syntheticBackup([
          for (var i = 1; i <= 2; i++)
            {
              'walletName': 'Synthetic watch $i',
              'watchOnly': true,
              'watchAddress': '0x${i.toString().padLeft(40, '0')}',
              'primaryCoinType': 'ETH',
            },
        ], 'synthetic-backup-password'),
      );
    });
    FilePickerPlatform.instance = _FakeFilePicker([
      _TestPlatformFile(file.path),
    ]);
    final store = _RestoreStore();
    await tester.pumpWidget(
      wrapForTest(
        const ImportCloudBackup(),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text(S.current.g_key_dex_select_token));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    for (var i = 0; i < 20 && find.text('key.txt').evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    expect(find.text('key.txt'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'synthetic-backup-password');
    await tester.ensureVisible(find.text(S.current.g_ui_backup_import_wallets));
    await tester.runAsync(() async {
      await tester.tap(find.text(S.current.g_ui_backup_import_wallets));
      store.owner = 'restore-B';
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    for (
      var i = 0;
      i < 40 &&
          find.text(S.current.g_ui_backup_import_failed).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(writes, isEmpty);
    expect(find.text(S.current.g_ui_backup_import_failed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeFilePicker extends FilePickerPlatform {
  _FakeFilePicker(this.files);

  final List<PlatformFile> files;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => files;
}

final class _TestPlatformFile extends PlatformFile {
  _TestPlatformFile(this.path);

  @override
  final String path;

  @override
  String get name => 'key.txt';

  @override
  Uri get uri => Uri.file(path);

  @override
  int? lengthSync() => 21;

  @override
  Future<int?> length() async => 21;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<String> _syntheticBackup(
  List<Map<String, dynamic>> wallets,
  String password,
) async {
  final salt = List<int>.filled(16, 7);
  final key = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 1,
    bits: 256,
  ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  final box = await AesCbc.with256bits(macAlgorithm: Hmac.sha256())
      .encrypt(utf8.encode(jsonEncode({'wallets': wallets})), secretKey: key);
  return jsonEncode({
    'app': 'N42Wallet',
    'version': 1,
    'iterations': 1,
    'salt': base64Encode(salt),
    'iv': base64Encode(box.nonce),
    'mac': base64Encode(box.mac.bytes),
    'data': base64Encode(box.cipherText),
  });
}
