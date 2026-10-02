import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_sui.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in SUI send test');
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
          return address.startsWith('0x${'11' * 32}') ||
              address.startsWith('0x${'22' * 32}');
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
      'coinType': 'SUI',
      'blockchainType': 'Sui',
      'unit': 'SUI',
      'miniName': 'SUI',
      'decimals': 9,
      'isContract': false,
      'contract': '',
    }
    ..address = '0x${'11' * 32}'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(2_000_000_000);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendSui(
          makeCoin(balance: balance),
          gasPriceLoader: (_) async => MessageModel()..data = BigInt.one,
          ownedObjectsLoader: (_) async => const [],
        ),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendSui));
    state.totalGasPrice = BigInt.from(1_000_000);
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets('SUI amount validation rejects truncation and fee overdraft', (
    tester,
  ) async {
    final state = await mount(tester);
    for (final value in ['', '0', '-1', '1e2', 'not-a-number']) {
      state.amountCheck(value: value);
      expect(state.amountErrorMessage, isNotEmpty, reason: value);
    }

    state.amountCheck(value: '0.000000001');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.one);

    state.amountCheck(value: '0.0000000001');
    expect(state.amountErrorMessage, isNotEmpty);
    state.amountCheck(value: '1.0000000001');
    expect(state.amountErrorMessage, isNotEmpty);
    state.amountCheck(value: '1.0000000000');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.from(1_000_000_000));

    // Transfer and fee together exceed the synthetic native balance.
    state.amountCheck(value: '1.999000001');
    expect(state.amountErrorMessage, isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SUI recipient validation handles empty and invalid addresses', (
    tester,
  ) async {
    final state = await mount(tester);

    expect(await state.toAddressCheck(''), isNull);
    expect(state.toErrorMessage, isNotEmpty);

    expect(await state.toAddressCheck('0x${'33' * 32}'), isNull);
    expect(state.toErrorMessage, isNotEmpty);

    expect(await state.toAddressCheck('0x${'11' * 32}'), isNull);
    expect(state.toErrorMessage, isNotEmpty, reason: 'sender address');

    expect(await state.toAddressCheck('0x${'22' * 32}'), '0x${'22' * 32}');
    expect(state.toErrorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
