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
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
              SizedBox(width: ScreenUtil().setWidth(6)),
              Text(
                S.of(context).g_key_aa_chain,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: subtitleColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: selectedChain.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Text(
                  selectedChain.suffix,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: selectedChain.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
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
        horizontal: ScreenUtil().setWidth(14),
        vertical: ScreenUtil().setWidth(8),
      ),
      decoration: BoxDecoration(
        color: isSelected ? chain.color.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
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
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Text(
                chain.symbol.substring(0, 1),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(16),
                  fontWeight: FontWeight.bold,
                  color: chain.color,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(
            chain.name,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? chain.color
                  : _themeColor(AppThemeKeys.mainTextColor.name),
            ),
          ),
          if (isSelected) ...[
            SizedBox(width: ScreenUtil().setWidth(6)),
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
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueColor.withAlpha(40), blueColor.withAlpha(15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: blueColor.withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            child: Center(
              child: Text(
                'ENS',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_ens_service,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32),
                    fontWeight: FontWeight.bold,
                    color: _themeColor(AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  S.of(context).g_key_ens_description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
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
        SizedBox(width: ScreenUtil().setWidth(16)),
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
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: _themeColor(AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              child: Icon(icon, size: ScreenUtil().setWidth(24), color: color),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: _themeColor(AppThemeKeys.mainTextColor.name),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(4)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
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
            Text(
              S.of(context).g_key_ens_my_domains,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
                color: _themeColor(AppThemeKeys.mainTextColor.name),
              ),
            ),
            if (ownedNames.isNotEmpty)
              Text(
                '${ownedNames.length}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: _themeColor(AppThemeKeys.mainBlueColor.name),
                ),
              ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
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
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtil().setWidth(48),
            color: Colors.red,
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            errorMessage!,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
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
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(color: blueColor.withAlpha(30), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.domain_rounded,
            size: ScreenUtil().setWidth(64),
            color: subtitleColor.withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_ens_no_domains,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w500,
              color: _themeColor(AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            canManageEns
                ? S.of(context).g_key_ens_get_started
                : S.of(context).g_key_bridge_chain_not_supported,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          ElevatedButton.icon(
            onPressed: canManageEns ? navigateToSearch : _showUnsupportedSnack,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.of(context).g_key_ens_search_register),
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
                vertical: ScreenUtil().setWidth(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
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
