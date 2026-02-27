part of 'aa_home_page.dart';

/// UI builder widgets for [_AAHomePageState].
///
/// Extracted from the main file to keep each file under 500 lines.
/// All methods here are private extensions of [_AAHomePageState].
extension _AAHomePageWidgets on _AAHomePageState {
  Widget buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withAlpha(30),
            const Color(0xFF8B5CF6).withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(56),
                height: ScreenUtil().setWidth(56),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withAlpha(30),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                ),
                child: Center(
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: ScreenUtil().setWidth(32),
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).g_key_aa_smart_accounts,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      S.of(context).g_key_aa_description,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          // 利益卡片
          buildBenefitCard(
            Icons.local_gas_station_outlined,
            S.of(context).g_key_aa_benefit_gas_title,
            S.of(context).g_key_aa_benefit_gas_desc,
            const Color(0xFF5E97F6),
          ),
          buildBenefitCard(
            Icons.layers_outlined,
            S.of(context).g_key_aa_benefit_batch_title,
            S.of(context).g_key_aa_benefit_batch_desc,
            const Color(0xFFFF9800),
          ),
          buildBenefitCard(
            Icons.people_outline,
            S.of(context).g_key_aa_benefit_recovery_title,
            S.of(context).g_key_aa_benefit_recovery_desc,
            const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget buildBenefitCard(IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ScreenUtil().setWidth(40),
            height: ScreenUtil().setWidth(40),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
            ),
            child: Center(
              child: Icon(icon, size: ScreenUtil().setWidth(22), color: color),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(2)),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFeatureCards() {
    return Row(
      children: [
        Expanded(
          child: buildFeatureCard(
            icon: Icons.send,
            title: S.of(context).g_key_48,
            subtitle: S.of(context).g_key_aa_send_desc,
            color: const Color(0xFF5E97F6),
            onTap: accounts.isNotEmpty
                ? () => navigateToSend(accounts.first)
                : null,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: buildFeatureCard(
            icon: Icons.layers,
            title: S.of(context).g_key_aa_batch,
            subtitle: S.of(context).g_key_aa_batch_desc,
            color: const Color(0xFFFF9800),
            onTap: accounts.isNotEmpty
                ? () => navigateToBatchTransaction(accounts.first)
                : null,
          ),
        ),
      ],
    );
  }

  Widget buildAdvancedFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_advanced_features,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        buildFeatureCard(
          icon: Icons.key,
          title: S.of(context).g_key_aa_session_keys,
          subtitle: S.of(context).g_key_aa_session_keys_desc,
          color: const Color(0xFF8B5CF6),
          onTap: accounts.isNotEmpty
              ? () => navigateToSessionKeys(accounts.first)
              : null,
        ),
      ],
    );
  }

  Widget buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).g_key_aa_create_first),
                ),
              );
            }
          : onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isDisabled ? Colors.grey.withAlpha(30) : color.withAlpha(40),
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Icon(
                  icon,
                  size: ScreenUtil().setWidth(24),
                  color: color,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(12)),
              Text(
                title,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_aa_my_accounts,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            if (accounts.isNotEmpty)
              TextButton(
                onPressed: navigateToAccountList,
                child: Text(S.of(context).g_key_aa_view_all),
              ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
        if (accounts.isEmpty)
          buildEmptyState()
        else
          buildAccountsList(),
      ],
    );
  }

  Widget buildEmptyState() {
    final steps = [
      S.of(context).g_key_aa_onboard_step1,
      S.of(context).g_key_aa_onboard_step2,
      S.of(context).g_key_aa_onboard_step3,
    ];
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: const Color(0xFF6366F1).withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_aa_no_accounts,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ...List.generate(steps.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
              child: Row(
                children: [
                  Container(
                    width: ScreenUtil().setWidth(28),
                    height: ScreenUtil().setWidth(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(20),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildAccountsList() {
    // 显示最多 3 个账户
    final displayAccounts = accounts.take(3).toList();

    return Column(
      children: displayAccounts.map((account) {
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
          child: SmartAccountCard(
            account: account,
            onTap: () => navigateToAccountDetail(account),
          ),
        );
      }).toList(),
    );
  }
}
