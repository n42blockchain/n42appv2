// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

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
        itemCount: kSupportedLanguages.length,
        itemBuilder: (context, index) {
          final language = kSupportedLanguages[index];
          final isSelected = isLanguageSelected(currentCode, language.code);

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
    return languageCodeFromLocale(locale);
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
              color: Colors.black.withValues(alpha: 0.05),
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
                errorBuilder: (_, _, _) => Container(
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
