// Copyright 2021-2026 N42 Inc. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

import 'session_key_models.dart';

/// Displays the three permission preset cards for [CreateSessionKeySheet].
///
/// Each card shows the preset's icon, title, risk badge and capability bullets.
/// Tapping a card calls [onChanged] and resets the risk confirmation state.
class SessionKeyPresetCards extends StatelessWidget {
  final SessionKeyPermission selected;
  final void Function(SessionKeyPermission) onChanged;

  const SessionKeyPresetCards({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static ({String label, Color riskColor}) _presetInfo(
      BuildContext context, SessionKeyPermission preset) =>
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

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: ScreenUtil().setWidth(12));
    final s = S.of(context);

    return Column(
      children: [
        _PresetCard(
          preset: SessionKeyPermission.transfer,
          selected: selected,
          onChanged: onChanged,
          riskLabel: s.g_key_aa_session_risk_low,
          can: [s.g_key_aa_session_transfer_can],
          cannot: [s.g_key_aa_session_preset_contract],
          presetInfo: _presetInfo(context, SessionKeyPermission.transfer),
        ),
        gap,
        _PresetCard(
          preset: SessionKeyPermission.contractCall,
          selected: selected,
          onChanged: onChanged,
          riskLabel: s.g_key_aa_session_risk_medium,
          can: [s.g_key_aa_session_contract_can],
          cannot: [s.g_key_aa_session_transfer_can],
          presetInfo: _presetInfo(context, SessionKeyPermission.contractCall),
        ),
        gap,
        _PresetCard(
          preset: SessionKeyPermission.full,
          selected: selected,
          onChanged: onChanged,
          riskLabel: s.g_key_aa_session_risk_high,
          can: [s.g_key_aa_session_full_warning],
          cannot: const [],
          isHighRisk: true,
          presetInfo: _presetInfo(context, SessionKeyPermission.full),
        ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  final SessionKeyPermission preset;
  final SessionKeyPermission selected;
  final void Function(SessionKeyPermission) onChanged;
  final String riskLabel;
  final List<String> can;
  final List<String> cannot;
  final bool isHighRisk;
  final ({String label, Color riskColor}) presetInfo;

  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onChanged,
    required this.riskLabel,
    required this.can,
    required this.cannot,
    required this.presetInfo,
    this.isHighRisk = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == preset;
    final cardColor = sessionKeyPermissionColor(preset);

    return GestureDetector(
      onTap: () => onChanged(preset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: isSelected
              ? cardColor.withAlpha(18)
              : AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isSelected ? cardColor : Colors.grey.withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, cardColor, isSelected),
            SizedBox(height: ScreenUtil().setWidth(12)),
            ...can.map((c) => _bullet(context, c, Icons.check_circle_outline, Colors.green)),
            ...cannot.map((c) => _bullet(context, c, Icons.remove_circle_outline, Colors.red)),
            if (isHighRisk) _buildHighRiskWarning(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color cardColor, bool isSelected) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(40),
          height: ScreenUtil().setWidth(40),
          decoration: BoxDecoration(
            color: cardColor.withAlpha(25),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
          ),
          child: Icon(
            sessionKeyPermissionIcon(preset),
            size: ScreenUtil().setWidth(22),
            color: cardColor,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: Text(
            presetInfo.label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w700,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(8),
            vertical: ScreenUtil().setWidth(3),
          ),
          decoration: BoxDecoration(
            color: presetInfo.riskColor.withAlpha(20),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Text(
            riskLabel,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              fontWeight: FontWeight.w600,
              color: presetInfo.riskColor,
            ),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(8)),
        if (isSelected)
          Icon(Icons.check_circle,
              size: ScreenUtil().setWidth(22), color: cardColor),
      ],
    );
  }

  Widget _buildHighRiskWarning(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(15),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber,
                size: ScreenUtil().setWidth(18), color: Colors.red),
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
    );
  }

  Widget _bullet(
      BuildContext context, String text, IconData icon, Color color) {
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
}
