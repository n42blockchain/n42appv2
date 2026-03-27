// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/validation/address_validator.dart';

/// ENS 确认对话框
///
/// 当用户输入 ENS 名称时显示，要求用户确认解析后的地址
class EnsConfirmDialog extends StatelessWidget {
  /// ENS 名称 (例如: vitalik.eth)
  final String ensName;

  /// 解析后的以太坊地址
  final String resolvedAddress;

  /// 代币符号 (用于显示)
  final String? tokenSymbol;

  const EnsConfirmDialog({
    super.key,
    required this.ensName,
    required this.resolvedAddress,
    this.tokenSymbol,
  });

  /// 显示 ENS 确认对话框
  ///
  /// 返回 true 表示用户确认，false 表示取消
  static Future<bool> show({
    required BuildContext context,
    required String ensName,
    required String resolvedAddress,
    String? tokenSymbol,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnsConfirmDialog(
        ensName: ensName,
        resolvedAddress: resolvedAddress,
        tokenSymbol: tokenSymbol,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    const successGreen = Color(0xFF4CAF50);

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
            decoration: BoxDecoration(
              color: blueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: blueColor,
              size: ScreenUtil().setWidth(32),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              S.of(context).g_key_ens_confirm_title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold,
                color: mainTextColor,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENS 检测提示
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
              decoration: BoxDecoration(
                color: successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                border: Border.all(
                  color: successGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: successGreen,
                    size: ScreenUtil().setWidth(28),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Expanded(
                    child: Text(
                      S.of(context).g_key_ens_detected,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w600,
                        color: successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),

            // ENS 名称
            _buildInfoRow(
              context,
              label: S.of(context).g_key_ens_name,
              value: ensName,
              icon: Icons.badge_outlined,
              iconColor: blueColor,
              textColor: mainTextColor,
              subtitleColor: subtitleColor,
              onCopy: () => _copyToClipboard(context, ensName),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),

            // 箭头指示
            Center(
              child: Icon(
                Icons.arrow_downward_rounded,
                color: subtitleColor,
                size: ScreenUtil().setWidth(32),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),

            // 解析后的地址
            _buildInfoRow(
              context,
              label: S.of(context).g_key_ens_resolved_address,
              value: resolvedAddress,
              displayValue: AddressValidator.getAddressPreview(
                resolvedAddress,
                prefixLength: 10,
                suffixLength: 8,
              ),
              icon: Icons.account_balance_wallet_outlined,
              iconColor: isDark ? Colors.orange : Colors.deepOrange,
              textColor: mainTextColor,
              subtitleColor: subtitleColor,
              onCopy: () => _copyToClipboard(context, resolvedAddress),
              showFullAddress: true,
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),

            // 安全警告
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(14)),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: ScreenUtil().setWidth(28),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Expanded(
                    child: Text(
                      S.of(context).g_key_ens_warning,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: isDark
                            ? Colors.orange.shade200
                            : Colors.orange.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(24),
              vertical: ScreenUtil().setWidth(12),
            ),
          ),
          child: Text(
            S.of(context).g_key_79, // Cancel
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: subtitleColor,
            ),
          ),
        ),
        // 确认按钮
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: blueColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(24),
              vertical: ScreenUtil().setWidth(12),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
          ),
          child: Text(
            S.of(context).g_key_ens_confirm_send,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      actionsPadding: EdgeInsets.all(ScreenUtil().setWidth(16)),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    String? displayValue,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onCopy,
    bool showFullAddress = false,
  }) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(14)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: subtitleColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: ScreenUtil().setWidth(24),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: subtitleColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCopy,
                child: Icon(
                  Icons.copy_rounded,
                  color: subtitleColor,
                  size: ScreenUtil().setWidth(22),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          SelectableText(
            displayValue ?? value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: 'monospace',
            ),
          ),
          if (showFullAddress && displayValue != null) ...[
            SizedBox(height: ScreenUtil().setWidth(4)),
            Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                color: subtitleColor,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_119), // "Copy"
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// ENS 解析加载对话框
class EnsResolvingDialog extends StatelessWidget {
  final String ensName;

  const EnsResolvingDialog({
    super.key,
    required this.ensName,
  });

  /// 显示 ENS 解析加载对话框
  static void show(BuildContext context, String ensName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnsResolvingDialog(ensName: ensName),
    );
  }

  /// 关闭对话框
  static void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final mainTextColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(60),
                height: ScreenUtil().setWidth(60),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(blueColor),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(24)),
              Text(
                S.of(context).g_key_ens_resolving,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              Text(
                ensName,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: blueColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
