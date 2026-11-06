import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:async';

import 'package:n42_wallet/features/wallet/services/apt_submission_journal.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';

import 'package:flutter/services.dart';
import 'package:n42_wallet/core/enums/load.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_apt.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _CapturingSender implements ChainSender {
  SendParams? params;
  int calls = 0;
  Completer<SendResult>? pending;
  @override
  Future<SendResult> send(SendParams params) async {
    calls++;
    this.params = params;
    return pending == null
        ? const SendResult.fail('fixture stop before signing')
        : await pending!.future;
  }
}

class _OfflineWalletProvider extends WalletActionProvider {
  _OfflineWalletProvider() {
    walletIndex = 0;
  }
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in Aptos send test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  setUp(() {
    HttpOverrides.global = _FailFastHttpOverrides();
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(() => HttpOverrides.global = null);

  CoinModel makeCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      'coinType': 'APT',
      'blockchainType': 'Aptos',
      'chainId': 1,
      'chainId_test': 2,
      'unit': 'APT',
      'miniName': 'APT',
      'decimals': 8,
      'isContract': false,
      'contract': '',
    }
    ..address =
        '0x1111111111111111111111111111111111111111111111111111111111111111'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(20001);

  Future<dynamic> mount(
    WidgetTester tester, {
    BigInt? balance,
    ChainSender? sender,
  }) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendApt(makeCoin(balance: balance), sender: sender),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendApt));
    // Isolate local amount/fee behavior from the blocked network gas lookup.
    state.gasPrice = BigInt.from(100);
    state.gas = BigInt.from(100);
    state.totalGasPrice = BigInt.from(10000);
    expect(tester.takeException(), isNull);
    return state;
  }

  for (final change in [
    'amount',
    'recipient',
    'network',
    'wallet',
    'source',
    'path',
    'fee',
    'decimals',
    'disposed',
  ]) {
    testWidgets('stale $change during address validation does not confirm', (
      tester,
    ) async {
      final pending = Completer<bool>();
      const channel = MethodChannel('trustdart');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) => pending.future);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final dynamic state = await mount(
        tester,
        balance: BigInt.from(1000000000),
      );
      state.toTextEditingController.text = '0x2';
      state.valueTextEditingController.text = '1';
      final sending = state.sendTransaction() as Future<void>;
      await tester.pump();
      switch (change) {
        case 'amount':
          state.valueTextEditingController.text = '2';
        case 'recipient':
          state.toTextEditingController.text = '0x3';
        case 'wallet':
          state.ref.read(wapBridgeProvider).walletIndex = 1;
        case 'network':
          state.widget.coinModel.isTest = true;
        case 'source':
          state.widget.coinModel.address = '0x3';
        case 'path':
          state.widget.coinModel.pathIndex = 1;
        case 'fee':
          state.totalGasPrice = BigInt.from(20000);
        case 'decimals':
          state.widget.coinModel.coin['decimals'] = 6;
        case 'disposed':
          await tester.pumpWidget(const SizedBox.shrink());
      }
      pending.complete(true);
      await sending;
      await tester.pumpAndSettle();
      if (change != 'disposed') expect(state.load, Load.finish);
      expect(find.byType(WalletBaseSend), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final change in [
    'unchanged',
    'cancel',
    'amount',
    'recipient',
    'network',
    'wallet',
    'source',
    'path',
    'fee',
    'decimals',
  ]) {
    testWidgets('confirmation route preserves request identity: $change', (
      tester,
    ) async {
      const channel = MethodChannel('trustdart');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => true);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final sender = _CapturingSender();
      final dynamic state = await mount(
        tester,
        balance: BigInt.from(1000000000),
        sender: sender,
      );
      state.toTextEditingController.text = '0x2';
      state.valueTextEditingController.text = '1';
      final sending = state.sendTransaction() as Future<void>;
      await tester.pumpAndSettle();
      expect(find.byType(WalletBaseSend), findsOneWidget);
      final confirmation = tester.widget<WalletBaseSend>(
        find.byType(WalletBaseSend),
      );
      expect(confirmation.transationRecordModel!.to1, '0x2');
      expect(confirmation.transationRecordModel!.price, BigInt.from(100000000));
      switch (change) {
        case 'amount':
          state.valueTextEditingController.text = '2';
        case 'recipient':
          state.toTextEditingController.text = '0x3';
        case 'network':
          state.widget.coinModel.isTest = true;
        case 'wallet':
          state.ref.read(wapBridgeProvider).walletIndex = 1;
        case 'source':
          state.widget.coinModel.address = '0x3';
        case 'path':
          state.widget.coinModel.pathIndex = 1;
        case 'fee':
          state.totalGasPrice = BigInt.from(20000);
        case 'decimals':
          state.widget.coinModel.coin['decimals'] = 6;
      }
      // Exercise the real route return boundary; native authentication is not
      // under test. The injected sender never signs or broadcasts a transaction.
      Navigator.of(tester.element(find.byType(WalletBaseSend)))
          .pop(change != 'cancel');
      await tester.pumpAndSettle();
      await sending;
      expect(sender.calls, change == 'unchanged' ? 1 : 0);
      if (change == 'unchanged') {
        expect(sender.params, isNotNull);
        expect(sender.params!.valueWeiOverride, BigInt.from(100000000));
      } else {
        expect(sender.params, isNull);
      }
      expect(state.load, Load.finish);
      expect(find.byType(WalletBaseSend), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final outcome in [
    'success',
    'failed',
    'pending',
    'offline',
    'save failure',
  ]) {
    testWidgets('reopened page reconciles $outcome without sending again', (
      tester,
    ) async {
      final coin = makeCoin();
      final journal = AptSubmissionJournal();
      final pending = await journal.broadcast(
        chainId: 1,
        sender: coin.address.toString(),
        sequence: BigInt.zero,
        signedTx: '00ff',
        isCurrent: () => true,
        send: (_) async {},
      );
      var saved = 0;
      final sender = _CapturingSender();
      final api = AptApi(
        read: (url) async {
          if (outcome == 'offline') throw const SocketException('offline');
          if (url.endsWith('/v1/')) {
            return {'chain_id': 1, 'ledger_timestamp': '1000000'};
          }
          return {
            'type': outcome == 'pending'
                ? 'pending_transaction'
                : 'user_transaction',
            'hash': pending.hash,
            'sender': pending.sender,
            'sequence_number': '0',
            if (outcome != 'pending') ...{
              'version': '1',
              'success': outcome != 'failed',
            },
          };
        },
      );
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendApt(
            coin,
            sender: sender,
            submissionJournal: AptSubmissionJournal(),
            recoveryApi: api,
            recoveryWriter: (original, receipt) async {
              saved++;
              expect(original.hash, pending.hash);
              expect(await journal.pending(1, pending.sender), isNotNull);
              if (outcome == 'save failure') throw StateError('disk');
            },
          ),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(pending.hash), findsOneWidget);
      final dynamic state = tester.state(find.byType(WalletChainSendApt));
      await state.sendTransaction();
      expect(sender.calls, 0);
      await tester.tap(find.byKey(const ValueKey('apt-recovery-refresh')));
      await tester.pumpAndSettle();
      final terminal = outcome == 'success' || outcome == 'failed';
      expect(
        await journal.pending(1, pending.sender),
        terminal ? isNull : isNotNull,
      );
      expect(find.text(pending.hash), terminal ? findsNothing : findsOneWidget);
      expect(saved, outcome == 'offline' || outcome == 'pending' ? 0 : 1);
      expect(sender.calls, 0);
      expect(tester.takeException(), isNull);
    });
  }

  for (final change in ['disposed', 'wallet', 'save failure']) {
    testWidgets('accepted Aptos transfer survives $change without resend', (
      tester,
    ) async {
      final sender = _CapturingSender()..pending = Completer<SendResult>();
      final coin = makeCoin();
      final saved = <TransationRecordModel>[];
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendApt(
            coin,
            sender: sender,
            transactionWriter: (record) async {
              saved.add(record);
              if (change == 'save failure') {
                throw StateError('storage unavailable');
              }
              return 42;
            },
          ),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(WalletChainSendApt));
      final record = TransationRecordModel()
        ..from1 = coin.address.toString()
        ..to1 = '0x2'
        ..price = BigInt.one;
      final sending = state.signTx(record) as Future<void>;
      await state.signTx(record);
      expect(sender.calls, 1);
      if (change == 'disposed') {
        await tester.pumpWidget(const SizedBox.shrink());
      } else if (change == 'wallet') {
        state.ref.read(wapBridgeProvider).walletIndex = 1;
      }
      sender.pending!.complete(SendResult.ok('0x${'ab' * 32}'));
      await sending;
      await tester.pumpAndSettle();
      expect(saved, hasLength(1));
      expect(saved.single.txHash, '0x${'ab' * 32}');
      expect(saved.single.walletIndex, 0);
      expect(saved.single.to1, '0x2');
      if (change != 'disposed') {
        if (change == 'wallet') {
          expect(state.errorMessage, isEmpty);
          state.ref.read(wapBridgeProvider).walletIndex = 0;
        } else {
          expect(state.errorMessage, contains('storage unavailable'));
          expect(state.errorMessage, contains('0x${'ab' * 32}'));
        }
        await state.signTx(record);
        expect(sender.calls, 1);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final token in [false, true]) {
    testWidgets('confirmed integer reaches sender exactly token=$token', (
      tester,
    ) async {
      final sender = _CapturingSender();
      final coin = makeCoin();
      coin.coin['decimals'] = token ? 6 : 8;
      coin.coin['isContract'] = token;
      coin.coin['contract'] = token ? '0x42::usd::USDC' : '';
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendApt(coin, sender: sender),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(WalletChainSendApt));
      final exact = BigInt.parse('9007199254740993');
      final record = TransationRecordModel()
        ..from1 = coin.address.toString()
        ..to1 = '0x2'
        ..contract = token ? '0x42::usd::USDC' : ''
        ..price = exact;
      await state.signTx(record);
      await tester.pumpAndSettle();
      expect(sender.params, isNotNull);
      expect(sender.params!.tokenDecimals, token ? 6 : 8);
      expect(sender.params!.valueWeiOverride, token ? null : exact);
      expect(sender.params!.tokenValueWeiOverride, token ? exact : null);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'APT validates syntax, precision and native fee against balance',
    (tester) async {
      final state = await mount(tester);
      for (final value in ['', '0', '-1', '1e2', 'not-a-number']) {
        state.amountCheck(value: value);
        expect(state.amountErrorMessage, isNotEmpty, reason: value);
      }

      state.amountCheck(value: '0.00000001');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.one);

      state.amountCheck(value: '0.000000010001');
      expect(
        state.amountErrorMessage,
        isNotEmpty,
        reason: 'non-zero precision beyond APT units must not truncate',
      );
      state.amountCheck(value: '0.000000010000');
      expect(
        state.amountErrorMessage,
        isEmpty,
        reason: 'extra fractional zeroes preserve the same APT amount',
      );
      expect(state.transferValue, BigInt.one);

      // A positive amount below one on-chain unit must not truncate to zero.
      state.transferValue = BigInt.zero;
      state.amountCheck(value: '0.000000001');
      expect(state.amountErrorMessage, isNotEmpty);
      expect(state.transferValue, BigInt.zero);

      // 10,002 base units transfer + 10,000 base units fee exceeds 20,001.
      state.amountCheck(value: '0.00010002');
      expect(state.amountErrorMessage, isNotEmpty);

      state.amountCheck(value: '0.00009999');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.from(9999));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('APT Max subtracts fee and clamps balances below fee to zero', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(25000));
    await state.maxTag();
    expect(state.transferValue, BigInt.from(15000));
    expect(state.valueTextEditingController.text, '0.00015');
    expect(state.amountErrorMessage, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    final belowFee = await mount(tester, balance: BigInt.from(9999));
    await belowFee.maxTag();
    expect(belowFee.transferValue, BigInt.zero);
    expect(belowFee.valueTextEditingController.text, '0');
    expect(tester.takeException(), isNull);
  });
}
