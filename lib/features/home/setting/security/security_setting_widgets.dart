// ignore_for_file: invalid_use_of_protected_member
part of 'security_setting.dart';

// ── Security setting widget components ───────────────────────────────────────

extension on _SecuritySettingState {
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.space4),
      child: Text(
        title,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).textPrimary,
        ),
      ),
    );
  }

  Widget buildNavigationWidget({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = AppColorTokens.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brMd,
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInset,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.space2),
                decoration: BoxDecoration(
                  color: colors.brandSubtle,
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(icon, color: colors.brand),
              ),
              SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.space2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: colors.textSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.space4),
              Icon(Icons.chevron_right, color: colors.textSubtitle),
            ],
          ),
        ),
      ),
    );
  }

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
