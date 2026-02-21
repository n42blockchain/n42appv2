// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/Staking_btc/self_custody1.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';

/// BTC 自托管质押 — 流程说明 & 风险提示入口页
///
/// 用户必须勾选"我已了解风险"才能进入真正的质押 WebView（[SelfCustody1]）。
class SelfCustody extends StatefulWidget {
  final CoinModel coinModel;
  const SelfCustody(this.coinModel, {super.key});

  @override
  State<SelfCustody> createState() => _SelfCustodyState();
}

class _SelfCustodyState extends State<SelfCustody> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(text: s.g_key_btc_stake_title),
      body: SafeArea(
        child: Stack(
          children: [
            // ── 滚动内容区 ─────────────────────────────────────────────
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(30),
                  ScreenUtil().setWidth(20),
                  ScreenUtil().setWidth(30),
                  ScreenUtil().setWidth(140),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoinHeader(context),
                    SizedBox(height: ScreenUtil().setWidth(28)),
                    _buildHowItWorks(context, s),
                    SizedBox(height: ScreenUtil().setWidth(24)),
                    _buildRiskWarning(context, s),
                    SizedBox(height: ScreenUtil().setWidth(20)),
                    _buildAcknowledgment(context, s),
                  ],
                ),
              ),
            ),

            // ── 底部固定按钮 ────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.backGroundColor.name),
                    height: ScreenUtil().setWidth(148),
                    child: buttonStyle6(
                      context,
                      () {
                        if (!_acknowledged) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelfCustody1(widget.coinModel),
                          ),
                        );
                      },
                      s.g_key_btc_stake_continue,
                      AppThemeUtils.getColorByKey(
                        context,
                        _acknowledged
                            ? AppThemeKeys.mainButtonBgColor.name
                            : AppThemeKeys.mainButtonBgColor3.name,
                      ),
                      AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonTextColor.name),
                      false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  代币头部：图标 + 名称 + 余额
  // ──────────────────────────────────────────────────────────────
  Widget _buildCoinHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(52),
          height: ScreenUtil().setWidth(52),
          margin: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
          child: ImageNetWork(
            imageUrl: widget.coinModel.coin['icon'] ?? '',
            placeholder: 'assets/img/list_default.png',
          ),
        ),
        Text(
          widget.coinModel.coin['name'] ?? '',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        Expanded(
          child: Text(
            '${widget.coinModel.balanceString()} ${widget.coinModel.coin['unit'] ?? ''}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  "How It Works" — 4 步流程说明
  // ──────────────────────────────────────────────────────────────
  Widget _buildHowItWorks(BuildContext context, S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.g_key_btc_stake_how_it_works,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
        _buildStep(
          context,
          step: 1,
          icon: Icons.lock_outline,
          iconColor: const Color(0xFFF7931A), // Bitcoin orange
          title: s.g_key_btc_stake_step1_title,
          desc: s.g_key_btc_stake_step1_desc,
        ),
        _buildStep(
          context,
          step: 2,
          icon: Icons.generating_tokens_outlined,
          iconColor: const Color(0xFF6366F1),
          title: s.g_key_btc_stake_step2_title,
          desc: s.g_key_btc_stake_step2_desc,
        ),
        _buildStep(
          context,
          step: 3,
          icon: Icons.star_outline_rounded,
          iconColor: const Color(0xFF22C55E),
          title: s.g_key_btc_stake_step3_title,
          desc: s.g_key_btc_stake_step3_desc,
        ),
        _buildStep(
          context,
          step: 4,
          icon: Icons.lock_open_outlined,
          iconColor: const Color(0xFF3B82F6),
          title: s.g_key_btc_stake_step4_title,
          desc: s.g_key_btc_stake_step4_desc,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required int step,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：序号圆圈 + 连接线
          Column(
            children: [
              Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setWidth(40),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: ScreenUtil().setWidth(22)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: ScreenUtil().setWidth(2),
                    margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(4)),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name)
                        .withAlpha(60),
                  ),
                ),
            ],
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // 右侧：标题 + 说明
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(isLast ? 0 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: ScreenUtil().setWidth(20),
                        height: ScreenUtil().setWidth(20),
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$step',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(14),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  风险提示卡
  // ──────────────────────────────────────────────────────────────
  Widget _buildRiskWarning(BuildContext context, S s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: Colors.orange.withAlpha(100), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: ScreenUtil().setWidth(24)),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                s.g_key_btc_stake_risk_warning,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          // 风险条目
          _buildRiskItem(s.g_key_btc_stake_risk1),
          _buildRiskItem(s.g_key_btc_stake_risk2),
          _buildRiskItem(s.g_key_btc_stake_risk3),
          _buildRiskItem(s.g_key_btc_stake_risk4),
        ],
      ),
    );
  }

  Widget _buildRiskItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: Colors.orange.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  "我已了解风险" 勾选框
  // ──────────────────────────────────────────────────────────────
  Widget _buildAcknowledgment(BuildContext context, S s) {
    return GestureDetector(
      onTap: () => setState(() => _acknowledged = !_acknowledged),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: ScreenUtil().setWidth(44),
            height: ScreenUtil().setWidth(44),
            decoration: BoxDecoration(
              color: _acknowledged
                  ? AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              border: Border.all(
                color: _acknowledged
                    ? AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name)
                    : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                width: 2,
              ),
            ),
            child: _acknowledged
                ? Icon(Icons.check,
                    color: Colors.white, size: ScreenUtil().setWidth(28))
                : null,
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              s.g_key_btc_stake_acknowledge,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
