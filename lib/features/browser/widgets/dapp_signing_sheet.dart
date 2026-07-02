import 'dart:convert';

import 'package:n42_wallet/core/security/signature_decoder.dart';
import 'package:n42_wallet/core/security/tx_risk_analyzer.dart';
import 'package:n42_wallet/features/wallet_connect/widgets/tx_risk_banner_widget.dart';
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
            horizontal: AppSpacing.space8,
            vertical: AppSpacing.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.space2),
              Text(
                origin,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: AppColorTokens.of(context).border),

        // 签名可读化：把原始 calldata/EIP-712/personal_sign 翻译成人类可读的
        // 标题+说明+风险等级+关键字段高亮（复用 WalletConnect 签名流程同款
        // TxRiskBannerWidget，视觉一致）。解码失败时静默回退，不影响下方原始
        // 数据展示——用户始终能看到真实请求内容。
        Builder(
          builder: (context) {
            final analysis = _decode();
            if (analysis == null) return const SizedBox.shrink();
            return TxRiskBannerWidget(analysis: analysis);
          },
        ),

        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space4,
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
              SizedBox(width: AppSpacing.space4),
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

  /// 按请求类型选择合适的解码器，返回 [TxRiskAnalysis]（复用 WalletConnect
  /// 流程的展示模型）。解析失败（如无法识别的 typed data 结构）返回 null，
  /// 调用方隐藏横幅、不影响原始数据的展示。
  TxRiskAnalysis? _decode() {
    try {
      final isTransaction = method.contains('Transaction');
      final SignatureDecodedResult result;

      if (isTransaction) {
        result = SignatureDecoder.decodeContractCall(
          calldata: details['data']?.toString() ?? '0x',
          contractAddress: details['to']?.toString(),
          fromAddress: details['from']?.toString(),
          value: details['value']?.toString(),
        );
      } else if (method.contains('signTypedData')) {
        final raw = details['data'] ?? details['message'];
        Map<String, dynamic>? typedData;
        if (raw is Map<String, dynamic>) {
          typedData = raw;
        } else if (raw is String) {
          final decoded = json.decode(raw);
          if (decoded is Map<String, dynamic>) typedData = decoded;
        }
        if (typedData == null) return null;
        result = SignatureDecoder.decodeTypedData(typedData);
      } else {
        // personal_sign / eth_sign
        final msg = (details['message'] ?? details['data'] ?? '').toString();
        if (msg.isEmpty) return null;
        result = SignatureDecoder.decodePersonalSign(msg);
      }

      return TxRiskAnalysis(
        level: result.riskLevel,
        functionName: result.title,
        fields: [
          if (result.description.isNotEmpty)
            TxRiskField('Details', result.description),
          for (final f in result.fields)
            TxRiskField(f.label, f.value, isHighlighted: f.isHighlighted),
        ],
        warnings: result.warnings,
      );
    } catch (_) {
      // 解析失败（畸形/未知结构）：静默回退，不阻断签名流程，原始数据仍可见。
      return null;
    }
  }

  Widget _itemWidget(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.ff888888.name,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            value,
            style: AppTypography.bodySm.copyWith(
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
