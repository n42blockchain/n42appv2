import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/validator_list_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

const _protocol = StakingProtocol(
  id: 'cosmos',
  name: 'Cosmos',
  description: 'Test protocol',
  chainType: StakingChainType.cosmos,
  chainSymbol: 'ATOM',
  logoUri: '',
  apy: 10,
  minStakeAmount: 1,
  unbondingPeriodDays: 21,
);

Validator _validator(
  String name,
  String address, {
  required double apy,
  required double commission,
  required int staked,
}) => Validator(
  address: address,
  name: name,
  description: '',
  logoUri: '',
  commission: commission,
  apy: apy,
  totalStaked: BigInt.from(staked),
  delegatorCount: 0,
  isActive: true,
  uptime: 100,
);

final _validators = [
  _validator(
    'Alpha Stake',
    'cosmosvaloper1alpha000000000000000000000000000000000',
    apy: 5,
    commission: 8,
    staked: 300,
  ),
  _validator(
    'Beta Nodes',
    'cosmosvaloper1beta000000000000000000000000000000000',
    apy: 12,
    commission: 2,
    staked: 100,
  ),
  _validator(
    'Gamma Pool',
    'cosmosvaloper1gamma00000000000000000000000000000000',
    apy: 8,
    commission: 5,
    staked: 500,
  ),
];

void main() {
  Future<void> openPage(
    WidgetTester tester, {
    List<Validator>? validators,
    Validator? selectedValidator,
    Completer<Validator?>? selection,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ScreenUtilInit(
        // AppSpacing and AppTypography use the app's 750px design baseline.
        designSize: const Size(750, 1334),
        child: MaterialApp(
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  final route = Navigator.of(context).push<Validator>(
                    MaterialPageRoute(
                      builder: (_) => ValidatorListPage(
                        protocol: _protocol,
                        validators: validators ?? _validators,
                        selectedValidator: selectedValidator,
                      ),
                    ),
                  );
                  if (selection != null) {
                    route.then(selection.complete);
                  }
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state when no validators were supplied', (
    tester,
  ) async {
    await openPage(tester, validators: const []);

    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('No validators found'), findsOneWidget);
  });

  testWidgets('orders APY descending by default and sorts by commission', (
    tester,
  ) async {
    await openPage(tester);

    expect(
      tester.getCenter(find.text('Beta Nodes')).dy,
      lessThan(tester.getCenter(find.text('Alpha Stake')).dy),
    );
    expect(find.text('Beta Nodes'), findsOneWidget);
    await tester.tap(find.text('Commission'));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.text('Alpha Stake')).dy,
      lessThan(tester.getCenter(find.text('Gamma Pool')).dy),
    );
    expect(
      tester.getCenter(find.text('Gamma Pool')).dy,
      lessThan(tester.getCenter(find.text('Beta Nodes')).dy),
    );
    await tester.tap(find.text('Commission'));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.text('Beta Nodes')).dy,
      lessThan(tester.getCenter(find.text('Alpha Stake')).dy),
    );

    await tester.tap(find.text('Staked'));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.text('Gamma Pool')).dy,
      lessThan(tester.getCenter(find.text('Beta Nodes')).dy),
    );
  });

  testWidgets('filters by case-insensitive name and full address', (
    tester,
  ) async {
    await openPage(tester);

    await tester.enterText(find.byType(TextField), 'gAmMa');
    await tester.pumpAndSettle();
    expect(find.text('Gamma Pool'), findsOneWidget);
    expect(find.text('Alpha Stake'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'cosmosvaloper1beta');
    await tester.pumpAndSettle();
    expect(find.text('Beta Nodes'), findsOneWidget);
    expect(find.text('Gamma Pool'), findsNothing);
  });

  testWidgets('clearing a nonmatching query returns the empty state to list', (
    tester,
  ) async {
    await openPage(tester);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.search_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.search_off), findsNothing);
    expect(find.text('Alpha Stake'), findsOneWidget);
  });

  testWidgets('tapping a validator returns it to the caller', (tester) async {
    final selection = Completer<Validator?>();
    await openPage(tester, selection: selection);
    await tester.tap(find.text('Alpha Stake'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(await selection.future, same(_validators.first));
  });

  testWidgets('marks the supplied validator as selected', (tester) async {
    await openPage(tester, selectedValidator: _validators.first);

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
