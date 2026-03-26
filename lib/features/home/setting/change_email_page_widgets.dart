// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/home/setting/change_email_page.dart';
import 'package:n42_wallet/features/home/setting/change_email_page_logic.dart';
import 'package:n42_wallet/features/home/setting/change_email_ui_helpers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// Widgets mixin for [ChangeEmailPage].
///
/// Contains all UI builder methods for step views and shared input helpers.
mixin ChangeEmailPageWidgetsMixin on State<ChangeEmailPage>,
    ChangeEmailPageLogicMixin {
  /// Theme color shortcut
  Color _tc(String key) => AppThemeUtils.getColorByKey(context, key);

  /// Reusable error box decoration (red-tinted border + background)
  BoxDecoration _errorBoxDecoration(Color errorColor) => BoxDecoration(
        color: errorColor.withAlpha(20),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: errorColor.withAlpha(80)),
      );

  // ── Step 0 ──────────────────────────────────────────────────────────────────

  Widget buildStep0(Color textColor, Color subColor, Color accentColor,
      Color fillColor, Color lineColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).g_email_current_label,
            style: TextStyle(fontSize: 13.sp, color: subColor)),
        SizedBox(height: 4.h),
        Text(
          AppGlobals.userInfo?.email ?? '',
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textColor),
        ),
        SizedBox(height: 28.h),

        Text(S.of(context).g_email_new_label,
            style: TextStyle(fontSize: 13.sp, color: subColor)),
        SizedBox(height: 8.h),
        TextField(
          controller: emailCtrl,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: TextStyle(fontSize: 15.sp, color: textColor),
          decoration: changeEmailInputDeco(
            hint: S.of(context).g_email_new_hint,
            fillColor: fillColor,
            accentColor: accentColor,
            subColor: subColor,
            errorText: emailError,
          ),
          onChanged: (_) {
            if (emailError != null) setState(() => emailError = null);
          },
          onSubmitted: (_) {
            if (chatSyncEnabled && chatAvailable) {
              passwordFocus.requestFocus();
            } else {
              sendN42Code();
            }
          },
        ),

        // ── Chat sync section ──────────────────────────────────────────────
        if (chatAvailable) ...[
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: _tc(AppThemeKeys.itemBgColor2.name),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.of(context).g_email_also_sync,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: textColor)),
                          SizedBox(height: 3.h),
                          Text('Both accounts will be updated in one flow',
                              style: TextStyle(
                                  fontSize: 12.sp, color: subColor)),
                        ],
                      ),
                    ),
                    Switch(
                      value: chatSyncEnabled,
                      onChanged: (v) => setState(() {
                        chatSyncEnabled = v;
                        passwordError = null;
                      }),
                      activeTrackColor: accentColor,
                      activeThumbColor: Colors.white,
                    ),
                  ],
                ),
                if (chatSyncEnabled) ...[
                  SizedBox(height: 12.h),
                  Divider(
                      color: _tc(AppThemeKeys.dividerColor.name),
                      height: 1),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).g_email_pwd_label,
                        style: TextStyle(fontSize: 13.sp, color: subColor)),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: passwordCtrl,
                    focusNode: passwordFocus,
                    obscureText: obscurePassword,
                    style: TextStyle(fontSize: 15.sp, color: textColor),
                    decoration: changeEmailInputDeco(
                      hint: S.of(context).g_email_pwd_hint,
                      fillColor: _tc(AppThemeKeys.itemBgColor.name),
                      accentColor: accentColor,
                      subColor: subColor,
                      errorText: passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: subColor,
                          size: 20.sp,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    onChanged: (_) {
                      if (passwordError != null) {
                        setState(() => passwordError = null);
                      }
                    },
                    onSubmitted: (_) => sendN42Code(),
                  ),
                ],
              ],
            ),
          ),
        ],

        SizedBox(height: 36.h),
        changeEmailPrimaryButton(
          label: S.of(context).g_email_send_code,
          onPressed: sendN42Code,
          loading: sendingN42Code,
          accentColor: accentColor,
        ),
      ],
    );
  }

  // ── Step 1: N42 验证码 ──────────────────────────────────────────────────────

  Widget buildStep1(Color textColor, Color subColor, Color accentColor,
      Color fillColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${S.of(context).g_email_n42_updated} →',
            style: TextStyle(fontSize: 13.sp, color: subColor)),
        SizedBox(height: 4.h),
        Text(
          emailCtrl.text.trim(),
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: accentColor),
        ),
        SizedBox(height: 28.h),

        Text(S.of(context).g_email_enter_code,
            style: TextStyle(fontSize: 13.sp, color: subColor)),
        SizedBox(height: 8.h),
        changeEmailCodeField(
          ctrl: n42CodeCtrl,
          focus: n42CodeFocus,
          textColor: textColor,
          fillColor: fillColor,
          accentColor: accentColor,
          subColor: subColor,
          errorText: n42CodeError,
          onChanged: (_) {
            if (n42CodeError != null) setState(() => n42CodeError = null);
          },
          onSubmitted: (_) => confirmN42(),
        ),
        SizedBox(height: 12.h),
        changeEmailResendRow(
          context: context,
          countdown: countdown,
          loading: sendingN42Code,
          onTap: resendN42Code,
          accentColor: accentColor,
          subColor: subColor,
        ),
        SizedBox(height: 32.h),
        changeEmailPrimaryButton(
          label: chatSyncEnabled && chatAvailable
              ? S.of(context).g_email_confirm_continue
              : S.of(context).g_email_confirm_change,
          onPressed: confirmN42,
          loading: confirmingN42,
          accentColor: accentColor,
        ),
        SizedBox(height: 12.h),
        changeEmailBackButton(
          label: S.of(context).g_email_back_to_email,
          onPressed: () => setState(() {
            step = 0;
            n42CodeCtrl.clear();
            n42CodeError = null;
          }),
          subColor: subColor,
        ),
      ],
    );
  }

  // ── Step 2: Chat 同步 ───────────────────────────────────────────────────────

  Widget buildStep2(Color textColor, Color subColor, Color accentColor,
      Color fillColor, Color lineColor) {
    const successColor = Color(0xFF22C55E);
    const errorColor = Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // N42 成功状态行
        Row(
          children: [
            Icon(Icons.check_circle, color: successColor, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).g_email_n42_updated,
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  Text(emailCtrl.text.trim(),
                      style: TextStyle(fontSize: 12.sp, color: subColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Divider(color: lineColor, height: 1),
        SizedBox(height: 20.h),

        // Chat 同步标题
        Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: accentColor, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(S.of(context).g_email_chat_sync_title,
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // ── 状态：正在请求 Chat 验证码 ─────────────────────────────────────
        if (requestingChatCode)
          Center(
            child: Column(
              children: [
                SizedBox(height: 16.h),
                CircularProgressIndicator(color: accentColor, strokeWidth: 2),
                SizedBox(height: 12.h),
                Text(S.of(context).g_email_chat_sending,
                    style: TextStyle(fontSize: 13.sp, color: subColor)),
                SizedBox(height: 8.h),
                Text('Code will be sent to ${emailCtrl.text.trim()}',
                    style: TextStyle(fontSize: 12.sp, color: subColor)),
              ],
            ),
          ),

        // ── 状态：请求 Chat 验证码失败（连密码都没过） ─────────────────────
        if (!requestingChatCode && chatSyncError != null && !chatCodeSent)
          ..._buildChatRequestError(
              errorColor, subColor, accentColor, textColor, lineColor),

        // ── 状态：Chat 验证码已发送，等待用户输入 ──────────────────────────
        if (chatCodeSent && !requestingChatCode)
          ..._buildChatCodeInput(
              textColor, subColor, accentColor, fillColor, errorColor),
      ],
    );
  }

  List<Widget> _buildChatRequestError(Color errorColor, Color subColor,
      Color accentColor, Color textColor, Color lineColor) {
    return [
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: _errorBoxDecoration(errorColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: errorColor, size: 16.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(S.of(context).g_email_chat_send_fail,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: errorColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(chatSyncError!,
                style: TextStyle(fontSize: 12.sp, color: subColor)),
          ],
        ),
      ),
      SizedBox(height: 16.h),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: skipChatSync,
              style: OutlinedButton.styleFrom(
                foregroundColor: subColor,
                side: BorderSide(color: lineColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(S.of(context).g_email_skip,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: requestChatCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text('Retry',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildChatCodeInput(Color textColor, Color subColor,
      Color accentColor, Color fillColor, Color errorColor) {
    return [
      Text(S.of(context).g_email_chat_code_sent_to,
          style: TextStyle(fontSize: 13.sp, color: subColor)),
      SizedBox(height: 4.h),
      Text(
        emailCtrl.text.trim(),
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: accentColor),
      ),
      SizedBox(height: 20.h),

      Text(S.of(context).g_email_chat_code_hint,
          style: TextStyle(fontSize: 13.sp, color: subColor)),
      SizedBox(height: 8.h),
      changeEmailCodeField(
        ctrl: chatCodeCtrl,
        focus: chatCodeFocus,
        textColor: textColor,
        fillColor: fillColor,
        accentColor: accentColor,
        subColor: subColor,
        errorText: null,
        onChanged: (_) {
          if (chatSyncError != null) setState(() => chatSyncError = null);
        },
        onSubmitted: (_) => confirmChat(),
      ),

      // Chat 错误（验证码错误等）
      if (chatSyncError != null) ...[
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: _errorBoxDecoration(errorColor),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: errorColor, size: 14.sp),
              SizedBox(width: 6.w),
              Expanded(
                  child: Text(chatSyncError!,
                      style:
                          TextStyle(fontSize: 12.sp, color: errorColor))),
            ],
          ),
        ),
      ],

      SizedBox(height: 12.h),
      changeEmailResendRow(
        context: context,
        countdown: countdown,
        loading: requestingChatCode,
        onTap: resendChatCode,
        accentColor: accentColor,
        subColor: subColor,
      ),
      SizedBox(height: 28.h),
      changeEmailPrimaryButton(
        label: S.of(context).g_email_chat_confirm,
        onPressed: confirmChat,
        loading: confirmingChat,
        accentColor: accentColor,
      ),
      SizedBox(height: 12.h),
      Center(
        child: TextButton(
          onPressed: skipChatSync,
          child: Text(
            S.of(context).g_email_skip_full,
            style: TextStyle(color: subColor, fontSize: 13.sp),
          ),
        ),
      ),
    ];
  }
}
