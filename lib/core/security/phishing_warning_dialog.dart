// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  final navigator = Navigator.of(context, rootNavigator: true);

  Color themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  final result = await tipsDialog3(
    context,
    Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: themeColor(AppThemeKeys.itemBgColor),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Warning header (red) ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
                horizontal: AppSpacing.space6,
              ),
              decoration: BoxDecoration(
                color: themeColor(AppThemeKeys.errorBgColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: themeColor(AppThemeKeys.errorTextColor),
                    size: ScreenUtil().setWidth(44),
                  ),
                  SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: Text(
                      s.g_phishing_warning_title,
                      style: AppTypography.headline.copyWith(
                        color: themeColor(AppThemeKeys.errorTextColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(AppSpacing.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.g_phishing_warning_body,
                    style: AppTypography.body.copyWith(
                      color: themeColor(AppThemeKeys.mainTextColor),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space4),
                  Text(
                    s.g_phishing_warning_url_label,
                    style: AppTypography.caption.copyWith(
                      color: themeColor(AppThemeKeys.ff888888),
                    ),
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: themeColor(AppThemeKeys.errorBgColor),
                      borderRadius: AppRadius.brSm,
                    ),
                    child: Text(
                      url,
                      style: AppTypography.caption.copyWith(
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
                      onTap: () => navigator.pop(false),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.md),
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: ScreenUtil().setWidth(88),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.g_phishing_go_back,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyStrong.copyWith(
                            color: themeColor(AppThemeKeys.mainBlueColor),
                          ),
                        ),
                      ),
                    ),
                  ),

                  VerticalDivider(
                    width: ScreenUtil().setWidth(1),
                    thickness: 1,
                  ),

                  // "Proceed Anyway" — danger / secondary action
                  Expanded(
                    child: InkWell(
                      onTap: () => navigator.pop(true),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(AppRadius.md),
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: ScreenUtil().setWidth(88),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.g_phishing_proceed_anyway,
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
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
    ),
  );
  return result is bool ? result : null;
}
