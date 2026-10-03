import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_dialogs.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _EstimatedTransferProvider extends BatchTransferProvider {
  @override
  BatchGasEstimate? get gasEstimate => BatchGasEstimate(
    gasLimit: BigInt.from(21000),
    gasPrice: BigInt.from(20),
    totalFee: BigInt.from(420000),
    isEip1559: false,
  );
}

Widget _app(Widget child) => ScreenUtilInit(
  designSize: const Size(750, 1334),
  builder: (context, child) => MaterialApp(
    theme: ThemeData.light(),
    localizationsDelegates: const [S.delegate],
    supportedLocales: S.delegate.supportedLocales,
    home: child,
  ),
  child: child,
);

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

_EstimatedTransferProvider _provider() {
  final provider = _EstimatedTransferProvider();
  provider.initialize(
    chainSymbol: 'ETH',
    rpcUrl: 'https://offline.invalid/rpc',
    chainId: 1,
    fromAddress: '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    tokenSymbol: 'USDC',
    decimals: 2,
  );
  provider.addItem(
    '0x1111111111111111111111111111111111111111',
    BigInt.from(1200),
  );
  provider.addItem(
    '0x2222222222222222222222222222222222222222',
    BigInt.from(2300),
  );
  return provider;
}

void main() {
  testWidgets('confirmation dialog reports transfer details and confirms', (
    tester,
  ) async {
    final provider = _provider();
    addTearDown(provider.dispose);
    Future<bool?>? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => result = showDialog<bool>(
                context: context,
                builder: (_) => BatchConfirmDialog(
                  provider: provider,
                  tokenSymbol: 'USDC',
                  formatGasFee: (_) => '0.00042 ETH',
                ),
              ),
              child: const Text('Open confirmation'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open confirmation'));
    await tester.pumpAndSettle();

    expect(find.textContaining('2'), findsWidgets);
    expect(find.textContaining('35 USDC'), findsOneWidget);
    expect(find.textContaining('0.00042 ETH'), findsOneWidget);
    expect(find.text(S.current.importantNotice), findsOneWidget);
    await tester.tap(find.text(S.current.g_key_78));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling confirmation returns false and barrier returns null', (
    tester,
  ) async {
    final provider = _provider();
    addTearDown(provider.dispose);
    Future<bool?>? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => result = showDialog<bool>(
                context: context,
                builder: (_) => BatchConfirmDialog(
                  provider: provider,
                  tokenSymbol: 'USDC',
                  formatGasFee: (_) => 'fee',
                ),
              ),
              child: const Text('Open confirmation'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open confirmation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_key_79));
    await tester.pumpAndSettle();
    expect(await result, isFalse);

    await tester.tap(find.text('Open confirmation'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(await result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'help dialog explains CSV format and dismisses on acknowledgment',
    (tester) async {
      Future<void>? result;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => result = showDialog<void>(
                  context: context,
                  builder: (_) => const BatchHelpDialog(),
                ),
                child: const Text('Open help'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open help'));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_key_batch_csv_format), findsOneWidget);
      expect(find.textContaining('address,amount,memo'), findsOneWidget);
      expect(
        find.textContaining(S.current.g_key_batch_swipe_remove),
        findsOneWidget,
      );
      expect(
        find.textContaining(S.current.g_key_batch_memo_optional),
        findsOneWidget,
      );
      expect(
        find.textContaining(S.current.g_key_batch_multicall_tip),
        findsOneWidget,
      );

      await tester.tap(find.text(S.current.g_key_burn_got_it));
      await tester.pumpAndSettle();
      await result;
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('result sheet exports and only displays an available tx hash', (
    tester,
  ) async {
    _setLargeViewport(tester);
    final provider = _provider();
    addTearDown(provider.dispose);
    var exports = 0;
    Future<void>? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => result = showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => BatchResultSheet(
                  provider: provider,
                  tokenSymbol: 'USDC',
                  onExport: (_) async => exports++,
                ),
              ),
              child: const Text('Open result'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();
    expect(find.text('TxHash:'), findsNothing);
    await tester.tap(find.text(S.current.g_key_batch_export_csv));
    await tester.pump();
    expect(exports, 1);
    await tester.tap(find.text(S.current.g_key_batch_done));
    await tester.pumpAndSettle();
    await result;
    expect(tester.takeException(), isNull);
  });

  testWidgets('result sheet exposes copy for an available transaction hash', (
    tester,
  ) async {
    _setLargeViewport(tester);
    // The transaction hash is normally written by a successful broadcast.
    // Exercise the rendered branch without starting a network request.
    final hashProvider =
        _HashTransferProvider(
          txHash:
              '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdef',
        )..initialize(
          chainSymbol: 'ETH',
          rpcUrl: 'https://offline.invalid/rpc',
          chainId: 1,
          fromAddress: '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          tokenSymbol: 'USDC',
          decimals: 2,
        );
    hashProvider.addItem(
      '0x1111111111111111111111111111111111111111',
      BigInt.from(1200),
    );
    addTearDown(hashProvider.dispose);
    final platformChannel = SystemChannels.platform;
    final platformCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platformChannel, (call) async {
          platformCalls.add(call);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platformChannel, null),
    );
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Builder(
            builder: (context) => BatchResultSheet(
              provider: hashProvider,
              tokenSymbol: 'USDC',
              onExport: (_) async {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('TxHash:'), findsOneWidget);
    expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.copy_outlined));
    await tester.pump();
    expect(
      platformCalls
          .where((call) => call.method == 'Clipboard.setData')
          .single
          .arguments,
      {'text': hashProvider.txHash},
    );
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _HashTransferProvider extends BatchTransferProvider {
  _HashTransferProvider({required String txHash}) : _hash = txHash;

  final String _hash;

  @override
  String? get txHash => _hash;
}
