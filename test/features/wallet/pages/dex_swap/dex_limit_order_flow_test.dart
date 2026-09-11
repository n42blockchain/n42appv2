import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_limit_order_form.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_limit_orders_page.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_token_select.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helpers/widget_test_helpers.dart';
import '../../../../helpers/test_current_user.dart';

MessageModel ok(dynamic data) => MessageModel()..data = data;
Map<String, dynamic> order(
  String id, {
  int status = 0,
  String hash = '',
  String symbol = 'ETH',
}) => {
  'order_id': id,
  'chain': 'ETH',
  'symbol_in': symbol,
  'symbol_out': 'USDC',
  'amount_in': '1.000000000000000001',
  'limit_price': '3000',
  'status': status,
  'tx_hash': hash,
  'created_at': 1700000000,
  'expires_at': 1800000000,
};

class _Api extends DexSwapApi {
  final creates = <Map<String, dynamic>>[];
  final queries = <String>[];
  final cancellations = <(String, String)>[];
  Future<MessageModel> Function(String) list = (_) async => ok([]);
  Future<MessageModel> Function() create = () async => ok(true);
  Future<MessageModel> Function() cancel = () async => ok(true);
  @override
  Future<MessageModel> createLimitOrder({
    required String uuid,
    required String chain,
    required String tokenIn,
    required String tokenOut,
    required String symbolIn,
    required String symbolOut,
    required String amountIn,
    required String limitPrice,
    int expiresIn = 86400,
  }) {
    creates.add({
      'uuid': uuid,
      'chain': chain,
      'in': tokenIn,
      'out': tokenOut,
      'amount': amountIn,
      'price': limitPrice,
      'expiry': expiresIn,
    });
    return create();
  }

  @override
  Future<MessageModel> getLimitOrders(
    String uuid, {
    int page = 1,
    int size = 20,
  }) {
    queries.add(uuid);
    return list(uuid);
  }

  @override
  Future<MessageModel> cancelLimitOrder(String orderId, String uuid) {
    cancellations.add((orderId, uuid));
    return cancel();
  }
}

void main() {
  late _Api api;
  late TestCurrentUser user;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = _Api();
    user = TestCurrentUser();
  });

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child,
          ),
        ),
        locale: locale,
        overrides: [
          currentUserProvider.overrideWith((ref) => user),
          wapBridgeProvider.overrideWith((ref) {
            final wallet = WalletActionProvider()..walletIndex = 0;
            wallet.walletInfoList.add(WalletInfo()..timestamp = 'wallet');
            return wallet;
          }),
        ],
      ),
    );
    await tester.pump();
  }

  for (final locale in S.delegate.supportedLocales.where(
    (locale) => !['en', 'qps'].contains(locale.languageCode),
  )) {
    final language = locale.toLanguageTag();
    testWidgets(
      '$language limit-order form localizes controls on a narrow screen',
      (tester) async {
        await mount(
          tester,
          DexLimitOrderForm(chain: 'ETH', api: api),
          locale: locale,
          textScale: 1.4,
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(DexLimitOrderForm));
        final strings = S.of(context);
        expect(find.text(strings.g_ui_order_place), findsOneWidget);
        expect(find.text(strings.g_ui_expires_in), findsOneWidget);
        expect(find.text(strings.g_ui_hours('24')), findsOneWidget);
        expect(find.text('Place Limit Order'), findsNothing);
        expect(
          Directionality.of(context),
          ['ar', 'ur'].contains(locale.languageCode)
              ? TextDirection.rtl
              : TextDirection.ltr,
        );
        expect(tester.takeException(), isNull);
        expect(api.creates, isEmpty);
      },
    );
  }

  testWidgets(
    'switching English to Arabic updates labels without losing amount input',
    (tester) async {
      final form = DexLimitOrderForm(chain: 'ETH', api: api);
      await mount(tester, form);
      await tester.enterText(find.byType(TextField).first, '1.25');
      await mount(tester, form, locale: const Locale('ar'));
      await tester.pumpAndSettle();
      final strings = S.of(tester.element(find.byType(DexLimitOrderForm)));
      expect(find.text(strings.g_ui_order_place), findsOneWidget);
      expect(find.text('Place Limit Order'), findsNothing);
      expect(find.text('1.25'), findsOneWidget);
      expect(api.creates, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  Future<void> choose(
    WidgetTester tester,
    int index, {
    String? address,
    String chain = 'ETH',
  }) async {
    final row = find
        .ancestor(
          of: find.byIcon(Icons.chevron_right).at(index),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(DexTokenSelect))).pop(
      DexTokenModel(
        address:
            address ??
            (index == 0
                ? '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
                : '0xtoken'),
        symbol: index == 0 ? 'ETH' : 'USDC',
        name: 'token',
        logoUri: '',
        decimals: 18,
        chain: chain,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester) async {
    await choose(tester, 0);
    await choose(tester, 1);
    await tester.enterText(
      find.byType(TextField).first,
      '1.000000000000000001',
    );
    await tester.enterText(
      find.byType(TextField).last,
      '3000.000000000000000001',
    );
    tester.testTextInput.hide();
    await tester.pump();
  }

  ElevatedButton submit(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));
  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.pump();
    await tester.tap(find.text(text));
    await tester.pump();
  }

  testWidgets(
    'typing enables submission and preserves exact values and selected expiry',
    (tester) async {
      await mount(tester, DexLimitOrderForm(chain: 'ETH', api: api));
      expect(submit(tester).onPressed, isNull);
      await fill(tester);
      expect(submit(tester).onPressed, isNotNull);
      await tapText(tester, '7d');
      await tapText(tester, 'Place Limit Order');
      await tester.pumpAndSettle();
      expect(api.creates.single, {
        'uuid': 'alice',
        'chain': 'ETH',
        'in': '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
        'out': '0xtoken',
        'amount': '1.000000000000000001',
        'price': '3000.000000000000000001',
        'expiry': 604800,
      });
      expect(find.text('Limit order created'), findsOneWidget);
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .every((f) => f.controller!.text.isEmpty),
        isTrue,
      );
      expect(submit(tester).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'invalid decimal, excess precision and same token cannot submit',
    (tester) async {
      await mount(tester, DexLimitOrderForm(chain: 'ETH', api: api));
      await fill(tester);
      for (final invalid in [
        '0',
        '-1',
        'NaN',
        '1e3',
        '0.0000000000000000001',
      ]) {
        await tester.enterText(find.byType(TextField).first, invalid);
        await tester.pump();
        expect(submit(tester).onPressed, isNull, reason: invalid);
      }
      await tester.enterText(find.byType(TextField).first, '1');
      await tester.enterText(find.byType(TextField).last, '-1');
      await tester.pump();
      expect(submit(tester).onPressed, isNull);
      await tester.enterText(find.byType(TextField).last, '1');
      await choose(
        tester,
        1,
        address: '0x0000000000000000000000000000000000000000',
      );
      expect(submit(tester).onPressed, isNull);
      expect(api.creates, isEmpty);
    },
  );

  testWidgets(
    'submission freezes inputs and duplicate taps until failure permits retry',
    (tester) async {
      final pending = Completer<MessageModel>();
      api.create = () => pending.future;
      await mount(tester, DexLimitOrderForm(chain: 'ETH', api: api));
      await fill(tester);
      final action = submit(tester).onPressed!;
      action();
      action();
      await tester.pump();
      expect(api.creates, hasLength(1));
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .every((f) => f.enabled == false),
        isTrue,
      );
      expect(
        tester
            .widgetList<ChoiceChip>(find.byType(ChoiceChip))
            .every((c) => c.onSelected == null),
        isTrue,
      );
      pending.complete(MessageModel.error()..data = 'Server rejected');
      await tester.pumpAndSettle();
      expect(find.text('Server rejected'), findsOneWidget);
      expect(submit(tester).onPressed, isNotNull);
      api.create = () async => throw StateError('offline');
      submit(tester).onPressed!();
      await tester.pumpAndSettle();
      expect(find.text('Failed to create order'), findsOneWidget);
      expect(submit(tester).onPressed, isNotNull);
    },
  );

  testWidgets(
    'network change clears form and ignores in-flight submission response',
    (tester) async {
      final chain = ValueNotifier('ETH');
      addTearDown(chain.dispose);
      final pending = Completer<MessageModel>();
      api.create = () => pending.future;
      await mount(
        tester,
        ValueListenableBuilder(
          valueListenable: chain,
          builder: (_, value, _) => DexLimitOrderForm(chain: value, api: api),
        ),
      );
      await fill(tester);
      submit(tester).onPressed!();
      await tester.pump();
      chain.value = 'BSC';
      await tester.pumpAndSettle();
      pending.complete(ok(true));
      await tester.pumpAndSettle();
      expect(find.text('Select'), findsNWidgets(2));
      expect(find.text('Limit order created'), findsNothing);
      expect(submit(tester).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'account change clears old form and anonymous user cannot place an order',
    (tester) async {
      await mount(tester, DexLimitOrderForm(chain: 'ETH', api: api));
      await fill(tester);
      user.select('bob');
      await tester.pumpAndSettle();
      expect(find.text('Select'), findsNWidgets(2));
      user.select('');
      await tester.pumpAndSettle();
      await fill(tester);
      expect(submit(tester).onPressed, isNull);
      expect(api.creates, isEmpty);
    },
  );

  testWidgets(
    'failed or malformed history shows retry instead of an empty account',
    (tester) async {
      api.list = (_) async => MessageModel.error()..data = 'offline';
      await mount(tester, DexLimitOrdersPage(api: api));
      await tester.pumpAndSettle();
      expect(find.text('Unable to load limit orders'), findsOneWidget);
      expect(find.text('No limit orders'), findsNothing);
      api.list = (_) async => ok([
        {'status': 'invalid'},
      ]);
      await tapText(tester, S.current.g_key_retry);
      await tester.pumpAndSettle();
      expect(find.text('Unable to load limit orders'), findsOneWidget);
      api.list = (_) async => ok([]);
      await tapText(tester, S.current.g_key_retry);
      await tester.pumpAndSettle();
      expect(find.text('No limit orders'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    },
  );

  testWidgets('overlapping history refresh keeps the newest response', (
    tester,
  ) async {
    final first = Completer<MessageModel>();
    api.list = (_) => first.future;
    await mount(tester, DexLimitOrdersPage(api: api));
    api.list = (_) async => ok([order('new', status: 2, symbol: 'NEW')]);
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    first.complete(ok([order('old', symbol: 'OLD')]));
    await tester.pumpAndSettle();
    expect(find.text('NEW → USDC'), findsOneWidget);
    expect(find.text('OLD → USDC'), findsNothing);
  });

  testWidgets(
    'changing account drops a late history response and resets cancellation',
    (tester) async {
      final pending = Completer<MessageModel>();
      api.list = (id) => id == 'alice'
          ? pending.future
          : Future.value(ok([order('bob', status: 2, symbol: 'BOB')]));
      await mount(tester, DexLimitOrdersPage(api: api));
      user.select('bob');
      await tester.pumpAndSettle();
      pending.complete(ok([order('alice', symbol: 'ALICE')]));
      await tester.pumpAndSettle();
      expect(find.text('BOB → USDC'), findsOneWidget);
      expect(find.text('ALICE → USDC'), findsNothing);
      expect(api.queries, ['alice', 'bob']);
      user.select('');
      await tester.pumpAndSettle();
      expect(find.text('No limit orders'), findsOneWidget);
      expect(api.queries, ['alice', 'bob']);
    },
  );

  testWidgets(
    'short hash and long symbol/amount fit the order card on a narrow screen',
    (tester) async {
      api.list = (_) async => ok([
        order('one', status: 2, hash: '0x1', symbol: 'VERY_LONG_TOKEN_SYMBOL'),
      ]);
      await mount(tester, DexLimitOrdersPage(api: api));
      await tester.pumpAndSettle();
      expect(find.text('0x1'), findsOneWidget);
      expect(find.text('Executed'), findsOneWidget);
      expect(find.text('Cancel Order'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancel submits once for the correct user and refreshes after success',
    (tester) async {
      final pending = Completer<MessageModel>();
      api.cancel = () => pending.future;
      api.list = (_) async => ok([order('one')]);
      await mount(tester, DexLimitOrdersPage(api: api));
      await tester.pumpAndSettle();
      final action = tester
          .widget<OutlinedButton>(find.byType(OutlinedButton))
          .onPressed!;
      action();
      action();
      await tester.pump();
      expect(api.cancellations, [('one', 'alice')]);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      api.list = (_) async => ok([order('one', status: 3)]);
      pending.complete(ok(true));
      await tester.pumpAndSettle();
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Order cancelled'), findsOneWidget);
      expect(api.queries, ['alice', 'alice']);
    },
  );

  testWidgets('limit tab, history and triggered order expose working routes', (
    tester,
  ) async {
    api.list = (_) async => ok([order('triggered', status: 1)]);
    await mount(tester, DexSwapHome(api: api));
    await tester.pumpAndSettle();
    await tapText(tester, 'Limit');
    await tester.pumpAndSettle();
    expect(find.byType(DexLimitOrderForm), findsOneWidget);
    expect(
      tester.widget<DexLimitOrderForm>(find.byType(DexLimitOrderForm)).api,
      same(api),
    );
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    expect(find.byType(DexLimitOrdersPage), findsOneWidget);
    expect(api.queries, ['alice']);
    await tapText(tester, 'Go to Swap');
    await tester.pumpAndSettle();
    expect(find.byType(DexSwapHome), findsOneWidget);
    expect(find.byType(DexLimitOrderForm), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(DexLimitOrdersPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(DexLimitOrderForm), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel failure and thrown error release the action for retry', (
    tester,
  ) async {
    api.list = (_) async => ok([order('one')]);
    api.cancel = () async => MessageModel.error()..data = 'Cannot cancel';
    await mount(tester, DexLimitOrdersPage(api: api));
    await tester.pumpAndSettle();
    await tapText(tester, 'Cancel Order');
    await tester.pumpAndSettle();
    expect(find.text('Cannot cancel'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );
    api.cancel = () async => throw StateError('offline');
    await tapText(tester, 'Cancel Order');
    await tester.pumpAndSettle();
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );
    expect(api.cancellations, hasLength(2));
  });
}
