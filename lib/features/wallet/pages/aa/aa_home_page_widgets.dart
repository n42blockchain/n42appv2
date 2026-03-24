part of 'aa_home_page.dart';

/// UI builder widgets for [_AAHomePageState].
///
/// Extracted from the main file to keep each file under 500 lines.
/// All methods here are private extensions of [_AAHomePageState].
extension _AAHomePageWidgets on _AAHomePageState {
  static const _kAccentColor = Color(0xFF6366F1);
  static const _kSecondaryAccent = Color(0xFF8B5CF6);
  static const _kBlue = Color(0xFF5E97F6);
  static const _kOrange = Color(0xFFFF9800);
  static const _kGreen = Color(0xFF4CAF50);

  Color _mainTextColor() => AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainTextColor.name,
      );

  Color _subtitleTextColor() => AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.itemSubtitleTextColor.name,
      );

  Color _itemBgColor() => AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.itemBgColor.name,
      );

  Widget buildHeaderCard() {
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;

    return Container(
      padding: EdgeInsets.all(sw(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kAccentColor.withAlpha(30),
            _kSecondaryAccent.withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sw(56),
                height: sw(56),
                decoration: BoxDecoration(
                  color: _kAccentColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(sw(16)),
                ),
                child: Center(
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: sw(32),
                    color: _kAccentColor,
                  ),
                ),
              ),
              SizedBox(width: sw(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).g_key_aa_smart_accounts,
                      style: TextStyle(
                        fontSize: sp(32),
                        fontWeight: FontWeight.bold,
                        color: _mainTextColor(),
                      ),
                    ),
                    SizedBox(height: sw(4)),
                    Text(
                      S.of(context).g_key_aa_description,
                      style: TextStyle(
                        fontSize: sp(24),
                        color: _subtitleTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sw(20)),
          buildBenefitCard(
            Icons.local_gas_station_outlined,
            S.of(context).g_key_aa_benefit_gas_title,
            S.of(context).g_key_aa_benefit_gas_desc,
            _kBlue,
          ),
          buildBenefitCard(
            Icons.layers_outlined,
            S.of(context).g_key_aa_benefit_batch_title,
            S.of(context).g_key_aa_benefit_batch_desc,
            _kOrange,
          ),
          buildBenefitCard(
            Icons.people_outline,
            S.of(context).g_key_aa_benefit_recovery_title,
            S.of(context).g_key_aa_benefit_recovery_desc,
            _kGreen,
          ),
        ],
      ),
    );
  }

  Widget buildBenefitCard(IconData icon, String title, String desc, Color color) {
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;

    return Padding(
      padding: EdgeInsets.only(bottom: sw(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(sw(40), sw(10), color, Icon(icon, size: sw(22), color: color)),
          SizedBox(width: sw(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sp(24),
                    fontWeight: FontWeight.w600,
                    color: _mainTextColor(),
                  ),
                ),
                SizedBox(height: sw(2)),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: sp(22),
                    color: _subtitleTextColor(),
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
    final sw = ScreenUtil().setWidth;
    final canUseAa = _hasOwnerAddress;

    return Row(
      children: [
        Expanded(
          child: buildFeatureCard(
            icon: Icons.send,
            title: S.of(context).g_key_48,
            subtitle: S.of(context).g_key_aa_send_desc,
            color: _kBlue,
            onTap: canUseAa && accounts.isNotEmpty
                ? () => navigateToSend(accounts.first)
                : null,
            disabledHint: canUseAa
                ? S.of(context).g_key_aa_create_first
                : S.of(context).g_key_bridge_chain_not_supported,
          ),
        ),
        SizedBox(width: sw(12)),
        Expanded(
          child: buildFeatureCard(
            icon: Icons.layers,
            title: S.of(context).g_key_aa_batch,
            subtitle: S.of(context).g_key_aa_batch_desc,
            color: _kOrange,
            onTap: canUseAa && accounts.isNotEmpty
                ? () => navigateToBatchTransaction(accounts.first)
                : null,
            disabledHint: canUseAa
                ? S.of(context).g_key_aa_create_first
                : S.of(context).g_key_bridge_chain_not_supported,
          ),
        ),
      ],
    );
  }

  Widget buildAdvancedFeatures() {
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;
    final canUseAa = _hasOwnerAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_advanced_features,
          style: TextStyle(
            fontSize: sp(26),
            fontWeight: FontWeight.w600,
            color: _mainTextColor(),
          ),
        ),
        SizedBox(height: sw(12)),
        buildFeatureCard(
          icon: Icons.key,
          title: S.of(context).g_key_aa_session_keys,
          subtitle: S.of(context).g_key_aa_session_keys_desc,
          color: _kSecondaryAccent,
          onTap: canUseAa && accounts.isNotEmpty
              ? () => navigateToSessionKeys(accounts.first)
              : null,
          disabledHint: canUseAa
              ? S.of(context).g_key_aa_create_first
              : S.of(context).g_key_bridge_chain_not_supported,
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
    String? disabledHint,
  }) {
    final isDisabled = onTap == null;
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;

    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    disabledHint ?? S.of(context).g_key_aa_create_first,
                  ),
                ),
              );
            }
          : onTap,
      child: Container(
        padding: EdgeInsets.all(sw(20)),
        decoration: BoxDecoration(
          color: _itemBgColor(),
          borderRadius: BorderRadius.circular(sw(16)),
          border: Border.all(
            color: isDisabled ? Colors.grey.withAlpha(30) : color.withAlpha(40),
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(sw(44), sw(12), color, Icon(icon, size: sw(24), color: color)),
              SizedBox(height: sw(12)),
              Text(
                title,
                style: TextStyle(
                  fontSize: sp(28),
                  fontWeight: FontWeight.w600,
                  color: _mainTextColor(),
                ),
              ),
              SizedBox(height: sw(4)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: sp(22),
                  color: _subtitleTextColor(),
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
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_aa_my_accounts,
              style: TextStyle(
                fontSize: sp(30),
                fontWeight: FontWeight.bold,
                color: _mainTextColor(),
              ),
            ),
            if (accounts.isNotEmpty)
              TextButton(
                onPressed: navigateToAccountList,
                child: Text(S.of(context).g_key_aa_view_all),
              ),
          ],
        ),
        SizedBox(height: sw(16)),
        if (!_hasOwnerAddress)
          buildUnsupportedState()
        else if (accounts.isEmpty)
          buildEmptyState()
        else
          buildAccountsList(),
      ],
    );
  }

  Widget buildUnsupportedState() {
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;
    return Container(
      padding: EdgeInsets.all(sw(24)),
      decoration: BoxDecoration(
        color: _itemBgColor(),
        borderRadius: BorderRadius.circular(sw(16)),
        border: Border.all(color: _kOrange.withAlpha(40)),
      ),
      child: Row(
        children: [
          _iconBox(
            sw(44),
            sw(12),
            _kOrange,
            Icon(Icons.info_outline, size: sw(24), color: _kOrange),
          ),
          SizedBox(width: sw(12)),
          Expanded(
            child: Text(
              S.of(context).g_key_bridge_chain_not_supported,
              style: TextStyle(
                fontSize: sp(24),
                color: _subtitleTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;
    final steps = [
      S.of(context).g_key_aa_onboard_step1,
      S.of(context).g_key_aa_onboard_step2,
      S.of(context).g_key_aa_onboard_step3,
    ];

    return Container(
      padding: EdgeInsets.all(sw(24)),
      decoration: BoxDecoration(
        color: _itemBgColor(),
        borderRadius: BorderRadius.circular(sw(16)),
        border: Border.all(color: _kAccentColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_aa_no_accounts,
            style: TextStyle(
              fontSize: sp(28),
              fontWeight: FontWeight.w600,
              color: _mainTextColor(),
            ),
          ),
          SizedBox(height: sw(16)),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: sw(12)),
              child: Row(
                children: [
                  Container(
                    width: sw(28),
                    height: sw(28),
                    decoration: const BoxDecoration(
                      color: Color(0x1E6366F1), // _kAccentColor.withAlpha(30)
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: sp(20),
                          fontWeight: FontWeight.bold,
                          color: _kAccentColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw(12)),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: sp(24),
                        color: _subtitleTextColor(),
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

  Widget buildAccountsList() {
    final sw = ScreenUtil().setWidth;
    final displayAccounts = accounts.take(3).toList();

    return Column(
      children: [
        for (final account in displayAccounts)
          Padding(
            padding: EdgeInsets.only(bottom: sw(12)),
            child: SmartAccountCard(
              account: account,
              onTap: () => navigateToAccountDetail(account),
            ),
          ),
      ],
    );
  }

  /// Builds a rounded colored icon box used in benefit cards and feature cards.
  Widget _iconBox(double size, double radius, Color color, Widget child) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(child: child),
    );
  }
}
