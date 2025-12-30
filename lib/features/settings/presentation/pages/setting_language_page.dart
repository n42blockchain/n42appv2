// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/generated/l10n.dart';

/// Language data model
class LanguageItem {
  final String code;
  final String name;
  final String icon;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.icon,
  });
}

/// Available languages
const List<LanguageItem> _languages = [
  LanguageItem(code: 'en', name: 'English', icon: 'assets/setting/english.png'),
  LanguageItem(code: 'zh_CN', name: '中文简体', icon: 'assets/setting/chinese.png'),
  LanguageItem(code: 'zh_TW', name: '中文繁體', icon: 'assets/setting/chinese_tw.png'),
  LanguageItem(code: 'ja', name: '日本語', icon: 'assets/setting/japanese.png'),
  LanguageItem(code: 'ko', name: '한국어', icon: 'assets/setting/korean.png'),
  LanguageItem(code: 'es_ES', name: 'Español', icon: 'assets/setting/spanish.png'),
  LanguageItem(code: 'fr', name: 'Français', icon: 'assets/setting/french.png'),
  LanguageItem(code: 'de', name: 'Deutsch', icon: 'assets/setting/german.png'),
  LanguageItem(code: 'it', name: 'Italiano', icon: 'assets/setting/italian.png'),
  LanguageItem(code: 'pt', name: 'Português', icon: 'assets/setting/portuguese.png'),
  LanguageItem(code: 'ru', name: 'Русский', icon: 'assets/setting/russian.png'),
  LanguageItem(code: 'vi', name: 'Tiếng Việt', icon: 'assets/setting/vietnamese.png'),
  LanguageItem(code: 'th', name: 'ไทย', icon: 'assets/setting/thai.png'),
  LanguageItem(code: 'id', name: 'Bahasa Indonesia', icon: 'assets/setting/indonesian.png'),
  LanguageItem(code: 'tr', name: 'Türkçe', icon: 'assets/setting/turkish.png'),
];

/// Language Setting Page - Riverpod Version
class SettingLanguagePage extends ConsumerWidget {
  const SettingLanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final currentCode = _localeToCode(locale);

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_4, // "Language"
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(20),
        ),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = currentCode == language.code;

          return _LanguageOptionItem(
            language: language,
            isSelected: isSelected,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(language.code);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  String _localeToCode(Locale locale) {
    if (locale.countryCode != null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}

/// Language Option Item
class _LanguageOptionItem extends StatelessWidget {
  final LanguageItem language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionItem({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(24),
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: isSelected
              ? Border.all(color: const Color(0xFF448BDF), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag icon (if exists)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                language.icon,
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setWidth(32),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(32),
                  color: Colors.grey[300],
                  child: const Icon(Icons.language, size: 20),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(24)),
            
            // Language name
            Expanded(
              child: Text(
                language.name,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            
            // Check mark
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF448BDF),
                size: ScreenUtil().setWidth(44),
              ),
          ],
        ),
      ),
    );
  }
}

