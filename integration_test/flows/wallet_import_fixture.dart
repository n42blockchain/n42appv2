import 'dart:io';
import 'dart:async';
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
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_one.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_three.dart';
import 'package:n42_wallet/features/wallet/models/mess_mnemonic_words_item.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

import '../../test/helpers/widget_test_helpers.dart';

const _enabled = bool.fromEnvironment('N42_DISPOSABLE_WALLET_QA');
// Public BIP39 zero-entropy vector. Never fund or broadcast from this fixture.
const _publicPhrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

class _ImportFixtureStore extends WalletActionProvider {
  _ImportFixtureStore(this.owner)
    : super(
        marketApi: _FixtureMarket(),
        stablecoinPriceRequest: (_) async => null,
      ) {
    buildwallet = true;
  }
  final String owner;
  @override
  String get userUUID => owner;
}

class _FixtureMarket extends MarketApi {
  @override
  Future<Map<String, dynamic>> getWalletCoinsInfo(String coins) async => {
    'error': false,
    'data': [
      {'coin': 'ETH', 'price': 1},
    ],
  };
}

void registerWalletImportFixture() {
  for (final mode in ['mnemonic', 'private-key', 'create']) {
    final privateKey = mode == 'private-key';
    final creating = mode == 'create';
    var expectedPhrase = _publicPhrase;
    final caseId = creating
        ? 'WLT-01'
        : privateKey
        ? 'WLT-03'
        : 'WLT-02';
    final label = creating ? 'created and backed-up' : mode;
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
        final initialBalanceRelease = Completer<void>();
        final initialBalanceRequested = Completer<void>();
        addTearDown(() {
          if (!initialBalanceRelease.isCompleted) {
            initialBalanceRelease.complete();
          }
        });
        if (mode == 'mnemonic') {
          final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
          addTearDown(() => server.close(force: true));
          server.listen((request) async {
            final body =
                jsonDecode(await utf8.decoder.bind(request).join()) as Map;
            final method = body['method'];
            if (method == 'eth_getBalance' &&
                !initialBalanceRelease.isCompleted) {
              if (!initialBalanceRequested.isCompleted) {
                initialBalanceRequested.complete();
              }
              await initialBalanceRelease.future;
            }
            request.response.headers.contentType = ContentType.json;
            request.response.write(
              jsonEncode({
                'jsonrpc': '2.0',
                'id': body['id'],
                if (method == 'eth_getBalance')
                  'result': '0xde0b6b3a7640000'
                else
                  'error': {'code': -32601, 'message': 'Read-only fixture'},
              }),
            );
            await request.response.close();
          });
          final originalChains = chainUrlMap;
          final eth = jsonDecode(
            jsonEncode(originalChains['ETH']),
          ) as Map<String, dynamic>;
          final base = eth['baseInfo'] as Map;
          base['service'] = 'http://127.0.0.1:${server.port}';
          base['service_test'] = base['service'];
          eth['mainnets'] = <String, dynamic>{};
          eth['testnets'] = <dynamic>[];
          chainUrlMap = {'ETH': eth};
          addTearDown(() {
            chainUrlMap = originalChains;
          });
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
            creating
                ? const CreateOne()
                : privateKey
                ? const ImportPrivatekey()
                : const ImportOne(),
            overrides: [wapBridgeProvider.overrideWith((ref) => store)],
          ),
        );
        await tester.pumpAndSettle();
        if (creating) {
          for (var index = 0; index < 3; index++) {
            final check = find.byType(RoundCheckBox).at(index);
            await tester.ensureVisible(check);
            await tester.tap(check);
            await tester.pumpAndSettle();
          }
          await tester.tap(find.text(S.current.g_key_wallet_c10));
          await _wait(tester, find.text(S.current.g_key_wallet_c44));
          await tester.ensureVisible(find.text(S.current.g_key_wallet_c44));
          await tester.tap(find.text(S.current.g_key_wallet_c44));
          await tester.pumpAndSettle();
          await tester.tap(find.text(S.current.g_key_wallet_c43));
          await _wait(tester, find.byType(CreateThree));
          expectedPhrase = tester
              .widget<CreateThree>(find.byType(CreateThree))
              .wInfo
              .mnemonic!;
          expect(expectedPhrase.split(' ').length == 12, isTrue);
          for (final word in expectedPhrase.split(' ')) {
            final candidate = find.byWidgetPredicate((widget) {
              final key = widget.key;
              return widget is GestureDetector &&
                  key is ValueKey<MessMnemonicWordsItem> &&
                  key.value.word == word &&
                  !key.value.isSelected;
            }).first;
            await tester.ensureVisible(candidate);
            await tester.tap(candidate);
            await tester.pumpAndSettle();
          }
          await tester.tap(find.text(S.current.g_key_wallet_c43));
          await _wait(tester, find.byType(CreatePassword));
        } else {
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
        }
        for (final entry in [
          (0, 'Native QA'),
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
        await _wait(
          tester,
          find.text(
            creating ? S.current.g_key_wallet_c22 : S.current.g_key_wallet_c15,
          ),
        );
        expect(find.byType(CreateFinish), findsOneWidget);
        expect(store.walletInfoLsit, hasLength(1));
        final wallet = store.walletInfoLsit.single;
        expect(wallet.walletUuid, owner);
        expect(wallet.walletName, 'Native QA');
        expect(
          privateKey
              ? wallet.privateKey == encodedKey
              : wallet.mnemonic == expectedPhrase,
          isTrue,
        );
        final key = '${owner}_${wallet.timestamp}';
        if (!privateKey) {
          expect(
            await SecureStorage().getMnemonic(key) == expectedPhrase,
            isTrue,
          );
        }
        final restarted = _ImportFixtureStore(owner);
        await restarted.getWalletInfo();
        expect(restarted.walletInfoLsit, hasLength(1));
        expect(
          privateKey
              ? restarted.walletInfoLsit.single.privateKey == encodedKey
              : restarted.walletInfoLsit.single.mnemonic == expectedPhrase,
          isTrue,
        );
        if (mode == 'mnemonic') {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          // Mirror the host's transaction provider without accessing user history.
          final transactions = TransactionRecordItemProvider(
            userUuid: () => owner,
            sessionIdentity: () => owner,
          );
          globalTripInstance = transactions;
          addTearDown(transactions.dispose);
          restarted.buildwallet = false;
          final connections = WalletConnectProvider();
          await tester.pumpWidget(
            wrapForTest(
              const WalletPage(),
              overrides: [
                wapBridgeProvider.overrideWith((ref) => restarted),
                wcpBridgeProvider.overrideWith((ref) => connections),
              ],
            ),
          );
          for (var attempt = 0; attempt < 600; attempt++) {
            await tester.pump(const Duration(milliseconds: 100));
            if (restarted.isWalletReady &&
                initialBalanceRequested.isCompleted) {
              break;
            }
          }
          expect(initialBalanceRequested.isCompleted, isTrue);
          expect(restarted.isWalletReady, isTrue);
          expect(find.byType(WalletBoard), findsOneWidget);
          expect(
            restarted.coinList
                .singleWhere((coin) => coin.config.coinType == 'ETH')
                .balance,
            BigInt.zero,
          );
          initialBalanceRelease.complete();
          for (var attempt = 0; attempt < 600; attempt++) {
            await tester.pump(const Duration(milliseconds: 100));
            if (restarted.coinList.any(
              (coin) => coin.balance == BigInt.parse('1000000000000000000'),
            )) {
              break;
            }
          }
          expect(restarted.isWalletReady, isTrue);
          final eth = restarted.coinList.singleWhere(
            (coin) => coin.config.coinType == 'ETH',
          );
          expect(
            eth.address.toString().toLowerCase(),
            '0x9858effd232b4033e47d90003d41ec34ecaeda94',
          );
          expect(eth.balance == BigInt.parse('1000000000000000000'), isTrue);
          expect(find.byType(WalletBoard), findsOneWidget);
          expect(find.text('Native QA'), findsWidgets);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
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
