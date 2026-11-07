import 'dart:io';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_one.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

import '../../test/helpers/widget_test_helpers.dart';

const _enabled = bool.fromEnvironment('N42_DISPOSABLE_WALLET_QA');
// Public BIP39 zero-entropy vector. Never fund or broadcast from this fixture.
const _publicPhrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

class _ImportFixtureStore extends WalletActionProvider {
  _ImportFixtureStore(this.owner) {
    buildwallet = true;
  }
  final String owner;
  @override
  String get userUUID => owner;
}

void registerWalletImportFixture() {
  for (final privateKey in [false, true]) {
    final caseId = privateKey ? 'WLT-03' : 'WLT-02';
    final label = privateKey ? 'private-key' : 'mnemonic';
    testWidgets(
      _enabled
          ? '$caseId imports a disposable $label wallet into native storage'
          : '$caseId imports a disposable $label wallet [BLOCKED: simulator opt-in required]',
      (tester) async {
        final device = DeviceInfoPlugin();
        final virtual = Platform.isAndroid
            ? !(await device.androidInfo).isPhysicalDevice
            : Platform.isIOS && !(await device.iosInfo).isPhysicalDevice;
        expect(
          virtual,
          isTrue,
          reason: 'Wallet fixtures require a disposable simulator.',
        );
        if (!virtual) return; // Never reach storage on a physical device.

        final input = TestWidgetsFlutterBinding.instance.testTextInput;
        if (!input.isRegistered) {
          input.register();
          addTearDown(input.unregister);
        }
        // Public scalar-one test vector. Never fund this known key.
        final publicKey = '${List.filled(63, '0').join()}1';
        final encodedKey = base64Encode(
          List<int>.generate(32, (i) => i == 31 ? 1 : 0),
        );
        if (privateKey) {
          final derived = await Trustdart().generateAddress(
            'N',
            "m/44'/60'/0'/0/0",
            'legacy',
            mnemonic: '',
            pk: publicKey,
            isImport: true,
          );
          expect(
            derived['legacy']?.toString().toLowerCase(),
            '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf',
          );
        }
        final owner = 'n42-native-qa-${DateTime.now().microsecondsSinceEpoch}';
        final store = _ImportFixtureStore(owner);
        final storage = SPUtil();
        final original = await storage.getWalletInfo() ?? <String, dynamic>{};
        expect(original.containsKey(owner), isFalse);
        addTearDown(() async {
          final all = await storage.getWalletInfo() ?? <String, dynamic>{};
          final record = all[owner];
          if (record is Map && record['wallet'] is List) {
            final wallets = record['wallet'] as List;
            for (var index = 0; index < wallets.length; index++) {
              final row = wallets[index] as Map;
              final timestamp = row['timestamp']?.toString().trim();
              final id = timestamp?.isNotEmpty == true ? timestamp! : '$index';
              final key = '${owner}_$id';
              await SecureStorage().deleteMnemonic(key);
              expect(await SecureStorage().getMnemonic(key), isNull);
            }
          }
          all.remove(owner);
          await storage.setWalletInfo(all);
          final cleaned = await storage.getWalletInfo() ?? <String, dynamic>{};
          expect(cleaned.containsKey(owner), isFalse);
          for (final entry in original.entries) {
            expect(
              jsonEncode(cleaned[entry.key]) == jsonEncode(entry.value),
              isTrue,
              reason: 'The fixture must preserve other wallet namespaces.',
            );
          }
        });

        await tester.runAsync(
          () => Clipboard.setData(const ClipboardData(text: '')),
        );
        await tester.pumpWidget(
          wrapForTest(
            privateKey ? const ImportPrivatekey() : const ImportOne(),
            overrides: [wapBridgeProvider.overrideWith((ref) => store)],
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField),
          privateKey ? publicKey : _publicPhrase,
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(privateKey ? S.current.g_key_78 : S.current.g_key_11),
        );
        await _wait(tester, find.byType(CreatePassword));
        for (final entry in [
          (0, 'Native QA Import'),
          (1, 'QaImport123!'),
          (2, 'QaImport123!'),
        ]) {
          final field = find.byType(TextField).at(entry.$1);
          await tester.ensureVisible(field);
          await tester.enterText(field, entry.$2);
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text(S.current.g_key_115));
        await _wait(tester, find.text(S.current.g_key_wallet_c15));
        expect(find.byType(CreateFinish), findsOneWidget);
        expect(store.walletInfoLsit, hasLength(1));
        final wallet = store.walletInfoLsit.single;
        expect(wallet.walletUuid, owner);
        expect(
          privateKey
              ? wallet.privateKey == encodedKey
              : wallet.mnemonic == _publicPhrase,
          isTrue,
        );
        final key = '${owner}_${wallet.timestamp}';
        if (!privateKey) {
          expect(
            await SecureStorage().getMnemonic(key) == _publicPhrase,
            isTrue,
          );
        }
        final restarted = _ImportFixtureStore(owner);
        await restarted.getWalletInfo();
        expect(restarted.walletInfoLsit, hasLength(1));
        expect(
          privateKey
              ? restarted.walletInfoLsit.single.privateKey == encodedKey
              : restarted.walletInfoLsit.single.mnemonic == _publicPhrase,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
      skip: !_enabled,
    );
  }
}

Future<void> _wait(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 300; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (target.evaluate().isNotEmpty) return;
  }
  expect(
    target,
    findsOneWidget,
    reason: 'Native import did not finish within 30 seconds.',
  );
}
