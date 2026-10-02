import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/hardware_wallet_accounts_page.dart';
import 'package:n42_wallet/features/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

const _address = '0x1111111111111111111111111111111111111111';

class _FakeHardwareWalletProvider extends ChangeNotifier
    implements HardwareWalletProvider {
  bool connected;
  HardwareWalletDevice? device;
  List<HardwareWalletAccount> accountList;
  final loadedCoinTypes = <String>[];
  int loadMoreCalls = 0;
  final importResults = <Object>[];
  Completer<void>? accountsLoadCompleter;
  Completer<void>? loadMoreCompleter;

  _FakeHardwareWalletProvider({
    this.connected = true,
    this.device,
    this.accountList = const [],
  });

  @override
  bool get isConnected => connected;

  @override
  HardwareWalletDevice? get currentDevice => device;

  @override
  List<HardwareWalletAccount> get accounts => accountList;

  @override
  Future<void> loadAccounts(String coinType) async {
    loadedCoinTypes.add(coinType);
    await accountsLoadCompleter?.future;
  }

  @override
  Future<void> loadMoreAccounts() async {
    loadMoreCalls++;
    await loadMoreCompleter?.future;
  }

  @override
  Future<bool> importAccount(HardwareWalletAccount account) async {
    final result = importResults.removeAt(0);
    if (result is Error || result is Exception) throw result;
    return result as bool;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

HardwareWalletAccount _account({int index = 0, String? name}) =>
    HardwareWalletAccount(
      address: _address,
      coinType: 'ETH',
      derivationPath: "m/44'/60'/0'/0/$index",
      name: name,
      index: index,
    );

void main() {
  final clipboardCalls = <MethodCall>[];

  Future<void> mount(
    WidgetTester tester,
    _FakeHardwareWalletProvider provider,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(HardwareWalletAccountsPage(provider: provider)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  setUp(() {
    clipboardCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') clipboardCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('disconnected state offers back navigation', (tester) async {
    final provider = _FakeHardwareWalletProvider(connected: false);
    await mount(tester, provider);

    final l10n = S.of(tester.element(find.byType(HardwareWalletAccountsPage)));
    expect(find.text(l10n.g_key_hw_not_connected), findsOneWidget);
    expect(find.text(l10n.g_key_hw_go_back), findsOneWidget);
    expect(provider.loadedCoinTypes, ['ETH']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state retries and changing coin reloads that chain', (
    tester,
  ) async {
    final provider = _FakeHardwareWalletProvider();
    await mount(tester, provider);
    final l10n = S.of(tester.element(find.byType(HardwareWalletAccountsPage)));

    expect(find.text(l10n.g_key_hw_no_accounts_found), findsOneWidget);
    expect(
      find.text(l10n.g_key_hw_open_ledger_app_hint('Ethereum')),
      findsOneWidget,
    );
    await tester.tap(find.text(l10n.g_key_aa_retry));
    await tester.pumpAndSettle();
    expect(provider.loadedCoinTypes, ['ETH', 'ETH']);

    await tester.tap(find.text('BNB', findRichText: true));
    await tester.pumpAndSettle();
    expect(provider.loadedCoinTypes.last, 'BNB');
    expect(tester.takeException(), isNull);
  });

  testWidgets('account and pagination loading states show progress', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final provider =
        _FakeHardwareWalletProvider(
            accountList: [_account(name: 'Cold storage')],
          )
          ..accountsLoadCompleter = Completer<void>()
          ..loadMoreCompleter = Completer<void>();

    await tester.pumpWidget(
      wrapForTest(HardwareWalletAccountsPage(provider: provider)),
    );
    await tester.pump();
    await tester.pump();
    final l10n = S.of(tester.element(find.byType(HardwareWalletAccountsPage)));

    expect(find.text(l10n.g_key_hw_loading_accounts), findsOneWidget);
    expect(find.text(l10n.g_key_hw_loading_hint), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    provider.accountsLoadCompleter!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Cold storage'), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.g_key_hw_load_more));
    await tester.tap(find.text(l10n.g_key_hw_load_more));
    await tester.pump();
    expect(find.text(l10n.g_key_hw_load_more), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    provider.loadMoreCompleter!.complete();
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_key_hw_load_more), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'account list copies its address, loads more, and can cancel import',
    (tester) async {
      final provider = _FakeHardwareWalletProvider(
        device: const HardwareWalletDevice(
          id: 'synthetic-ledger',
          name: 'Ledger Nano X',
          type: HardwareWalletType.ledgerNanoX,
          firmwareVersion: '2.1.0',
        ),
        accountList: [_account(name: 'Cold storage')],
      );
      await mount(tester, provider);

      expect(find.text('Ledger Nano X'), findsOneWidget);
      expect(find.text('Cold storage'), findsOneWidget);
      expect(find.text("m/44'/60'/0'/0/0"), findsOneWidget);
      expect(find.text(_address), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      expect((clipboardCalls.single.arguments as Map)['text'], _address);

      final l10n = S.of(
        tester.element(find.byType(HardwareWalletAccountsPage)),
      );
      await tester.ensureVisible(find.text(l10n.g_key_hw_load_more));
      await tester.tap(find.text(l10n.g_key_hw_load_more));
      await tester.pumpAndSettle();
      expect(provider.loadMoreCalls, 1);

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.g_key_79));
      await tester.pumpAndSettle();
      expect(provider.importResults, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('import reports success, duplicate, and provider failures', (
    tester,
  ) async {
    final account = _account(name: 'Cold storage');
    final provider = _FakeHardwareWalletProvider(accountList: [account])
      ..importResults.addAll([true, false, StateError('provider failed')]);
    await mount(tester, provider);
    final l10n = S.of(tester.element(find.byType(HardwareWalletAccountsPage)));

    Future<void> confirmImport() async {
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.g_key_hw_add));
      await tester.pumpAndSettle();
    }

    await confirmImport();
    expect(
      find.text(l10n.g_key_hw_account_added(account.shortAddress)),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));

    await confirmImport();
    expect(find.text(l10n.g_key_hw_account_already_imported), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));

    await confirmImport();
    expect(find.textContaining('provider failed'), findsOneWidget);
    expect(provider.importResults, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
