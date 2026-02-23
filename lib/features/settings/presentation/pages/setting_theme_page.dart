// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/constants/app_colors.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

/// Theme options configuration
const _themeConfigs = <(ThemeMode, String, Color, Color)>[
  (ThemeMode.dark, "assets/home/setting/dark_model.png", AppColors.darkThemeBg, AppColors.darkThemeText),
  (ThemeMode.light, "assets/home/setting/light_model.png", AppColors.lightThemeBg, AppColors.lightThemeText),
  (ThemeMode.system, "assets/home/setting/sys_m.png", AppColors.systemThemeBg, AppColors.systemThemeBgDark),
];

String _getLabel(BuildContext context, ThemeMode mode) => switch (mode) {
  ThemeMode.dark => S.of(context).g_key_129,
  ThemeMode.light => S.of(context).g_key_128,
  ThemeMode.system => S.of(context).g_key_127,
};

class SettingThemePage extends ConsumerWidget {
  const SettingThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_126),
      body: Column(
        children: [
          for (final (mode, icon, bgColor, textColor) in _themeConfigs)
            _ThemeOptionItem(
              imagePath: icon,
              label: _getLabel(context, mode),
              isSelected: currentMode == mode,
              backgroundColor: bgColor,
              fontColor: textColor,
              onTap: () => ref.read(themeModeProvider.notifier).setTheme(mode),
            ),
        ],
      ),
    );
  }
}

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
        margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(36),
          vertical: ScreenUtil().setWidth(34),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: ScreenUtil().setWidth(32), color: fontColor),
            SizedBox(width: ScreenUtil().setWidth(30)),
            Text(label, style: TextStyle(color: fontColor, fontSize: ScreenUtil().setSp(32))),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, size: ScreenUtil().setWidth(48), color: AppColors.primaryBlue)
            else
              SizedBox(width: ScreenUtil().setWidth(48)),
          ],
        ),
      ),
    );
  }
}
