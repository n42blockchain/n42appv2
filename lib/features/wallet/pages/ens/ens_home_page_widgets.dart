part of 'ens_home_page.dart';

/// UI widget build methods for [_EnsHomePageState].
///
/// Depends on [_EnsHomeLogicMixin] for all shared state and business methods.
mixin _EnsHomeWidgetsMixin on _EnsHomeLogicMixin {
  /// Shorthand for theme color lookup to reduce repetitive boilerplate.
  Color _themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

  Widget buildChainSelector() {
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor.name);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor.name),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: selectedChain.color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                size: ScreenUtil().setWidth(18),
                color: subtitleColor,
              ),
              SizedBox(width: AppSpacing.space2),
              Flexible(
                child: Text(
                  S.of(context).g_key_aa_chain,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: subtitleColor),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                  vertical: AppSpacing.space2,
                ),
                decoration: BoxDecoration(
                  color: selectedChain.color.withAlpha(20),
                  borderRadius: AppRadius.brSm,
                ),
                child: Text(
                  selectedChain.suffix,
                  style: AppTypography.captionSm.copyWith(
                    color: selectedChain.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: EnsChainConfig.supportedChains.map((chain) {
                final isSelected = selectedChain.id == chain.id;
                return Padding(
                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                  child: GestureDetector(
                    onTap: () {
                      selectChain(chain);
                    },
                    child: _buildChainChip(chain, isSelected),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainChip(EnsChainConfig chain, bool isSelected) {
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor.name);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: isSelected ? chain.color.withAlpha(25) : Colors.transparent,
        borderRadius: AppRadius.brSm,
        border: Border.all(
          color: isSelected ? chain.color : subtitleColor.withAlpha(40),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ScreenUtil().setWidth(24),
            height: ScreenUtil().setWidth(24),
            decoration: BoxDecoration(
              color: chain.color.withAlpha(30),
              borderRadius: AppRadius.brMd,
            ),
            child: Center(
              child: Text(
                chain.symbol.substring(0, 1),
                style: AppTypography.captionSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: chain.color,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space2),
          Text(
            chain.name,
            style: AppTypography.caption.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? chain.color
                  : _themeColor(AppThemeKeys.mainTextColor.name),
            ),
          ),
          if (isSelected) ...[
            SizedBox(width: AppSpacing.space2),
            Icon(
              Icons.check_circle,
              size: ScreenUtil().setWidth(18),
              color: chain.color,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildHeaderCard() {
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor.name);
    return Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueColor.withAlpha(40), blueColor.withAlpha(15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: blueColor.withAlpha(30),
              borderRadius: AppRadius.brMd,
            ),
            child: Center(
              child: Text(
                'ENS',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: blueColor,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_ens_service,
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _themeColor(AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  S.of(context).g_key_ens_description,
                  style: AppTypography.caption.copyWith(
                    color: _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickActions() {
    final canManageEns = _hasWalletAddress;
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.search_rounded,
            title: S.of(context).g_key_ens_search,
            subtitle: S.of(context).g_key_ens_search_desc,
            color: const Color(0xFF5E97F6),
            onTap: canManageEns ? navigateToSearch : _showUnsupportedSnack,
          ),
        ),
        SizedBox(width: AppSpacing.space4),
        Expanded(
          child: _buildActionCard(
            icon: Icons.autorenew_rounded,
            title: S.of(context).g_key_ens_renew,
            subtitle: S.of(context).g_key_ens_renew_desc,
            color: const Color(0xFF66BB6A),
            onTap: () {
              if (!canManageEns) {
                _showUnsupportedSnack();
                return;
              }
              if (ownedNames.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).g_key_ens_no_domains)),
                );
              } else {
                // 导航到续费页面
                navigateToManagement(ownedNames.first);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: _themeColor(AppThemeKeys.itemBgColor.name),
          borderRadius: AppRadius.brMd,
          border: Border.all(color: color.withAlpha(40), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ScreenUtil().setWidth(44),
              height: ScreenUtil().setWidth(44),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: AppRadius.brMd,
              ),
              child: Icon(icon, size: ScreenUtil().setWidth(24), color: color),
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              title,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: _themeColor(AppThemeKeys.mainTextColor.name),
              ),
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOwnedNamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                S.of(context).g_key_ens_my_domains,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _themeColor(AppThemeKeys.mainTextColor.name),
                ),
              ),
            ),
            if (ownedNames.isNotEmpty)
              Text(
                '${ownedNames.length}',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _themeColor(AppThemeKeys.mainBlueColor.name),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.space4),
        if (isLoading)
          _buildLoadingState()
        else if (errorMessage != null)
          _buildErrorState()
        else if (ownedNames.isEmpty)
          _buildEmptyState()
        else
          _buildOwnedNamesList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space16),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor.name),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtil().setWidth(48),
            color: Colors.red,
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            errorMessage!,
            style: AppTypography.bodySm.copyWith(
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.space4),
          TextButton(
            onPressed: loadOwnedNames,
            child: Text(S.of(context).g_swap_key_6),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor.name);
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor.name);
    final canManageEns = _hasWalletAddress;
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor.name),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: blueColor.withAlpha(30), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.domain_rounded,
            size: ScreenUtil().setWidth(64),
            color: subtitleColor.withAlpha(100),
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_ens_no_domains,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w500,
              color: _themeColor(AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            canManageEns
                ? S.of(context).g_key_ens_get_started
                : S.of(context).g_key_bridge_chain_not_supported,
            style: AppTypography.caption.copyWith(color: subtitleColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.space4),
          ElevatedButton.icon(
            onPressed: canManageEns ? navigateToSearch : _showUnsupportedSnack,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.of(context).g_key_ens_search_register),
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space6,
                vertical: AppSpacing.space4,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedNamesList() {
    return Column(
      children: ownedNames.map((ens) {
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
          child: EnsOwnedListItem(
            ownedEns: ens,
            onTap: () => navigateToManagement(ens),
          ),
        );
      }).toList(),
    );
  }
}
