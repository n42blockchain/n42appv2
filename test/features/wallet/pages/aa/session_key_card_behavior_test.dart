import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_card.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_models.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

SessionKeyData _key({
  SessionKeyStatus status = SessionKeyStatus.active,
  SessionKeyPermission permission = SessionKeyPermission.transfer,
  BigInt? spendingLimit,
  BigInt? usedAmount,
}) => SessionKeyData(
  keyAddress: '0x1234567890abcdef1234567890abcdef12345678',
  label: 'Trading key',
  permission: permission,
  status: status,
  createdAt: DateTime(2026, 1, 2),
  expiresAt: status == SessionKeyStatus.active
      ? DateTime.now().add(const Duration(days: 4))
      : DateTime(2026, 1, 1),
  dappName: 'N42 DEX',
  allowedContracts: const ['0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'],
  spendingLimit: spendingLimit,
  spendingToken: spendingLimit == null ? null : 'ETH',
  usedAmount: usedAmount,
  transactionCount: 12,
  chainId: 8453,
);

void main() {
  testWidgets(
    'active key renders metadata, limits, progress, and copy action',
    (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          SessionKeyCard(
            keyData: _key(
              spendingLimit: BigInt.from(1000000000000000000),
              usedAmount: BigInt.from(850000000000000000),
            ),
            showActions: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = S.of(tester.element(find.byType(SessionKeyCard)));

      expect(find.text('Trading key'), findsOneWidget);
      expect(find.text('N42 DEX'), findsOneWidget);
      expect(find.text('0x1234...5678'), findsOneWidget);
      expect(find.text(l10n.g_key_aa_active), findsOneWidget);
      expect(find.text('12 txns'), findsOneWidget);
      expect(find.text('≤ 1 ETH'), findsOneWidget);
      expect(find.text('85.0%'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.85,
      );
      expect(find.byIcon(Icons.timer), findsOneWidget);

      await tester.tap(find.text('0x1234...5678'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(l10n.copy), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'inactive keys show status and permission but no actions or timer',
    (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          Column(
            children: [
              SessionKeyCard(
                keyData: _key(
                  status: SessionKeyStatus.expired,
                  permission: SessionKeyPermission.approve,
                ),
                showActions: true,
                onRevoke: () {},
              ),
              SessionKeyCard(
                keyData: _key(
                  status: SessionKeyStatus.revoked,
                  permission: SessionKeyPermission.contractCall,
                ),
                showActions: true,
                onRevoke: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = S.of(tester.element(find.byType(SessionKeyCard).first));

      expect(find.text(l10n.g_key_aa_expired), findsOneWidget);
      expect(find.text(l10n.g_key_aa_revoked_status), findsOneWidget);
      expect(find.text(l10n.g_key_aa_approve), findsOneWidget);
      expect(find.text(l10n.g_key_aa_session_preset_contract), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsNothing);
      expect(find.text(l10n.g_key_aa_details), findsNothing);
      expect(find.text(l10n.g_key_aa_revoke), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'active key actions open details and report confirmed revocation',
    (tester) async {
      var revokeCount = 0;
      await tester.pumpWidget(
        wrapForTest(
          SessionKeyCard(
            keyData: _key(
              permission: SessionKeyPermission.full,
              spendingLimit: BigInt.zero,
            ),
            showActions: true,
            onRevoke: () => revokeCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = S.of(tester.element(find.byType(SessionKeyCard)));

      await tester.tap(find.text(l10n.g_key_aa_details));
      await tester.pumpAndSettle();
      expect(find.text(l10n.g_key_aa_session_details), findsOneWidget);
      expect(find.text('Trading key'), findsNWidgets(2));
      expect(find.text('2026-01-02'), findsOneWidget);
      expect(find.text('1970-01-01'), findsNothing);

      Navigator.of(tester.element(find.byType(SessionKeyCard))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.g_key_aa_revoke));
      await tester.pumpAndSettle();
      expect(find.text(l10n.g_key_aa_revoke_session), findsOneWidget);

      await tester.tap(find.text(l10n.g_key_79));
      await tester.pumpAndSettle();
      expect(revokeCount, 0);

      await tester.tap(find.text(l10n.g_key_aa_revoke));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.g_key_aa_revoke).last);
      await tester.pumpAndSettle();
      expect(revokeCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  test('compact formatters cover zero, fractional, and elapsed values', () {
    expect(sessionKeyFormatBigInt(BigInt.zero, 18), '0');
    expect(sessionKeyFormatBigInt(BigInt.from(1500000000000000000), 18), '1.5');
    expect(sessionKeyFormatBigInt(BigInt.from(2000000000000000000), 18), '2');
    expect(sessionKeyFormatRemainingTime(const Duration(days: 3)), '3d');
    expect(sessionKeyFormatRemainingTime(const Duration(hours: 5)), '5h');
    expect(sessionKeyFormatRemainingTime(const Duration(minutes: 12)), '12m');
    expect(sessionKeyFormatRemainingTime(Duration.zero), 'expired');
  });
}
