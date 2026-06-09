// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/core/security/address_label_service.dart';
import 'package:n42_wallet/core/security/tx_risk_analyzer.dart';
import 'package:n42_wallet/core/security/tx_simulation_result.dart';
import 'package:n42_wallet/core/security/tx_simulation_service.dart';
import 'package:n42_wallet/features/wallet/api/tokenview_enhanced_api.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet_connect/widgets/tx_risk_banner_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/tx_simulation_card.dart';
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

  const WalletConnectAlertWidget(
    this.metadata,
    this.actionDataMap, {
    super.key,
  });

  @override
  ConsumerState<WalletConnectAlertWidget> createState() =>
      _WalletConnectAlertWidgetState();
}

class _WalletConnectAlertWidgetState
    extends ConsumerState<WalletConnectAlertWidget> {
  TxSimulationResult _simResult = TxSimulationResult.simulating();
  ContractCreatorInfo? _contractCreatorInfo;
  AddressLabel? _toAddressLabel;

  @override
  void initState() {
    super.initState();
    if (widget.actionDataMap['signType'] == 'transaction') {
      _runSimulation();
      _fetchContractCreatorInfo();
    } else {
      _simResult = TxSimulationResult.unavailable();
    }
    _checkAddressLabels();
  }

  Future<void> _fetchContractCreatorInfo() async {
    final toAddr = widget.actionDataMap['to'] as String? ?? '';
    final coinType = widget.actionDataMap['coinType'] as String? ?? '';
    if (toAddr.isEmpty || coinType.isEmpty) return;

    final chain = _coinTypeToChain(coinType);
    if (chain == null) return;

    final info = await const TokenViewEnhancedApi().getContractCreator(
      chain,
      toAddr,
    );
    if (mounted && info != null && (info.creatorAddress?.isNotEmpty ?? false)) {
      setState(() => _contractCreatorInfo = info);
    }
  }

  void _checkAddressLabels() {
    final toAddr = widget.actionDataMap['to'] as String? ?? '';
    if (toAddr.isNotEmpty) {
      _toAddressLabel = AddressLabelService.getLabel(toAddr);
    }
  }

  static String? _coinTypeToChain(String coinType) =>
      switch (coinType.toUpperCase()) {
        'ETH' || 'N' => 'eth',
        'BNB' => 'bnb',
        'BASE' => 'base',
        'TRX' => 'trx',
        _ => null,
      };

  Future<void> _runSimulation() async {
    final coinType = widget.actionDataMap['coinType'] as String? ?? '';
    if (coinType.isEmpty) {
      if (mounted)
        setState(() => _simResult = TxSimulationResult.unavailable());
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
      riskAnalysis =
          TxRiskAnalyzer.analyzeTypedData(
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

                // Address label + contract creator info
                _buildSecurityInsights(context),

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
        _buildActionButtons(context, isTransaction),
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
          SizedBox(width: AppSpacing.space2),
          Text(
            widget.metadata.name,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textPrimary,
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      child: Text(
        isTransaction ? s.s_key_3 : s.g_connect_key12,
        style: AppTypography.body.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColorTokens.of(context).textPrimary,
        ),
      ),
    );
  }

  // ── Data rows ─────────────────────────────────────────────────────────────────

  Widget _buildTransactionRows(BuildContext context) {
    return _buildDataRows(context, [
      ('Network', 'network'),
      ('From', 'from'),
      ('To', 'to'),
      ('Gas', 'gas'),
      ('Data', 'data'),
    ]);
  }

  Widget _buildMessageRows(BuildContext context) {
    return _buildDataRows(context, [
      ('Network', 'network'),
      ('Address', 'from'),
      ('Data', 'data'),
    ]);
  }

  /// Build labeled data rows with dividers between them.
  Widget _buildDataRows(BuildContext context, List<(String, String)> fields) {
    final children = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      if (i > 0) children.add(_divider(context));
      final (label, key) = fields[i];
      children.add(
        _itemWidget(context, label, widget.actionDataMap[key] ?? ''),
      );
    }
    return Column(children: children);
  }

  // ── Buttons ───────────────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, bool isTransaction) {
    final s = S.of(context);
    final wcp = ref.read(wcpBridgeProvider);
    final cancelState = isTransaction
        ? WalletConnectState.transaction
        : WalletConnectState.messageSign;
    return _buttonRow(
      context,
      cancelLabel: s.g_connect_key3,
      onCancel: () {
        wcp.cancelTap(cancelState);
        Navigator.pop(context);
      },
      confirmLabel: s.g_key_78,
      onConfirm: () {
        isTransaction ? wcp.transactionSignTap() : wcp.messageSignTap();
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
        color: AppColorTokens.of(context).bgBase,
        border: Border(
          top: BorderSide(color: AppColorTokens.of(context).border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: ScreenUtil().setWidth(88),
              child: AppButton(
                label: cancelLabel,
                variant: AppButtonVariant.secondary,
                onPressed: onCancel,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: SizedBox(
              height: ScreenUtil().setWidth(88),
              child: AppButton(label: confirmLabel, onPressed: onConfirm),
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
    color: AppColorTokens.of(context).border,
  );

  Widget _itemWidget(BuildContext context, String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.ff888888.name,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textPrimary,
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

  // ── Security insights ─────────────────────────────────────────────────────

  Widget _buildSecurityInsights(BuildContext context) {
    final su = ScreenUtil();
    final items = <Widget>[];

    // Address label badge
    if (_toAddressLabel != null) {
      final Color tagColor;
      final IconData tagIcon;
      switch (_toAddressLabel!.riskLevel) {
        case 'danger':
          tagColor = AppColorTokens.of(context).danger;
          tagIcon = Icons.dangerous_outlined;
        case 'caution':
          tagColor = AppColorTokens.of(context).warning;
          tagIcon = Icons.warning_amber_outlined;
        default:
          tagColor = AppColorTokens.of(context).success;
          tagIcon = Icons.verified_outlined;
      }
      items.add(
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: su.setWidth(20),
            vertical: su.setWidth(10),
          ),
          decoration: BoxDecoration(
            color: tagColor.withAlpha(15),
            borderRadius: BorderRadius.circular(su.setWidth(12)),
            border: Border.all(color: tagColor.withAlpha(40)),
          ),
          child: Row(
            children: [
              Icon(tagIcon, size: su.setWidth(32), color: tagColor),
              SizedBox(width: su.setWidth(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toAddressLabel!.name,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tagColor,
                      ),
                    ),
                    Text(
                      _toAddressLabel!.category.toUpperCase(),
                      style: AppTypography.captionSm.copyWith(
                        color: tagColor.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Contract creator info
    if (_contractCreatorInfo != null) {
      final isNew = _contractCreatorInfo!.isNewContract;
      final ageDays = _contractCreatorInfo!.contractAgeDays;
      final creatorAddr = _contractCreatorInfo!.creatorAddress ?? '';
      final c = AppColorTokens.of(context);
      final contractAccent = isNew ? c.warning : c.brand;

      items.add(
        Container(
          margin: EdgeInsets.only(top: su.setWidth(8)),
          padding: EdgeInsets.symmetric(
            horizontal: su.setWidth(20),
            vertical: su.setWidth(10),
          ),
          decoration: BoxDecoration(
            color: contractAccent.withAlpha(15),
            borderRadius: BorderRadius.circular(su.setWidth(12)),
            border: Border.all(
              color: contractAccent.withAlpha(40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.code,
                    size: su.setWidth(28),
                    color: contractAccent,
                  ),
                  SizedBox(width: su.setWidth(8)),
                  Text(
                    'Contract Info',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: su.setWidth(6)),
              if (creatorAddr.isNotEmpty)
                Text(
                  'Creator: ${creatorAddr.length > 16 ? '${creatorAddr.substring(0, 8)}...${creatorAddr.substring(creatorAddr.length - 8)}' : creatorAddr}',
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              if (ageDays != null)
                Text(
                  'Age: ${ageDays >= 365
                      ? '${(ageDays / 365).toStringAsFixed(1)} years'
                      : ageDays >= 30
                      ? '${(ageDays / 30).toStringAsFixed(0)} months'
                      : '$ageDays days'}',
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              if (isNew)
                Padding(
                  padding: EdgeInsets.only(top: su.setWidth(6)),
                  child: Text(
                    '⚠ New contract (< 7 days), proceed with caution',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).warning,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: su.setWidth(30),
        vertical: su.setWidth(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }
}
