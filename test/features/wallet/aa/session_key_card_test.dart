import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_card.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_models.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late bool revoked;

  setUp(() {
    revoked = false;
  });

  testWidgets('active card displays permissions, usage and available actions', (
    tester,
  ) async {
    final data = _sessionKey(
      status: SessionKeyStatus.active,
      permission: SessionKeyPermission.transfer,
      dappName: 'Example DApp',
      spendingLimit: BigInt.from(10).pow(18),
      spendingToken: 'ETH',
      usedAmount: BigInt.from(5) * BigInt.from(10).pow(17),
      transactionCount: 5,
    );
    await _mount(tester, data, showActions: true);

    expect(find.text('Daily transfer'), findsOneWidget);
    expect(find.text('Example DApp'), findsOneWidget);
    expect(find.text(S.current.g_key_aa_active), findsOneWidget);
    expect(find.text('0x1234...abcd'), findsOneWidget);
    expect(find.text('5 txns'), findsOneWidget);
    expect(find.text('50.0%'), findsOneWidget);
    expect(find.text('≤ 1 ETH'), findsOneWidget);
    expect(find.text(S.current.g_key_aa_details), findsOneWidget);
    expect(find.text(S.current.g_key_aa_revoke), findsOneWidget);
  });

  testWidgets('revoke callback runs only after the user confirms', (
    tester,
  ) async {
    await _mount(
      tester,
      _sessionKey(status: SessionKeyStatus.active),
      showActions: true,
      onRevoke: () => revoked = true,
    );

    await tester.tap(find.text(S.current.g_key_aa_revoke));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(revoked, isFalse);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(S.current.g_key_79),
      ),
    );
    await tester.pumpAndSettle();
    expect(revoked, isFalse);

    await tester.tap(find.text(S.current.g_key_aa_revoke));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(S.current.g_key_aa_revoke),
      ),
    );
    await tester.pumpAndSettle();
    expect(revoked, isTrue);
  });

  testWidgets('expired card hides active-only spending and action controls', (
    tester,
  ) async {
    await _mount(
      tester,
      _sessionKey(
        status: SessionKeyStatus.expired,
        spendingLimit: BigInt.from(10).pow(18),
        spendingToken: 'ETH',
      ),
      showActions: true,
    );

    expect(find.text(S.current.g_key_aa_expired), findsOneWidget);
    expect(find.text(S.current.g_key_aa_spending_limit), findsNothing);
    expect(find.text(S.current.g_key_aa_details), findsNothing);
    expect(find.text(S.current.g_key_aa_revoke), findsNothing);
  });

  testWidgets('tapping the displayed address shows the copy confirmation', (
    tester,
  ) async {
    await _mount(
      tester,
      _sessionKey(status: SessionKeyStatus.revoked),
      showActions: false,
    );

    await tester.tap(find.text('0x1234...abcd'));
    await tester.pumpAndSettle();

    expect(find.text(S.current.copy), findsOneWidget);
  });
}

Future<void> _mount(
  WidgetTester tester,
  SessionKeyData keyData, {
  required bool showActions,
  VoidCallback? onRevoke,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    wrapForTest(
      Scaffold(
        body: SingleChildScrollView(
          child: SessionKeyCard(
            keyData: keyData,
            showActions: showActions,
            onRevoke: onRevoke,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SessionKeyData _sessionKey({
  required SessionKeyStatus status,
  SessionKeyPermission permission = SessionKeyPermission.full,
  String? dappName,
  BigInt? spendingLimit,
  String? spendingToken,
  BigInt? usedAmount,
  int? transactionCount,
}) {
  final now = DateTime.now();
  return SessionKeyData(
    keyAddress: '0x1234567890abcdef1234abcd',
    label: 'Daily transfer',
    permission: permission,
    status: status,
    createdAt: now.subtract(const Duration(days: 1)),
    expiresAt: now.add(const Duration(days: 10)),
    dappName: dappName,
    spendingLimit: spendingLimit,
    spendingToken: spendingToken,
    usedAmount: usedAmount,
    transactionCount: transactionCount,
  );
}
