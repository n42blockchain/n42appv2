import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_helpers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// 固定在顶部的代币列表标题栏：包含网络选择、排序、小额过滤。
class WalletCoinListHeader extends StatelessWidget {
  const WalletCoinListHeader({
    super.key,
    required this.waValue,
    required this.smallAssetsThreshold,
    required this.onAddToken,
    required this.onChangeNetwork,
    required this.onThresholdChanged,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearchVisible,
    required this.onSearchVisibilityChanged,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onMarketTap,
    required this.onPortfolioTap,
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;
  final VoidCallback onAddToken;
  final VoidCallback onChangeNetwork;
  final ValueChanged<double> onThresholdChanged;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearchVisible;
  final ValueChanged<bool> onSearchVisibilityChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onMarketTap;
  final VoidCallback onPortfolioTap;

  String _networkLabel(BuildContext context) {
    if (waValue.walletInfo.networkIndex == -1) {
      return S.of(context).g_token_m_key_4;
    }
    return waValue.coinModels[waValue.walletInfo.networkIndex].config.name;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: WalletSliverAppBarDelegate(
        // 搜索展开时额外显示一行输入框；收起时保持两行紧凑布局。
        minHeight: ScreenUtil().setWidth(isSearchVisible ? 280.0 : 192.0),
        maxHeight: ScreenUtil().setWidth(isSearchVisible ? 280.0 : 192.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space6,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).bgBase,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(AppRadius.xl),
              topLeft: Radius.circular(AppRadius.xl),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _TopRow(
                networkLabel: _networkLabel(context),
                onAddToken: onAddToken,
                onChangeNetwork: onChangeNetwork,
                isSearchVisible: isSearchVisible,
                onSearchVisibilityChanged: onSearchVisibilityChanged,
                onMarketTap: onMarketTap,
                onPortfolioTap: onPortfolioTap,
              ),
              if (isSearchVisible) ...[
                SizedBox(height: AppSpacing.space2),
                _TokenSearchField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: onSearchChanged,
                  onClose: () => onSearchVisibilityChanged(false),
                ),
              ],
              const Spacer(),
              _BottomRow(
                waValue: waValue,
                smallAssetsThreshold: smallAssetsThreshold,
                onThresholdChanged: onThresholdChanged,
                onRefresh: onRefresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.networkLabel,
    required this.onAddToken,
    required this.onChangeNetwork,
    required this.isSearchVisible,
    required this.onSearchVisibilityChanged,
    required this.onMarketTap,
    required this.onPortfolioTap,
  });

  final String networkLabel;
  final VoidCallback onAddToken;
  final VoidCallback onChangeNetwork;
  final bool isSearchVisible;
  final ValueChanged<bool> onSearchVisibilityChanged;
  final VoidCallback onMarketTap;
  final VoidCallback onPortfolioTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final blueColor = AppColorTokens.of(context).brand;

    return Row(
      children: [
        SizedBox(
          // 保留标题的最小展示宽度，避免快捷入口和网络筛选把 Tokens 压成 Tok…
          width: su.setWidth(124),
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              S.of(context).g_token_m_key_11,
              maxLines: 1,
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.space4),
        _HeaderIconButton(
          icon: isSearchVisible
              ? Icons.search_off_rounded
              : Icons.search_rounded,
          tooltip: S.of(context).g_token_m_key_12,
          onTap: () => onSearchVisibilityChanged(!isSearchVisible),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAddToken,
            borderRadius: AppRadius.brMd,
            child: SizedBox(
              // >=88.w 命中区（44dp 触控红线），视觉 36.w 不变
              width: su.setWidth(88),
              height: su.setWidth(88),
              child: Center(
                child: Container(
                  width: su.setWidth(36),
                  height: su.setWidth(36),
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: AppRadius.brMd,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: su.setWidth(24),
                  ),
                ),
              ),
            ),
          ),
        ),
        _MoreMenu(onMarketTap: onMarketTap, onPortfolioTap: onPortfolioTap),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onChangeNetwork,
            borderRadius: AppRadius.brPill,
            child: Container(
              constraints: BoxConstraints(
                minHeight: su.setWidth(88),
                maxWidth: su.setWidth(190),
              ),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: blueColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.brPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      networkLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: blueColor,
                    size: su.setWidth(24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: SizedBox(
            width: su.setWidth(88),
            height: su.setWidth(88),
            child: Icon(
              icon,
              size: su.setWidth(36),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.onMarketTap, required this.onPortfolioTap});

  final VoidCallback onMarketTap;
  final VoidCallback onPortfolioTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return SizedBox(
      width: su.setWidth(88),
      height: su.setWidth(88),
      child: PopupMenuButton<int>(
        tooltip: S.of(context).g_key_m_7,
        icon: Icon(
          Icons.more_horiz_rounded,
          size: su.setWidth(36),
          color: AppColorTokens.of(context).textSubtitle,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        color: AppColorTokens.of(context).bgSurface,
        onSelected: (value) {
          if (value == 0) {
            onMarketTap();
          } else {
            onPortfolioTap();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 0,
            child: ListTile(
              leading: const Icon(Icons.insights_rounded),
              title: Text(S.of(context).g_home_market),
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: ListTile(
              leading: const Icon(Icons.donut_large_rounded),
              title: Text(S.of(context).g_portfolio_title),
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenSearchField extends StatelessWidget {
  const _TokenSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return SizedBox(
      height: ScreenUtil().setWidth(72),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTypography.body.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: S.of(context).g_token_m_key_12,
          hintStyle: AppTypography.body.copyWith(color: colors.textSubtitle),
          prefixIcon: Icon(Icons.search_rounded, color: colors.textSubtitle),
          suffixIcon: IconButton(
            tooltip: S.of(context).g_key_batch_clear_all,
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: colors.textSubtitle),
          ),
          filled: true,
          fillColor: colors.bgSurface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: AppRadius.brMd,
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.brMd,
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.brMd,
            borderSide: BorderSide(color: colors.brand),
          ),
        ),
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.waValue,
    required this.smallAssetsThreshold,
    required this.onThresholdChanged,
    required this.onRefresh,
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;
  final ValueChanged<double> onThresholdChanged;
  final VoidCallback onRefresh;

  static const List<double> _thresholdCycle = [0.0, 1.0, 5.0, 10.0, 50.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SortButton(
          label: S.of(context).g_browser_key6,
          sortValue: waValue.walletInfo.coinSort['name'] ?? -1,
          onTap: () => waValue.setCoinSortAssets("name"),
        ),
        SizedBox(width: AppSpacing.space4),
        _SortButton(
          label: S.of(context).g_key_198,
          sortValue: waValue.walletInfo.coinSort['assets'] ?? -1,
          onTap: () => waValue.setCoinSortAssets("assets"),
        ),
        SizedBox(width: AppSpacing.space4),
        _SortButton(
          label: '24h%',
          sortValue: waValue.walletInfo.coinSort['change'] ?? -1,
          onTap: () => waValue.setCoinSortAssets("change"),
        ),
        const Spacer(),
        _RefreshButton(
          isRefreshing:
              waValue.load == Load.refresh ||
              waValue.loadBalance == Load.loading,
          onTap: onRefresh,
        ),
        _ThresholdButton(
          threshold: smallAssetsThreshold,
          thresholdCycle: _thresholdCycle,
          onChanged: onThresholdChanged,
        ),
      ],
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.isRefreshing, required this.onTap});

  final bool isRefreshing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final color = AppColorTokens.of(context).textSubtitle;
    return Tooltip(
      message: S.of(context).g_key_bridge_refresh,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: SizedBox(
            width: su.setWidth(88),
            height: su.setWidth(88),
            child: Center(
              child: isRefreshing
                  ? SizedBox(
                      width: su.setWidth(30),
                      height: su.setWidth(30),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColorTokens.of(context).brand,
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      size: su.setWidth(32),
                      color: color,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.label,
    required this.sortValue,
    required this.onTap,
  });

  final String label;
  final int sortValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brSm,
        child: Container(
          // >=88.w 命中高（44dp 触控红线）
          constraints: BoxConstraints(minHeight: ScreenUtil().setWidth(88)),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textSubtitle,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: AppSpacing.space2),
              SizedBox(
                width: ScreenUtil().setWidth(16),
                height: ScreenUtil().setWidth(16),
                child: Image.asset(
                  "assets/wallet/assets$sortValue.png",
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThresholdButton extends StatelessWidget {
  const _ThresholdButton({
    required this.threshold,
    required this.thresholdCycle,
    required this.onChanged,
  });

  final double threshold;
  final List<double> thresholdCycle;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = threshold > 0;
    final label = active ? '< \$${threshold.toInt()}' : S.of(context).g_key_9;
    final blueColor = AppColorTokens.of(context).brand;
    final subColor = AppColorTokens.of(context).textSubtitle;

    return PopupMenuButton<double>(
      tooltip: S.of(context).g_key_9,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      color: AppColorTokens.of(context).bgSurface,
      itemBuilder: (context) => thresholdCycle
          .map(
            (value) => CheckedPopupMenuItem<double>(
              value: value,
              checked: value == threshold,
              child: Text(
                value == 0 ? S.of(context).g_key_9 : '< \$${value.toInt()}',
              ),
            ),
          )
          .toList(),
      child: Container(
        constraints: BoxConstraints(minHeight: ScreenUtil().setWidth(88)),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: active
              ? blueColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: AppRadius.brMd,
          border: active
              ? Border.all(color: blueColor.withValues(alpha: 0.25), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: ScreenUtil().setWidth(24),
              color: active ? blueColor : subColor,
            ),
            SizedBox(width: AppSpacing.space2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: active ? blueColor : subColor,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: ScreenUtil().setWidth(20),
              color: active ? blueColor : subColor,
            ),
          ],
        ),
      ),
    );
  }
}
