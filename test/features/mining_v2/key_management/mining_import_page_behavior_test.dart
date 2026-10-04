import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/widgets/app_button.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_import.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:cryptography/cryptography.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrapForTest(const MiningImport()));
    await tester.pumpAndSettle();
  }

  testWidgets('empty import reports the missing encrypted payload locally', (
    tester,
  ) async {
    await mount(tester);
    final context = tester.element(find.byType(MiningImport));

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text(S.of(context).g_mining_key_110), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(S.of(context).g_mining_key_105), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password validation blocks import before decryption', (
    tester,
  ) async {
    await mount(tester);
    final context = tester.element(find.byType(MiningImport));
    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), 'not an encrypted envelope');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(find.text(S.of(context).g_mining_key_106), findsOneWidget);

    await tester.enterText(fields.at(1), 'short');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(find.text(S.of(context).g_mining_key_98(8)), findsWidgets);
    expect(find.textContaining('FormatException'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pasted payload is placed into the encrypted data field', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': '{"version":"1"}'};
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await mount(tester);
    final context = tester.element(find.byType(MiningImport));

    await tester.tap(find.text(S.of(context).g_key_166));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '{"version":"1"}',
    );
    expect(find.text(S.of(context).g_mining_key_105), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling the file picker leaves the payload unchanged', (
    tester,
  ) async {
    const filePickerChannel = MethodChannel(
      'miguelruivo.flutter.plugins.filepicker',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(filePickerChannel, (call) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(filePickerChannel, null),
    );
    await mount(tester);
    final context = tester.element(find.byType(MiningImport));

    await tester.tap(find.text(S.of(context).g_mining_key_111));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('malformed envelope shows an inline failure without wallet RPC', (
    tester,
  ) async {
    await mount(tester);
    final context = tester.element(find.byType(MiningImport));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'not-json');
    await tester.enterText(fields.at(1), '12345678');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(S.of(context).g_mining_key_107), findsOneWidget);
    expect(find.byType(MiningImport), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong password shows localized decryption guidance', (
    tester,
  ) async {
    final encrypted = await _encryptedFixture('87654321');
    await mount(tester);
    final context = tester.element(find.byType(MiningImport));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), encrypted);
    await tester.enterText(fields.at(1), '12345678');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(S.of(context).g_mining_key_107), findsOneWidget);
    expect(find.textContaining('Exception:'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsupported envelope version shows localized guidance', (
    tester,
  ) async {
    await mount(tester);
    final context = tester.element(find.byType(MiningImport));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '{"version":"2"}');
    await tester.enterText(fields.at(1), '12345678');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(find.text(S.of(context).g_mining_key_108), findsOneWidget);
    expect(find.textContaining('unsupported encryption version'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<String> _encryptedFixture(String password) async {
  final salt = Uint8List.fromList(List.generate(16, (index) => index + 1));
  final iv = Uint8List.fromList(List.generate(12, (index) => index + 1));
  const iterations = 1;
  const dklen = 32;
  final key = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: dklen * 8,
  ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  final encrypted = await AesGcm.with256bits().encrypt(
    utf8.encode(
      jsonEncode(const {
        'validator': {'publicKey': 'validator-public'},
      }),
    ),
    secretKey: key,
    nonce: iv,
  );

  return jsonEncode({
    'version': '1',
    'kdf': {
      'name': 'pbkdf2',
      'params': {'iterations': iterations, 'dklen': dklen},
      'salt': base64Encode(salt),
    },
    'cipher': {'name': 'aes-256-gcm', 'iv': base64Encode(iv)},
    'ciphertext': base64Encode(encrypted.cipherText),
    'tag': base64Encode(encrypted.mac.bytes),
  });
}
