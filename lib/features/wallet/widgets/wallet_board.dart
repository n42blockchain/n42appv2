import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletBoard extends StatefulWidget {
  final double accountPrice;
  final String? walletName;

  /// 动态 USD→CNY 汇率（由 WalletActionProvider 提供，备用值 7.3）
  final double usdToCnyRate;

  /// 最后成功更新价格的时间（用于展示"更新于 X 分钟前"）
  final DateTime? priceLastUpdated;
  final bool priceRefreshFailed;
  final bool hasPartialPrices;
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
    this.priceRefreshFailed = false,
    this.hasPartialPrices = false,
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
              ? [const Color(0xFF0F1D38), const Color(0xFF1A0B3B)]
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
            padding: EdgeInsets.all(AppSpacing.space6),
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
                Wrap(
                  spacing: AppSpacing.space6,
                  runSpacing: AppSpacing.space2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (widget.accountPrice > 0) ...[
                      Text(
                        '≈ ¥${oCcyCny.format(cny)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.onOverlaySecondary,
                        ),
                      ),
                    ],
                    WalletPriceStatus(
                      updated: widget.priceLastUpdated,
                      failed: widget.priceRefreshFailed,
                      partial: widget.hasPartialPrices,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.space4),
                // 分割线
                Container(height: 1, color: AppColorTokens.onOverlayBorder),
                SizedBox(height: AppSpacing.space4),
                // 操作按钮行(4 个按钮 spaceEvenly 均匀分布)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final button in buttonList()) Expanded(child: button),
                  ],
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
        const ValueKey<String>('wallet_action_send'),
        S.of(context).g_key_48,
        'assets/wallet/w_send.png',
        widget.sendTap,
      ),
      _buildActionBtn(
        const ValueKey<String>('wallet_action_receive'),
        S.of(context).g_key_33,
        'assets/wallet/w_receive.png',
        widget.receiveTap,
      ),
      // Swap 入口:iOS 商店审核对 DEX/交易所类功能审查严格(Guideline 3.1.5),
      // 该按钮在 iOS 上隐藏,仅 Android 保留(AppConfig.swapFeatureEnabled)。
      if (AppConfig.swapFeatureEnabled)
        _buildActionBtn(
          const ValueKey<String>('wallet_action_swap'),
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
    Key key,
    String label,
    String imagePath,
    GestureTapCallback? onTap,
  ) {
    // Material(transparent) 让 ripple 画在渐变卡之上——此前最近 Material
    // 祖先在渐变层之下，按压态被卡片渐变完全遮挡（§5 红线）。
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: AppRadius.brLg,
        highlightColor: Colors.white.withValues(alpha: 0.10),
        splashColor: Colors.white.withValues(alpha: 0.08),
        child: _actionBtnBody(label, imagePath),
      ),
    );
  }

  Widget _actionBtnBody(String label, String imagePath) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: AppRadius.brMd,
            border: Border.all(color: AppColorTokens.onOverlayBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: ScreenUtil().setWidth(36),
                height: ScreenUtil().setWidth(36),
                color: Colors.white,
              ),
              SizedBox(width: AppSpacing.space4),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.onOverlayPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Advances only the age label; never requests quotes or rebuilds asset rows.
class WalletPriceStatus extends StatefulWidget {
  const WalletPriceStatus({
    super.key,
    this.updated,
    this.failed = false,
    this.partial = false,
    this.now,
  });

  final DateTime? updated;
  final bool failed;
  final bool partial;
  final DateTime Function()? now;

  @override
  State<WalletPriceStatus> createState() => _WalletPriceStatusState();
}

class _WalletPriceStatusState extends State<WalletPriceStatus>
    with WidgetsBindingObserver {
  Timer? _timer;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedule();
  }

  @override
  void didUpdateWidget(WalletPriceStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _schedule();
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  void _schedule() {
    _timer?.cancel();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (widget.updated == null ||
        widget.partial ||
        widget.failed ||
        !TickerMode.of(context) ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed))
      return;
    final age = _now.difference(widget.updated!);
    // Align to the displayed minute/hour boundary, including after resume.
    final unit = age.inHours >= 1
        ? const Duration(hours: 1)
        : const Duration(minutes: 1);
    final elapsed = age.isNegative ? 0 : age.inMicroseconds;
    final delay = Duration(
      microseconds: unit.inMicroseconds - elapsed % unit.inMicroseconds,
    );
    _timer = Timer(delay, () {
      if (!mounted) return;
      setState(() {});
      _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final minutes = widget.updated == null
        ? 0
        : _now.difference(widget.updated!).inMinutes;
    final label = widget.partial
        ? s.g_wallet_prices_partial
        : widget.updated == null
        ? s.g_wallet_prices_unavailable
        : widget.failed
        ? s.g_wallet_prices_cached
        : minutes < 1
        ? s.g_wallet_prices_just_updated
        : minutes < 60
        ? s.g_wallet_prices_minutes(minutes)
        : s.g_wallet_prices_hours(minutes ~/ 60);
    return Text(
      label,
      key: const ValueKey('wallet_price_status'),
      style: AppTypography.captionSm.copyWith(
        color: AppColorTokens.onOverlaySecondary,
      ),
    );
  }
}
