import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_send_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/aa_transaction_preview.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _wallet = '0x1111111111111111111111111111111111111111';
const _accountAddress = '0x2222222222222222222222222222222222222222';
const _recipient = '0x3333333333333333333333333333333333333333';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('blocked by offline AA send widget test');
  }
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

SmartAccount _account() => SmartAccount(
  address: _accountAddress,
  type: SmartAccountType.simpleAccount,
  ownerAddress: _wallet,
  state: SmartAccountState.notDeployed,
  chainId: 1,
  salt: BigInt.zero,
  factoryAddress: '0x${'f' * 40}',
  createdAt: DateTime(2026, 1, 1),
  label: 'Treasury Account',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;

  setUp(() {
    HttpOverrides.global = _OfflineHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  Future<dynamic> openPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      wrapForTest(AASendPage(account: _account(), walletAddress: _wallet)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    return tester.state(find.byType(AASendPage));
  }

  void prepareReview(
    dynamic state, {
    String to = _recipient,
    String amount = '0.25',
  }) {
    state.toController.text = to;
    state.amountController.text = amount;
    state.estimatedGas = BigInt.from(21000);
    state.maxFeePerGas = BigInt.from(2000000000);
    state.setState(() {});
  }

  testWidgets('send form shows account, empty gas and blocks incomplete send', (
    tester,
  ) async {
    await openPage(tester);
    final l10n = S.of(tester.element(find.byType(AASendPage)));

    expect(find.text('Treasury Account'), findsOneWidget);
    expect(find.text('0x2222...2222'), findsOneWidget);
    expect(find.text('AA'), findsOneWidget);
    expect(find.text(l10n.g_wallet_receiver_address), findsOneWidget);
    expect(find.text(l10n.g_key_44), findsOneWidget);
    expect(find.text('ETH'), findsWidgets);
    expect(find.text('-'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'invalid recipient is rejected before opening transaction review',
    (tester) async {
      final state = await openPage(tester);
      prepareReview(state, to: 'not-an-address');
      await tester.pump();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      final l10n = S.of(tester.element(find.byType(AASendPage)));
      expect(find.text(l10n.g_key_t_50), findsOneWidget);
      expect(find.byType(AATransactionPreview), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('valid input opens review and cancel stays before signing', (
    tester,
  ) async {
    final state = await openPage(tester);
    prepareReview(state);
    await tester.pump();

    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(AATransactionPreview)));

    expect(find.byType(AATransactionPreview), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AATransactionPreview),
        matching: find.text('0.25'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AATransactionPreview),
        matching: find.text('0.000042 ETH'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('3333...3333'), findsOneWidget);
    await tester.tap(find.text(l10n.g_key_79));
    await tester.pumpAndSettle();

    expect(find.byType(AATransactionPreview), findsNothing);
    expect(find.byType(AASendPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero amount does not open a transaction review', (tester) async {
    final state = await openPage(tester);
    prepareReview(state, amount: '0');
    await tester.pump();

    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(AATransactionPreview), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
