import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/constants/app_colors.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// Theme options configuration
class _ThemeOption {
  final ThemeMode mode;
  final String icon;
  final String Function(BuildContext) labelBuilder;
  final Color bgColor;
  final Color textColor;

  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.labelBuilder,
    required this.bgColor,
    required this.textColor,
  });
}

final _themeOptions = [
  _ThemeOption(
    mode: ThemeMode.dark,
    icon: "assets/home/setting/dark_model.png",
    labelBuilder: (ctx) => S.of(ctx).g_key_129,
    bgColor: AppColors.darkThemeBg,
    textColor: AppColors.darkThemeText,
  ),
  _ThemeOption(
    mode: ThemeMode.light,
    icon: "assets/home/setting/light_model.png",
    labelBuilder: (ctx) => S.of(ctx).g_key_128,
    bgColor: AppColors.lightThemeBg,
    textColor: AppColors.lightThemeText,
  ),
  _ThemeOption(
    mode: ThemeMode.system,
    icon: "assets/home/setting/sys_m.png",
    labelBuilder: (ctx) => S.of(ctx).g_key_127,
    bgColor: AppColors.systemThemeBg,
    textColor: AppColors.systemThemeBgDark,
  ),
];

class SettingTheme extends ConsumerWidget {
  const SettingTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_126),
      body: ListView.builder(
        itemCount: _themeOptions.length,
        itemBuilder: (context, index) {
          final option = _themeOptions[index];
          return _ThemeItem(
            option: option,
            isSelected: currentMode == option.mode,
            onTap: () => ref.read(themeModeProvider.notifier).setTheme(option.mode),
          );
        },
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  final _ThemeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeItem({required this.option, required this.isSelected, required this.onTap});

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
          color: option.bgColor,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Row(
          children: [
            Image.asset(option.icon, width: ScreenUtil().setWidth(32), color: option.textColor),
            SizedBox(width: ScreenUtil().setWidth(30)),
            Text(
              option.labelBuilder(context),
              style: TextStyle(color: option.textColor, fontSize: ScreenUtil().setSp(32)),
            ),
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
