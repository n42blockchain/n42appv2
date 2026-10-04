import 'dart:io';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_algo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('blocked by test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  const trustdart = MethodChannel('trustdart');
  const toast = MethodChannel('PonnamKarthik/fluttertoast');
  final validatedAddresses = <String>[];

  setUp(() {
    HttpOverrides.global = _FailFastHttpOverrides();
    validatedAddresses.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(trustdart, (call) async {
        final address = (call.arguments as Map)['address'] as String;
        validatedAddresses.add(address);
        return address == 'VALID' || address == 'SENDER';
      })
      ..setMockMethodCallHandler(toast, (_) async => true);
  });
  tearDown(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(trustdart, null)
      ..setMockMethodCallHandler(toast, null);
  });

  CoinModel makeCoin({BigInt? balance, bool token = false}) => CoinModel()
    ..coin = {
      'coinType': 'ALGO',
      'blockchainType': 'Algorand',
      'unit': token ? 'USDC' : 'ALGO',
      'miniName': token ? 'USDC' : 'ALGO',
      'decimals': token ? 6 : 6,
      'isContract': token,
      'contract': 'asset-id',
      'contractTest': 'test-asset-id',
    }
    ..address = 'SENDER'
    ..balance = balance ?? BigInt.from(10000000);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendAlgo(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    final dynamic state = tester.state(find.byType(WalletChainSendAlgo));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 8));
    state.load = Load.finish;
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets(
    'ALGO amount validation rejects invalid and fee-over-balance values',
    (tester) async {
      final state = await mount(tester);
      state.totalGasPrice = BigInt.from(1000);
      state.amountCheck(value: '');
      expect(state.amountErrorMessage, isNotEmpty);
      for (final value in ['0', '-1', '1e2', 'not-a-number', '0.0000001']) {
        state.amountCheck(value: value);
        expect(state.amountErrorMessage, isNotEmpty, reason: value);
      }
      state.amountCheck(value: '9.999');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.from(9999000));
      state.amountCheck(value: '10');
      expect(state.amountErrorMessage, isNotEmpty);
    },
  );

  testWidgets('ALGO Max subtracts the fixed fee and clamps at zero', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(10000000));
    state.totalGasPrice = BigInt.from(1000);
    await state.maxTag();
    expect(state.transferValue, BigInt.from(9999000));
    expect(state.valueTextEditingController.text, '9.999');
    expect(state.amountErrorMessage, isEmpty);

    state.widget.coinModel.balance = BigInt.from(1000);
    state.totalGasPrice = BigInt.from(1000);
    await state.maxTag();
    expect(state.transferValue, BigInt.zero);
    expect(state.valueTextEditingController.text, '0');
  });

  testWidgets(
    'ALGO token Max uses the token balance without native fee subtraction',
    (tester) async {
      final coin = makeCoin(balance: BigInt.from(1234567), token: true);
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendAlgo(coin),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      final dynamic state = tester.state(find.byType(WalletChainSendAlgo));
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 8));
      state.gasLimitLoad = Load.finish;
      await state.maxTag();
      expect(state.transferValue, BigInt.from(1234567));
      expect(state.valueTextEditingController.text, '1.234567');
      expect(state.amountErrorMessage, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ALGO token amount cannot exceed the token balance', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendAlgo(
          makeCoin(balance: BigInt.from(1234567), token: true),
        ),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    final dynamic state = tester.state(find.byType(WalletChainSendAlgo));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 8));
    state.load = Load.finish;
    state.totalGasPrice = BigInt.from(1000);

    state.amountCheck(value: '1.234567');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.from(1234567));

    state.amountCheck(value: '1.234568');
    expect(state.amountErrorMessage, isNotEmpty);
    expect(state.transferValue, BigInt.from(1234567));
  });

  testWidgets(
    'ALGO send preflight rejects loading and invalid recipient before confirmation',
    (tester) async {
      final state = await mount(tester);
      state.valueTextEditingController.text = '1';
      state.toTextEditingController.text = 'invalid';
      state.totalGasPrice = BigInt.from(1000);
      state.load = Load.loading;

      await state.sendTransaction();
      expect(validatedAddresses, isEmpty);
      expect(state.load, Load.loading);
      expect(find.byType(WalletBaseSend), findsNothing);
      expect(find.byType(WalletChainSendAlgo), findsOneWidget);
      await tester.pump(const Duration(seconds: 8));

      state.load = Load.finish;
      await state.sendTransaction();
      await tester.pumpAndSettle();

      expect(validatedAddresses, ['invalid']);
      expect(state.toErrorMessage, isNotEmpty);
      expect(state.load, Load.finish);
      expect(find.byType(WalletBaseSend), findsNothing);
      expect(find.byType(WalletChainSendAlgo), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ALGO recipient validation trims chain prefix and rejects self', (
    tester,
  ) async {
    final state = await mount(tester);

    expect(await state.toAddressCheck(''), isNull);
    expect(validatedAddresses, isEmpty);
    expect(await state.toAddressCheck('invalid'), isNull);
    expect(await state.toAddressCheck('algorand:VALID'), 'VALID');
    expect(state.toErrorMessage, isEmpty);
    expect(await state.toAddressCheck('SENDER'), isNull);
    expect(state.toErrorMessage, isNotEmpty);
    expect(validatedAddresses, ['invalid', 'VALID', 'SENDER']);
  });

  testWidgets(
    'missing ALGO asset hides transfer form and offers registration',
    (tester) async {
      final coin = makeCoin()..other = AlgoModel.fromCode(404);
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendAlgo(coin),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 8));

      final dynamic state = tester.state(find.byType(WalletChainSendAlgo));
      expect(state.algoTokenAdd, isFalse);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
