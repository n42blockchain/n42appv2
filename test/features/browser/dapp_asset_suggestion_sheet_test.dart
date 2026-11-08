import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/models/watch_asset_metadata.dart';
import 'package:n42_wallet/features/browser/models/watch_asset_request.dart';
import 'package:n42_wallet/features/browser/widgets/dapp_asset_suggestion_sheet.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

Future<WatchAssetMetadata> asset() => WatchAssetMetadata.load(
  request: WatchAssetRequest.parse([
    {
      'type': 'ERC20',
      'options': {'address': '0x52908400098527886E0F7030069857D2E4169EE7'},
    },
  ], 1),
  rpc: (method, params) async => switch (method) {
    'eth_chainId' => '0x1',
    'eth_getCode' => '0x6000',
    _ =>
      (params.first as Map)['data'] == '0x95d89b41'
          ? '0x414243${''.padRight(58, '0')}'
          : '0x${'12'.padLeft(64, '0')}',
  },
  validateRequest: () {},
);

void main() {
  Future<void> open(
    WidgetTester tester,
    Future<void> Function() approve, {
    Locale locale = const Locale('en'),
  }) async {
    final metadata = await asset();
    await tester.pumpWidget(
      WidgetTestWrapper(
        locale: locale,
        textScaler: const TextScaler.linear(2),
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              builder: (_) => DAppAssetSuggestionSheet(
                origin: 'https://example.test',
                chainName: 'Ethereum',
                asset: metadata,
                onApprove: approve,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  for (final locale in [
    const Locale('en'),
    const Locale('zh'),
    const Locale('de'),
    const Locale('ar'),
  ]) {
    testWidgets(
      'asset details and explicit cancellation fit $locale at 320px/2x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var calls = 0;
        await open(tester, () async {
          calls++;
        }, locale: locale);
        expect(find.text(S.current.g_token_m_key_20), findsOneWidget);
        expect(find.text('Ethereum (1)'), findsOneWidget);
        expect(
          find.text('0x52908400098527886E0F7030069857D2E4169EE7'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(S.current.g_key_79));
        await tester.pumpAndSettle();
        expect(calls, 0);
        expect(find.byType(DAppAssetSuggestionSheet), findsNothing);
      },
    );
  }
  testWidgets('save failure keeps the preview and allows retry', (
    tester,
  ) async {
    var calls = 0;
    await open(tester, () async {
      if (++calls == 1) throw StateError('storage unavailable');
    });
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('asset-save-error')), findsOneWidget);
    expect(find.byType(DAppAssetSuggestionSheet), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(DAppAssetSuggestionSheet), findsNothing);
  });
  testWidgets('pending save prevents duplicate approval and dismissal', (
    tester,
  ) async {
    final gate = Completer<void>();
    var calls = 0;
    await open(tester, () {
      calls++;
      return gate.future;
    });
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(calls, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(DAppAssetSuggestionSheet), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(DAppAssetSuggestionSheet), findsNothing);
  });
}
