// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/pages/wallet_manage/keystore/export_keystore_page.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Keystore 导出警告说明页。
///
/// 用户必须勾选风险确认框后才能进入下一步（查看并复制 Keystore）。
class ExportKeystoreDesc extends StatefulWidget {
  final String keystoreJson;
  const ExportKeystoreDesc({required this.keystoreJson, super.key});

  @override
  State<ExportKeystoreDesc> createState() => _ExportKeystoreDescState();
}

class _ExportKeystoreDescState extends State<ExportKeystoreDesc> {
  /// 用户是否已勾选风险确认框
  bool _riskAcknowledged = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.ff888888.name);
    final errorBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.errorBgColor.name);
    final errorText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.errorTextColor.name);
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);

    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_ex_keystore),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 页面标题 ─────────────────────────────────────────
                    Text(
                      s.g_key_ex_keystore_1,
                      style: TextStyle(
                        color: mainText,
                        fontSize: ScreenUtil().setSp(36),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(16)),

                    // ── 安全警告框（红色底色） ────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                      decoration: BoxDecoration(
                        color: errorBg,
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(12)),
                      ),
                      child: Text(
                        s.g_key_ex_keystore_2,
                        style: TextStyle(
                          color: errorText,
                          fontSize: ScreenUtil().setSp(28),
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(24)),

                    Divider(height: ScreenUtil().setWidth(1)),
                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // ── 条目 1 ────────────────────────────────────────────
                    Text(
                      '1. ${s.g_key_ex_keystore_3}',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: ScreenUtil().setSp(30),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20)),

                    // ── 条目 2 ────────────────────────────────────────────
                    Text(
                      '2. ${s.g_key_ex_keystore_4}',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: ScreenUtil().setSp(30),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(40)),

                    // ── 风险确认勾选框 ────────────────────────────────────
                    _RiskCheckbox(
                      label: s.g_key_ex_keystore_confirm_risk,
                      value: _riskAcknowledged,
                      onChanged: (v) =>
                          setState(() => _riskAcknowledged = v ?? false),
                    ),

                    // 底部按钮的占位高度
                    SizedBox(height: ScreenUtil().setWidth(148)),
                  ],
                ),
              ),
            ),

            // ── 底部按钮 ──────────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: ScreenUtil().setWidth(1)),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setWidth(148),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.backGroundColor.name),
                    child: buttonStyle2(
                      context,
                      // 未勾选时 onTap=null → buttonStyle2 自动禁用
                      _riskAcknowledged
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExportKeystorePage(
                                    keystoreJson: widget.keystoreJson,
                                  ),
                                ),
                              )
                          : null,
                      s.next,
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
}

/// 风险确认勾选框组件。
class _RiskCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _RiskCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(44),
            height: ScreenUtil().setWidth(44),
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
              child: Text(
                label,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
