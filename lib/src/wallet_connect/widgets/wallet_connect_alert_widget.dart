// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42appv2/core/security/tx_risk_analyzer.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42appv2/src/wallet_connect/widgets/tx_risk_banner_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:n42appv2/generated/l10n.dart';

/// WalletConnect signing confirmation bottom sheet.
///
/// Shows a risk analysis banner above the approve/reject buttons for all
/// transaction requests. For typed-data (EIP-712) requests, detects Permit
/// patterns and surfaces appropriate warnings.
class WalletConnectAlertWidget extends ConsumerWidget {
  final wallet_connect.PairingMetadata metadata;
  final Map<String, dynamic> actionDataMap;

  const WalletConnectAlertWidget(this.metadata, this.actionDataMap, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTransaction = actionDataMap['signType'] == 'transaction';

    // Compute risk analysis synchronously — pure function, no I/O
    final TxRiskAnalysis riskAnalysis;
    if (isTransaction) {
      riskAnalysis = TxRiskAnalyzer.analyze(
        calldata: actionDataMap['data'] as String?,
        ethValue: actionDataMap['value'] as String?,
        toAddress: actionDataMap['to'] as String?,
      );
    } else {
      // Message sign — try EIP-712 typed data analysis
      riskAnalysis = TxRiskAnalyzer.analyzeTypedData(
            actionDataMap['data'] as String?,
          ) ??
          const TxRiskAnalysis(
            level: TxRiskLevel.safe,
            functionName: 'Message Signature',
          );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── DApp metadata header ─────────────────────────────────────────────
        _buildHeader(context),

        // ── Section title ────────────────────────────────────────────────────
        _buildTitle(context, isTransaction),

        // ── Scrollable content ───────────────────────────────────────────────
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data rows
                if (isTransaction)
                  _buildTransactionRows(context)
                else
                  _buildMessageRows(context),

                // Risk banner — always shown for transaction; for message only
                // when a meaningful analysis is available (e.g. Permit detected)
                if (isTransaction ||
                    riskAnalysis.level != TxRiskLevel.safe ||
                    riskAnalysis.hasWarnings)
                  TxRiskBannerWidget(analysis: riskAnalysis),
              ],
            ),
          ),
        ),

        // ── Action buttons — always visible at bottom ─────────────────────────
        if (isTransaction)
          _buildTransactionButtons(context, ref)
        else
          _buildMessageButtons(context, ref),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(80),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ImageNetWork(
            imageUrl: metadata.icons.isNotEmpty ? metadata.icons[0] : '',
            height: ScreenUtil().setWidth(60),
            width: ScreenUtil().setWidth(60),
            placeholder: 'assets/img/list_default.png',
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Text(
            metadata.name,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ],
      ),
    );
  }

  // ── Title ────────────────────────────────────────────────────────────────────

  Widget _buildTitle(BuildContext context, bool isTransaction) {
    final s = S.of(context);
    return Container(
      height: ScreenUtil().setWidth(60),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Text(
        isTransaction ? s.s_key_3 : s.g_connect_key12,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.w600,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
        ),
      ),
    );
  }

  // ── Data rows ─────────────────────────────────────────────────────────────────

  Widget _buildTransactionRows(BuildContext context) {
    return Column(
      children: [
        _itemWidget(context, 'Network', actionDataMap['network'] ?? ''),
        _divider(context),
        _itemWidget(context, 'From', actionDataMap['from'] ?? ''),
        _divider(context),
        _itemWidget(context, 'To', actionDataMap['to'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Gas', actionDataMap['gas'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Data', actionDataMap['data'] ?? ''),
      ],
    );
  }

  Widget _buildMessageRows(BuildContext context) {
    return Column(
      children: [
        _itemWidget(context, 'Network', actionDataMap['network'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Address', actionDataMap['from'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Data', actionDataMap['data'] ?? ''),
      ],
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────────

  Widget _buildTransactionButtons(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    return _buttonRow(
      context,
      cancelLabel: s.g_connect_key3,
      onCancel: () {
        ref
            .read(wcpBridgeProvider)
            .cancelTap(WalletConnectState.transaction);
        Navigator.pop(context);
      },
      confirmLabel: s.g_key_78,
      onConfirm: () {
        ref.read(wcpBridgeProvider).transactionSignTap();
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMessageButtons(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    return _buttonRow(
      context,
      cancelLabel: s.g_connect_key3,
      onCancel: () {
        ref
            .read(wcpBridgeProvider)
            .cancelTap(WalletConnectState.messageSign);
        Navigator.pop(context);
      },
      confirmLabel: s.g_key_78,
      onConfirm: () {
        ref.read(wcpBridgeProvider).messageSignTap();
        Navigator.pop(context);
      },
    );
  }

  Widget _buttonRow(
    BuildContext context, {
    required String cancelLabel,
    required VoidCallback onCancel,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(36),
        top: ScreenUtil().setWidth(16),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        border: Border(
          top: BorderSide(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: ScreenUtil().setWidth(88),
              child: buttonStyle2(context, onCancel, cancelLabel),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),
          Expanded(
            child: SizedBox(
              height: ScreenUtil().setWidth(88),
              child: buttonStyle2(context, onConfirm, confirmLabel),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────

  Widget _divider(BuildContext context) => Divider(
        height: ScreenUtil().setWidth(1),
        indent: ScreenUtil().setWidth(30),
        endIndent: ScreenUtil().setWidth(30),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.dividerColor.name),
      );

  Widget _itemWidget(BuildContext context, String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.ff888888.name),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
