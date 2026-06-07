// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/export_keystore_page.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExportKeystoreDesc extends StatefulWidget {
  final String keystoreJson;
  const ExportKeystoreDesc({required this.keystoreJson, super.key});

  @override
  State<ExportKeystoreDesc> createState() => _ExportKeystoreDescState();
}

class _ExportKeystoreDescState extends State<ExportKeystoreDesc> {
  bool _riskAcknowledged = false;

  Widget _descItem(String text, Color color) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: ScreenUtil().setSp(30),
      height: 1.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final subtitleColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.ff888888.name,
    );
    final errorBg = AppColorTokens.of(context).dangerBg;
    final errorText = AppColorTokens.of(context).danger;
    final mainText = AppColorTokens.of(context).textPrimary;

    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_ex_keystore),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.g_key_ex_keystore_1,
                      style: AppTypography.title.copyWith(
                        color: mainText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.space4),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.space6),
                      decoration: BoxDecoration(
                        color: errorBg,
                        borderRadius: AppRadius.brMd,
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
                    SizedBox(height: AppSpacing.space6),

                    Divider(height: ScreenUtil().setWidth(1)),
                    SizedBox(height: AppSpacing.space6),

                    _descItem('1. ${s.g_key_ex_keystore_3}', subtitleColor),
                    SizedBox(height: AppSpacing.space4),
                    _descItem('2. ${s.g_key_ex_keystore_4}', subtitleColor),
                    SizedBox(height: AppSpacing.space12),

                    _RiskCheckbox(
                      label: s.g_key_ex_keystore_confirm_risk,
                      value: _riskAcknowledged,
                      onChanged: (v) =>
                          setState(() => _riskAcknowledged = v ?? false),
                    ),

                    SizedBox(height: ScreenUtil().setWidth(148)),
                  ],
                ),
              ),
            ),

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
                    padding: EdgeInsets.all(AppSpacing.space8),
                    color: AppColorTokens.of(context).bgBase,
                    child: AppButton(
                      label: s.next,
                      onPressed: _riskAcknowledged
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExportKeystorePage(
                                  keystoreJson: widget.keystoreJson,
                                ),
                              ),
                            )
                          : null,
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
              activeColor: AppColorTokens.of(context).brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
              child: Text(
                label,
                style: TextStyle(
                  color: AppColorTokens.of(context).textPrimary,
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
