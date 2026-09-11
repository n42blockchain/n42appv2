import 'dart:io';
import 'dart:ui' as ui;
import 'package:n42_wallet/features/wallet/data/transaction_history_repository.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_query.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/profile/profile_home_page.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_confirm.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/wallet_activity_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_limit_order_form.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_limit_orders_page.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import '../helpers/test_current_user.dart';

Future<void> loadFont() async {
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  for (final path in [
    '/System/Library/Fonts/Supplemental/Arial.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    r'C:\Windows\Fonts\segoeui.ttf',
  ]) {
    final file = File(path);
    if (file.existsSync()) {
      await (FontLoader('WalletAuditFont')..addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())),
          ))
          .load();
      return;
    }
  }
}

void main() {
  setUpAll(loadFont);
  for (final dark in [false, true]) {
    for (final screen in [
      'profile',
      'swap-confirm',
      'activity',
      'asset-history',
      'limit-form',
      'limit-orders',
    ]) {
      testWidgets('$screen ${dark ? 'dark' : 'light'} has no layout errors', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = const Size(780, 1688);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final key = GlobalKey();
        final Widget page = switch (screen) {
          'profile' => const ProfileHomePage(),
          'activity' => const WalletActivityPage(),
          'limit-form' => Scaffold(
            appBar: AppBar(title: const Text('Limit Order')),
            body: DexLimitOrderForm(chain: 'ETH', api: _VisualLimitApi()),
          ),
          'limit-orders' => DexLimitOrdersPage(api: _VisualLimitApi()),
          'asset-history' => TransactionHistoryList(
            CoinModel()
              ..address = '0x0000000000000000000000000000000000000011'
              ..coin = {
                'coinType': 'ETH',
                'blockchainType': 'Ethereum',
                'unit': 'ETH',
                'decimals': 18,
              },
            repository: _VisualHistoryRepository(),
          ),
          _ => const DexSwapConfirm(
            quote: DexQuoteModel(
              orderId: 'visual-fixture',
              tokenInSymbol: 'WETH',
              tokenOutSymbol: 'USDC',
              amountIn: '0.125',
              amountOut: '312.123456',
              minAmountOut: '310.562838',
              priceImpact: '',
              gasEstimate: '~0.003 ETH',
              source: 'Uniswap V3',
              calldata: '',
              routerAddr: '',
              chain: 'ETH',
            ),
          ),
        };
        final base = dark
            ? ThemeAdapter.buildDark(ThemeAdapter.defaultAccent)
            : ThemeAdapter.buildLight(ThemeAdapter.defaultAccent);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              if (screen.startsWith('limit-'))
                currentUserProvider.overrideWith((ref) => TestCurrentUser()),
            ],
            child: ScreenUtilInit(
              designSize: const Size(750, 1334),
              minTextAdapt: true,
              builder: (_, _) => MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: AppGlobals.navigatorKey,
                locale: const Locale('en'),
                supportedLocales: S.delegate.supportedLocales,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: base.copyWith(
                  appBarTheme: base.appBarTheme.copyWith(
                    titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
                      fontFamily: 'WalletAuditFont',
                    ),
                    toolbarTextStyle: base.appBarTheme.toolbarTextStyle
                        ?.copyWith(fontFamily: 'WalletAuditFont'),
                  ),
                  textTheme: base.textTheme.apply(
                    fontFamily: 'WalletAuditFont',
                  ),
                  primaryTextTheme: base.primaryTextTheme.apply(
                    fontFamily: 'WalletAuditFont',
                  ),
                ),
                home: RepaintBoundary(key: key, child: page),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final output = Directory('test/screenshots/out/wallet-audit');
          output.createSync(recursive: true);
          File(
            '${output.path}/$screen-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
}

class _VisualLimitApi extends DexSwapApi {
  @override
  Future<MessageModel> getLimitOrders(
    String uuid, {
    int page = 1,
    int size = 20,
  }) async => MessageModel()
    ..data = [
      for (final status in [0, 1])
        {
          'order_id': 'visual-limit-$status',
          'chain': 'ETH',
          'symbol_in': status == 0 ? 'Wrapped Ethereum' : 'ETH',
          'symbol_out': 'USDC',
          'amount_in': '1.000000000000000001',
          'limit_price': '3000',
          'status': status,
          'tx_hash': status == 0 ? '' : '0x1234',
          'created_at': 1789012800,
          'expires_at': 1800000000,
        },
    ];
}

class _VisualHistoryRepository extends TransactionHistoryRepository {
  @override
  Future<TransactionHistoryPage> load({
    required TransactionHistoryScope scope,
    TransactionHistoryFilter filter = const TransactionHistoryFilter(),
    int offset = 0,
    int limit = 50,
  }) async {
    final records = [
      for (final state in [1, 2])
        TransationRecordModel()
          ..address = scope.address
          ..from1 = scope.address
          ..to1 = '0x0000000000000000000000000000000000000022'
          ..state = state
          ..txTime = '1789012800'
          ..price = BigInt.parse(
            state == 1 ? '125000000000000001' : '20000000000000000',
          )
          ..coin = {
            'coinType': 'ETH',
            'blockchainType': 'Ethereum',
            'unit': 'ETH',
            'decimals': 18,
          }
          ..errorMessage = state == 2 ? 'Transaction reverted' : '',
    ];
    return TransactionHistoryPage(records, hasMore: false);
  }
}
