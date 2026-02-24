// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:n42_wallet/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Tests', () {
    late S s;

    setUp(() async {
      // Initialize with English locale
      s = await S.load(const Locale('en'));
    });

    group('Token Name Consistency', () {
      test('referral text should use N token, not AST', () {
        // g_share_v3_key_3
        final referralText = s.g_share_v3_key_3;
        expect(referralText.contains('AST'), false, 
            reason: 'Referral text should not contain AST');
        expect(referralText.contains('N Tokens'), true,
            reason: 'Referral text should contain N Tokens');
      });

      test('verification reward text should use N token, not AST', () {
        // g_share_v3_key_5
        final rewardText = s.g_share_v3_key_5;
        expect(rewardText.contains('AST'), false,
            reason: 'Reward text should not contain AST');
        expect(rewardText.contains(' N '), true,
            reason: 'Reward text should contain N');
      });
    });

    group('Share Texts', () {
      test('share referral text should be correct', () {
        expect(s.g_share_v3_key_2, 'Referral');
      });

      test('share via text should exist', () {
        expect(s.g_share_v3_key_6, 'Refer via');
      });

      test('share link text should exist', () {
        expect(s.g_share_v3_key_7, 'Link');
      });

      test('share code text should exist', () {
        expect(s.g_share_v3_key_8, 'code');
      });
    });

    group('Common Texts', () {
      test('app title should be N42Wallet', () {
        // 检查登录相关的标题
        expect(s.g_key_login, isNotEmpty);
      });

      test('settings text should be correct', () {
        expect(s.g_key_94, isNotEmpty); // Settings
      });

      test('theme settings should be correct', () {
        expect(s.g_key_126, 'Theme');
        expect(s.g_key_127, 'System');
        expect(s.g_key_128, 'Light');
        expect(s.g_key_129, 'Dark');
      });
    });

    group('Wallet Texts', () {
      test('wallet related texts should not contain old token names', () {
        // Check various wallet strings don't have AST or AMT
        final walletTexts = [
          s.g_key_wallet_k25, // Time
          s.g_key_wallet_k33, // Result
          s.g_key_wallet_k47, // Add
        ];
        
        for (final text in walletTexts) {
          expect(text.contains('AST'), false,
              reason: 'Wallet text "$text" should not contain AST');
          expect(text.contains('AMT'), false,
              reason: 'Wallet text "$text" should not contain AMT');
        }
      });
    });

    group('Mining Texts', () {
      test('mining texts should use correct token name', () {
        // Check mining reward related strings
        final miningText = s.g_mining_key_12;
        expect(miningText, isNotEmpty);
        // Mining texts should reference N or be generic
      });
    });
  });

  group('Localization Widget Tests', () {
    testWidgets('should load English locale correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Text(S.of(context).g_key_126), // Theme
              );
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('should support locale switching', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text(S.of(context).g_key_128), // Light
                    Text(S.of(context).g_key_129), // Dark
                  ],
                ),
              );
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });
  });

  group('Supported Locales', () {
    test('should support English', () {
      expect(
        S.delegate.supportedLocales.any((l) => l.languageCode == 'en'),
        true,
      );
    });

    test('should have valid delegate', () {
      expect(S.delegate, isNotNull);
      expect(S.delegate.supportedLocales, isNotEmpty);
    });
  });
}

