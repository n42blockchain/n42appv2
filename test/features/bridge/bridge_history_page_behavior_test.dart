import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_history_page.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _HistoryProvider extends BridgeProvider {
  final entries = <BridgeTransaction>[];
  int statusChecks = 0;
  int refreshes = 0;

  @override
  List<BridgeTransaction> get transactions => entries;

  @override
  Future<void> checkTransactionStatus(BridgeTransaction transaction) async {
    statusChecks++;
  }

  @override
  Future<void> refreshPendingTransactions() async {
    refreshes++;
  }
}

BridgeToken _token(int chainId, String symbol) => BridgeToken(
  address: '0x0000000000000000000000000000000000000000',
  symbol: symbol,
  name: symbol,
  decimals: 18,
  chainId: chainId,
  logoUri: '',
);

BridgeTransaction _transaction({
  required String hash,
  required BridgeTransactionStatus status,
  String? destinationHash,
  String? bridgeTool,
}) => BridgeTransaction(
  txHash: hash,
  fromChainId: BridgeChainIds.ethereum,
  toChainId: BridgeChainIds.arbitrum,
  fromToken: _token(BridgeChainIds.ethereum, 'ETH'),
  toToken: _token(BridgeChainIds.arbitrum, 'ARB'),
  fromAmount: '0.25',
  toAmount: '0.24',
  fromAddress: '0xsender',
  toAddress: '0xrecipient',
  status: status,
  createdAt: DateTime(2026, 10, 2, 3, 4),
  destinationTxHash: destinationHash,
  bridgeTool: bridgeTool,
);

void main() {
  late _HistoryProvider provider;
  setUp(() => provider = _HistoryProvider());
  tearDown(() => provider.dispose());

  testWidgets('empty history offers the localized empty state', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(Scaffold(body: BridgeHistoryPage(provider: provider))),
    );

    final context = tester.element(find.byType(BridgeHistoryPage));
    expect(find.text(S.of(context).g_key_132), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'transaction statuses render details and pending action checks status',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      provider.entries.addAll([
        _transaction(
          hash: '0x1234567890abcdef1234567890abcdef12345678',
          status: BridgeTransactionStatus.pending,
          bridgeTool: 'Across',
        ),
        _transaction(
          hash: '0xabcdef1234567890abcdef1234567890abcdef12',
          status: BridgeTransactionStatus.completed,
          destinationHash: '0xfedcba0987654321fedcba0987654321fedcba09',
        ),
        _transaction(
          hash: '0x1111111111111111',
          status: BridgeTransactionStatus.inProgress,
        ),
        _transaction(
          hash: '0x2222222222222222',
          status: BridgeTransactionStatus.failed,
        ),
      ]);
      await tester.pumpWidget(
        wrapForTest(Scaffold(body: BridgeHistoryPage(provider: provider))),
      );

      final context = tester.element(find.byType(BridgeHistoryPage));
      final l10n = S.of(context);
      expect(find.text(l10n.g_key_bridge_status_pending), findsOneWidget);
      expect(find.text(l10n.g_key_bridge_status_in_progress), findsOneWidget);
      expect(find.text(l10n.g_key_bridge_status_completed), findsOneWidget);
      expect(find.text(l10n.g_key_bridge_status_failed), findsOneWidget);
      expect(find.text('Across'), findsOneWidget);
      expect(find.text('Dest: '), findsOneWidget);
      expect(find.text('0x123456...345678'), findsOneWidget);

      await tester.tap(find.text(l10n.g_key_bridge_refresh).first);
      await tester.pump();
      expect(provider.statusChecks, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pull to refresh asks provider to refresh pending transactions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(Scaffold(body: BridgeHistoryPage(provider: provider))),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(provider.refreshes, 1);
    expect(tester.takeException(), isNull);
  });
}
