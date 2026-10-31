import 'package:n42_wallet/features/browser/pages/browser_setting.dart';
import 'package:n42_wallet/features/home/setting/setting_sys_language.dart';
import 'package:n42_wallet/features/home/setting/setting_theme.dart';
import 'package:n42_wallet/features/home/widgets/nav_setting_item.dart';
import 'package:n42_wallet/features/mining_v3/pages/mobileverify_debug_page.dart';
import 'package:n42_wallet/core/enums/mining_engine_kind.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Setting Home Page - Migrated to Riverpod
///
/// This page demonstrates Riverpod integration:
/// - Uses ConsumerWidget for automatic state updates
/// - Watches localeProvider for current language
/// - No manual initState/setState needed for language changes
class SettingHomePage extends ConsumerWidget {
  const SettingHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale from Riverpod - automatically updates when language changes
    final locale = ref.watch(localeProvider);
    final localeCode = _getLocaleCode(locale);

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_94),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space8,
        ),
        child: Column(children: [_buildNavEnter(context, ref, localeCode)]),
      ),
    );
  }

  /// Convert Locale to language code string
  String _getLocaleCode(Locale locale) {
    return languageCodeFromLocale(locale);
  }

  Widget _settingCard(BuildContext context, {required Widget child}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: AppColorTokens.of(context).bgSurface,
      ),
      child: child,
    );
  }

  Widget _buildNavEnter(
    BuildContext context,
    WidgetRef ref,
    String appSysLang,
  ) {
    return Column(
      children: [
        _settingCard(
          context,
          child: NavSettingItem(
            path: "assets/home/setting/language.png",
            action: S.of(context).s_key_4,
            imgColor: AppColorTokens.of(context).brand,
            callback: () async {
              final returnStr = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingSysLanguage(appSysLang),
                ),
              );
              if (!context.mounted) return;
              if (returnStr != null && returnStr is String) {
                ref.read(localeProvider.notifier).setLocale(returnStr);
              }
            },
          ),
        ),
        _settingCard(
          context,
          child: NavSettingItem(
            path: "assets/home/setting/nav_img_7.png",
            action: S.of(context).g_key_126,
            imgColor: AppColorTokens.of(context).brand,
            callback: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingTheme()));
            },
          ),
        ),
        _settingCard(
          context,
          child: NavSettingItem(
            path: "assets/home/setting/nav_img_2.png",
            action: S.of(context).g_browser_key11,
            imgColor: AppColorTokens.of(context).brand,
            callback: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => BrowserSetting()));
            },
          ),
        ),
        _settingCard(context, child: _buildMiningVersionToggle(context, ref)),
        // Mining v3 (mobileverify) phase 1 probe; debug builds only.
        if (kDebugMode)
          _settingCard(
            context,
            child: NavSettingItem(
              path: 'assets/home/setting/mining.png',
              action: 'Mining v3 probe',
              imgColor: AppColorTokens.of(context).brand,
              callback: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MobileVerifyDebugPage(),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMiningVersionToggle(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(miningEngineKindProvider);
    final kinds = [
      MiningEngineKind.v1,
      MiningEngineKind.v2,
      if (miningV3Available) MiningEngineKind.v3,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/home/setting/mining.png',
            width: ScreenUtil().setWidth(40),
            color: AppColorTokens.of(context).brand,
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).g_setting_mining_version,
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                Text(
                  _miningEngineLabel(context, engine),
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                SegmentedButton<MiningEngineKind>(
                  segments: [
                    for (final kind in kinds)
                      ButtonSegment(
                        value: kind,
                        label: Text(kind.name.toUpperCase()),
                      ),
                  ],
                  selected: {engine},
                  showSelectedIcon: false,
                  onSelectionChanged: (selected) => ref
                      .read(miningEngineKindProvider.notifier)
                      .select(selected.single),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _miningEngineLabel(
    BuildContext context,
    MiningEngineKind kind,
  ) => switch (kind) {
    MiningEngineKind.v1 => S.of(context).g_setting_mining_v1_label,
    MiningEngineKind.v2 => S.of(context).g_setting_mining_v2_label,
    // v3 is not offered to users yet (miningV3Available); localise it
    // when it is.
    MiningEngineKind.v3 => 'Mobile verification (V3)',
  };
}
