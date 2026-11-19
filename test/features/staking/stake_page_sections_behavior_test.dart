import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/staking/pages/stake_page.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _Wallet extends Fake implements LegacyWalletActionProviderAdapter {
  @override
  List<CoinModel> coinModels = [];
}

/// Supplies one staking position and counts unstake attempts without network.
class _FakeStakingProvider extends StakingProvider {
  _FakeStakingProvider(this._positionsForTest);

  final List<StakingPosition> _positionsForTest;
  int unstakeCalls = 0;

  @override
  List<StakingPosition> get positions => _positionsForTest;

  @override
  Future<void> loadValidators() async {}

  @override
  Future<void> loadUserPositions(
    String address,
    StakingChainType chainType,
  ) async {}

  @override
  Future<StakingTransactionResponse?> buildUnstakeTransaction({
    required StakingPosition position,
    required BigInt amount,
    required String fromAddress,
  }) async {
    unstakeCalls++;
    return null;
  }
}

class _OfflineHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('network disabled for stake page test');
  }
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousOverrides = HttpOverrides.current;

  setUpAll(() => globalWapAdapter = _Wallet());
  setUp(() => HttpOverrides.global = _OfflineHttpOverrides());
  tearDown(() => HttpOverrides.global = previousOverrides);

  Future<void> openUnstakeTab(
    WidgetTester tester,
    StakingProtocol protocol, {
    String? address,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(StakePage(protocol: protocol, userAddress: address)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_key_stake_unstake).first);
    await tester.pumpAndSettle();
  }

  testWidgets('liquid protocol explains unstaking and receive token', (
    tester,
  ) async {
    await openUnstakeTab(tester, StakingProtocols.ethLido);

    expect(
      find.text(S.current.g_key_stake_liquid_staking_label),
      findsNWidgets(2),
    );
    final liquidDescription = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('stETH') &&
          widget.text.toPlainText().contains(
            S.current.g_key_stake_liquid_unstake_desc,
          ),
    );
    expect(liquidDescription, findsOneWidget);
    expect(find.text(S.current.g_key_stake_go_to_swap), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('liquid protocol hides the swap entry on iOS', (tester) async {
    await tester.runOnIOS(() async {
      await openUnstakeTab(tester, StakingProtocols.ethLido);

      expect(
        find.text(S.current.g_key_stake_liquid_staking_label),
        findsNWidgets(2),
      );
      expect(find.text(S.current.g_key_stake_go_to_swap), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('non-liquid protocol without an address shows no-wallet hint', (
    tester,
  ) async {
    await openUnstakeTab(tester, StakingProtocols.solNative);

    expect(
      find.text(S.current.g_key_stake_unbonding_warning('2')),
      findsOneWidget,
    );
    expect(find.text(S.current.g_key_stake_no_wallet), findsOneWidget);
    expect(find.text(S.current.g_key_stake_select_position), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'non-liquid protocol with no active positions shows empty state',
    (tester) async {
      await openUnstakeTab(
        tester,
        StakingProtocols.atomNative,
        address: 'cosmos1testaddress',
      );

      expect(
        find.text(S.current.g_key_stake_unbonding_warning('21')),
        findsOneWidget,
      );
      expect(
        find.text(S.current.g_key_stake_no_active_positions),
        findsOneWidget,
      );
      expect(
        find.text(S.current.g_key_stake_select_position),
        findsNWidgets(2),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('stake asks for password or biometric verification after confirming', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        StakePage(
          protocol: StakingProtocols.ethLido,
          userAddress: '0x1111111111111111111111111111111111111111',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pumpAndSettle();

    final stakeButton = find.widgetWithText(AppButton, S.current.g_key_stake_stake);
    await tester.ensureVisible(stakeButton);
    await tester.pumpAndSettle();
    await tester.tap(stakeButton);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WalletSecurityVerification), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unstake waits for security verification and only unstakes after success',
    (tester) async {
      final position = StakingPosition(
        id: 'sol-stake-account-1',
        protocol: StakingProtocols.solNative,
        stakedAmount: BigInt.from(1000000000),
        rewardsEarned: BigInt.zero,
        pendingRewards: BigInt.zero,
        stakedAt: DateTime(2026),
        status: StakingPositionStatus.active,
      );
      final provider = _FakeStakingProvider([position]);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrapForTest(
          StakePage(
            protocol: StakingProtocols.solNative,
            userAddress: 'sol-wallet-address',
            provider: provider,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.g_key_stake_unstake).first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.textContaining('${S.current.g_key_stake_staked}:'),
      );
      await tester.pumpAndSettle();

      final unstakeButton = find.widgetWithText(
        AppButton,
        S.current.g_key_stake_unstake,
      );
      Future<void> tapUnstake() async {
        await tester.ensureVisible(unstakeButton);
        await tester.pumpAndSettle();
        await tester.tap(unstakeButton);
        await tester.pumpAndSettle();
      }

      void resolveVerification(bool? result) {
        tester
            .state<NavigatorState>(find.byType(Navigator).last)
            .pop(result);
      }

      // Cancel: the verification page returns false, nothing is unstaked.
      await tapUnstake();
      expect(find.byType(WalletSecurityVerification), findsOneWidget);
      expect(provider.unstakeCalls, 0);
      resolveVerification(false);
      await tester.pumpAndSettle();
      expect(find.byType(WalletSecurityVerification), findsNothing);
      expect(provider.unstakeCalls, 0);

      // Failure: verification is dismissed without a success result.
      await tapUnstake();
      expect(find.byType(WalletSecurityVerification), findsOneWidget);
      resolveVerification(null);
      await tester.pumpAndSettle();
      expect(provider.unstakeCalls, 0);

      // Success: only now the unstake transaction is built.
      await tapUnstake();
      expect(find.byType(WalletSecurityVerification), findsOneWidget);
      expect(provider.unstakeCalls, 0);
      resolveVerification(true);
      await tester.pumpAndSettle();
      expect(provider.unstakeCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
