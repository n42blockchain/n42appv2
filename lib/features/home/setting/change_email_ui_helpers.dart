// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Stateless UI helpers shared across all change-email step views.

Widget changeEmailCodeField({
  required TextEditingController ctrl,
  required FocusNode focus,
  required Color textColor,
  required Color fillColor,
  required Color accentColor,
  required Color subColor,
  String? errorText,
  required ValueChanged<String> onChanged,
  required ValueChanged<String> onSubmitted,
}) {
  return TextField(
    controller: ctrl,
    focusNode: focus,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ],
    style: AppTypography.caption.copyWith(
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: 8,
    ),
    decoration: changeEmailInputDeco(
      hint: '------',
      fillColor: fillColor,
      accentColor: accentColor,
      subColor: subColor,
      errorText: errorText,
      counterText: '',
    ),
    onChanged: onChanged,
    onSubmitted: onSubmitted,
  );
}

Widget changeEmailResendRow({
  required BuildContext context,
  required int countdown,
  required bool loading,
  required VoidCallback onTap,
  required Color accentColor,
  required Color subColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // TextButton 自带 48dp 最小命中区 + 禁用态（§5 触控红线）
      TextButton(
        onPressed: (countdown > 0 || loading) ? null : onTap,
        child: Text(
          countdown > 0
              ? S.of(context).g_email_resend_countdown(countdown)
              : S.of(context).g_email_resend,
          style: AppTypography.caption.copyWith(
            color: countdown > 0 ? subColor : accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget changeEmailPrimaryButton({
  required String label,
  required Future<void> Function() onPressed,
  required bool loading,
  required Color accentColor,
}) {
  return SizedBox(
    width: double.infinity,
    // 96.h≈48dp（§2.1 Primary 标准高，44dp 触控红线）
    height: 96.h,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl),
      ),
      child: loading
          ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label, style: AppTypography.bodyStrong),
    ),
  );
}

Widget changeEmailBackButton({
  required String label,
  required VoidCallback onPressed,
  required Color subColor,
}) {
  return Center(
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.captionSm.copyWith(
          color: subColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}

InputDecoration changeEmailInputDeco({
  required String hint,
  required Color fillColor,
  required Color accentColor,
  required Color subColor,
  String? errorText,
  String? counterText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: subColor),
    errorText: errorText,
    counterText: counterText,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: fillColor,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: accentColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
    ),
  );
}
