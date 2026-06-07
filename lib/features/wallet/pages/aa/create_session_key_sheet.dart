// Copyright 2021-2026 N42 Inc. All rights reserved.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/repository/session_key_repository.dart';

import 'session_key_models.dart';
import 'session_key_preset_cards.dart';
import 'session_key_form_widgets.dart';

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
  State<CreateSessionKeySheet> createState() => CreateSessionKeySheetState();
}

class CreateSessionKeySheetState extends State<CreateSessionKeySheet> {
  SessionKeyPermission _preset = SessionKeyPermission.transfer;
  final TextEditingController _labelCtrl = TextEditingController();
  final FocusNode _labelFocus = FocusNode();
  Duration _expiry = const Duration(days: 1);
  final TextEditingController _amountCtrl = TextEditingController();
  String _amountToken = 'ETH';
  bool _noLimit = true;
  bool _riskConfirmed = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _labelFocus.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  /// Returns (label, riskColor) for the given [preset] in the current locale.
  ({String label, Color riskColor}) _presetInfo(SessionKeyPermission preset) =>
      switch (preset) {
        SessionKeyPermission.transfer => (
          label: S.of(context).g_key_aa_session_preset_transfer,
          riskColor: Colors.green,
        ),
        SessionKeyPermission.contractCall => (
          label: S.of(context).g_key_aa_session_preset_contract,
          riskColor: Colors.orange,
        ),
        SessionKeyPermission.full => (
          label: S.of(context).g_key_aa_session_preset_full,
          riskColor: Colors.red,
        ),
        SessionKeyPermission.approve => (
          label: S.of(context).g_key_aa_approve,
          riskColor: Colors.orange,
        ),
      };

  static const _expiryOptions = [
    (label: '1h', duration: Duration(hours: 1)),
    (label: '1d', duration: Duration(days: 1)),
    (label: '7d', duration: Duration(days: 7)),
    (label: '30d', duration: Duration(days: 30)),
  ];

  String _expiryI18n(Duration d) => switch (d.inHours) {
    1 => S.of(context).g_key_aa_session_1h,
    24 => S.of(context).g_key_aa_session_1d,
    168 => S.of(context).g_key_aa_session_7d,
    _ => S.of(context).g_key_aa_session_30d,
  };

  Color _themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.96,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: _themeColor(AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(24)),
          ),
        ),
        child: Column(
          children: [
            _buildDragHandle(),
            _buildTitle(context),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space6,
                ),
                children: _buildFormBody(context),
              ),
            ),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormBody(BuildContext context) {
    final info = _presetInfo(_preset);
    final trimmed = _labelCtrl.text.trim();
    final dappStr = trimmed.isNotEmpty ? trimmed : '?';
    final spendingLine =
        (_preset == SessionKeyPermission.transfer &&
            !_noLimit &&
            _amountCtrl.text.isNotEmpty)
        ? '${_amountCtrl.text} $_amountToken'
        : null;

    return [
      _buildSectionHeader('1. ${S.of(context).g_key_aa_session_select_preset}'),
      SizedBox(height: AppSpacing.space4),
      SessionKeyPresetCards(
        selected: _preset,
        onChanged: (p) => setState(() {
          _preset = p;
          _riskConfirmed = false;
        }),
      ),
      SizedBox(height: AppSpacing.space6),
      _buildSectionHeader('2. ${S.of(context).g_key_aa_session_dapp_label}'),
      SizedBox(height: AppSpacing.space4),
      _buildLabelField(),
      SizedBox(height: AppSpacing.space6),
      _buildSectionHeader('3. ${S.of(context).g_key_aa_session_expiry}'),
      SizedBox(height: AppSpacing.space4),
      _buildExpiryChips(),
      if (_preset == SessionKeyPermission.transfer) ...[
        SizedBox(height: AppSpacing.space6),
        _buildSectionHeader(
          '4. ${S.of(context).g_key_aa_session_amount_limit}',
        ),
        SizedBox(height: AppSpacing.space4),
        SessionKeyAmountLimit(
          amountCtrl: _amountCtrl,
          selectedToken: _amountToken,
          noLimit: _noLimit,
          onNoLimitChanged: (v) => setState(() => _noLimit = v ?? true),
          onTokenChanged: (t) => setState(() => _amountToken = t),
        ),
      ],
      SizedBox(height: AppSpacing.space6),
      SessionKeyRiskSummary(
        preset: _preset,
        dappLabel: dappStr,
        expiryLabel: _expiryI18n(_expiry),
        permissionLabel: info.label,
        riskColor: info.riskColor,
        spendingLimitLine: spendingLine,
      ),
      SizedBox(height: AppSpacing.space4),
      SessionKeyConfirmCheckbox(
        value: _riskConfirmed,
        onChanged: (v) => setState(() => _riskConfirmed = v ?? false),
      ),
      SizedBox(height: AppSpacing.space6),
    ];
  }

  Widget _buildDragHandle() {
    return Padding(
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
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              S.of(context).g_key_aa_create_session,
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
                color: _themeColor(AppThemeKeys.mainTextColor.name),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.bodySm.copyWith(
        fontWeight: FontWeight.w600,
        color: _themeColor(AppThemeKeys.mainTextColor.name),
      ),
    );
  }

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelCtrl,
      focusNode: _labelFocus,
      decoration: InputDecoration(
        hintText: S.of(context).g_key_aa_session_dapp_hint,
        prefixIcon: const Icon(Icons.label_outline),
        border: OutlineInputBorder(borderRadius: AppRadius.brMd),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _labelFocus.unfocus(),
    );
  }

  Widget _buildExpiryChips() {
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor.name);

    return Wrap(
      spacing: ScreenUtil().setWidth(10),
      children: _expiryOptions.map((opt) {
        final isSelected = _expiry == opt.duration;
        return GestureDetector(
          onTap: () => setState(() => _expiry = opt.duration),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? blueColor.withAlpha(25)
                  : Colors.grey.withAlpha(15),
              borderRadius: AppRadius.brMd,
              border: Border.all(
                color: isSelected ? blueColor : Colors.grey.withAlpha(40),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _expiryI18n(opt.duration),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? blueColor
                    : _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCreateButton() {
    final canCreate = _riskConfirmed && !_isSaving;
    return Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canCreate ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor(AppThemeKeys.mainBlueColor.name),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.withAlpha(50),
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
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
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final trimmedLabel = _labelCtrl.text.trim();
    final info = _presetInfo(_preset);
    final label = trimmedLabel.isNotEmpty ? trimmedLabel : info.label;

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
      if (ok) {
        widget.onCreated(key);
      }
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? S.of(context).g_key_aa_session_create_success
                : S.of(context).g_key_aa_session_create_failed,
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  static String _generateKeyAddress() {
    final rng = Random.secure();
    final bytes = List.generate(20, (_) => rng.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '0x$hex';
  }
}
