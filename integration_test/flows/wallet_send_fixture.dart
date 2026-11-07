import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_form.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../test/helpers/widget_test_helpers.dart';

const _enabled = bool.fromEnvironment('N42_DISPOSABLE_WALLET_QA');

class _SendFixtureWallet extends WalletActionProvider {
  @override
  String get userUUID => 'n42-send-form-qa';
}

void registerWalletSendFixture() {
  for (final scenario in ['recipient', 'amount', 'gas']) {
    testWidgets('native send form validates $scenario using loopback RPC', (
      tester,
    ) async {
      final info = DeviceInfoPlugin();
      final virtual = Platform.isAndroid
          ? !(await info.androidInfo).isPhysicalDevice
          : Platform.isIOS && !(await info.iosInfo).isPhysicalDevice;
      expect(virtual, isTrue, reason: 'Requires a disposable simulator.');
      if (!virtual) return;
      final input = TestWidgetsFlutterBinding.instance.testTextInput;
      if (!input.isRegistered) {
        input.register();
        addTearDown(input.unregister);
      }
      final methods = <String>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        final body = jsonDecode(
          await utf8.decoder.bind(request).join(),
        ) as Map<String, dynamic>;
        final method = body['method'] as String;
        methods.add(method);
        final result = switch (method) {
          'eth_getBalance' => '0xde0b6b3a7640000', // 1 ETH
          'eth_gasPrice' => '0x77359400', // 2 Gwei
          _ => null,
        };
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': body['id'],
            'result': ?result,
            if (result == null)
              'error': {
                'code': -32601,
                'message': 'Fixture method unavailable',
              },
          }),
        );
        await request.response.close();
      });
      final rpc = 'http://127.0.0.1:${server.port}';
      final base = chainUrlMap['ETH']['baseInfo'] as Map<String, dynamic>;
      final original = Map<String, dynamic>.from(base);
      addTearDown(() {
        base
          ..clear()
          ..addAll(original);
      });
      base['service'] = rpc;
      base['service_test'] = rpc;
      final coin = CoinModel()
        ..coin = Map<String, dynamic>.from(base)
        ..address = '0x1111111111111111111111111111111111111111';
      // Balance refresh updates the selected wallet's in-memory coin map.
      // Seed that required context without loading or persisting any account.
      final store = _SendFixtureWallet();
      store.walletInfoLsit.add(
        WalletInfo(
          walletUuid: store.userUUID,
          walletName: 'Synthetic Send QA',
          coinInfo: {
            'ETH': {'baseInfo': coin.coin},
          },
        ),
      );
      store.walletIndex = 0;
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSend(coin),
          overrides: [wapBridgeProvider.overrideWith((ref) => store)],
        ),
      );
      final dynamic state = tester.state(find.byType(WalletChainSend));
      for (var i = 0; i < 300; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (state.load == Load.finish && methods.contains('eth_gasPrice')) {
          break;
        }
      }
      expect(state.load, Load.finish);
      expect(coin.balance, BigInt.parse('1000000000000000000'));
      expect(methods, contains('eth_getBalance'));
      expect(methods, contains('eth_gasPrice'));
      Finder field(Type parent) => find
          .descendant(of: find.byType(parent), matching: find.byType(TextField))
          .first;
      Future<void> enter(Type parent, String value) async {
        final target = field(parent);
        await tester.ensureVisible(target);
        await tester.enterText(target, value);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(target).controller!.text == value,
          isTrue,
          reason: 'Synthetic input must be retained unchanged.',
        );
      }

      if (scenario == 'recipient') {
        await enter(SendAmountWidget, '0.1');
        await enter(SendToWidget, 'invalid-recipient');
        await tester.ensureVisible(find.text(S.current.g_key_48));
        await tester.tap(find.text(S.current.g_key_48));
        await tester.pumpAndSettle();
        expect(state.toErrorMessage, isNotEmpty);
        expect(find.text(state.toErrorMessage as String), findsWidgets);
      } else if (scenario == 'amount') {
        for (final value in ['0', '2', '0.0000000000000000001']) {
          await enter(SendAmountWidget, value);
          expect(state.amountErrorMessage, isNotEmpty);
          expect(find.text(state.amountErrorMessage as String), findsWidgets);
        }
      } else {
        expect(state.gas, BigInt.from(21000));
        expect(state.totalGasPrice, BigInt.from(42000000000000));
        expect(find.textContaining('0.000042'), findsWidgets);
      }
      expect(find.byType(WalletChainSend), findsOneWidget);
      expect(
        methods.where((m) => m.startsWith('eth_send') || m.contains('sign')),
        isEmpty,
        reason: 'Validation must never sign or broadcast.',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 8));
    }, skip: !_enabled);
  }
}
