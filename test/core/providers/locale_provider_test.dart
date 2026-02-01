// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with English locale by default', () async {
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'en');
    });

    test('getLocaleInfo should return correct info for English', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('en'));

      expect(info['title'], 'English');
      expect(info['icon'], contains('english'));
    });

    test('getLocaleInfo should fallback to English for Chinese Simplified', () async {
      // Note: Chinese is not in kSupportedLanguages, so it falls back to English
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('zh', 'CN'));

      expect(info['title'], 'English');
      expect(info['icon'], contains('english'));
    });

    test('getLocaleInfo should fallback to English for Chinese Traditional', () async {
      // Note: Chinese is not in kSupportedLanguages, so it falls back to English
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('zh', 'TW'));

      expect(info['title'], 'English');
      expect(info['icon'], contains('english'));
    });

    test('getLocaleInfo should return correct info for Japanese', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('ja'));

      expect(info['title'], '日本語');
      expect(info['icon'], contains('japanese'));
    });

    test('getLocaleInfo should return correct info for Spanish', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('es'));

      expect(info['title'], 'Español');
      expect(info['icon'], contains('spanish'));
    });

    test('getLocaleInfo should fallback to English for unknown locale', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('unknown'));

      expect(info['title'], 'English');
    });
  });

  group('Locale Utilities', () {
    test('Locale should be created correctly', () {
      const enLocale = Locale('en');
      const zhCNLocale = Locale('zh', 'CN');
      const zhTWLocale = Locale('zh', 'TW');

      expect(enLocale.languageCode, 'en');
      expect(zhCNLocale.languageCode, 'zh');
      expect(zhCNLocale.countryCode, 'CN');
      expect(zhTWLocale.countryCode, 'TW');
    });
  });
}
