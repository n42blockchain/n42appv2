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

/// Theme Setting Page - Riverpod Version
///
/// Demonstrates migration from Provider to Riverpod.
/// Uses ConsumerStatefulWidget for stateful logic with Riverpod.
class SettingThemePage extends ConsumerWidget {
  const SettingThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from Riverpod
    final themeMode = ref.watch(themeModeProvider);
    final themeModeType = _themeModeToInt(themeMode);

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_126,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dark Mode
          _ThemeOptionItem(
            imagePath: "assets/home/setting/dark_model.png",
            label: S.of(context).g_key_129,
            isSelected: themeModeType == 2,
            backgroundColor: const Color(0xff1E1E1E),
            fontColor: const Color(0xffffffff),
            onTap: () => _switchTheme(ref, 2),
          ),
          
          // Light Mode
          _ThemeOptionItem(
            imagePath: "assets/home/setting/light_model.png",
            label: S.of(context).g_key_128,
            isSelected: themeModeType == 1,
            backgroundColor: const Color(0xffffffff),
            fontColor: const Color(0xff121212),
            onTap: () => _switchTheme(ref, 1),
          ),
          
          // System Mode
          _ThemeOptionItem(
            imagePath: "assets/home/setting/sys_m.png",
            label: S.of(context).g_key_127,
            isSelected: themeModeType == 0,
            backgroundColor: const Color(0xffBEBEBE),
            fontColor: const Color(0xff373739),
            onTap: () => _switchTheme(ref, 0),
          ),
        ],
      ),
    );
  }

  void _switchTheme(WidgetRef ref, int type) {
    final notifier = ref.read(themeModeProvider.notifier);
    switch (type) {
      case 0:
        notifier.setTheme(ThemeMode.system);
        break;
      case 1:
        notifier.setTheme(ThemeMode.light);
        break;
      case 2:
        notifier.setTheme(ThemeMode.dark);
        break;
    }
  }

  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }
}

/// Theme Option Item Widget
class _ThemeOptionItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isSelected;
  final Color backgroundColor;
  final Color fontColor;
  final VoidCallback onTap;

  const _ThemeOptionItem({
    required this.imagePath,
    required this.label,
    required this.isSelected,
    required this.backgroundColor,
    required this.fontColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Column(
          children: [
            SizedBox(height: ScreenUtil().setWidth(34)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: ScreenUtil().setWidth(36)),
                Image.asset(
                  imagePath,
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                  fit: BoxFit.cover,
                  color: fontColor,
                ),
                SizedBox(width: ScreenUtil().setWidth(30)),
                Text(
                  label,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: ScreenUtil().setSp(32),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: ScreenUtil().setWidth(48),
                    color: const Color(0xFF448BDF),
                  )
                else
                  SizedBox(width: ScreenUtil().setWidth(48)),
                SizedBox(width: ScreenUtil().setWidth(40)),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(34)),
          ],
        ),
      ),
    );
  }
}

