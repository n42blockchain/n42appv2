import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_page.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_page.dart';
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
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;
  final VoidCallback onAddToken;
  final VoidCallback onChangeNetwork;
  final ValueChanged<double> onThresholdChanged;

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
        // 192.w - 2*space2 = 176.w → 两行各 88.w（44dp 触控红线）
        minHeight: ScreenUtil().setWidth(192.0),
        maxHeight: ScreenUtil().setWidth(192.0),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TopRow(
                waValue: waValue,
                networkLabel: _networkLabel(context),
                onAddToken: onAddToken,
                onChangeNetwork: onChangeNetwork,
              ),
              _BottomRow(
                waValue: waValue,
                smallAssetsThreshold: smallAssetsThreshold,
                onThresholdChanged: onThresholdChanged,
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
    required this.waValue,
    required this.networkLabel,
    required this.onAddToken,
    required this.onChangeNetwork,
  });

  final WalletActionProvider waValue;
  final String networkLabel;
  final VoidCallback onAddToken;
  final VoidCallback onChangeNetwork;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final blueColor = AppColorTokens.of(context).brand;

    return Row(
      children: [
        Flexible(
          child: Text(
            S.of(context).g_token_m_key_11,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headline.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.space4),
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarketPage()),
            ),
            borderRadius: AppRadius.brMd,
            child: SizedBox(
              width: su.setWidth(88),
              height: su.setWidth(88),
              child: Icon(
                Icons.insights_rounded,
                size: su.setWidth(36),
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
        ),
        SizedBox(width: su.setWidth(4)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PortfolioPage()),
            ),
            borderRadius: AppRadius.brMd,
            child: SizedBox(
              width: su.setWidth(88),
              height: su.setWidth(88),
              child: Icon(
                Icons.donut_large_rounded,
                size: su.setWidth(36),
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
        ),
        SizedBox(width: su.setWidth(4)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onChangeNetwork,
            borderRadius: AppRadius.brPill,
            child: Container(
              constraints: BoxConstraints(
                minHeight: su.setWidth(88),
                maxWidth: su.setWidth(240),
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

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.waValue,
    required this.smallAssetsThreshold,
    required this.onThresholdChanged,
  });

  final WalletActionProvider waValue;
  final double smallAssetsThreshold;
  final ValueChanged<double> onThresholdChanged;

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
        _ThresholdButton(
          threshold: smallAssetsThreshold,
          thresholdCycle: _thresholdCycle,
          onChanged: onThresholdChanged,
        ),
      ],
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
    final label = active ? '< \$${threshold.toInt()}' : '< \$';
    final blueColor = AppColorTokens.of(context).brand;
    final subColor = AppColorTokens.of(context).textSubtitle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final idx = thresholdCycle.indexOf(threshold);
          final next = thresholdCycle[(idx + 1) % thresholdCycle.length];
          onChanged(next);
        },
        borderRadius: AppRadius.brMd,
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
            ],
          ),
        ),
      ),
    );
  }
}
