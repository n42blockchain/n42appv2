import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return waValue.coinModels[waValue.walletInfo.networkIndex].coin['name'] ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: WalletSliverAppBarDelegate(
        minHeight: ScreenUtil().setWidth(165.0),
        maxHeight: ScreenUtil().setWidth(165.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(24),
            vertical: ScreenUtil().setWidth(18),
          ),
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).bgBase,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(ScreenUtil().setWidth(28)),
              topLeft: Radius.circular(ScreenUtil().setWidth(28)),
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: su.setSp(32),
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
        ),
        SizedBox(width: su.setWidth(12)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAddToken,
            borderRadius: BorderRadius.circular(su.setWidth(16)),
            child: Container(
              width: su.setWidth(36),
              height: su.setWidth(36),
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(su.setWidth(12)),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: su.setWidth(22),
              ),
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PortfolioPage()),
            ),
            borderRadius: BorderRadius.circular(su.setWidth(16)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: su.setWidth(10),
                vertical: su.setWidth(6),
              ),
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
            borderRadius: BorderRadius.circular(su.setWidth(20)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: su.setWidth(14),
                vertical: su.setWidth(8),
              ),
              decoration: BoxDecoration(
                color: blueColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(su.setWidth(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    networkLabel,
                    style: TextStyle(
                      fontSize: su.setSp(24),
                      fontWeight: FontWeight.w500,
                      color: blueColor,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: blueColor,
                    size: su.setWidth(22),
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
        SizedBox(width: ScreenUtil().setWidth(12)),
        _SortButton(
          label: S.of(context).g_key_198,
          sortValue: waValue.walletInfo.coinSort['assets'] ?? -1,
          onTap: () => waValue.setCoinSortAssets("assets"),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
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
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(8),
            vertical: ScreenUtil().setWidth(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColorTokens.of(context).textSubtitle,
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(4)),
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

    return GestureDetector(
      onTap: () {
        final idx = thresholdCycle.indexOf(threshold);
        final next = thresholdCycle[(idx + 1) % thresholdCycle.length];
        onChanged(next);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(14),
          vertical: ScreenUtil().setWidth(6),
        ),
        decoration: BoxDecoration(
          color: active
              ? blueColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
              size: ScreenUtil().setWidth(26),
              color: active ? blueColor : subColor,
            ),
            SizedBox(width: ScreenUtil().setWidth(5)),
            Text(
              label,
              style: TextStyle(
                color: active ? blueColor : subColor,
                fontSize: ScreenUtil().setSp(22),
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
