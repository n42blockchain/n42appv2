import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_order_model.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_transaction_detail.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import '../../../helpers/widget_test_helpers.dart';

class _SwapAstApi extends SwapAstApi {
  _SwapAstApi(this.response);

  final Future<MessageModel> Function(int orderId) response;
  final requestedOrderIds = <int>[];

  @override
  Future<MessageModel> getNftOrAstDetail(int orderId) {
    requestedOrderIds.add(orderId);
    return response(orderId);
  }
}

SwapAstOrderModel _order({int state = 0}) => SwapAstOrderModel()
  ..id = 73
  ..orderNum = 2.5
  ..orderPrice = 3.75
  ..payNum = 12.5
  ..payCoin = 'USDT'
  ..payTx = '0xfeed'
  ..orderState = state
  ..type = 2
  ..created = 1_696_000_000;

Map<String, dynamic> _detail({required int state}) => {
  'id': 73,
  'order_num': 2.5,
  'order_price': 3.75,
  'pay_num': 12.5,
  'pay_coin': 'USDT',
  'pay_tx': '0xfeed',
  'order_state': state,
  'type': 2,
  'created': 1_696_000_000,
};

void main() {
  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    required _SwapAstApi api,
    int initialState = 0,
  }) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      wrapForTest(
        SwapAstTransactionDetail(
          _order(state: initialState),
          swapAstApiForTesting: api,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('processing response displays payment status and order details', (
    tester,
  ) async {
    final api = _SwapAstApi(
      (_) async => MessageModel()..data = _detail(state: 0),
    );
    await pumpDetail(tester, api: api);

    final context = tester.element(find.byType(SwapAstTransactionDetail));
    expect(api.requestedOrderIds, [73]);
    expect(find.text(S.of(context).g_swap_key_24), findsOneWidget);
    expect(find.text('USDT/N'), findsOneWidget);
    expect(find.text('+2.5'), findsOneWidget);
    expect(find.text('12.5 USDT'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('success response displays completion and paid order amounts', (
    tester,
  ) async {
    final api = _SwapAstApi(
      (_) async => MessageModel()..data = _detail(state: 5),
    );
    await pumpDetail(tester, api: api, initialState: 0);

    final context = tester.element(find.byType(SwapAstTransactionDetail));
    expect(find.text(S.of(context).g_swap_key_18), findsOneWidget);
    expect(find.text('3.75N', findRichText: true), findsOneWidget);
    expect(find.text('12.5 USDT'), findsOneWidget);
    expect(find.text('2.5 N'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed detail response keeps the supplied order visible', (
    tester,
  ) async {
    final api = _SwapAstApi(
      (_) async => MessageModel.error()..data = 'offline',
    );
    await pumpDetail(tester, api: api, initialState: 0);

    expect(api.requestedOrderIds, [73]);
    expect(find.text('USDT/N'), findsOneWidget);
    expect(find.text('+2.5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
