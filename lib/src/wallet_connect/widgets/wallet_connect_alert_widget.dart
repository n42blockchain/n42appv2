// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/core/security/tx_risk_analyzer.dart';
import 'package:n42_wallet/core/security/tx_simulation_result.dart';
import 'package:n42_wallet/core/security/tx_simulation_service.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/src/wallet_connect/widgets/tx_risk_banner_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/image_network.dart';
import 'package:n42_wallet/src/widgets/tx_simulation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:n42_wallet/generated/l10n.dart';

/// WalletConnect signing confirmation bottom sheet.
///
/// Shows a risk analysis banner and an on-chain simulation result above the
/// approve/reject buttons for all transaction requests. For typed-data
/// (EIP-712) requests, detects Permit patterns and surfaces appropriate warnings.
class WalletConnectAlertWidget extends ConsumerStatefulWidget {
  final wallet_connect.PairingMetadata metadata;
  final Map<String, dynamic> actionDataMap;

  const WalletConnectAlertWidget(this.metadata, this.actionDataMap, {super.key});

  @override
  ConsumerState<WalletConnectAlertWidget> createState() =>
      _WalletConnectAlertWidgetState();
}

class _WalletConnectAlertWidgetState
    extends ConsumerState<WalletConnectAlertWidget> {
  TxSimulationResult _simResult = TxSimulationResult.simulating();

  @override
  void initState() {
    super.initState();
    if (widget.actionDataMap['signType'] == 'transaction') {
      _runSimulation();
    } else {
      // Message signing — no simulation needed
      _simResult = TxSimulationResult.unavailable();
    }
  }

  Future<void> _runSimulation() async {
    final coinType = widget.actionDataMap['coinType'] as String? ?? '';
    if (coinType.isEmpty) {
      if (mounted) setState(() => _simResult = TxSimulationResult.unavailable());
      return;
    }

    final result = await TxSimulationService.simulate(
      coinType: coinType,
      from: widget.actionDataMap['from'] as String? ?? '',
      to: widget.actionDataMap['to'] as String? ?? '',
      data: widget.actionDataMap['data'] as String? ?? '0x',
      value: _parseHexValue(widget.actionDataMap['value']),
    );

    if (mounted) setState(() => _simResult = result);
  }

  /// Parse a hex-encoded value string (e.g. "0x1a") to BigInt, returning null
  /// if the string is absent, zero, or unparseable.
  BigInt? _parseHexValue(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    if (s.isEmpty || s == '0x' || s == '0x0' || s == '0') return null;
    try {
      final clean = s.startsWith('0x') ? s.substring(2) : s;
      final v = BigInt.parse(clean, radix: 16);
      return v > BigInt.zero ? v : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTransaction = widget.actionDataMap['signType'] == 'transaction';

    // Compute risk analysis synchronously — pure function, no I/O
    final TxRiskAnalysis riskAnalysis;
    if (isTransaction) {
      riskAnalysis = TxRiskAnalyzer.analyze(
        calldata: widget.actionDataMap['data'] as String?,
        ethValue: widget.actionDataMap['value'] as String?,
        toAddress: widget.actionDataMap['to'] as String?,
      );
    } else {
      // Message sign — try EIP-712 typed data analysis
      riskAnalysis = TxRiskAnalyzer.analyzeTypedData(
            widget.actionDataMap['data'] as String?,
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

                // Simulation card — only for transactions
                if (isTransaction) TxSimulationCard(result: _simResult),

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
          _buildTransactionButtons(context)
        else
          _buildMessageButtons(context),
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
            imageUrl: widget.metadata.icons.isNotEmpty
                ? widget.metadata.icons[0]
                : '',
            height: ScreenUtil().setWidth(60),
            width: ScreenUtil().setWidth(60),
            placeholder: 'assets/img/list_default.png',
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Text(
            widget.metadata.name,
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
        _itemWidget(context, 'Network', widget.actionDataMap['network'] ?? ''),
        _divider(context),
        _itemWidget(context, 'From', widget.actionDataMap['from'] ?? ''),
        _divider(context),
        _itemWidget(context, 'To', widget.actionDataMap['to'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Gas', widget.actionDataMap['gas'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Data', widget.actionDataMap['data'] ?? ''),
      ],
    );
  }

  Widget _buildMessageRows(BuildContext context) {
    return Column(
      children: [
        _itemWidget(context, 'Network', widget.actionDataMap['network'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Address', widget.actionDataMap['from'] ?? ''),
        _divider(context),
        _itemWidget(context, 'Data', widget.actionDataMap['data'] ?? ''),
      ],
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────────

  Widget _buildTransactionButtons(BuildContext context) {
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

  Widget _buildMessageButtons(BuildContext context) {
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
