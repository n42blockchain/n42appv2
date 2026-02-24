// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/widgets/feature_entry_cards.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('EnsEntryCard Widget Tests', () {
    testWidgets('should display register message when no ENS name',
        (WidgetTester tester) async {
      bool onTapCalled = false;
      bool onRegisterCalled = false;

      await tester.pumpWidget(wrapForTest(
        EnsEntryCard(
          ensName: null,
          onTap: () => onTapCalled = true,
          onRegisterTap: () => onRegisterCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Should show ENS text/icon
      expect(find.text('ENS'), findsOneWidget);

      // Tap should trigger onRegisterTap when no ENS name
      await tester.tap(find.byType(EnsEntryCard));
      await tester.pumpAndSettle();

      expect(onRegisterCalled, true);
      expect(onTapCalled, false);
    });

    testWidgets('should display ENS name when provided',
        (WidgetTester tester) async {
      bool onTapCalled = false;
      bool onRegisterCalled = false;

      await tester.pumpWidget(wrapForTest(
        EnsEntryCard(
          ensName: 'alice.eth',
          onTap: () => onTapCalled = true,
          onRegisterTap: () => onRegisterCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Should show the ENS name
      expect(find.text('alice.eth'), findsOneWidget);

      // Should show settings icon for existing ENS
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // Tap should trigger onTap when ENS name exists
      await tester.tap(find.byType(EnsEntryCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, true);
      expect(onRegisterCalled, false);
    });

    testWidgets('should show add icon when no ENS name',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        EnsEntryCard(
          ensName: null,
          onTap: () {},
          onRegisterTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });

  group('SmartAccountEntryCard Widget Tests', () {
    testWidgets('should display create message when no smart account',
        (WidgetTester tester) async {
      bool onTapCalled = false;
      bool onCreateCalled = false;

      await tester.pumpWidget(wrapForTest(
        SmartAccountEntryCard(
          hasSmartAccount: false,
          onTap: () => onTapCalled = true,
          onCreateTap: () => onCreateCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Should show wallet icon
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);

      // Should show add icon when no account
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Tap should trigger onCreateTap
      await tester.tap(find.byType(SmartAccountEntryCard));
      await tester.pumpAndSettle();

      expect(onCreateCalled, true);
      expect(onTapCalled, false);
    });

    testWidgets('should display account info when smart account exists',
        (WidgetTester tester) async {
      bool onTapCalled = false;

      await tester.pumpWidget(wrapForTest(
        SmartAccountEntryCard(
          hasSmartAccount: true,
          accountAddress: '0x1234567890abcdef1234567890abcdef12345678',
          isDeployed: true,
          onTap: () => onTapCalled = true,
          onCreateTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Should show forward arrow for existing account
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);

      // Should show check icon for deployed account
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Tap should trigger onTap
      await tester.tap(find.byType(SmartAccountEntryCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, true);
    });

    testWidgets('should show pending icon when not deployed',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        SmartAccountEntryCard(
          hasSmartAccount: true,
          accountAddress: '0x1234567890abcdef1234567890abcdef12345678',
          isDeployed: false,
          onTap: () {},
          onCreateTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Should show hourglass icon for pending deployment
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    });

    testWidgets('should format address correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        SmartAccountEntryCard(
          hasSmartAccount: true,
          accountAddress: '0x1234567890abcdef1234567890abcdef12345678',
          isDeployed: true,
          onTap: () {},
          onCreateTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Should show truncated address
      expect(find.text('0x12345678...12345678'), findsOneWidget);
    });
  });

  group('FeatureEntryHorizontal Widget Tests', () {
    testWidgets('should display both ENS and AA cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        FeatureEntryHorizontal(
          ensName: null,
          hasSmartAccount: false,
          isSmartAccountDeployed: false,
          onEnsTap: () {},
          onSmartAccountTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Should have horizontal scroll
      expect(find.byType(ListView), findsOneWidget);

      // Should show ENS icon
      expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);

      // Should show wallet icon
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });

    testWidgets('should display ENS name when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        FeatureEntryHorizontal(
          ensName: 'bob.eth',
          hasSmartAccount: false,
          isSmartAccountDeployed: false,
          onEnsTap: () {},
          onSmartAccountTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('bob.eth'), findsOneWidget);
    });

    testWidgets('should trigger correct callbacks',
        (WidgetTester tester) async {
      bool ensClicked = false;
      bool aaClicked = false;

      await tester.pumpWidget(wrapForTest(
        FeatureEntryHorizontal(
          ensName: null,
          hasSmartAccount: false,
          isSmartAccountDeployed: false,
          onEnsTap: () => ensClicked = true,
          onSmartAccountTap: () => aaClicked = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap ENS card (first GestureDetector in list)
      final gestures = find.byType(GestureDetector);
      await tester.tap(gestures.first);
      await tester.pumpAndSettle();

      expect(ensClicked, true);
      expect(aaClicked, false);
    });

    testWidgets('should handle long ENS names without overflow',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        FeatureEntryHorizontal(
          ensName: 'verylongensname.eth',
          hasSmartAccount: false,
          isSmartAccountDeployed: false,
          onEnsTap: () {},
          onSmartAccountTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // FittedBox should handle long text without errors
      expect(find.byType(FittedBox), findsWidgets);
      expect(find.text('verylongensname.eth'), findsOneWidget);
    });
  });

  group('FeatureEntrySection Widget Tests', () {
    testWidgets('should display section title and both cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        FeatureEntrySection(
          ensName: null,
          hasSmartAccount: false,
          onEnsTap: () {},
          onEnsRegisterTap: () {},
          onSmartAccountTap: () {},
          onSmartAccountCreateTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Should show both entry cards
      expect(find.byType(EnsEntryCard), findsOneWidget);
      expect(find.byType(SmartAccountEntryCard), findsOneWidget);
    });

    testWidgets('should pass correct props to child cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        FeatureEntrySection(
          ensName: 'test.eth',
          hasSmartAccount: true,
          smartAccountAddress: '0xabc123',
          isSmartAccountDeployed: true,
          onEnsTap: () {},
          onEnsRegisterTap: () {},
          onSmartAccountTap: () {},
          onSmartAccountCreateTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Verify ENS name is displayed
      expect(find.text('test.eth'), findsOneWidget);

      // Verify deployed status icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('Theme Support Tests', () {
    testWidgets('should render correctly in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        EnsEntryCard(
          ensName: 'theme.eth',
          onTap: () {},
          onRegisterTap: () {},
        ),
        themeMode: ThemeMode.light,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EnsEntryCard), findsOneWidget);
    });

    testWidgets('should render correctly in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapForTest(
        EnsEntryCard(
          ensName: 'theme.eth',
          onTap: () {},
          onRegisterTap: () {},
        ),
        themeMode: ThemeMode.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EnsEntryCard), findsOneWidget);
    });
  });
}
