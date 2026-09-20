import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_logic.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

/// Uses the production validation/navigation state machine. Only external
/// address resolution, gas estimation, and signing are substituted offline.
class _SendHarness extends ConsumerStatefulWidget {
  const _SendHarness({super.key, required this.coin});
  final CoinModel coin;

  @override
  ConsumerState<_SendHarness> createState() => _SendHarnessState();
}

class _SendHarnessState extends ConsumerState<_SendHarness>
    with SendLogicMixin<_SendHarness> {
  @override
  CoinModel get coinModel => widget.coin;
  @override
  CoinModel? chainModel;
  @override
  final regular = Regular();
  @override
  TokenViewApi get tokenViewApi =>
      throw StateError('Unexpected live API access');
  @override
  final toTextEditingController = TextEditingController(text: 'recipient');
  @override
  final valueTextEditingController = TextEditingController(text: '1');
  @override
  final noteTextEditingController = TextEditingController();

  String? resolvedAddress = '0x2222222222222222222222222222222222222222';
  Completer<String?>? addressGate;
  Completer<bool>? estimateGate;
  int addressChecks = 0;
  int estimates = 0;
  int signatures = 0;
  int dismissals = 0;
  String estimateError = '';
  BigInt? estimatedFee;
  TransationRecordModel? confirmationRecord;

  @override
  void initState() {
    super.initState();
    load = Load.finish;
  }

  @override
  Future<String?> toAddressCheck(String addr) async {
    addressChecks++;
    return addressGate == null ? resolvedAddress : await addressGate!.future;
  }

  @override
  void closeKeyboard() => dismissals++;

  @override
  Future<dynamic> estimateGasEthLocal({
    bool checkAddress = true,
    String? amountOverride,
    bool dismissKeyboard = true,
  }) async {
    estimates++;
    if (estimateGate != null) await estimateGate!.future;
    totalGasPrice = estimatedFee ?? totalGasPrice;
    errorMessage = estimateError;
    return estimateError.isEmpty;
  }

  @override
  Future<void> signTx(TransationRecordModel trModel) async => signatures++;

  @override
  Widget buildWalletBaseSend(TransationRecordModel trModel, String chainUnit) {
    confirmationRecord = trModel;
    return Scaffold(
      body: Column(
        children: [
          Text('Confirm $chainUnit'),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  void dispose() {
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    noteTextEditingController.dispose();
    super.dispose();
  }
}

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (_) async => true);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  Future<_SendHarnessState> mount(
    WidgetTester tester, {
    bool contract = false,
    int decimals = 6,
    String blockchain = 'Ethereum',
    BigInt? balance,
  }) async {
    final coin = CoinModel()
      ..coin = {
        'coinType': blockchain == 'Ripple' ? 'XRP' : 'ETH',
        'blockchainType': blockchain,
        'unit': 'ETH',
        'decimals': decimals,
        'isContract': contract,
        'contract': contract
            ? '0x1111111111111111111111111111111111111111'
            : '',
      }
      ..address = '0x3333333333333333333333333333333333333333'
      ..balance = balance ?? BigInt.from(10000000);
    final key = GlobalKey<_SendHarnessState>();
    await tester.pumpWidget(
      wrapForTest(
        _SendHarness(key: key, coin: coin),
        overrides: [
          wapBridgeProvider.overrideWith(
            (ref) => WalletActionProvider()..walletIndex = 2,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  testWidgets('native amount plus fee must fit balance exactly', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(1000100));
    state.totalGasPrice = BigInt.from(100);
    state.amountCheck(value: '1');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.from(1000000));
    state.amountCheck(value: '1.000001');
    expect(state.amountErrorMessage, isNotEmpty);
  });

  testWidgets(
    'amount validation rejects zero, negative, exponent and excess scale',
    (tester) async {
      final state = await mount(tester);
      for (final value in ['0', '-1', '1e2', '0.0000001', 'not-a-number']) {
        state.amountCheck(value: value);
        expect(state.amountErrorMessage, isNotEmpty, reason: value);
      }
      state.amountCheck(value: '0.000001');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.one);
    },
  );

  testWidgets('zero precision requires a positive whole unit', (tester) async {
    final state = await mount(tester, decimals: 0);
    state.amountCheck(value: '0.5');
    expect(state.amountErrorMessage, isNotEmpty);
    state.amountCheck(value: '1');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.one);
  });

  testWidgets(
    'native amounts above double-safe integers preserve smallest units',
    (tester) async {
      final balance = BigInt.parse('9007199254740993123457');
      final state = await mount(tester, balance: balance);
      state.amountCheck(value: '9007199254740993.123456');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.parse('9007199254740993123456'));
    },
  );

  testWidgets('XRP amount validation reserves ten coins as well as fee', (
    tester,
  ) async {
    final state = await mount(
      tester,
      blockchain: 'Ripple',
      balance: BigInt.from(11000100),
    );
    state.totalGasPrice = BigInt.from(100);
    state.amountCheck(value: '1');
    expect(state.amountErrorMessage, isEmpty);
    state.amountCheck(value: '1.000001');
    expect(state.amountErrorMessage, isNotEmpty);
  });

  testWidgets(
    'invalid amount returns before recipient lookup or fee estimate',
    (tester) async {
      final state = await mount(tester);
      state.valueTextEditingController.text = '0';
      await state.sendTransaction();
      expect(state.addressChecks, 0);
      expect(state.estimates, 0);
      expect(state.signatures, 0);
      expect(state.confirmationRecord, isNull);
      expect(state.load, Load.finish);
    },
  );

  testWidgets('unresolved recipient releases busy state without confirmation', (
    tester,
  ) async {
    final state = await mount(tester);
    state.resolvedAddress = null;
    await state.sendTransaction();
    expect(state.addressChecks, 1);
    expect(state.estimates, 0);
    expect(state.signatures, 0);
    expect(state.load, Load.finish);
  });

  testWidgets('fee estimation failure blocks confirmation and permits retry', (
    tester,
  ) async {
    final state = await mount(tester);
    state.estimateError = 'RPC refused estimate';
    await state.sendTransaction();
    expect(state.errorMessage, 'RPC refused estimate');
    expect(state.confirmationRecord, isNull);
    expect(state.signatures, 0);
    expect(state.load, Load.finish);
  });

  testWidgets('contract token needs parent-chain funds before confirmation', (
    tester,
  ) async {
    final state = await mount(tester, contract: true);
    state.estimatedFee = BigInt.one;
    await state.sendTransaction();
    expect(state.confirmationRecord, isNull);
    expect(state.signatures, 0);
    expect(state.load, Load.finish);
    expect(state.signTxCheck(), isFalse);
    state.chainModel = CoinModel()..balance = BigInt.one;
    expect(state.signTxCheck(), isTrue);
    state.totalGasPrice = BigInt.two;
    expect(state.signTxCheck(), isFalse);
    // Fluttertoast clears its display flag on a seven-second timer.
    await tester.pump();
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('canceling confirmation never invokes signing and unlocks form', (
    tester,
  ) async {
    final state = await mount(tester);
    state.noteTextEditingController.text = '  test memo  ';
    final operation = state.sendTransaction();
    await tester.pumpAndSettle();
    expect(find.text('Confirm ETH'), findsOneWidget);
    expect(state.confirmationRecord!.walletIndex, 2);
    expect(state.confirmationRecord!.price, BigInt.from(1000000));
    expect(state.confirmationRecord!.message, 'test memo');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await operation;
    expect(state.signatures, 0);
    expect(state.load, Load.finish);
  });

  testWidgets(
    'duplicate taps while address lookup runs share one confirmation',
    (tester) async {
      final state = await mount(tester);
      state.addressGate = Completer<String?>();
      final first = state.sendTransaction();
      await state.sendTransaction();
      expect(state.addressChecks, 1);
      expect(state.load, Load.loading);
      state.addressGate!.complete(state.resolvedAddress);
      await tester.pumpAndSettle();
      expect(find.text('Confirm ETH'), findsOneWidget);
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      await first;
      expect(state.estimates, 1);
      expect(state.signatures, 1);
      await tester.pump(const Duration(seconds: 8));
    },
  );

  testWidgets(
    'leaving during pending address lookup does not confirm or sign',
    (tester) async {
      final state = await mount(tester);
      state.addressGate = Completer<String?>();
      final operation = state.sendTransaction();
      await tester.pumpWidget(const SizedBox());
      state.addressGate!.complete(state.resolvedAddress);
      await operation;
      expect(state.estimates, 0);
      expect(state.signatures, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('token overspend is rejected before confirmation or signing', (
    tester,
  ) async {
    final state = await mount(
      tester,
      contract: true,
      balance: BigInt.from(1000000),
    );
    state.chainModel = CoinModel()..balance = BigInt.from(100);
    state.estimatedFee = BigInt.one;
    state.valueTextEditingController.text = '1.000001';
    final operation = state.sendTransaction();
    await tester.pumpAndSettle();
    final confirmed = state.confirmationRecord != null;
    if (confirmed) {
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
    await operation;
    expect(
      confirmed,
      isFalse,
      reason: 'Insufficient token units must not reach approval',
    );
    expect(state.signatures, 0);
    expect(state.amountErrorMessage, isNotEmpty);
    expect(state.addressChecks, 0);
    expect(state.estimates, 0);
  });

  testWidgets('increased fee is revalidated before native confirmation', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(10000000));
    state.valueTextEditingController.text = '9';
    state.estimatedFee = BigInt.from(2000000);
    final operation = state.sendTransaction();
    await tester.pumpAndSettle();
    final confirmed = state.confirmationRecord != null;
    if (confirmed) {
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
    await operation;
    expect(
      confirmed,
      isFalse,
      reason: 'Amount plus refreshed fee exceeds native balance',
    );
    expect(state.addressChecks, 1);
    expect(state.estimates, 1);
    expect(state.signatures, 0);
    expect(state.amountErrorMessage, isNotEmpty);
    expect(state.load, Load.finish);
  });

  testWidgets('amount plus refreshed fee exactly at balance can be confirmed', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(10000000));
    state.valueTextEditingController.text = '8';
    state.estimatedFee = BigInt.from(2000000);
    final operation = state.sendTransaction();
    await tester.pumpAndSettle();
    expect(find.text('Confirm ETH'), findsOneWidget);
    expect(state.confirmationRecord!.price, BigInt.from(8000000));
    expect(state.confirmationRecord!.gasPrice, BigInt.from(2000000));
    expect(state.amountErrorMessage, isEmpty);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await operation;
    expect(state.signatures, 0);
    expect(state.load, Load.finish);
  });
}
