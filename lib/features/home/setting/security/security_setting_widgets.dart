// ignore_for_file: invalid_use_of_protected_member
part of 'security_setting.dart';

// ── Security setting widget components ───────────────────────────────────────

extension on _SecuritySettingState {
  Widget buildOpenWidget(
    String title,
    bool value,
    Function valueChange, {
    bool enabled = true,
  }) {
    final titleColor = AppThemeUtils.getColorByKey(
      context,
      enabled
          ? AppThemeKeys.mainTextColor.name
          : AppThemeKeys.itemSubtitleTextColor.name,
    );
    return Container(
      height: ScreenUtil().setWidth(88.0),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.body.copyWith(color: titleColor),
            ),
          ),
          Switch(
            activeTrackColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonBgColor.name,
            ),
            value: value,
            onChanged: enabled ? (v) => valueChange(v) : null,
          ),
        ],
      ),
    );
  }
}
