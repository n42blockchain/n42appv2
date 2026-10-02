import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_purchase_step_content.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

CommitResult _commit({int minWaitTime = 120}) => CommitResult(
  commitmentHash: 'commitment',
  secret: 'secret',
  commitTime: DateTime(2026, 10, 2),
  minWaitTime: minWaitTime,
);

RegisterResult _registration({String? txHash}) => RegisterResult.success(
  txHash: txHash ?? '0x1234567890abcdef1234567890abcdef',
  name: 'my-domain.eth',
  expiresAt: DateTime(2036, 10, 2),
);

void main() {
  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpStep(
    WidgetTester tester, {
    required int step,
    int remainingSeconds = 60,
    CommitResult? commitResult,
    RegisterResult? registerResult,
    String? errorMessage,
    String domainName = 'my-domain',
  }) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: SingleChildScrollView(
            child: EnsPurchaseStepContent(
              currentStep: step,
              remainingSeconds: remainingSeconds,
              commitResult: commitResult,
              registerResult: registerResult,
              errorMessage: errorMessage,
              domainName: domainName,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('initial step explains registration and waiting requirements', (
    tester,
  ) async {
    await pumpStep(tester, step: 0);

    final context = tester.element(find.byType(EnsPurchaseStepContent));
    expect(
      find.text(S.of(context).g_key_ens_registration_info),
      findsOneWidget,
    );
    expect(find.text(S.of(context).g_key_ens_two_step_process), findsOneWidget);
    expect(find.text(S.of(context).g_key_ens_wait_time_info), findsOneWidget);
    expect(find.text(S.of(context).g_key_ens_keep_app_open), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'commit and register steps show their distinct progress messages',
    (tester) async {
      await pumpStep(tester, step: 1);
      var context = tester.element(find.byType(EnsPurchaseStepContent));
      expect(find.text(S.of(context).g_key_ens_committing), findsOneWidget);
      expect(find.text(S.of(context).g_key_ens_please_wait), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);

      await pumpStep(tester, step: 3);
      context = tester.element(find.byType(EnsPurchaseStepContent));
      expect(find.text(S.of(context).g_key_ens_registering), findsOneWidget);
      expect(find.text(S.of(context).g_key_ens_finalizing), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('waiting step renders remaining time and progress context', (
    tester,
  ) async {
    await pumpStep(
      tester,
      step: 2,
      remainingSeconds: 65,
      commitResult: _commit(minWaitTime: 120),
    );

    final context = tester.element(find.byType(EnsPurchaseStepContent));
    expect(find.text('01:05'), findsOneWidget);
    expect(find.text(S.of(context).g_key_ens_waiting), findsOneWidget);
    expect(find.text(S.of(context).g_key_ens_wait_explanation), findsOneWidget);
    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(progress.value, closeTo(55 / 120, 0.001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('success content includes the registered domain and short hash', (
    tester,
  ) async {
    await pumpStep(
      tester,
      step: 4,
      domainName: 'my-domain',
      registerResult: _registration(),
    );

    final context = tester.element(find.byType(EnsPurchaseStepContent));
    expect(find.text(S.of(context).g_key_ens_success), findsOneWidget);
    expect(
      find.text('my-domain.eth ${S.of(context).g_key_ens_is_yours}'),
      findsOneWidget,
    );
    expect(
      find.text(
        S.of(context).g_ui_transaction_hash_value('0x12345678...abcdef'),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('error content prefers the supplied failure reason', (
    tester,
  ) async {
    await pumpStep(tester, step: -1, errorMessage: 'Registration rejected');

    final context = tester.element(find.byType(EnsPurchaseStepContent));
    expect(find.text(S.of(context).g_key_ens_failed), findsOneWidget);
    expect(find.text('Registration rejected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('action button enables only the action for the current step', (
    tester,
  ) async {
    await setPhoneSize(tester);
    var starts = 0;
    var retries = 0;
    var dones = 0;

    Widget actionFor(int step) => wrapForTest(
      Scaffold(
        body: EnsPurchaseActionButton(
          currentStep: step,
          onStart: () => starts++,
          onRetry: () => retries++,
          onDone: () => dones++,
        ),
      ),
    );

    await tester.pumpWidget(actionFor(0));
    final context = tester.element(find.byType(EnsPurchaseActionButton));
    await tester.tap(find.text(S.of(context).g_key_ens_start_registration));
    expect(starts, 1);

    await tester.pumpWidget(actionFor(2));
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    await tester.pumpWidget(actionFor(4));
    final doneContext = tester.element(find.byType(EnsPurchaseActionButton));
    await tester.tap(find.text(S.of(doneContext).g_swap_key_18));
    expect(dones, 1);

    await tester.pumpWidget(actionFor(-1));
    final retryContext = tester.element(find.byType(EnsPurchaseActionButton));
    await tester.tap(find.text(S.of(retryContext).g_swap_key_6));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });
}
