import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_token_card.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_action_buttons.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_token_select.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/widget_test_helpers.dart';

class _Api extends DexSwapApi {
  final owners = <String>[];
  @override
  Future<MessageModel> getQuote({
    required String chain,
    required String tokenIn,
    required String tokenOut,
    required String amountIn,
    required String userAddr,
    int slippageBps = 50,
  }) async {
    owners.add(userAddr);
    return MessageModel()
      ..data = {
        'chain': chain,
        'order_id': 'fixture',
        'amount_out_raw': '1000000',
        'tx_value': amountIn,
        'calldata': '0x1234',
        'router_addr': '0x111111125421ca6dc452d289314280a0f8842a65',
      };
  }
}

const eoa = '0x0000000000000000000000000000000000000011';
const smart = '0x0000000000000000000000000000000000000022';

Future<void> select(
  WidgetTester tester,
  int index,
  String address,
  String symbol,
  int decimals,
) async {
  tester.widget<DexTokenCard>(find.byType(DexTokenCard).at(index)).onTokenTap();
  await tester.pumpAndSettle();
  Navigator.of(tester.element(find.byType(DexTokenSelect))).pop(
    DexTokenModel(
      address: address,
      symbol: symbol,
      name: symbol,
      logoUri: '',
      decimals: decimals,
      chain: 'ETH',
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets(
    'smart account selection requotes its owner and watch-only wallets cannot execute',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final wallet = WalletInfo()..timestamp = 'fixture-wallet';
      wallet.addSmartAccount(
        SmartAccount(
          address: smart,
          type: SmartAccountType.simpleAccount,
          ownerAddress: eoa,
          state: SmartAccountState.deployed,
          chainId: 1,
          salt: BigInt.zero,
          factoryAddress: '0xfactory',
          createdAt: DateTime(2026),
        ),
      );
      final coin = CoinModel()
        ..address = eoa
        ..coin = {
          'coinType': 'ETH',
          'blockchainType': 'Ethereum',
          'contract': '',
          'unit': 'ETH',
          'decimals': 18,
          'path': "m/44'/60'/0'/0/0",
        };
      final wap = WalletActionProvider()..walletIndex = 0;
      wap.walletInfoList.add(wallet);
      wap.coinModels.add(coin);
      final api = _Api();
      await tester.pumpWidget(
        wrapForTest(
          DexSwapHome(api: api),
          overrides: [wapBridgeProvider.overrideWith((ref) => wap)],
        ),
      );
      await tester.pumpAndSettle();
      await select(
        tester,
        0,
        '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
        'ETH',
        18,
      );
      await select(tester, 1, '0xtoken', 'USDC', 6);
      tester
              .widget<DexTokenCard>(find.byType(DexTokenCard).first)
              .controller!
              .text =
          '1.000000000000000001';
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(api.owners, [eoa]);
      tester.widget<Switch>(find.byType(Switch)).onChanged!(true);
      await tester.pumpAndSettle();
      expect(api.owners, [eoa, smart]);
      var buttons = tester.widget<DexActionButtons>(
        find.byType(DexActionButtons),
      );
      expect(buttons.quote!.accountAddress, smart);
      expect(buttons.quote!.txValue, '1000000000000000001');
      wallet.watchOnly = true;
      wap.refresh();
      await tester.pumpAndSettle();
      buttons = tester.widget<DexActionButtons>(find.byType(DexActionButtons));
      buttons.onSwapConfirmed(buttons.quote!);
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_dex_account_unavailable), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
