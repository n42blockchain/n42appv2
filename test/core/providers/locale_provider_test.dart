// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
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

    test('should set Chinese Simplified locale', () async {
      container.read(localeProvider.notifier).setLocale('zh_CN');
      await Future.delayed(const Duration(milliseconds: 50));
      
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'zh');
      expect(locale.countryCode, 'CN');
    });

    test('should set Chinese Traditional locale', () async {
      container.read(localeProvider.notifier).setLocale('zh_TW');
      await Future.delayed(const Duration(milliseconds: 50));
      
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'zh');
      expect(locale.countryCode, 'TW');
    });

    test('should set Spanish locale', () async {
      container.read(localeProvider.notifier).setLocale('es_ES');
      await Future.delayed(const Duration(milliseconds: 50));
      
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'es');
      expect(locale.countryCode, 'ES');
    });

    test('should set Japanese locale', () async {
      container.read(localeProvider.notifier).setLocale('ja');
      await Future.delayed(const Duration(milliseconds: 50));
      
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'ja');
    });

    test('should get correct locale info for English', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('en'));
      
      expect(info['title'], 'English');
      expect(info['icon'], contains('english'));
    });

    test('should get correct locale info for Chinese Simplified', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('zh', 'CN'));
      
      expect(info['title'], '中文简体');
      expect(info['icon'], contains('chinese'));
    });

    test('should get correct locale info for Chinese Traditional', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('zh', 'TW'));
      
      expect(info['title'], '中文繁體');
      expect(info['icon'], contains('chinese_tw'));
    });

    test('should get correct locale info for Japanese', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('ja'));
      
      expect(info['title'], '日本語');
      expect(info['icon'], contains('japanese'));
    });

    test('should get correct locale info for Spanish', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('es'));
      
      expect(info['title'], 'España');
      expect(info['icon'], contains('spanish'));
    });

    test('should fallback to English for unknown locale', () async {
      final notifier = container.read(localeProvider.notifier);
      final info = notifier.getLocaleInfo(const Locale('unknown'));
      
      expect(info['title'], 'English');
    });

    test('should notify listeners on locale change', () async {
      int notifyCount = 0;
      
      container.listen<Locale>(
        localeProvider,
        (previous, next) {
          notifyCount++;
        },
        fireImmediately: false,
      );
      
      container.read(localeProvider.notifier).setLocale('zh_CN');
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(notifyCount, greaterThanOrEqualTo(1));
    });
  });
}

