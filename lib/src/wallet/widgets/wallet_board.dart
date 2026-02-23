//看板类型
import 'dart:io';

import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/widgets/board_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
  //payment code
  final GestureTapCallback? paymentCodeTap;
  //buy
  final GestureTapCallback? buyTap;
  //sell
  final GestureTapCallback? sellTap;

  const WalletBoard({
    super.key,
    required this.accountPrice,
    this.usdToCnyRate = 7.3,
    this.priceLastUpdated,
    this.swapTap,
    this.walletName,
    this.receiveTap,
    this.sendTap,
    this.paymentCodeTap,
    this.buyTap,
    this.sellTap,
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── USD 总额（加粗突出）──
          Padding(
            padding: EdgeInsets.only(
              top: ScreenUtil().setWidth(30),
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
              bottom: ScreenUtil().setWidth(2),
            ),
            child: Text(
              _formatUsd(widget.accountPrice),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(44),   // 40 → 44，突出层级
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          // ── CNY 折算 + 汇率更新时间 ──
          Padding(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              bottom: ScreenUtil().setWidth(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (widget.accountPrice > 0) ...[
                  Text(
                    '≈ ¥${oCcyCny.format(cny)}',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                ],
                // 最后更新时间（细灰字）
                if (widget.priceLastUpdated != null)
                  Text(
                    _lastUpdatedLabel(),
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name)
                          .withValues(alpha: 0.5),
                      fontSize: ScreenUtil().setSp(20),
                    ),
                  ),
                if (widget.accountPrice == 0 && widget.priceLastUpdated == null)
                  SizedBox(height: ScreenUtil().setWidth(22)),
              ],
            ),
          ),
          // ── 操作按钮行 ──
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttonList(),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(30)),
          Divider(
            height: 1,
            endIndent: 0,
            indent: 0,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
        ],
      ),
    );
  }

  List<Widget> buttonList() {
    return [
      Flexible(child: sendWidget()),
      SizedBox(width: ScreenUtil().setWidth(20)),
      Flexible(child: receiveWidget()),
      if (Platform.isAndroid) ...[
        SizedBox(width: ScreenUtil().setWidth(20)),
        Flexible(child: buyWidget()),
        SizedBox(width: ScreenUtil().setWidth(20)),
        Flexible(child: sellWidget()),
      ],
    ];
  }

  Widget emptyWidget() {
    return const Expanded(child: SizedBox());
  }

  Widget sendWidget() {
    return BoardItem(
      action: S.of(context).g_key_100,
      imagePath: 'assets/wallet/w_send.png',
      onTap: widget.sendTap,
    );
  }

  Widget swapWidget() {
    return BoardItem(
      action: S.of(context).g_swap_key_35,
      imagePath: 'assets/wallet/w_swap.png',
      onTap: widget.swapTap,
    );
  }

  Widget receiveWidget() {
    return BoardItem(
      action: S.of(context).g_key_33,
      imagePath: 'assets/wallet/w_receive.png',
      onTap: widget.receiveTap,
    );
  }

  Widget paymentCodeWidget() {
    return BoardItem(
      action: 'Payment code',
      imagePath: 'assets/wallet/w_receive.png',
      onTap: widget.paymentCodeTap,
    );
  }

  Widget buyWidget() {
    return BoardItem(
      action: S.of(context).g_key_211,
      imagePath: 'assets/wallet/w_buy.png',
      onTap: widget.buyTap,
    );
  }

  Widget sellWidget() {
    return BoardItem(
      action: S.of(context).g_key_212,
      imagePath: 'assets/wallet/w_sell.png',
      onTap: widget.sellTap,
    );
  }
}
