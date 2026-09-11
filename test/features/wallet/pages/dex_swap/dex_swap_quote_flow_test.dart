import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_action_buttons.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_form_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_token_card.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_token_select.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';
import '../../../../helpers/test_current_user.dart';

const owner = '0x0000000000000000000000000000000000000011';
const native = '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';
const router = '0x111111125421ca6dc452d289314280a0f8842a65';

class _Request {
  final String amount;
  final String owner;
  final int slippage;
  final result = Completer<MessageModel>();
  _Request(this.amount, this.owner, this.slippage);

  void succeed({
    String? value,
    String chain = 'ETH',
    String to = router,
    String data = '0x1234',
  }) {
    result.complete(
      MessageModel()
        ..data = {
          'chain': chain,
          'order_id': 'order-$amount-$slippage',
          'amount_out_raw': '1000000',
          'tx_value': value ?? amount,
          'calldata': data,
          'router_addr': to,
        },
    );
  }
}

class _Api extends DexSwapApi {
  final commits = <(String, String, String)>[];
  Future<MessageModel> Function() record = () async =>
      MessageModel()..data = true;
  @override
  Future<MessageModel> commit(String uuid, String orderId, String txHash) {
    commits.add((uuid, orderId, txHash));
    return record();
  }

  final requests = <_Request>[];
  @override
  Future<MessageModel> getQuote({
    required String chain,
    required String tokenIn,
    required String tokenOut,
    required String amountIn,
    required String userAddr,
    int slippageBps = 50,
  }) {
    final request = _Request(amountIn, userAddr, slippageBps);
    requests.add(request);
    return request.result.future;
  }
}

class _Sender extends ChainSender {
  final params = <SendParams>[];
  Future<SendResult> Function() result = () async =>
      const SendResult.fail('Unexpected send');
  @override
  Future<SendResult> send(SendParams value) {
    params.add(value);
    return result();
  }
}

class _Fixture {
  final sender = _Sender();
  final user = TestCurrentUser();
  final api = _Api();
  final coin = CoinModel()
    ..address = owner
    ..coin = {
      'coinType': 'ETH',
      'blockchainType': 'Ethereum',
      'contract': '',
      'unit': 'ETH',
      'decimals': 18,
      'path': {'legacy': "m/44'/60'/0'/0/0"},
    };
  final wap = WalletActionProvider()..walletIndex = 0;

  _Fixture() {
    wap.walletInfoList.add(WalletInfo()..timestamp = 'wallet');
    wap.coinModels.add(coin);
  }

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        DexSwapHome(api: api, senderForChain: (_) => sender),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => wap),
          currentUserProvider.overrideWith((ref) => user),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await token(tester, 0, native, 'ETH', 18);
    await token(tester, 1, '0xtoken', 'USDC', 6);
  }

  Future<void> token(
    WidgetTester tester,
    int index,
    String address,
    String symbol,
    int decimals, {
    String chain = 'ETH',
  }) async {
    tester
        .widget<DexTokenCard>(find.byType(DexTokenCard).at(index))
        .onTokenTap();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(DexTokenSelect))).pop(
      DexTokenModel(
        address: address,
        symbol: symbol,
        name: symbol,
        logoUri: '',
        decimals: decimals,
        chain: chain,
      ),
    );
    await tester.pumpAndSettle();
  }

  DexActionButtons buttons(WidgetTester tester) =>
      tester.widget<DexActionButtons>(find.byType(DexActionButtons));

  Future<void> amount(WidgetTester tester, String amount) async {
    tester
            .widget<DexTokenCard>(find.byType(DexTokenCard).first)
            .controller!
            .text =
        amount;
    await tester.pump(const Duration(milliseconds: 650));
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> ready(WidgetTester tester, _Fixture f) async {
    await f.mount(tester);
    await f.amount(tester, '1.000000000000000001');
    f.api.requests.single.succeed(
      data: '0x04e45aaf${'0' * (64 * 3)}${owner.substring(2).padLeft(64, '0')}',
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'EOA execution sends exact wei, selected derivation path and records the order',
    (tester) async {
      final f = _Fixture();
      f.coin.pathIndex = 3;
      f.sender.result = () async => const SendResult.ok('0xbroadcast');
      await ready(tester, f);
      final q = f.buttons(tester).quote!;
      f.buttons(tester).onSwapConfirmed(q);
      await tester.pumpAndSettle();
      final params = f.sender.params.single;
      expect(params.valueWeiOverride, BigInt.parse('1000000000000000001'));
      expect(params.fromAddress, owner);
      expect(params.toAddress, router);
      expect(params.path, "m/44'/60'/0'/0/3");
      expect(params.coinType, 'ETH');
      expect(params.calldata, q.calldata);
      expect(params.chainConfig, same(f.coin.coin));
      expect(f.api.commits, [('alice', q.orderId, '0xbroadcast')]);
      expect(f.buttons(tester).quote, isNull);
      expect(find.text(S.current.g_key_dex_swap_success), findsOneWidget);
      await f.dispose(tester);
    },
  );

  testWidgets(
    'send failure releases loading without recording a phantom swap',
    (tester) async {
      final f = _Fixture();
      f.sender.result = () async => const SendResult.fail('User cancelled');
      await ready(tester, f);
      final q = f.buttons(tester).quote!;
      f.buttons(tester).onSwapConfirmed(q);
      await tester.pumpAndSettle();
      expect(find.text('User cancelled'), findsOneWidget);
      expect(f.buttons(tester).quote, same(q));
      expect(f.api.commits, isEmpty);
      f.sender.result = () async => throw StateError('sender failed');
      f.buttons(tester).onSwapConfirmed(q);
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_dex_execution_invalid), findsOneWidget);
      expect(f.api.commits, isEmpty);
      await f.dispose(tester);
    },
  );

  testWidgets('missing derivation path stops before sending', (tester) async {
    final f = _Fixture();
    f.coin.coin.remove('path');
    await ready(tester, f);
    f.buttons(tester).onSwapConfirmed(f.buttons(tester).quote!);
    await tester.pumpAndSettle();
    expect(f.sender.params, isEmpty);
    expect(f.api.commits, isEmpty);
    expect(find.text(S.current.g_key_175), findsOneWidget);
    await f.dispose(tester);
  });

  for (final throwsError in [false, true]) {
    testWidgets(
      'recording failure (throws=$throwsError) cannot re-enable a broadcast quote',
      (tester) async {
        final f = _Fixture();
        f.sender.result = () async => const SendResult.ok('0xbroadcast');
        f.api.record = () async {
          if (throwsError) throw StateError('history offline');
          return MessageModel.error()..data = 'history offline';
        };
        await ready(tester, f);
        final confirmed = f.buttons(tester).quote!;
        f.buttons(tester).onSwapConfirmed(confirmed);
        await tester.pumpAndSettle();
        expect(
          find.textContaining(S.current.g_dex_history_record_failed),
          findsOneWidget,
        );
        expect(find.textContaining('0xbroadcast'), findsOneWidget);
        expect(f.buttons(tester).quote, isNull);
        f.buttons(tester).onSwapConfirmed(confirmed);
        await tester.pumpAndSettle();
        expect(f.sender.params, hasLength(1));
        expect(f.api.commits, hasLength(1));
        await f.dispose(tester);
      },
    );
  }

  testWidgets(
    'a missing broadcast hash cannot become a successful history record',
    (tester) async {
      final f = _Fixture();
      f.sender.result = () async => const SendResult.ok(null);
      await ready(tester, f);
      f.buttons(tester).onSwapConfirmed(f.buttons(tester).quote!);
      await tester.pumpAndSettle();
      expect(f.api.commits, isEmpty);
      expect(f.buttons(tester).quote, isNull);
      expect(find.text(S.current.g_key_dex_swap_success), findsNothing);
      await f.dispose(tester);
    },
  );

  testWidgets(
    'account changes during broadcast do not record the swap under the new user',
    (tester) async {
      final f = _Fixture();
      final pending = Completer<SendResult>();
      f.sender.result = () => pending.future;
      await ready(tester, f);
      final q = f.buttons(tester).quote!;
      f.buttons(tester).onSwapConfirmed(q);
      await tester.pump();
      f.user.select('bob');
      await tester.pump();
      pending.complete(const SendResult.ok('0xbroadcast'));
      await tester.pumpAndSettle();
      expect(f.api.commits, [('alice', q.orderId, '0xbroadcast')]);
      expect(find.text(S.current.g_key_dex_swap_success), findsNothing);
      await f.dispose(tester);
    },
  );

  testWidgets('successful broadcast is recorded after the page closes', (
    tester,
  ) async {
    final f = _Fixture();
    final pending = Completer<SendResult>();
    f.sender.result = () => pending.future;
    await ready(tester, f);
    final q = f.buttons(tester).quote!;
    f.buttons(tester).onSwapConfirmed(q);
    await tester.pump();
    await f.dispose(tester);
    pending.complete(const SendResult.ok('0xlate-broadcast'));
    await tester.pumpAndSettle();
    expect(f.api.commits, [('alice', q.orderId, '0xlate-broadcast')]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late amount response cannot overwrite the newest quote', (
    tester,
  ) async {
    final f = _Fixture();
    await f.mount(tester);
    await f.amount(tester, '1');
    await f.amount(tester, '2');
    expect(f.api.requests.map((r) => r.amount), [
      '1000000000000000000',
      '2000000000000000000',
    ]);
    f.api.requests.last.succeed();
    await tester.pumpAndSettle();
    final current = f.buttons(tester).quote;
    expect(current!.amountIn, '2');
    f.api.requests.first.succeed();
    await tester.pumpAndSettle();
    expect(f.buttons(tester).quote, same(current));
    await f.dispose(tester);
  });

  testWidgets(
    'editing amount invalidates a displayed confirmation immediately',
    (tester) async {
      final f = _Fixture();
      await f.mount(tester);
      await f.amount(tester, '1');
      f.api.requests.single.succeed();
      await tester.pumpAndSettle();
      final confirmed = f.buttons(tester).quote!;
      tester
              .widget<DexTokenCard>(find.byType(DexTokenCard).first)
              .controller!
              .text =
          '2';
      await tester.pump();
      expect(f.buttons(tester).quote, isNull);
      f.buttons(tester).onSwapConfirmed(confirmed);
      await tester.pump();
      expect(find.text(S.current.g_audit_quote_changed), findsOneWidget);
      await f.dispose(tester);
    },
  );

  testWidgets('slippage change requotes once and ignores the older request', (
    tester,
  ) async {
    final f = _Fixture();
    await f.mount(tester);
    await f.amount(tester, '1');
    tester.widget<DexSlippageRow>(find.byType(DexSlippageRow)).onChanged(100);
    await tester.pump();
    expect(f.api.requests.map((r) => r.slippage), [50, 100]);
    f.api.requests.first.succeed();
    await tester.pump();
    expect(f.buttons(tester).quote, isNull);
    f.api.requests.last.succeed();
    await tester.pumpAndSettle();
    expect(f.buttons(tester).quote!.orderId, endsWith('-100'));
    tester.widget<DexSlippageRow>(find.byType(DexSlippageRow)).onChanged(100);
    await tester.pump();
    expect(f.api.requests, hasLength(2));
    await f.dispose(tester);
  });

  testWidgets(
    'wallet address change requotes and rejects previous account response',
    (tester) async {
      final f = _Fixture();
      await f.mount(tester);
      await f.amount(tester, '1');
      f.coin.address = '0x0000000000000000000000000000000000000033';
      f.wap.refresh();
      await tester.pump();
      expect(f.api.requests, hasLength(2));
      expect(f.api.requests.last.owner, f.coin.address);
      f.api.requests.last.succeed();
      await tester.pumpAndSettle();
      f.api.requests.first.succeed();
      await tester.pumpAndSettle();
      expect(f.buttons(tester).quote!.accountAddress, f.coin.address);
      await f.dispose(tester);
    },
  );

  testWidgets('changing network clears tokens and ignores a pending quote', (
    tester,
  ) async {
    final f = _Fixture();
    await f.mount(tester);
    await f.amount(tester, '1');
    tester
        .widget<DexChainChips>(find.byType(DexChainChips))
        .onChainChanged('BSC');
    await tester.pump();
    f.api.requests.single.succeed();
    await tester.pumpAndSettle();
    expect(f.buttons(tester).quote, isNull);
    final cards = tester.widgetList<DexTokenCard>(find.byType(DexTokenCard));
    expect(cards.every((c) => c.token == null), isTrue);
    expect(cards.first.controller!.text, isEmpty);
    await f.dispose(tester);
  });

  testWidgets('testnet and wrong-chain token cannot request mainnet quotes', (
    tester,
  ) async {
    final f = _Fixture();
    f.coin.isTest = true;
    await f.mount(tester);
    await f.amount(tester, '1');
    await tester.pump();
    expect(f.api.requests, isEmpty);
    expect(find.text(S.current.g_dex_account_unavailable), findsOneWidget);
    f.coin.isTest = false;
    await f.token(tester, 1, '0xtoken', 'USDC', 6, chain: 'BSC');
    await tester.pump(const Duration(milliseconds: 650));
    expect(f.api.requests, isEmpty);
    expect(find.text(S.current.g_dex_execution_invalid), findsOneWidget);
    await f.dispose(tester);
  });

  testWidgets('quote service failure can recover when the amount is retried', (
    tester,
  ) async {
    final f = _Fixture();
    await f.mount(tester);
    await f.amount(tester, '1');
    f.api.requests.single.result.complete(
      MessageModel.error()..data = 'Service unavailable',
    );
    await tester.pumpAndSettle();
    expect(find.text('Service unavailable'), findsOneWidget);
    expect(f.buttons(tester).quote, isNull);
    await f.amount(tester, '2');
    f.api.requests.last.succeed();
    await tester.pumpAndSettle();
    expect(find.text('Service unavailable'), findsNothing);
    expect(f.buttons(tester).quote!.amountIn, '2');
    await f.dispose(tester);
  });

  for (final badValue in ['-1', '1.5', '0']) {
    testWidgets(
      'native quote with invalid transaction value $badValue is rejected',
      (tester) async {
        final f = _Fixture();
        await f.mount(tester);
        await f.amount(tester, '1');
        f.api.requests.single.succeed(value: badValue);
        await tester.pumpAndSettle();
        expect(f.buttons(tester).quote, isNull);
        expect(find.text(S.current.g_key_dex_quote_failed), findsOneWidget);
        await f.dispose(tester);
      },
    );
  }

  testWidgets('untrusted router cannot advance to signing', (tester) async {
    final f = _Fixture();
    await f.mount(tester);
    await f.amount(tester, '1');
    f.api.requests.single.succeed(
      to: '0x00000000000000000000000000000000000000ff',
    );
    await tester.pumpAndSettle();
    final buttons = f.buttons(tester);
    buttons.onSwapConfirmed(buttons.quote!);
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_key_dex_untrusted_router), findsOneWidget);
    expect(find.byType(DexSwapHome), findsOneWidget);
    await f.dispose(tester);
  });

  testWidgets('trusted router with a foreign output recipient is blocked', (
    tester,
  ) async {
    final f = _Fixture();
    await f.mount(tester);
    await f.amount(tester, '1');
    final foreign = '00000000000000000000000000000000000000ff'.padLeft(64, '0');
    f.api.requests.single.succeed(data: '0x04e45aaf${'0' * (64 * 3)}$foreign');
    await tester.pumpAndSettle();
    final buttons = f.buttons(tester);
    buttons.onSwapConfirmed(buttons.quote!);
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_key_dex_untrusted_router), findsOneWidget);
    expect(find.byType(DexSwapHome), findsOneWidget);
    await f.dispose(tester);
  });

  testWidgets(
    'disposing during a quote request ignores its eventual response',
    (tester) async {
      final f = _Fixture();
      await f.mount(tester);
      await f.amount(tester, '1');
      await f.dispose(tester);
      f.api.requests.single.succeed();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
