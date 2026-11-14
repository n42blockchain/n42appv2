import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

import 'dart:io';
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_sui.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _StubResolver extends TransactionStateResolver {
  (int, String?) reply = (-1, null);
  final asked = <String>[];
  @override
  Future<(int, String?)> resolveStateWithReason(
    TransationRecordModel trm,
  ) async {
    asked.add(trm.txHash);
    return reply;
  }
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
    Future<SendResult> Function(SendParams)? transactionSender,
    Future<int> Function(TransationRecordModel)? transactionWriter,
    Future<MessageModel?> Function(CoinModel)? gasPriceLoader,
    Future<List<dynamic>> Function(CoinModel)? ownedObjectsLoader,
    Future<List<TransationRecordModel>> Function(TransationRecordModel)?
    pendingTransactions,
    TransactionStateResolver? stateResolver,
    Future<int> Function(TransationRecordModel)? saveResolvedTransaction,
    Future<int> Function(TransationRecordModel)? dismissPendingTransactions,
  }) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendSui(
          makeCoin(balance: balance),
          transactionSender: transactionSender,
          transactionWriter: transactionWriter,
          gasPriceLoader:
              gasPriceLoader ?? (_) async => MessageModel()..data = BigInt.one,
          ownedObjectsLoader: ownedObjectsLoader ?? (_) async => const [],
          pendingTransactions: pendingTransactions ?? (_) async => [],
          stateResolver: stateResolver,
          saveResolvedTransaction: saveResolvedTransaction,
          dismissPendingTransactions: dismissPendingTransactions,
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

  TransationRecordModel recordFor(dynamic state) => TransationRecordModel()
    ..from1 = state.widget.coinModel.address
    ..walletIndex = state.ref.read(wapBridgeProvider).walletIndex
    ..to1 = '0x${'22' * 32}'
    ..price = BigInt.from(1000000000);

  for (final leave in [false, true]) {
    testWidgets(
      'accepted receipt persists for original source after ${leave ? 'disposal' : 'source switch'}',
      (tester) async {
        final broadcast = Completer<SendResult>();
        final saved = <TransationRecordModel>[];
        var sends = 0;
        final state = await mount(
          tester,
          transactionSender: (_) {
            sends++;
            return broadcast.future;
          },
          transactionWriter: (record) async {
            saved.add(record);
            return 7;
          },
        );
        final record = recordFor(state);
        final pending = state.signTx(record);
        await tester.pump();
        await state.signTx(record);
        expect(sends, 1);
        if (leave) {
          await tester.pumpWidget(const SizedBox());
        } else {
          state.widget.coinModel.address = '0x${'44' * 32}';
        }
        broadcast.complete(const SendResult.ok('confirmed-hash'));
        await pending;
        expect(saved, [record]);
        expect(saved.single.from1, '0x${'11' * 32}');
        expect(saved.single.txHash, 'confirmed-hash');
        expect(saved.single.trId, 7);
        if (!leave) {
          state.widget.coinModel.address = record.from1;
          await state.signTx(record);
          expect(sends, 1);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final persisted in [true, false]) {
    testWidgets('unknown outcome keeps the digest and blocks re-signing: '
        'persisted=$persisted', (tester) async {
      var sends = 0;
      final saved = <TransationRecordModel>[];
      final state = await mount(
        tester,
        transactionSender: (_) async {
          sends++;
          return const SendResult.uncertain(
            'unknown-digest',
            'Sui transfer outcome is unknown; check transaction unknown-digest',
          );
        },
        transactionWriter: (record) async {
          if (!persisted) throw StateError('disk unavailable');
          saved.add(record);
          return 9;
        },
      );
      final record = recordFor(state);
      await state.signTx(record);
      expect(state.errorMessage, contains('unknown-digest'));
      expect(record.txHash, 'unknown-digest');
      expect(record.state, 0);
      expect(saved, persisted ? [record] : isEmpty);
      await state.signTx(record);
      expect(sends, 1);
      await tester.pump(const Duration(seconds: 8));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('plain failure before submission allows a retry', (tester) async {
    var sends = 0;
    final state = await mount(
      tester,
      transactionSender: (_) async {
        sends++;
        return const SendResult.fail('balance unavailable');
      },
      transactionWriter: (_) async => fail('nothing to record'),
    );
    final record = recordFor(state);
    await state.signTx(record);
    await state.signTx(record);
    expect(sends, 2);
    await tester.pump(const Duration(seconds: 8));
    expect(tester.takeException(), isNull);
  });

  testWidgets('local persistence failure does not enable a second broadcast', (
    tester,
  ) async {
    var sends = 0;
    final state = await mount(
      tester,
      transactionSender: (_) async {
        sends++;
        return const SendResult.ok('accepted-hash');
      },
      transactionWriter: (_) async => throw StateError('disk unavailable'),
    );
    final record = recordFor(state);
    await state.signTx(record);
    expect(state.errorMessage, contains('accepted-hash'));
    await state.signTx(record);
    expect(sends, 1);
    expect(record.txHash, 'accepted-hash');
    await tester.pump(const Duration(seconds: 8));
    expect(tester.takeException(), isNull);
  });

  for (final changed in ['amount', 'recipient', 'network', 'source', 'path']) {
    testWidgets('send stops when $changed changes during address validation', (
      tester,
    ) async {
      final state = await mount(tester);
      state.valueTextEditingController.text = '1';
      state.toTextEditingController.text = '0x${'22' * 32}';
      final validation = Completer<bool>();
      var signingCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(trustdart, (call) async {
            if (call.method == 'validateAddress') return validation.future;
            signingCalls++;
            throw StateError('Stale request reached signer');
          });
      final pending = state.sendTransaction();
      await tester.pump();
      if (changed == 'amount') state.valueTextEditingController.text = '0.5';
      if (changed == 'recipient') {
        state.toTextEditingController.text = '0x${'33' * 32}';
      }
      if (changed == 'network') state.widget.coinModel.isTest = true;
      if (changed == 'source') {
        state.widget.coinModel.address = '0x${'44' * 32}';
      }
      if (changed == 'path') state.widget.coinModel.pathIndex = 1;
      validation.complete(true);
      await pending;
      await tester.pump();
      expect(signingCalls, 0);
      expect(state.load, Load.finish);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('leaving during address validation does not set disposed state', (
    tester,
  ) async {
    final state = await mount(tester);
    state.valueTextEditingController.text = '1';
    state.toTextEditingController.text = '0x${'22' * 32}';
    final validation = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trustdart, (_) => validation.future);
    final pending = state.sendTransaction();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    validation.complete(true);
    await pending;
    expect(tester.takeException(), isNull);
  });

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

  group('earlier unresolved send', () {
    TransationRecordModel earlier() => TransationRecordModel()
      ..trId = 3
      ..coin = {'blockchainType': 'Sui', 'coinType': 'SUI'}
      ..coinMiniName = 'SUI'
      ..from1 = '0x${'11' * 32}'
      ..txHash = 'earlier-digest';

    for (final (state, reason) in [(1, null), (2, 'Sui transaction failed')]) {
      testWidgets('settled on chain ($state) is saved and does not block', (
        tester,
      ) async {
        var sends = 0;
        final saved = <TransationRecordModel>[];
        final resolver = _StubResolver()..reply = (state, reason);
        final page = await mount(
          tester,
          transactionSender: (_) async {
            sends++;
            return const SendResult.ok('new-digest');
          },
          transactionWriter: (_) async => 8,
          pendingTransactions: (_) async => [earlier()],
          stateResolver: resolver,
          saveResolvedTransaction: (record) async {
            saved.add(record);
            return 1;
          },
        );
        await page.signTx(recordFor(page));
        await tester.pumpAndSettle();
        expect(resolver.asked, ['earlier-digest']);
        expect(saved.single.txHash, 'earlier-digest');
        expect(saved.single.state, state);
        expect(saved.single.errorMessage, reason ?? '');
        expect(sends, 1);
        expect(find.text(S.current.g_memo_pending_unknown_title), findsNothing);
        await tester.pump(const Duration(seconds: 8));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a result that was not saved still blocks', (tester) async {
      var sends = 0;
      final page = await mount(
        tester,
        transactionSender: (_) async {
          sends++;
          return const SendResult.ok('new-digest');
        },
        pendingTransactions: (_) async => [earlier()],
        stateResolver: _StubResolver()..reply = (1, null),
        saveResolvedTransaction: (_) async => 0,
        dismissPendingTransactions: (_) async => 0,
      );
      await page.signTx(recordFor(page));
      await tester.pumpAndSettle();
      expect(sends, 0);
      expect(find.text(S.current.g_memo_pending_unknown_title), findsOneWidget);
      await tester.tap(find.text(S.current.g_memo_pending_keep_waiting));
      await tester.pumpAndSettle();
    });

    for (final dismiss in [false, true]) {
      testWidgets('unknown outcome blocks and offers to stop waiting: '
          'dismiss=$dismiss', (tester) async {
        var sends = 0;
        var dismissals = 0;
        var blocking = true;
        String? dismissedFrom;
        final page = await mount(
          tester,
          transactionSender: (_) async {
            sends++;
            return const SendResult.ok('new-digest');
          },
          transactionWriter: (_) async => 8,
          pendingTransactions: (_) async => blocking ? [earlier()] : [],
          stateResolver: _StubResolver(),
          saveResolvedTransaction: (_) async => fail('nothing settled'),
          dismissPendingTransactions: (record) async {
            dismissals++;
            dismissedFrom = record.from1;
            blocking = false;
            return 1;
          },
        );
        final record = recordFor(page);
        await page.signTx(record);
        await tester.pumpAndSettle();
        expect(sends, 0);
        expect(record.txHash, isEmpty);
        expect(
          find.text(S.current.g_memo_pending_unknown_title),
          findsOneWidget,
        );
        await tester.tap(
          find.text(
            dismiss
                ? S.current.g_memo_pending_dismiss
                : S.current.g_memo_pending_keep_waiting,
          ),
        );
        await tester.pumpAndSettle();
        expect(dismissals, dismiss ? 1 : 0);
        expect(dismissedFrom, dismiss ? '0x${'11' * 32}' : isNull);
        await page.signTx(record);
        await tester.pumpAndSettle();
        expect(sends, dismiss ? 1 : 0);
        if (!dismiss) {
          await tester.tap(find.text(S.current.g_memo_pending_keep_waiting));
          await tester.pumpAndSettle();
        }
        await tester.pump(const Duration(seconds: 8));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a failed history lookup stops the send', (tester) async {
      var sends = 0;
      final page = await mount(
        tester,
        transactionSender: (_) async {
          sends++;
          return const SendResult.ok('new-digest');
        },
        pendingTransactions: (_) async => throw StateError('db closed'),
      );
      await page.signTx(recordFor(page));
      await tester.pumpAndSettle();
      expect(sends, 0);
      expect(page.errorMessage, contains('db closed'));
      expect(find.text(S.current.g_memo_pending_unknown_title), findsNothing);
      await tester.pump(const Duration(seconds: 8));
      expect(tester.takeException(), isNull);
    });
  });
}
