import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletBoard extends StatefulWidget {
  final double accountPrice;
  final String? walletName;

  /// 动态 USD→CNY 汇率（由 WalletActionProvider 提供，备用值 7.3）
  final double usdToCnyRate;

  /// 最后成功更新价格的时间（用于展示"更新于 X 分钟前"）
  final DateTime? priceLastUpdated;
  //swap
  final GestureTapCallback? swapTap;
  //send
  final GestureTapCallback? sendTap;
  //receive
  final GestureTapCallback? receiveTap;
  //buy (in-app purchase)
  final GestureTapCallback? buyTap;

  const WalletBoard({
    super.key,
    required this.accountPrice,
    this.usdToCnyRate = 7.3,
    this.priceLastUpdated,
    this.swapTap,
    this.walletName,
    this.receiveTap,
    this.sendTap,
    this.buyTap,
  });

  @override
  State<WalletBoard> createState() => _WalletBoardState();
}

class _WalletBoardState extends State<WalletBoard> {
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  final oCcyCny = NumberFormat("#,##0", "zh_CN");

  String _formatUsd(double usd) {
    if (usd == 0) return '\$0.00';
    if (usd > 0 && usd < 0.01) return '< \$0.01';
    if (usd >= 1e9) return '\$${(usd / 1e9).toStringAsFixed(2)}B';
    if (usd >= 1e6) return '\$${(usd / 1e6).toStringAsFixed(2)}M';
    return '\$${oCcy.format(usd)}';
  }

  /// 返回 "更新于 X 分钟前" / "刚刚" 文本
  String _lastUpdatedLabel() {
    final t = widget.priceLastUpdated;
    if (t == null) return '';
    final minutes = DateTime.now().difference(t).inMinutes;
    if (minutes < 1) return 'Just updated';
    if (minutes < 60) return 'Updated ${minutes}m ago';
    final hours = minutes ~/ 60;
    return 'Updated ${hours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final cny = widget.accountPrice * widget.usdToCnyRate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        // 资产卡专属品牌渐变（炫彩强调，豁免通用令牌）
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F2044), const Color(0xFF1A0B3B)]
              : [const Color(0xFF1565C0), const Color(0xFF7B1FA2)],
          stops: const [0.0, 1.0],
        ),
        borderRadius: AppRadius.brXl,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF1565C0).withValues(alpha: 0.24)
                : const Color(0xFF1565C0).withValues(alpha: 0.31),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 装饰性背景圆圈
          Positioned(
            right: -ScreenUtil().setWidth(30),
            top: -ScreenUtil().setWidth(30),
            child: Container(
              width: ScreenUtil().setWidth(200),
              height: ScreenUtil().setWidth(200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            right: ScreenUtil().setWidth(40),
            bottom: -ScreenUtil().setWidth(20),
            child: Container(
              width: ScreenUtil().setWidth(120),
              height: ScreenUtil().setWidth(120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.02),
              ),
            ),
          ),
          // 主内容
          Padding(
            padding: EdgeInsets.all(AppSpacing.space8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总资产标签
                Text(
                  S.of(context).g_key_29,
                  style: AppTypography.captionSm.copyWith(
                    color: AppColorTokens.onOverlaySecondary,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                // USD 总额
                Text(
                  _formatUsd(widget.accountPrice),
                  style: AppTypography.displayLg.copyWith(
                    color: AppColorTokens.onOverlayPrimary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                // CNY + 更新时间行
                Row(
                  children: [
                    if (widget.accountPrice > 0) ...[
                      Text(
                        '≈ ¥${oCcyCny.format(cny)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.onOverlaySecondary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.space6),
                    ],
                    if (widget.priceLastUpdated != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.space4,
                          vertical: AppSpacing.space2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorTokens.onOverlayBorder,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Text(
                          _lastUpdatedLabel(),
                          style: AppTypography.captionSm.copyWith(
                            color: AppColorTokens.onOverlaySecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.space8),
                // 分割线
                Container(height: 1, color: AppColorTokens.onOverlayBorder),
                SizedBox(height: AppSpacing.space6),
                // 操作按钮行(4 个按钮 spaceEvenly 均匀分布)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buttonList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buttonList() {
    final buttons = <Widget>[
      _buildActionBtn(
        S.of(context).g_key_48,
        'assets/wallet/w_send.png',
        widget.sendTap,
      ),
      _buildActionBtn(
        S.of(context).g_key_33,
        'assets/wallet/w_receive.png',
        widget.receiveTap,
      ),
      // Swap 入口:此前 swapTap 回调(→ showSwapModeSheet,含 DEX Swap/Buy N)
      // 传入却无按钮渲染,DEX Swap 在钱包首页不可达(接线复审第二轮 C3/T21)。
      _buildActionBtn(
        S.of(context).g_key_dex_swap_btn,
        'assets/wallet/w_swap.png',
        widget.swapTap,
      ),
      /*_buildActionBtn(
        S.of(context).g_iap_title,
        'assets/wallet/w_buy.png',
        widget.buyTap,
      ),*/
    ];
    return buttons;
  }

  Widget _buildActionBtn(
    String label,
    String imagePath,
    GestureTapCallback? onTap,
  ) {
    // Material(transparent) 让 ripple 画在渐变卡之上——此前最近 Material
    // 祖先在渐变层之下，按压态被卡片渐变完全遮挡（§5 红线）。
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brLg,
        highlightColor: Colors.white.withValues(alpha: 0.10),
        splashColor: Colors.white.withValues(alpha: 0.08),
        child: _actionBtnBody(label, imagePath),
      ),
    );
  }

  Widget _actionBtnBody(String label, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenUtil().setWidth(96),
          height: ScreenUtil().setWidth(96),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.11),
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
          child: Center(
            child: Image.asset(
              imagePath,
              width: ScreenUtil().setWidth(44),
              height: ScreenUtil().setWidth(44),
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.space2),
        Text(
          label,
          style: AppTypography.captionSm.copyWith(
            color: AppColorTokens.onOverlayPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
