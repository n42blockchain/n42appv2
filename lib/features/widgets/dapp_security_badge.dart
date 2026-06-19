// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/generated/l10n.dart';

// ─── Icon helper ─────────────────────────────────────────────────────────

IconData _levelIcon(DAppSecurityLevel level) {
  switch (level) {
    case DAppSecurityLevel.verified:
      return Icons.verified_rounded;
    case DAppSecurityLevel.safe:
      return Icons.lock_rounded;
    case DAppSecurityLevel.caution:
      return Icons.warning_amber_rounded;
    case DAppSecurityLevel.blocked:
      return Icons.gpp_bad_rounded;
  }
}

String _levelLabel(BuildContext context, DAppSecurityLevel level) {
  final s = S.of(context);
  switch (level) {
    case DAppSecurityLevel.verified:
      return s.g_dapp_security_verified;
    case DAppSecurityLevel.safe:
      return s.g_dapp_security_safe;
    case DAppSecurityLevel.caution:
      return s.g_dapp_security_caution;
    case DAppSecurityLevel.blocked:
      return s.g_dapp_security_blocked;
  }
}

// ─── Compact icon (URL bar) ───────────────────────────────────────────────

/// Small icon shown inside the browser URL bar left slot.
/// Falls back to a plain search icon when [info] is null.
class DAppSecurityIcon extends StatelessWidget {
  final DAppSecurityInfo? info;
  final double size;

  const DAppSecurityIcon({super.key, this.info, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (info == null) {
      return Icon(
        Icons.search,
        color: AppColorTokens.of(context).brand,
        size: size.sp,
      );
    }
    return Icon(
      _levelIcon(info!.level),
      color: Color(info!.level.colorValue),
      size: size.sp,
    );
  }
}

// ─── Full badge (WalletConnect connection screen) ─────────────────────────

/// Horizontal pill badge with icon + label (+ optional reason).
/// Designed for the WalletConnect DApp metadata section.
class DAppSecurityBadge extends StatelessWidget {
  final DAppSecurityInfo info;

  /// When true, shows the [DAppSecurityInfo.reason] as subtitle text.
  final bool showReason;

  const DAppSecurityBadge({
    super.key,
    required this.info,
    this.showReason = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(info.level.colorValue);
    final bgColor = color.withAlpha(25);
    final label = _levelLabel(context, info.level);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_levelIcon(info.level), color: color, size: 24.sp),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (showReason && info.reason != null)
                Text(
                  info.reason!,
                  style: AppTypography.captionSm.copyWith(
                    fontWeight: FontWeight.w400,
                    color: color.withAlpha(200),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Method history chips (Session list) ─────────────────────────────────

/// A row of compact chips showing which methods a DApp has previously used.
class DAppMethodChips extends StatelessWidget {
  final List<String> methods;

  const DAppMethodChips({super.key, required this.methods});

  @override
  Widget build(BuildContext context) {
    if (methods.isEmpty) return const SizedBox.shrink();
    final subColor = AppColorTokens.of(context).textPrimary.withAlpha(153);

    // Show at most 4 chips to avoid overflow
    final shown = methods.length > 4
        ? methods.sublist(methods.length - 4)
        : methods;

    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: shown.map((m) {
        final short = _shortName(m);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: subColor.withAlpha(20),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            short,
            style: AppTypography.captionSm.copyWith(
              color: subColor,
              fontFamily: 'monospace',
            ),
          ),
        );
      }).toList(),
    );
  }

  static String _shortName(String method) {
    // e.g. "eth_sendTransaction" → "sendTx"
    const map = {
      'eth_sendTransaction': 'sendTx',
      'eth_signTransaction': 'signTx',
      'personal_sign': 'sign',
      'eth_sign': 'sign',
      'eth_signTypedData': 'signTyped',
      'eth_signTypedData_v3': 'signTyped',
      'eth_signTypedData_v4': 'signTyped',
      'wallet_switchEthereumChain': 'switchChain',
      'wallet_addEthereumChain': 'addChain',
      'eth_requestAccounts': 'connect',
      'tron_signMessage': 'tronSign',
      'tron_signTransaction': 'tronTx',
    };
    return map[method] ?? method.replaceFirst(RegExp(r'^(eth_|wallet_)'), '');
  }
}
