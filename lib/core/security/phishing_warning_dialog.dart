// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/shared/widgets/tips_dialog_3.dart';

/// Display a full-screen-blocking phishing warning dialog.
///
/// Returns `true` if the user chose "Proceed Anyway", `false` or `null`
/// if they chose to go back (or dismissed the dialog).
///
/// Usage:
/// ```dart
/// final proceed = await showPhishingWarningDialog(context, url);
/// if (proceed == true) { /* user accepted the risk */ }
/// ```
Future<bool?> showPhishingWarningDialog(
  BuildContext context,
  String url,
) async {
  final s = S.of(context);

  Color themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  final result = await tipsDialog3(
    context,
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        color: themeColor(AppThemeKeys.itemBgColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Warning header (red) ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(20),
              horizontal: ScreenUtil().setWidth(24),
            ),
            decoration: BoxDecoration(
              color: themeColor(AppThemeKeys.errorBgColor),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(16)),
                topRight: Radius.circular(ScreenUtil().setWidth(16)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: themeColor(AppThemeKeys.errorTextColor),
                  size: ScreenUtil().setWidth(44),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: Text(
                    s.g_phishing_warning_title,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: themeColor(AppThemeKeys.errorTextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.g_phishing_warning_body,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: themeColor(AppThemeKeys.mainTextColor),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(16)),
                Text(
                  s.g_phishing_warning_url_label,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: themeColor(AppThemeKeys.ff888888),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                  decoration: BoxDecoration(
                    color: themeColor(AppThemeKeys.errorBgColor),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Text(
                    url,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: themeColor(AppThemeKeys.errorTextColor),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: ScreenUtil().setWidth(1)),

          // ── Action buttons ───────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                // "Go Back (Safe)" — safe / primary action
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(ScreenUtil().setWidth(16)),
                    ),
                    child: Container(
                      height: ScreenUtil().setWidth(88),
                      alignment: Alignment.center,
                      child: Text(
                        s.g_phishing_go_back,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.bold,
                          color: themeColor(AppThemeKeys.mainBlueColor),
                        ),
                      ),
                    ),
                  ),
                ),

                VerticalDivider(width: ScreenUtil().setWidth(1), thickness: 1),

                // "Proceed Anyway" — danger / secondary action
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(ScreenUtil().setWidth(16)),
                    ),
                    child: Container(
                      height: ScreenUtil().setWidth(88),
                      alignment: Alignment.center,
                      child: Text(
                        s.g_phishing_proceed_anyway,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          color: themeColor(AppThemeKeys.ff888888),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  return result as bool?;
}
