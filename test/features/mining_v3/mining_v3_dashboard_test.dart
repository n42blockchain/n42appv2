import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/features/mining_v3/widgets/mining_v3_dashboard.dart';
import 'package:n42_wallet/features/mining_v3/widgets/mining_v3_connection_sheet.dart';
import 'package:n42_wallet/features/mining_v3/widgets/mining_v3_block_sheet.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class _Native implements MobileVerifyApi {
  MvMinerStatus status = MvMinerStatus.idle;
  @override
  Future<MvMinerStatus> minerStatus() async => status;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Store implements SecureStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _now = DateTime(2026, 10, 31, 12, 30);
final _active = MvMinerStatus(
  running: true,
  phase: 'mining',
  endpoint: 'http://node:21100',
  startedAtMs: _now
      .subtract(const Duration(hours: 1, minutes: 23, seconds: 45))
      .millisecondsSinceEpoch,
  deviceIndex: 8,
  verified: 12,
  certified: 10,
  failed: 1,
  lastBlock: const MvVerified(
    blockNumber: 1003,
    blockHash: '0xabc',
    receiptsRoot: '0xroot',
    txs: 8,
    index: 8,
    elapsedMs: 12,
  ),
  log: const [
    '12:29:01 verified block 1001 (3 txs, 8 ms)',
    '12:29:10 block 1001 certified, 4 signers',
    '12:29:20 block 1002 failed: invalid receipts',
    '12:29:30 verified block 1003 (8 txs, 12 ms)',
  ],
);

void main() {
  late _Native native;
  late MiningV3Engine engine;
  final boundary = GlobalKey();
  setUp(() {
    native = _Native();
    engine = MiningV3Engine(
      api: native,
      store: _Store(),
      now: () => _now,
      refreshEvery: const Duration(days: 1),
    );
  });
  tearDown(() => engine.dispose());

  Future<void> mount(
    WidgetTester tester, {
    Widget? child,
    bool dark = false,
    double scale = 1,
    Locale locale = const Locale('en'),
  }) async {
    await engine.refresh();
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: dark
            ? ThemeAdapter.buildDark(ThemeAdapter.defaultAccent)
            : ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: boundary,
          child:
              child ??
              ListenableBuilder(
                listenable: engine,
                builder: (context, _) => MiningV3Dashboard(
                  engine: engine,
                  endpoint: '',
                  onToggle: () {},
                  onSettings: () {},
                  onBlock: (b) => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        MiningV3BlockSheet(engine: engine, block: b),
                  ),
                ),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('idle shows setup, unknown rewards and honest empty activity', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('Set up mining'), findsOneWidget);
    expect(find.text('Not reported'), findsOneWidget);
    expect(find.text('0 N'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Your first block starts here'),
      300,
    );
    expect(find.text('Your first block starts here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'real activity filters, selects and displays certificate details',
    (tester) async {
      native.status = _active;
      await mount(tester);
      expect(find.text('01:23:45'), findsOneWidget);
      expect(find.text('Pause mining'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('mining_v3_filter_certified')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Block #1,003'), findsNothing);
      await tester.scrollUntilVisible(find.text('Block #1,001'), 200);
      await tester.tap(find.text('Block #1,001'));
      await tester.pumpAndSettle();
      expect(find.text('Certificate signers'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Block hash'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('node validates credentials and keeps failed save open', (
    tester,
  ) async {
    await mount(
      tester,
      child: Scaffold(
        body: MiningV3ConnectionSheet(
          engine: engine,
          endpoint: 'https://user:secret@node',
          onSave: (_) async => throw StateError('disk unavailable'),
        ),
      ),
    );
    await tester.tap(find.text('Save node'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter an http://'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'https://node/');
    await tester.tap(find.text('Save node'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not save the node. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('running node cannot be edited', (tester) async {
    native.status = _active;
    await mount(
      tester,
      child: Scaffold(
        body: MiningV3ConnectionSheet(
          engine: engine,
          endpoint: 'http://node',
          onSave: (_) async => fail('must not save'),
        ),
      ),
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
      isFalse,
    );
    expect(find.text('Pause mining to change the node.'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final locale in [const Locale('en'), const Locale('zh', 'TW')]) {
        testWidgets('layout ${dark ? "dark" : "light"} $scale $locale', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          native.status = _active;
          await mount(tester, dark: dark, scale: scale, locale: locale);
          expect(tester.takeException(), isNull);
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('mining_v3_block_1001')),
            250,
            maxScrolls: 30,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  test(
    'endpoint normalization rejects unsupported or credentialed addresses',
    () {
      expect(
        normalizeMiningV3Endpoint(' https://node:21100/// '),
        'https://node:21100',
      );
      for (final value in [
        '',
        'node',
        'ftp://node',
        'http://u:p@node',
        'http://node?token=x',
        'http://node#x',
      ]) {
        expect(normalizeMiningV3Endpoint(value), isNull);
      }
    },
  );
}
