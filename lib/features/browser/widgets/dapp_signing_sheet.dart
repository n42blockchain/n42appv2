import 'dart:convert';

import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Bottom sheet for DApp signing confirmations (EIP-1193 provider).
///
/// Returns `true` (approved) or `false` (rejected) via `Navigator.pop`.
class DAppSigningSheet extends StatelessWidget {
  final String origin;
  final String method;
  final Map<String, dynamic> details;

  const DAppSigningSheet({
    required this.origin,
    required this.method,
    required this.details,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isTransaction = method.contains('Transaction');
    final title = isTransaction ? 'Transaction' : 'Sign Message';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30),
            vertical: ScreenUtil().setWidth(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              Text(
                origin,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: AppColorTokens.of(context).border),

        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _itemWidget(context, 'Method', method),
                if (isTransaction) ...[
                  if (details['from'] != null)
                    _itemWidget(context, 'From', details['from'].toString()),
                  if (details['to'] != null)
                    _itemWidget(context, 'To', details['to'].toString()),
                  if (details['value'] != null && details['value'] != '0x0')
                    _itemWidget(context, 'Value', details['value'].toString()),
                  if (details['data'] != null && details['data'] != '0x')
                    _itemWidget(
                      context,
                      'Data',
                      _truncate(details['data'].toString(), 200),
                    ),
                ] else ...[
                  _itemWidget(context, 'Data', _formatSignData(details)),
                ],
              ],
            ),
          ),
        ),

        // Buttons
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: ScreenUtil().setWidth(36),
            top: ScreenUtil().setWidth(16),
            left: ScreenUtil().setWidth(30),
            right: ScreenUtil().setWidth(30),
          ),
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).bgBase,
            border: Border(
              top: BorderSide(
                color: AppColorTokens.of(context).border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: ScreenUtil().setWidth(88),
                  child: AppButton(
                    label: s.g_key_79,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20)),
              Expanded(
                child: SizedBox(
                  height: ScreenUtil().setWidth(88),
                  child: AppButton(
                    label: s.g_key_78,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemWidget(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.ff888888.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(6)),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppColorTokens.of(context).textPrimary,
            ),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatSignData(Map<String, dynamic> details) {
    final msg = details['message'] ?? details['data'] ?? '';
    if (msg is String && msg.startsWith('{')) {
      try {
        final parsed = json.decode(msg);
        return const JsonEncoder.withIndent('  ').convert(parsed);
      } catch (_) {}
    }
    return _truncate(msg.toString(), 500);
  }

  String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s;
    return '${s.substring(0, maxLen)}...';
  }
}
