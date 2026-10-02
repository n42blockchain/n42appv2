import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import '../../../helpers/widget_test_helpers.dart';

class _FailingSwapAstApi extends SwapAstApi {
  int listRequests = 0;

  @override
  Future<MessageModel> getNftOrAstList(int type) async {
    listRequests++;
    return MessageModel.error()..data = 'synthetic offline';
  }
}

class _WalletStore extends WalletActionProvider {
  _WalletStore(this.map);

  final Map<String, dynamic> map;

  @override
  Map<String, dynamic> get walletMap => map;
}

void main() {
  late _WalletStore walletStore;
  late _FailingSwapAstApi swapApi;

  setUp(() {
    walletStore = _WalletStore({
      'ETH': {
        'mainnets': {
          '0XTOKEN': {'symbol': 'USDC'},
        },
      },
    });
    swapApi = _FailingSwapAstApi();
  });

  Future<dynamic> open(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTest(
        SwapAstHome(swapAstApiForTesting: swapApi),
        overrides: [wapBridgeProvider.overrideWith((ref) => walletStore)],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return tester.state(find.byType(SwapAstHome));
  }

  SwapAstModel payOption({double price = 2, double balance = 12}) =>
      SwapAstModel(
          7,
          'AST',
          'Synthetic option',
          '',
          100,
          'ETH',
          'USDC',
          '0xToken',
          6,
          'uuid',
          '0xRecipient',
          2,
          0,
          0,
          0,
        )
        ..price = price
        ..balance = balance;

  testWidgets('failed catalogue load renders an error and retries on demand', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('synthetic offline'), findsOneWidget);
    expect(swapApi.listRequests, 1);
    await tester.tap(find.text(S.current.g_swap_key_6));
    await tester.pumpAndSettle();

    expect(swapApi.listRequests, 2);
    expect(find.text('synthetic offline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('amount entry converts by price and checks available balance', (
    tester,
  ) async {
    final dynamic state = await open(tester);
    state.youPay = payOption();
    state.getCoinModel = CoinModel()..coinPrice = 5;

    state.payInput(value: '2');
    expect(state.getTextEditingController.text, '0.8');
    state.getInput(value: '1.25');
    expect(state.payTextEditingController.text, '3.125');

    state.getInput(value: 'Infinity');
    expect(state.payTextEditingController.text, '3.125');
    expect(state.checkPayInput(), isTrue);
    state.payTextEditingController.text = '13';
    expect(state.checkPayInput(), isFalse);
    state.payTextEditingController.text = 'not-an-amount';
    expect(state.checkPayInput(), isFalse);

    state.load = Load.finish;
    state.youPay.balance = 12.0;
    state.percentTap(25);
    expect(state.payTextEditingController.text, '3.0');
    expect(state.getTextEditingController.text, '1.2');

    state.payTextEditingController.text = 'unchanged';
    state.youPay.balance = 0.0;
    state.percentTap(50);
    expect(state.payTextEditingController.text, 'unchanged');
    expect(tester.takeException(), isNull);
  });

  testWidgets('price data and token lookup use normalized coin keys', (
    tester,
  ) async {
    final dynamic state = await open(tester);
    state.youPay = payOption(price: 4);
    state.getCoinModel = CoinModel();
    state.coinMarketInfo = [
      {'coin': 'N', 'price': '2'},
      {'coin': 'usdc', 'price': 4},
    ];

    expect(state.setCoinModelPrice(), isTrue);
    expect(state.getCoinModel.coinPrice, 2);
    expect(state.youPay.price, 4);

    state.getUsdtMap('eth', '0xtoken');
    expect(state.token['symbol'], 'USDC');
    state.getUsdtMap('ETH', '');
    expect(state.token, isNull);
    expect(tester.takeException(), isNull);
  });
}
