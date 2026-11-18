import 'dart:convert';

import 'package:n42_wallet/core/security/signature_decoder.dart';
import 'package:n42_wallet/core/security/tx_risk_analyzer.dart';
import 'package:n42_wallet/features/wallet_connect/widgets/tx_risk_banner_widget.dart';
import 'package:n42_wallet/features/widgets/signing_payload_details.dart';
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

  /// 连接授权请求（`eth_requestAccounts`）——不是签名，展示必须区别于签名，
  /// 否则用户看到的是标题 "Sign Message"、内容空白的框，既看不懂也不像授权。
  bool get _isConnect => method == 'eth_requestAccounts';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isTransaction = method.contains('Transaction');
    final payload = details['message'] ?? details['data'];
    final title = _isConnect
        ? s.g_key_dapp_connect_title
        : (isTransaction ? s.s_key_3 : s.g_key_msgsign_title);

    // 高度上限 + 底部安全区：sheet 以 isScrollControlled 打开时最大可占满全屏，
    // 若不设上限，长内容会把底部按钮顶出可视区域，用户无法批准/拒绝。
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
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
                  // 签名可读化：把原始 calldata/EIP-712/personal_sign 翻译成人类
                  // 可读的标题+说明+风险等级+关键字段高亮（复用 WalletConnect 签名
                  // 流程同款 TxRiskBannerWidget）。结构化签名无法解码时仍显示
                  // 提示，完整的签名请求可在下方展开。
                  //
                  // 必须放在可滚动区内：风险字段/警告较多时该横幅很高，若留在
                  // Flexible 之外会挤压滚动区并把底部按钮顶出屏幕。
                  if (!_isConnect)
                    Builder(
                      builder: (context) {
                        final analysis = _decode(s);
                        if (analysis == null) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.space4),
                          child: TxRiskBannerWidget(analysis: analysis),
                        );
                      },
                    ),
                  if (_isConnect) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.space4),
                      child: Text(
                        s.g_key_dapp_connect_desc,
                        style: AppTypography.body.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                    ),
                    if (details['address'] != null)
                      _itemWidget(
                        context,
                        s.g_key_dapp_connect_account,
                        details['address'].toString(),
                      ),
                  ] else ...[
                    _itemWidget(context, s.g_ui3_method, method),
                  ],
                  if (!_isConnect)
                    if (isTransaction) ...[
                      if (details['from'] != null)
                        _itemWidget(
                          context,
                          s.g_key_75,
                          details['from'].toString(),
                        ),
                      if (details['to'] != null)
                        _itemWidget(
                          context,
                          s.g_key_38,
                          details['to'].toString(),
                        ),
                      if (details['value'] != null && details['value'] != '0x0')
                        _itemWidget(
                          context,
                          s.g_key_wallet_k55,
                          details['value'].toString(),
                        ),
                      if (details['data'] != null && details['data'] != '0x')
                        _itemWidget(
                          context,
                          s.g_ui3_data,
                          _truncate(details['data'].toString(), 200),
                        ),
                    ] else ...[
                      _itemWidget(context, s.g_ui3_data, _formatSignData(details)),
                      if (payload is String && payload.isNotEmpty)
                        SigningPayloadDetails(payload: payload),
                    ],
                ],
              ),
            ),
          ),

          // Buttons —— 用 SafeArea 兜住 iPhone 底部 home indicator，
          // 否则批准/拒绝按钮会被系统手势条压住。
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).bgBase,
              border: Border(
                top: BorderSide(
                  color: AppColorTokens.of(context).border,
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: ScreenUtil().setWidth(36),
              top: ScreenUtil().setWidth(16),
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: AppTouch.target,
                      child: AppButton(
                        label: s.g_key_79,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _close(context, false),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: SizedBox(
                      height: AppTouch.target,
                      child: AppButton(
                        label: s.g_key_78,
                        onPressed: () => _close(context, true),
                      ),
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

  /// 按请求类型选择合适的解码器，返回 [TxRiskAnalysis]（复用 WalletConnect
  /// 流程的展示模型）。解析失败（如无法识别的 typed data 结构）返回 null，
  /// 调用方隐藏横幅、不影响原始数据的展示。
  /// Pops the sheet once. A fast double tap would otherwise pop a second
  /// time and close the browser page underneath.
  void _close(BuildContext context, bool approved) {
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    Navigator.pop(context, approved);
  }

  TxRiskAnalysis? _decode(S s) {
    final isTypedData = method.startsWith('eth_signTypedData');
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
      } else if (isTypedData) {
        final raw = details['data'] ?? details['message'];
        Map<String, dynamic>? typedData;
        if (raw is Map<String, dynamic>) {
          typedData = raw;
        } else if (raw is String) {
          final decoded = json.decode(raw);
          if (decoded is Map<String, dynamic>) typedData = decoded;
        }
        if (typedData == null) return TxRiskAnalyzer.unavailableTypedPreview;
        result = SignatureDecoder.decodeTypedData(typedData);
      } else {
        // personal_sign / eth_sign
        final msg = (details['message'] ?? details['data'] ?? '').toString();
        if (msg.isEmpty) return null;
        result = SignatureDecoder.decodePersonalSign(msg);
      }

      return result.toRiskAnalysis(includeDescription: true);
    } catch (_) {
      return isTypedData ? TxRiskAnalyzer.unavailableTypedPreview : null;
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
            // textSubtitle: #888888 measured ~3.5:1 on the sheet background.
            style: AppTypography.caption.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
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
