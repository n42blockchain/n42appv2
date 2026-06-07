import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/constants/app_colors.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

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

// ── Preset accent colors ──────────────────────────────────────────────────

const _presetAccents = [
  Color(0xFF1976F9), // default blue
  Color(0xFF009688), // teal
  Color(0xFF7B1FA2), // purple
  Color(0xFFF57C00), // orange
  Color(0xFF388E3C), // green
  Color(0xFFC62828), // red
  Color(0xFFE91E63), // pink
  Color(0xFF303F9F), // indigo
];

class SettingTheme extends ConsumerWidget {
  const SettingTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final currentAccent = ref.watch(accentColorProvider);
    final isDefault =
        currentAccent.toARGB32() == ThemeAdapter.defaultAccent.toARGB32();

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_126),
      body: ListView(
        children: [
          // ── Theme mode section ────────────────────────────────────────
          ...List.generate(_themeOptions.length, (index) {
            final option = _themeOptions[index];
            return _ThemeItem(
              option: option,
              isSelected: currentMode == option.mode,
              onTap: () =>
                  ref.read(themeModeProvider.notifier).setTheme(option.mode),
            );
          }),

          // ── Accent color section ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.space8,
              AppSpacing.space8,
              AppSpacing.space8,
              AppSpacing.space2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    S.of(context).g_theme_accent_color,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headline.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withAlpha(180),
                    ),
                  ),
                ),
                if (!isDefault)
                  InkWell(
                    onTap: () => ref.read(accentColorProvider.notifier).reset(),
                    child: Text(
                      S.of(context).g_theme_accent_reset,
                      style: AppTypography.bodySm.copyWith(
                        color: currentAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space2,
            ),
            child: Wrap(
              spacing: AppSpacing.space4,
              runSpacing: AppSpacing.space4,
              children: _presetAccents.map((color) {
                final selected = color.toARGB32() == currentAccent.toARGB32();
                return GestureDetector(
                  onTap: () =>
                      ref.read(accentColorProvider.notifier).setAccent(color),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    width: ScreenUtil().setWidth(60),
                    height: ScreenUtil().setWidth(60),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(120),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: AppSpacing.space6),
        ],
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  final _ThemeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space8,
            ),
            decoration: BoxDecoration(
              color: option.bgColor,
              borderRadius: AppRadius.brMd,
            ),
            child: Row(
              children: [
                Image.asset(
                  option.icon,
                  width: ScreenUtil().setWidth(32),
                  color: option.textColor,
                ),
                SizedBox(width: AppSpacing.space8),
                Text(
                  option.labelBuilder(context),
                  style: AppTypography.body.copyWith(color: option.textColor),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: ScreenUtil().setWidth(48),
                    color: AppColorTokens.of(context).brand,
                  )
                else
                  SizedBox(width: AppSpacing.space12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
