// Copyright 2021-2026 N42 Inc. All rights reserved.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/wallet/aa/repository/session_key_repository.dart';

import 'session_key_models.dart';

class KeyDetailsSheet extends StatelessWidget {
  final SessionKeyData keyData;

  const KeyDetailsSheet({super.key, required this.keyData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(4),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_aa_session_details,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          _row(context, S.of(context).g_key_aa_label, keyData.label),
          _row(context, S.of(context).g_key_aa_permission,
              _permLabel(context, keyData.permission)),
          _row(context, S.of(context).g_key_aa_created,
              _date(keyData.createdAt)),
          _row(context, S.of(context).g_key_aa_expires,
              _date(keyData.expiresAt)),
          _row(context, S.of(context).g_key_aa_transactions,
              '${keyData.transactionCount ?? 0}'),
          if (keyData.spendingToken != null && keyData.spendingLimit != null)
            _row(
              context,
              S.of(context).g_key_aa_spending_limit,
              '${_formatBigInt(keyData.spendingLimit!, 18)} ${keyData.spendingToken}',
            ),
          SizedBox(height: ScreenUtil().setWidth(24)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w500,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _permLabel(BuildContext context, SessionKeyPermission p) {
    switch (p) {
      case SessionKeyPermission.transfer:
        return S.of(context).g_key_aa_session_preset_transfer;
      case SessionKeyPermission.approve:
        return S.of(context).g_key_aa_approve;
      case SessionKeyPermission.contractCall:
        return S.of(context).g_key_aa_session_preset_contract;
      case SessionKeyPermission.full:
        return S.of(context).g_key_aa_session_preset_full;
    }
  }

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _formatBigInt(BigInt value, int decimals) {
    if (value == BigInt.zero) return '0';
    final pow = BigInt.from(10).pow(decimals);
    final whole = value ~/ pow;
    final frac = (value % pow).toString().padLeft(decimals, '0');
    final trimmed = frac.replaceAll(RegExp(r'0+$'), '');
    return trimmed.isEmpty ? whole.toString() : '$whole.$trimmed';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Create session key sheet — user-friendly wizard
// ════════════════════════════════════════════════════════════════════════════

/// Bottom sheet wizard for creating a new [SessionKeyData].
///
/// ## Permission Presets (solves "权限边界难懂" UX problem)
///
/// Instead of exposing raw permission flags, the wizard offers three
/// clearly-described templates:
///
/// 1. **限量发送** (transfer) — LOW risk
///    - Can: send tokens within the spending limit you set
///    - Cannot: approve tokens to any address, call arbitrary contracts
///
/// 2. **合约操作** (contractCall) — MEDIUM risk
///    - Can: interact with the DApp's contracts, approve its tokens
///    - Cannot: transfer ETH/tokens to unknown addresses
///
/// 3. **完整代理** (full) — HIGH risk
///    - Can: execute any transaction on your behalf
///    - Must confirm an extra "I understand the risk" disclosure
///
/// Each card shows the risk level and plain-language bullets, making the
/// permission model understandable without blockchain expertise.
class CreateSessionKeySheet extends StatefulWidget {
  final SmartAccount account;
  final SessionKeyRepository repository;
  final void Function(SessionKeyData) onCreated;

  const CreateSessionKeySheet({
    super.key,
    required this.account,
    required this.repository,
    required this.onCreated,
  });

  @override
  State<CreateSessionKeySheet> createState() =>
      CreateSessionKeySheetState();
}

class CreateSessionKeySheetState extends State<CreateSessionKeySheet> {
  // ── Step 1: preset ────────────────────────────────────────────────────────
  SessionKeyPermission _preset = SessionKeyPermission.transfer;

  // ── Step 2: DApp label ────────────────────────────────────────────────────
  final TextEditingController _labelCtrl = TextEditingController();
  final FocusNode _labelFocus = FocusNode();

  // ── Step 3: expiry ────────────────────────────────────────────────────────
  Duration _expiry = const Duration(days: 1);

  // ── Step 4: spending limit (transfer preset only) ─────────────────────────
  final TextEditingController _amountCtrl = TextEditingController();
  String _amountToken = 'ETH';
  bool _noLimit = true;

  // ── Step 5: risk confirmation ─────────────────────────────────────────────
  bool _riskConfirmed = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _labelFocus.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.96,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(24)),
          ),
        ),
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
              child: Center(
                child: Container(
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setWidth(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // ── Title ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
                vertical: ScreenUtil().setWidth(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).g_key_aa_create_session,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(24),
                ),
                children: [
                  _buildSectionHeader(
                      '1. ${S.of(context).g_key_aa_session_select_preset}'),
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  _buildPresetCards(),
                  SizedBox(height: ScreenUtil().setWidth(24)),
                  _buildSectionHeader(
                      '2. ${S.of(context).g_key_aa_session_dapp_label}'),
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  _buildLabelField(),
                  SizedBox(height: ScreenUtil().setWidth(24)),
                  _buildSectionHeader(
                      '3. ${S.of(context).g_key_aa_session_expiry}'),
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  _buildExpiryChips(),
                  if (_preset == SessionKeyPermission.transfer) ...[
                    SizedBox(height: ScreenUtil().setWidth(24)),
                    _buildSectionHeader(
                        '4. ${S.of(context).g_key_aa_session_amount_limit}'),
                    SizedBox(height: ScreenUtil().setWidth(12)),
                    _buildAmountLimit(),
                  ],
                  SizedBox(height: ScreenUtil().setWidth(24)),
                  _buildRiskSummary(),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  _buildConfirmCheckbox(),
                  SizedBox(height: ScreenUtil().setWidth(24)),
                ],
              ),
            ),
            // ── Create button ────────────────────────────────────────────
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(26),
        fontWeight: FontWeight.w700,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainTextColor.name,
        ),
      ),
    );
  }

  // ── Step 1: Preset cards ──────────────────────────────────────────────────

  Widget _buildPresetCards() {
    return Column(
      children: [
        _buildPresetCard(
          preset: SessionKeyPermission.transfer,
          riskLabel: S.of(context).g_key_aa_session_risk_low,
          riskColor: Colors.green,
          can: [S.of(context).g_key_aa_session_transfer_can],
          cannot: [S.of(context).g_key_aa_session_preset_contract],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        _buildPresetCard(
          preset: SessionKeyPermission.contractCall,
          riskLabel: S.of(context).g_key_aa_session_risk_medium,
          riskColor: Colors.orange,
          can: [S.of(context).g_key_aa_session_contract_can],
          cannot: [S.of(context).g_key_aa_session_transfer_can],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        _buildPresetCard(
          preset: SessionKeyPermission.full,
          riskLabel: S.of(context).g_key_aa_session_risk_high,
          riskColor: Colors.red,
          can: [S.of(context).g_key_aa_session_full_warning],
          cannot: const [],
          isHighRisk: true,
        ),
      ],
    );
  }

  Widget _buildPresetCard({
    required SessionKeyPermission preset,
    required String riskLabel,
    required Color riskColor,
    required List<String> can,
    required List<String> cannot,
    bool isHighRisk = false,
  }) {
    final isSelected = _preset == preset;
    final color = sessionKeyPermissionColor(preset);

    return GestureDetector(
      onTap: () => setState(() {
        _preset = preset;
        _riskConfirmed = false; // reset consent on preset change
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(18)
              : AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setWidth(40),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(10)),
                  ),
                  child: Icon(
                    sessionKeyPermissionIcon(preset),
                    size: ScreenUtil().setWidth(22),
                    color: color,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: _presetTitle(context, preset),
                ),
                // Risk badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(8),
                    vertical: ScreenUtil().setWidth(3),
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withAlpha(20),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(18),
                      fontWeight: FontWeight.w600,
                      color: riskColor,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
                if (isSelected)
                  Icon(Icons.check_circle,
                      size: ScreenUtil().setWidth(22), color: color),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            // ── Bullets ───────────────────────────────────────────────
            ...can.map((c) => _bullet(
                  c,
                  Icons.check_circle_outline,
                  Colors.green,
                )),
            ...cannot.map((c) => _bullet(
                  c,
                  Icons.remove_circle_outline,
                  Colors.red,
                )),
            if (isHighRisk) ...[
              SizedBox(height: ScreenUtil().setWidth(8)),
              Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(15),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        size: ScreenUtil().setWidth(18),
                        color: Colors.red),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Expanded(
                      child: Text(
                        S.of(context).g_key_aa_session_risk_warning,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(20),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _presetTitle(BuildContext context, SessionKeyPermission preset) {
    String title;
    switch (preset) {
      case SessionKeyPermission.transfer:
        title = S.of(context).g_key_aa_session_preset_transfer;
        break;
      case SessionKeyPermission.contractCall:
        title = S.of(context).g_key_aa_session_preset_contract;
        break;
      case SessionKeyPermission.full:
        title = S.of(context).g_key_aa_session_preset_full;
        break;
      default:
        title = S.of(context).g_key_aa_approve;
    }
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(26),
        fontWeight: FontWeight.w700,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainTextColor.name,
        ),
      ),
    );
  }

  Widget _bullet(String text, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: ScreenUtil().setWidth(16), color: color),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Label ─────────────────────────────────────────────────────────

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelCtrl,
      focusNode: _labelFocus,
      decoration: InputDecoration(
        hintText: S.of(context).g_key_aa_session_dapp_hint,
        prefixIcon: const Icon(Icons.label_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(14),
        ),
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _labelFocus.unfocus(),
    );
  }

  // ── Step 3: Expiry chips ──────────────────────────────────────────────────

  static const _expiryOptions = [
    (label: '1h',  duration: Duration(hours: 1)),
    (label: '1d',  duration: Duration(days: 1)),
    (label: '7d',  duration: Duration(days: 7)),
    (label: '30d', duration: Duration(days: 30)),
  ];

  Widget _buildExpiryChips() {
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    // Map duration → i18n label
    String expiryI18n(Duration d) {
      if (d.inHours == 1) return S.of(context).g_key_aa_session_1h;
      if (d.inDays == 1) return S.of(context).g_key_aa_session_1d;
      if (d.inDays == 7) return S.of(context).g_key_aa_session_7d;
      return S.of(context).g_key_aa_session_30d;
    }

    return Wrap(
      spacing: ScreenUtil().setWidth(10),
      children: _expiryOptions.map((opt) {
        final isSelected = _expiry == opt.duration;
        return GestureDetector(
          onTap: () => setState(() => _expiry = opt.duration),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(10),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? blueColor.withAlpha(25)
                  : Colors.grey.withAlpha(15),
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(20)),
              border: Border.all(
                color: isSelected ? blueColor : Colors.grey.withAlpha(40),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              expiryI18n(opt.duration),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? blueColor
                    : AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Step 4: Spending limit (transfer only) ────────────────────────────────

  Widget _buildAmountLimit() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountCtrl,
                enabled: !_noLimit,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: S.of(context).g_key_aa_session_amount_hint,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(14),
                  ),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            _buildTokenChips(),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        Row(
          children: [
            Checkbox(
              value: _noLimit,
              onChanged: (v) => setState(() => _noLimit = v ?? true),
            ),
            Text(
              S.of(context).g_key_aa_session_amount_limit,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenChips() {
    const tokens = ['ETH', 'USDC', 'USDT'];
    return Row(
      children: tokens.map((t) {
        final isSelected = _amountToken == t;
        return GestureDetector(
          onTap: () => setState(() => _amountToken = t),
          child: Container(
            margin: EdgeInsets.only(left: ScreenUtil().setWidth(6)),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(12),
              vertical: ScreenUtil().setWidth(8),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8B5CF6).withAlpha(25)
                  : Colors.grey.withAlpha(15),
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(10)),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.grey.withAlpha(40),
              ),
            ),
            child: Text(
              t,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Step 5: Risk summary ──────────────────────────────────────────────────

  Widget _buildRiskSummary() {
    final color = _presetRiskColor();
    final label = _labelCtrl.text.trim();
    final dappStr = label.isNotEmpty ? label : '?';
    final expiryStr = _formatExpiry();

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: ScreenUtil().setWidth(20), color: color),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                S.of(context).g_key_aa_permission,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w700,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _summaryRow(
              '🏷️', '${S.of(context).g_key_aa_session_dapp_label}: $dappStr'),
          _summaryRow('⏱️',
              '${S.of(context).g_key_aa_session_expiry}: $expiryStr'),
          _summaryRow(
            '🔑',
            '${S.of(context).g_key_aa_permission}: ${_presetLabelStr()}',
          ),
          if (_preset == SessionKeyPermission.transfer &&
              !_noLimit &&
              _amountCtrl.text.isNotEmpty)
            _summaryRow(
              '💰',
              '${S.of(context).g_key_aa_session_amount_limit}: '
              '${_amountCtrl.text} $_amountToken',
            ),
          if (_preset == SessionKeyPermission.full) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Row(
              children: [
                Icon(Icons.warning_amber,
                    size: ScreenUtil().setWidth(18), color: Colors.red),
                SizedBox(width: ScreenUtil().setWidth(6)),
                Expanded(
                  child: Text(
                    S.of(context).g_key_aa_session_risk_warning,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: ScreenUtil().setSp(20))),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _riskConfirmed,
          onChanged: (v) => setState(() => _riskConfirmed = v ?? false),
          activeColor: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => _riskConfirmed = !_riskConfirmed),
            child: Padding(
              padding:
                  EdgeInsets.only(top: ScreenUtil().setWidth(12)),
              child: Text(
                S.of(context).g_key_aa_session_confirm_risk,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    final canCreate = _riskConfirmed && !_isSaving;
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canCreate ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.withAlpha(50),
              padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(16)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    height: ScreenUtil().setWidth(24),
                    width: ScreenUtil().setWidth(24),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    S.of(context).g_key_aa_create_session,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() => _isSaving = true);

    final label = _labelCtrl.text.trim().isNotEmpty
        ? _labelCtrl.text.trim()
        : _presetLabelStr();

    BigInt? spendingLimit;
    if (_preset == SessionKeyPermission.transfer &&
        !_noLimit &&
        _amountCtrl.text.isNotEmpty) {
      final parsed = double.tryParse(_amountCtrl.text);
      if (parsed != null && parsed > 0) {
        spendingLimit = BigInt.from((parsed * 1e18).toInt());
      }
    }

    final now = DateTime.now();
    final key = SessionKeyData(
      keyAddress: _generateKeyAddress(),
      label: label,
      permission: _preset,
      status: SessionKeyStatus.active,
      createdAt: now,
      expiresAt: now.add(_expiry),
      spendingLimit: spendingLimit,
      spendingToken: spendingLimit != null ? _amountToken : null,
      transactionCount: 0,
      chainId: widget.account.chainId,
    );

    final ok = await widget.repository.saveKey(key);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? S.of(context).g_key_aa_session_create_success
              : S.of(context).g_key_aa_session_create_failed),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
      if (ok) widget.onCreated(key);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _presetRiskColor() {
    switch (_preset) {
      case SessionKeyPermission.transfer:
        return Colors.green;
      case SessionKeyPermission.contractCall:
        return Colors.orange;
      case SessionKeyPermission.full:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _presetLabelStr() {
    switch (_preset) {
      case SessionKeyPermission.transfer:
        return S.of(context).g_key_aa_session_preset_transfer;
      case SessionKeyPermission.contractCall:
        return S.of(context).g_key_aa_session_preset_contract;
      case SessionKeyPermission.full:
        return S.of(context).g_key_aa_session_preset_full;
      default:
        return S.of(context).g_key_aa_approve;
    }
  }

  String _formatExpiry() {
    if (_expiry.inHours == 1) return S.of(context).g_key_aa_session_1h;
    if (_expiry.inDays == 1) return S.of(context).g_key_aa_session_1d;
    if (_expiry.inDays == 7) return S.of(context).g_key_aa_session_7d;
    return S.of(context).g_key_aa_session_30d;
  }

  /// Generate a random-looking Ethereum address for the new session key.
  ///
  /// In production, this would be derived from the HD wallet using a
  /// dedicated derivation path (e.g. m/44'/60'/0'/1/index) or generated
  /// by the smart contract account system.
  static String _generateKeyAddress() {
    final rng = Random.secure();
    final bytes =
        List.generate(20, (_) => rng.nextInt(256));
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '0x$hex';
  }
}
