import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
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

  Future<dynamic> mount(
    WidgetTester tester, {
    BigInt? balance,
    Future<MessageModel?> Function(CoinModel)? gasPriceLoader,
    Future<List<dynamic>> Function(CoinModel)? ownedObjectsLoader,
  }) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendSui(
          makeCoin(balance: balance),
          gasPriceLoader:
              gasPriceLoader ?? (_) async => MessageModel()..data = BigInt.one,
          ownedObjectsLoader: ownedObjectsLoader ?? (_) async => const [],
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

  testWidgets('gas loading records failed response and always finishes', (
    tester,
  ) async {
    final state = await mount(
      tester,
      gasPriceLoader: (_) async => MessageModel.error()..data = 'offline',
    );

    await state.getGasPrice();

    expect(state.gasPrice, BigInt.zero);
    expect(state.totalGasPrice, BigInt.zero);
    expect(state.errorMessage, 'offline');
    expect(state.load, Load.finish);
    await tester.pump(const Duration(seconds: 8));
    expect(tester.takeException(), isNull);
  });

  testWidgets('owned SUI objects are reduced to sendable coin fields', (
    tester,
  ) async {
    final state = await mount(
      tester,
      ownedObjectsLoader: (_) async => [
        {
          'data': {
            'objectId': '0xobject',
            'digest': 'digest-1',
            'version': '7',
            'content': {
              'fields': {'balance': '123456789'},
            },
            'ignored': true,
          },
        },
      ],
    );

    await state.getOwnerObjects();

    expect(state.utxos, [
      {
        'objectId': '0xobject',
        'objectDigest': 'digest-1',
        'version': '7',
        'balance': '123456789',
      },
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('max amount reserves the estimated native gas fee', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(2_000_000_000));
    state.totalGasPrice = BigInt.from(125);

    await state.maxTag();

    expect(state.transferValue, BigInt.from(1_999_999_875));
    expect(state.valueTextEditingController.text, '1.999999875');
    expect(state.amountErrorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gas estimate exits before signing when amount is empty', (
    tester,
  ) async {
    final state = await mount(tester);
    state.toTextEditingController.text = '0x${'22' * 32}';
    state.valueTextEditingController.clear();

    final result = await state.estimateGasEthLocal();

    expect(result, isNull);
    expect(state.gasLimitLoad, Load.finish);
    expect(state.errorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gas estimate exits when recipient validation has an error', (
    tester,
  ) async {
    final state = await mount(tester);
    state.toTextEditingController.text = 'invalid';
    state.valueTextEditingController.text = '1';
    state.toErrorMessage = 'invalid recipient';

    final result = await state.estimateGasEthLocal(checkAddress: false);

    expect(result, isNull);
    expect(state.gasLimitLoad, Load.finish);
    expect(state.errorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('send readiness rejects invalid recipient before confirmation', (
    tester,
  ) async {
    final state = await mount(tester);
    state.valueTextEditingController.text = '1';
    state.toTextEditingController.text = '0x${'33' * 32}';

    await state.sendTransaction();

    expect(state.toErrorMessage, isNotEmpty);
    expect(state.load, Load.finish);
    expect(find.byType(WalletChainSendSui), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('send readiness leaves a running send untouched', (tester) async {
    final state = await mount(tester);
    state.load = Load.loading;

    await state.sendTransaction();

    expect(state.load, Load.loading);
    await tester.pump(const Duration(seconds: 8));
    expect(tester.takeException(), isNull);
  });
}
