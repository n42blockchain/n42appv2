import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/paymaster_select_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _PaymasterHost extends StatefulWidget {
  const _PaymasterHost({required this.loadOptions});

  final Future<List<PaymasterOption>> Function(int chainId, String symbol)
  loadOptions;

  @override
  State<_PaymasterHost> createState() => _PaymasterHostState();
}

class _PaymasterHostState extends State<_PaymasterHost> {
  int _chainId = 1;

  String get _symbol => _chainId == 1 ? 'ETH' : 'POL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () => setState(() => _chainId = 137),
            child: const Text('Switch chain'),
          ),
          Expanded(
            child: PaymasterSelectPage(
              key: const ValueKey('paymaster-page'),
              currentOption: PaymasterOption.none,
              chainId: _chainId,
              chainSymbol: _symbol,
              loadOptionsForTesting: widget.loadOptions,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('chain changes reload options and ignore the old response', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final firstResponse = Completer<List<PaymasterOption>>();
    final secondResponse = Completer<List<PaymasterOption>>();
    final requests = <(int, String)>[];
    Future<List<PaymasterOption>> loadOptions(int chainId, String symbol) {
      requests.add((chainId, symbol));
      return chainId == 1 ? firstResponse.future : secondResponse.future;
    }

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(750, 1334),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: _PaymasterHost(loadOptions: loadOptions),
        ),
      ),
    );
    expect(requests, [(1, 'ETH')]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.text('Switch chain'));
    await tester.pump();
    expect(requests, [(1, 'ETH'), (137, 'POL')]);

    const dai = PaymasterOption(
      type: PaymasterType.erc20,
      tokenSymbol: 'DAI',
      tokenAddress: '0xdai-on-polygon',
      decimals: 18,
    );
    secondResponse.complete([PaymasterOption.none, dai]);
    await tester.pumpAndSettle();
    expect(find.textContaining('DAI'), findsOneWidget);

    const usdc = PaymasterOption(
      type: PaymasterType.erc20,
      tokenSymbol: 'USDC',
      tokenAddress: '0xusdc-on-ethereum',
      decimals: 6,
    );
    firstResponse.complete([PaymasterOption.none, usdc]);
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('DAI'), findsOneWidget);
    expect(find.textContaining('USDC'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unavailable choices stay disabled and selection is returned', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(750, 1334),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          locale: const Locale('en'),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: const Scaffold(body: Center(child: Text('Wallet'))),
        ),
      ),
    );

    const dai = PaymasterOption(
      type: PaymasterType.erc20,
      tokenSymbol: 'DAI',
      tokenAddress: '0xdai',
      decimals: 18,
    );
    const unavailable = PaymasterOption(
      type: PaymasterType.sponsored,
      isAvailable: false,
      unavailableReason: 'Sponsorship is unavailable',
    );
    final resultFuture = navigatorKey.currentState!.push<PaymasterOption>(
      MaterialPageRoute(
        builder: (_) => PaymasterSelectPage(
          currentOption: PaymasterOption.none,
          chainId: 137,
          chainSymbol: 'POL',
          loadOptionsForTesting: (_, _) async => [
            PaymasterOption.none,
            unavailable,
            dai,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    var cards = tester.widgetList<PaymasterOptionCard>(
      find.byType(PaymasterOptionCard),
    );
    expect(cards.map((card) => card.isSelected), [true, false, false]);

    await tester.tap(find.text('Sponsored (Free)'));
    await tester.pump();
    cards = tester.widgetList<PaymasterOptionCard>(
      find.byType(PaymasterOptionCard),
    );
    expect(cards.map((card) => card.isSelected), [true, false, false]);

    await tester.tap(find.text('Pay with DAI').first);
    await tester.pump();
    cards = tester.widgetList<PaymasterOptionCard>(
      find.byType(PaymasterOptionCard),
    );
    expect(cards.map((card) => card.isSelected), [false, false, true]);
    await tester.tap(find.text('Confirm'));

    final result = await resultFuture;
    expect(result?.type, PaymasterType.erc20);
    expect(result?.tokenSymbol, 'DAI');
    expect(result?.tokenAddress, '0xdai');
    expect(tester.takeException(), isNull);
  });

  testWidgets('load errors can be retried into a ready options list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var attempts = 0;
    Future<List<PaymasterOption>> loadOptions(int chainId, String symbol) {
      attempts++;
      if (attempts == 1) return Future.error(StateError('network offline'));
      return Future.value([PaymasterOption.none]);
    }

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(750, 1334),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: PaymasterSelectPage(
            currentOption: PaymasterOption.none,
            chainId: 1,
            chainSymbol: 'ETH',
            loadOptionsForTesting: loadOptions,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.byType(PaymasterOptionCard), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(find.text('Confirm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
