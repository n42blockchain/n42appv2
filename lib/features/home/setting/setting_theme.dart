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
  Color(0xFF5B6CFF), // default indigo
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

    final currentStyle = AppStylePresets.match(currentAccent, currentMode);

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_126),
      body: ListView(
        children: [
          // ── Style preset section ──────────────────────────────────────
          _SectionHeader(
            title: S.of(context).g_theme_style,
            subtitle: currentStyle == null
                ? S.of(context).g_theme_style_custom
                : currentStyle.name,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
            child: Wrap(
              spacing: AppSpacing.space4,
              runSpacing: AppSpacing.space4,
              children: AppStylePresets.all.map((preset) {
                return _StylePresetCard(
                  preset: preset,
                  selected: currentStyle?.id == preset.id,
                  onTap: () {
                    ref
                        .read(accentColorProvider.notifier)
                        .setAccent(preset.accent);
                    ref.read(themeModeProvider.notifier).setTheme(preset.mode);
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: AppSpacing.space8),

          // ── Theme mode section ────────────────────────────────────────
          _SectionHeader(title: S.of(context).g_theme_mode),
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
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        ref.read(accentColorProvider.notifier).setAccent(color),
                    customBorder: const CircleBorder(),
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
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
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

// ── Section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.headline.copyWith(
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          if (subtitle != null)
            Flexible(
              child: Text(
                subtitle!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTypography.bodySm.copyWith(
                  color: AppColorTokens.of(context).brand,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Style preset card ─────────────────────────────────────────────────────

class _StylePresetCard extends StatelessWidget {
  final StylePreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _StylePresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  IconData get _modeIcon => switch (preset.mode) {
    ThemeMode.dark => Icons.dark_mode_rounded,
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.system => Icons.brightness_auto_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brLg,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: ScreenUtil().setWidth(328),
          padding: EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: c.bgSurface,
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color: selected ? preset.accent : c.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 品牌色预览：强调底 + 模式图标 + mini CTA 暗示
              Container(
                height: ScreenUtil().setWidth(96),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [preset.accent, preset.accent.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.brMd,
                ),
                padding: EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _modeIcon,
                          color: Colors.white,
                          size: ScreenUtil().setWidth(28),
                        ),
                        const Spacer(),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: ScreenUtil().setWidth(30),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // mini 按钮 + 文本条，暗示该色驱动全 App CTA/强调
                    Row(
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(64),
                          height: ScreenUtil().setWidth(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.brPill,
                          ),
                        ),
                        SizedBox(width: AppSpacing.space2),
                        Container(
                          width: ScreenUtil().setWidth(40),
                          height: ScreenUtil().setWidth(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(90),
                            borderRadius: AppRadius.brPill,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.space4),
              Text(
                preset.name,
                style: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
              ),
              SizedBox(height: AppSpacing.space2),
              Text(
                preset.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.captionSm.copyWith(color: c.textSubtitle),
              ),
            ],
          ),
        ),
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
