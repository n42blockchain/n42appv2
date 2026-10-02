import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_ton.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in TON send test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  const trustdart = MethodChannel('trustdart');
  const toast = MethodChannel('PonnamKarthik/fluttertoast');

  setUp(() {
    HttpOverrides.global = _FailFastHttpOverrides();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(trustdart, (call) async {
        if (call.method == 'validateAddress') {
          final address = (call.arguments as Map)['address'] as String;
          return address.startsWith(
            'EQRecipient000000000000000000000000000000000000',
          );
        }
        throw StateError('Unexpected Trustdart call: ${call.method}');
      })
      ..setMockMethodCallHandler(toast, (_) async => true);
  });

  tearDown(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(trustdart, null)
      ..setMockMethodCallHandler(toast, null);
  });

  CoinModel makeCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      'coinType': 'TON',
      'blockchainType': 'TheOpenNetwork',
      'unit': 'TON',
      'miniName': 'TON',
      'decimals': 9,
      'isContract': false,
      'contract': '',
    }
    ..address = 'EQSender000000000000000000000000000000000000'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(5000000000);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendTon(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendTon));
    expect(state.totalGasPrice, BigInt.from(1000000));
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets('TON amount rejects invalid values and exact fee-over-balance', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(2000000));
    for (final value in ['', '0', '-1', '1e2', 'not-a-number']) {
      state.amountCheck(value: value);
      expect(state.amountErrorMessage, isNotEmpty, reason: value);
    }

    state.amountCheck(value: '0.000000001');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.one);
    state.amountCheck(value: '0.0000000001');
    expect(state.amountErrorMessage, isNotEmpty);

    state.amountCheck(value: '0.00100000001');
    expect(
      state.amountErrorMessage,
      isNotEmpty,
      reason: 'non-zero precision beyond TON nano units must not truncate',
    );
    state.amountCheck(value: '0.001000000000');
    expect(
      state.amountErrorMessage,
      isEmpty,
      reason: 'extra fractional zeroes preserve the same nano amount',
    );
    expect(state.transferValue, BigInt.from(1000000));

    state.amountCheck(value: '0.001');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.from(1000000));
    state.amountCheck(value: '0.001001');
    expect(state.amountErrorMessage, isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TON Max subtracts the network fee and clamps at zero', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(5000000000));
    await state.maxTag();
    expect(state.transferValue, BigInt.from(4999000000));
    expect(state.valueTextEditingController.text, '4.999');
    expect(state.amountErrorMessage, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    final empty = await mount(tester, balance: BigInt.from(1000000));
    await empty.maxTag();
    expect(empty.transferValue, BigInt.zero);
    expect(empty.valueTextEditingController.text, '0');
    expect(tester.takeException(), isNull);
  });

  testWidgets('TON address validation trims work to the native validator', (
    tester,
  ) async {
    final state = await mount(tester);
    expect(
      await state.toAddressCheck(
        'EQRecipient000000000000000000000000000000000000',
      ),
      'EQRecipient000000000000000000000000000000000000',
    );
    expect(
      await state.toAddressCheck(
        'EQSender000000000000000000000000000000000000',
      ),
      isNull,
    );
    expect(await state.toAddressCheck('invalid'), isNull);
    expect(await state.toAddressCheck(''), isNull);
    expect(tester.takeException(), isNull);
  });
}
