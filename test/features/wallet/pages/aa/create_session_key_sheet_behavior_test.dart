import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/repository/session_key_repository.dart';
import 'package:n42_wallet/features/wallet/pages/aa/create_session_key_sheet.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_models.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _Repository extends Mock implements SessionKeyRepository {}

class _FakeSessionKeyData extends Fake implements SessionKeyData {}

SmartAccount _account() => SmartAccount(
  address: '0x${'a' * 40}',
  type: SmartAccountType.simpleAccount,
  ownerAddress: '0x${'1' * 40}',
  state: SmartAccountState.deployed,
  chainId: 8453,
  salt: BigInt.one,
  factoryAddress: '0x${'f' * 40}',
  createdAt: DateTime(2026, 1, 1),
  label: 'Base account',
);

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  final scrollable = find
      .descendant(
        of: find.byType(CreateSessionKeySheet),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(target, 140, scrollable: scrollable);
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeSessionKeyData()));

  Future<S> openSheet(
    WidgetTester tester, {
    required _Repository repository,
    required ValueChanged<SessionKeyData> onCreated,
  }) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CreateSessionKeySheet(
                  account: _account(),
                  repository: repository,
                  onCreated: onCreated,
                ),
              ),
              child: const Text('Open session-key form'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open session-key form'));
    await tester.pumpAndSettle();
    return S.of(tester.element(find.byType(CreateSessionKeySheet)));
  }

  testWidgets(
    'bounded transfer key requires confirmation and saves its scope',
    (tester) async {
      final repository = _Repository();
      when(() => repository.saveKey(any())).thenAnswer((_) async => true);
      SessionKeyData? created;
      final l10n = await openSheet(
        tester,
        repository: repository,
        onCreated: (key) => created = key,
      );

      final createButton = find.byType(ElevatedButton).last;
      expect(tester.widget<ElevatedButton>(createButton).onPressed, isNull);
      expect(find.text(l10n.g_key_aa_session_risk_low), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        '  Dex access  ',
      );
      await _scrollTo(
        tester,
        find.text(l10n.g_key_aa_session_amount_limit).last,
      );
      await tester.ensureVisible(find.byType(Checkbox).first);
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox).first).value,
        isFalse,
      );
      await tester.ensureVisible(find.byType(TextFormField).last);
      await tester.enterText(find.byType(TextFormField).last, '1.5');
      await tester.ensureVisible(find.text('USDC'));
      await tester.tap(find.text('USDC'));
      await tester.ensureVisible(find.text(l10n.g_key_aa_session_7d));
      await tester.tap(find.text(l10n.g_key_aa_session_7d));
      await _scrollTo(tester, find.text(l10n.g_key_aa_session_confirm_risk));
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();

      expect(tester.widget<ElevatedButton>(createButton).onPressed, isNotNull);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(created, isNotNull);
      expect(created!.label, 'Dex access');
      expect(created!.permission, SessionKeyPermission.transfer);
      expect(created!.spendingLimit, BigInt.from(1500000000000000000));
      expect(created!.spendingToken, 'USDC');
      expect(created!.expiresAt.difference(created!.createdAt).inDays, 7);
      expect(created!.chainId, 8453);
      expect(created!.keyAddress, matches(RegExp(r'^0x[0-9a-f]{40}$')));
      expect(find.byType(CreateSessionKeySheet), findsNothing);
      expect(find.text(l10n.g_key_aa_session_create_success), findsOneWidget);
      verify(() => repository.saveKey(any())).called(1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('full delegation displays high-risk disclosure before saving', (
    tester,
  ) async {
    final repository = _Repository();
    when(() => repository.saveKey(any())).thenAnswer((_) async => true);
    SessionKeyData? created;
    final l10n = await openSheet(
      tester,
      repository: repository,
      onCreated: (key) => created = key,
    );

    await tester.ensureVisible(find.text(l10n.g_key_aa_session_preset_full));
    await tester.tap(find.text(l10n.g_key_aa_session_preset_full));
    await tester.pumpAndSettle();

    expect(find.text(l10n.g_key_aa_session_risk_high), findsOneWidget);
    expect(find.text(l10n.g_key_aa_session_risk_warning), findsWidgets);
    expect(find.text(l10n.g_key_aa_session_amount_limit), findsNothing);

    await _scrollTo(tester, find.text(l10n.g_key_aa_session_confirm_risk));
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(created?.permission, SessionKeyPermission.full);
    expect(created?.spendingLimit, isNull);
    verify(() => repository.saveKey(any())).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('repository failure reports failure without emitting a key', (
    tester,
  ) async {
    final repository = _Repository();
    when(() => repository.saveKey(any())).thenAnswer((_) async => false);
    var createCount = 0;
    final l10n = await openSheet(
      tester,
      repository: repository,
      onCreated: (_) => createCount++,
    );

    await _scrollTo(tester, find.text(l10n.g_key_aa_session_confirm_risk));
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(createCount, 0);
    expect(find.byType(CreateSessionKeySheet), findsNothing);
    expect(find.text(l10n.g_key_aa_session_create_failed), findsOneWidget);
    verify(() => repository.saveKey(any())).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing the permission preset clears prior risk consent', (
    tester,
  ) async {
    final repository = _Repository();
    when(() => repository.saveKey(any())).thenAnswer((_) async => true);
    final l10n = await openSheet(
      tester,
      repository: repository,
      onCreated: (_) {},
    );

    await _scrollTo(tester, find.text(l10n.g_key_aa_session_confirm_risk));
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed,
      isNotNull,
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, 700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.g_key_aa_session_preset_full));
    await tester.tap(find.text(l10n.g_key_aa_session_preset_full));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text(l10n.g_key_aa_session_confirm_risk));

    expect(tester.widget<Checkbox>(find.byType(Checkbox).last).value, isFalse);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}
