import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bridge_provider_approval_test.dart' show FakeBridgeApiClient;

MessageModel ok(dynamic data) => MessageModel()..data = data;
BridgeChain chain(int id) => BridgeChain(
  chainId: id,
  key: '$id',
  name: '$id',
  logoUri: '',
  nativeToken: 'ETH',
  nativeDecimals: 18,
);
BridgeToken token(int id, {bool native = true}) => BridgeToken(
  address: native ? '0x0000000000000000000000000000000000000000' : '0xtoken',
  symbol: 'ETH',
  name: 'ETH',
  decimals: 18,
  chainId: id,
  logoUri: '',
);
BridgeRoute route(
  BridgeToken from,
  BridgeToken to, {
  String id = 'route',
  String amount = '1000000000000000001',
}) => BridgeRoute(
  id: id,
  steps: [
    BridgeRouteStep(
      type: 'lifi',
      tool: 'bridge',
      toolName: 'Bridge',
      toolLogoUri: '',
      fromToken: from,
      toToken: to,
      fromAmount: amount,
      toAmount: '990000000000000000',
      estimatedSeconds: 30,
    ),
  ],
  fromToken: from,
  toToken: to,
  fromAmount: amount,
  toAmount: '990000000000000000',
  toAmountMin: '980000000000000000',
  gasCostUSD: 1,
  estimatedSeconds: 30,
  tags: ['RECOMMENDED'],
);

class _Api extends FakeBridgeApiClient {
  final requests = <BridgeQuoteRequest>[];
  final steps = <Map<String, dynamic>>[];
  final approvalAmounts = <String?>[];
  var statusCalls = 0;
  var allowanceCalls = 0;
  Future<MessageModel> Function(BridgeQuoteRequest) routes = (_) async =>
      ok(BridgeQuoteResponse(routes: []));
  Future<MessageModel> Function() step = () async => ok(
    BridgeTransactionResponse(
      txData: {'to': '0xrouter', 'data': '0x1234', 'value': '0x1'},
    ),
  );
  Future<MessageModel> Function() allowance = () async =>
      ok({'allowance': '0'});
  Future<MessageModel> Function() approval = () async =>
      ok({'to': '0xtoken', 'data': 'approve'});
  Future<MessageModel> Function() status = () async =>
      ok(BridgeStatusResponse(status: BridgeTransactionStatus.pending));
  @override
  Future<MessageModel> getChains() async => ok([chain(1), chain(42161)]);
  @override
  Future<MessageModel> getTokens({int? chainId}) async => ok(<BridgeToken>[]);
  @override
  Future<MessageModel> getRoutes(BridgeQuoteRequest request) {
    requests.add(request);
    return routes(request);
  }

  @override
  Future<MessageModel> getStepTransaction({
    required Map<String, dynamic> step,
  }) {
    steps.add(step);
    return this.step();
  }

  @override
  Future<MessageModel> getTokenApproval({
    required int chainId,
    required String tokenAddress,
    required String walletAddress,
    required String spenderAddress,
  }) {
    allowanceCalls++;
    return allowance();
  }

  @override
  Future<MessageModel> getApprovalTransaction({
    required int chainId,
    required String tokenAddress,
    required String spenderAddress,
    String? amount,
  }) {
    approvalAmounts.add(amount);
    return approval();
  }

  @override
  Future<MessageModel> getStatus({
    required String txHash,
    required int fromChainId,
    required int toChainId,
    required String bridge,
  }) {
    statusCalls++;
    return status();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Api api;
  late BridgeProvider provider;
  var disposed = false;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = _Api();
    provider = BridgeProvider(lifiApi: api);
    disposed = false;
  });
  tearDown(() {
    if (!disposed) provider.dispose();
  });
  void dispose() {
    provider.dispose();
    disposed = true;
  }

  Future<void> configure({bool native = true}) async {
    await provider.setFromChain(chain(1));
    await provider.setToChain(chain(42161));
    provider.setFromToken(token(1, native: native));
    provider.setToToken(token(42161));
    provider.setFromAmount('1.000000000000000001');
    provider.selectRoute(route(provider.fromToken!, provider.toToken!));
  }

  Future<MessageModel> execute(
    Future<String?> Function(Map<String, dynamic>) sign,
  ) => provider.executeBridge(
    fromAddress: '0xalice',
    toAddress: '0xbob',
    signAndSend: sign,
  );
  Future<void> quote() =>
      provider.getQuote(fromAddress: '0xalice', toAddress: '0xbob');

  test(
    'empty token lists do not crash initialization or chain selection',
    () async {
      await provider.initialize();
      expect(provider.state, BridgeState.idle);
      expect(provider.fromToken, isNull);
      expect(provider.toToken, isNull);
      expect(provider.getTokensForChain(1), isEmpty);
    },
  );

  test('newer quote wins and amount conversion preserves one wei', () async {
    await configure();
    final first = Completer<MessageModel>();
    api.routes = (_) => first.future;
    final pending = quote();
    expect(api.requests.single.fromAmount, '1000000000000000001');
    provider.setFromAmount('2');
    api.routes = (_) async => ok(
      BridgeQuoteResponse(
        routes: [route(provider.fromToken!, provider.toToken!, id: 'new')],
      ),
    );
    await quote();
    first.complete(
      ok(
        BridgeQuoteResponse(
          routes: [route(provider.fromToken!, provider.toToken!, id: 'old')],
        ),
      ),
    );
    await pending;
    expect(provider.selectedRoute!.id, 'new');
    expect(provider.state, BridgeState.idle);
  });

  test(
    'slippage/reset invalidates pending quotes and current routes',
    () async {
      await configure();
      final pending = Completer<MessageModel>();
      api.routes = (_) => pending.future;
      final request = quote();
      provider.setSlippage(1);
      expect(provider.selectedRoute, isNull);
      pending.complete(
        ok(
          BridgeQuoteResponse(
            routes: [route(provider.fromToken!, provider.toToken!)],
          ),
        ),
      );
      await request;
      expect(provider.selectedRoute, isNull);
      final next = Completer<MessageModel>();
      api.routes = (_) => next.future;
      final second = quote();
      provider.reset();
      next.complete(MessageModel.error()..data = 'old failure');
      await second;
      expect(provider.errorMessage, isNull);
      expect(provider.state, BridgeState.idle);
    },
  );

  test(
    'invalid or zero amounts stop before the quote API and failures can retry',
    () async {
      await configure();
      for (final amount in ['0', '-1', 'NaN', '0.0000000000000000001']) {
        provider.setFromAmount(amount);
        await quote();
        expect(provider.state, BridgeState.error);
      }
      expect(api.requests, isEmpty);
      provider.setFromAmount('1');
      api.routes = (_) async => throw StateError('offline');
      await quote();
      expect(provider.errorMessage, 'Failed to get quote');
      api.routes = (_) async => ok(
        BridgeQuoteResponse(
          routes: [route(provider.fromToken!, provider.toToken!)],
        ),
      );
      await quote();
      expect(provider.state, BridgeState.idle);
      expect(provider.errorMessage, isNull);
    },
  );

  test(
    'native send persists exact original intent even if form changes during signing',
    () async {
      await configure();
      final sent = <Map<String, dynamic>>[];
      final result = await execute((tx) async {
        sent.add(tx);
        provider.setFromAmount('99');
        return '0xsent';
      });
      expect(result.error, isFalse);
      expect(result.data, '0xsent');
      expect(sent, hasLength(1));
      expect(api.allowanceCalls, 0);
      final transaction = provider.transactions.single;
      expect(transaction.fromAmount, '1.000000000000000001');
      expect(transaction.fromChainId, 1);
      expect(transaction.toChainId, 42161);
      expect(transaction.fromAddress, '0xalice');
      expect(transaction.toAddress, '0xbob');
      expect(transaction.status, BridgeTransactionStatus.pending);
      final prefs = await SharedPreferences.getInstance();
      await Future<void>.delayed(Duration.zero);
      expect(
        jsonDecode(prefs.getString('bridge_transactions_v1')!)[0]['txHash'],
        '0xsent',
      );
    },
  );

  test(
    'duplicate execution is rejected while the first transaction is preparing',
    () async {
      await configure();
      final step = Completer<MessageModel>();
      api.step = () => step.future;
      var signs = 0;
      final first = execute((_) async {
        signs++;
        return '0xsent';
      });
      final second = await execute((_) async {
        signs++;
        return '0xduplicate';
      });
      expect(second.error, isTrue);
      expect(api.steps, hasLength(1));
      step.complete(ok(BridgeTransactionResponse(txData: {'to': '0xrouter'})));
      expect((await first).error, isFalse);
      expect(signs, 1);
      expect(provider.transactions, hasLength(1));
    },
  );

  test(
    'configuration change during preparation aborts before signing',
    () async {
      await configure();
      final pending = Completer<MessageModel>();
      api.step = () => pending.future;
      var signs = 0;
      final result = execute((_) async {
        signs++;
        return '0xsent';
      });
      provider.setFromAmount('2');
      pending.complete(
        ok(BridgeTransactionResponse(txData: {'to': '0xrouter'})),
      );
      expect((await result).data, 'Bridge selection changed');
      expect(signs, 0);
      expect(provider.transactions, isEmpty);
    },
  );

  test(
    'cancelled and thrown signing do not create phantom history and allow retry',
    () async {
      await configure();
      expect((await execute((_) async => null)).error, isTrue);
      expect(provider.transactions, isEmpty);
      expect(
        (await execute((_) async => throw StateError('signing failed'))).error,
        isTrue,
      );
      expect(provider.transactions, isEmpty);
      expect((await execute((_) async => '0xretry')).error, isFalse);
      expect(provider.transactions.single.txHash, '0xretry');
    },
  );

  test(
    'broadcast completed after disposal is persisted for restoration',
    () async {
      await configure();
      final result = await execute((_) async {
        dispose();
        return '0xlate-broadcast';
      });
      expect(result.error, isFalse);
      expect(result.data, '0xlate-broadcast');
      final restored = BridgeProvider(lifiApi: api);
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.transactions.single.txHash, '0xlate-broadcast');
      expect(restored.transactions.single.fromAmount, '1.000000000000000001');
      expect(
        restored.transactions.single.status,
        BridgeTransactionStatus.pending,
      );
    },
  );

  test('empty broadcast hash never creates a pending transaction', () async {
    await configure();
    expect((await execute((_) async => '')).error, isTrue);
    expect(provider.transactions, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bridge_transactions_v1'), isNull);
  });

  test('sufficient hexadecimal allowance skips approval signing', () async {
    await configure(native: false);
    api.allowance = () async => ok({'allowance': '0xde0b6b3a7640001'});
    var signs = 0;
    expect(
      (await execute((_) async {
        signs++;
        return '0xsent';
      })).error,
      isFalse,
    );
    expect(signs, 1);
    expect(api.approvalAmounts, isEmpty);
  });

  testWidgets(
    'approval requests exact amount and waits for allowance before bridge send',
    (tester) async {
      await configure(native: false);
      api.allowance = () async => ok({
        'allowance': api.allowanceCalls == 1 ? '0' : '1000000000000000001',
      });
      final sends = <Map<String, dynamic>>[];
      final result = execute((tx) async {
        sends.add(tx);
        return sends.length == 1 ? '0xapproval' : '0xbridge';
      });
      await tester.pump();
      expect(sends, hasLength(1));
      expect(provider.state, BridgeState.approving);
      expect(api.approvalAmounts, ['1000000000000000001']);
      await tester.pump(const Duration(seconds: 3));
      expect((await result).error, isFalse);
      expect(sends, hasLength(2));
      expect(provider.transactions.single.txHash, '0xbridge');
      provider.stopPolling();
    },
  );

  testWidgets('approval timeout never signs the bridge transaction', (
    tester,
  ) async {
    await configure(native: false);
    var sends = 0;
    final result = execute((_) async {
      sends++;
      return '0xapproval';
    });
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(seconds: 3));
    }
    expect((await result).data, 'Approval not confirmed in time');
    expect(sends, 1);
    expect(provider.transactions, isEmpty);
  });

  test(
    'disposing during approval transaction lookup prevents any signature',
    () async {
      await configure(native: false);
      final pending = Completer<MessageModel>();
      api.approval = () => pending.future;
      var sends = 0;
      final result = execute((_) async {
        sends++;
        return '0xapproval';
      });
      await Future<void>.delayed(Duration.zero);
      dispose();
      pending.complete(ok({'to': '0xtoken'}));
      expect((await result).error, isTrue);
      expect(sends, 0);
    },
  );

  test(
    'changing token while checking allowance prevents approval signing',
    () async {
      await configure(native: false);
      final pending = Completer<MessageModel>();
      api.allowance = () => pending.future;
      var sends = 0;
      final result = execute((_) async {
        sends++;
        return '0xapproval';
      });
      await Future<void>.delayed(Duration.zero);
      provider.setFromToken(token(1));
      pending.complete(ok({'allowance': '0'}));
      expect((await result).data, 'Bridge selection changed');
      expect(sends, 0);
    },
  );

  test(
    'concurrent status polls deduplicate and terminal callback fires once',
    () async {
      await configure();
      await execute((_) async => '0xsent');
      final pending = Completer<MessageModel>();
      api.status = () => pending.future;
      final callbacks = <BridgeTransactionStatus>[];
      provider.onStatusChanged = (_, state) => callbacks.add(state);
      final original = provider.transactions.single;
      final first = provider.checkTransactionStatus(original);
      await provider.checkTransactionStatus(original);
      expect(api.statusCalls, 1);
      pending.complete(
        ok(
          BridgeStatusResponse(
            status: BridgeTransactionStatus.completed,
            destinationTxHash: '0xdestination',
          ),
        ),
      );
      await first;
      await provider.checkTransactionStatus(original);
      await provider.refreshPendingTransactions();
      expect(api.statusCalls, 1);
      expect(callbacks, [BridgeTransactionStatus.completed]);
      expect(provider.transactions.single.destinationTxHash, '0xdestination');
    },
  );

  test(
    'status transport failure preserves history and releases poll for retry',
    () async {
      await configure();
      await execute((_) async => '0xsent');
      api.status = () async => throw StateError('offline');
      await provider.refreshPendingTransactions();
      expect(
        provider.transactions.single.status,
        BridgeTransactionStatus.pending,
      );
      api.status = () async =>
          ok(BridgeStatusResponse(status: BridgeTransactionStatus.failed));
      await provider.refreshPendingTransactions();
      expect(
        provider.transactions.single.status,
        BridgeTransactionStatus.failed,
      );
      expect(api.statusCalls, 2);
    },
  );

  testWidgets(
    'persisted pending transaction resumes polling and terminal history is retained',
    (tester) async {
      final tx = BridgeTransaction(
        txHash: '0xrestored',
        fromChainId: 1,
        toChainId: 42161,
        fromToken: token(1),
        toToken: token(42161),
        fromAmount: '1',
        toAmount: '0.9',
        fromAddress: 'alice',
        toAddress: 'bob',
        status: BridgeTransactionStatus.pending,
        createdAt: DateTime(2026),
        bridgeTool: 'bridge',
      );
      SharedPreferences.setMockInitialValues({
        'bridge_transactions_v1': jsonEncode([tx.toJson()]),
      });
      api.status = () async =>
          ok(BridgeStatusResponse(status: BridgeTransactionStatus.completed));
      await provider.initialize();
      expect(provider.transactions.single.txHash, '0xrestored');
      await tester.pump(const Duration(seconds: 10));
      expect(api.statusCalls, 1);
      expect(
        provider.transactions.single.status,
        BridgeTransactionStatus.completed,
      );
      await tester.pump(const Duration(seconds: 10));
      expect(api.statusCalls, 1);
    },
  );

  test(
    'corrupt persisted history is ignored without partially restoring records',
    () async {
      final valid = BridgeTransaction(
        txHash: '0xvalid',
        fromChainId: 1,
        toChainId: 42161,
        fromToken: token(1),
        toToken: token(42161),
        fromAmount: '1',
        toAmount: '0.9',
        fromAddress: 'alice',
        toAddress: 'bob',
        status: BridgeTransactionStatus.completed,
        createdAt: DateTime(2026),
      );
      SharedPreferences.setMockInitialValues({
        'bridge_transactions_v1': jsonEncode([
          valid.toJson(),
          {'fromChainId': 'invalid'},
        ]),
      });
      await provider.initialize();
      expect(provider.transactions, isEmpty);
      expect(provider.state, BridgeState.idle);
    },
  );
}
