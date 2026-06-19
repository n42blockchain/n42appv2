// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// Paymaster 类型
enum PaymasterType {
  /// 不使用 Paymaster (用户自付 Gas)
  none,

  /// 免费 Paymaster (Gas 由协议赞助)
  sponsored,

  /// ERC20 Paymaster (使用 ERC20 代币支付 Gas)
  erc20,
}

/// Paymaster 选项数据
class PaymasterOption {
  final PaymasterType type;
  final String? tokenSymbol;
  final String? tokenAddress;

  /// Token decimals for ERC-20 paymaster (e.g. 6 for USDC/USDT, 18 for DAI)
  final int? decimals;
  final double? exchangeRate; // 1 ETH = X token
  /// Human-readable estimated gas cost in the token, e.g. "1.23 USDC"
  final String? estimatedCost;
  final bool isAvailable;
  final String? unavailableReason;

  const PaymasterOption({
    required this.type,
    this.tokenSymbol,
    this.tokenAddress,
    this.decimals,
    this.exchangeRate,
    this.estimatedCost,
    this.isAvailable = true,
    this.unavailableReason,
  });

  static const none = PaymasterOption(type: PaymasterType.none);
  static const sponsored = PaymasterOption(type: PaymasterType.sponsored);
}

/// Paymaster 选项卡片
class PaymasterOptionCard extends StatelessWidget {
  final PaymasterOption option;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaymasterOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !option.isAvailable;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: isSelected
              ? _getOptionColor(context).withAlpha(20)
              : AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: isSelected
                ? _getOptionColor(context)
                : isDisabled
                ? AppColorTokens.of(context).border.withAlpha(30)
                : AppColorTokens.of(context).textSubtitle.withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Row(
            children: [
              // 图标
              _buildIcon(context),
              SizedBox(width: AppSpacing.space4),

              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getTitle(context),
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDisabled
                                ? AppColorTokens.of(context).textTertiary
                                : AppColorTokens.of(context).textPrimary,
                          ),
                        ),
                        if (option.type == PaymasterType.sponsored) ...[
                          SizedBox(width: AppSpacing.space2),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.space2,
                              vertical: AppSpacing.space2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorTokens.of(
                                context,
                              ).success.withAlpha(30),
                              borderRadius: AppRadius.brSm,
                            ),
                            child: Text(
                              S.of(context).g_key_aa_free,
                              style: AppTypography.captionSm.copyWith(
                                color: AppColorTokens.of(context).success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: AppSpacing.space2),
                    Text(
                      isDisabled && option.unavailableReason != null
                          ? option.unavailableReason!
                          : _getSubtitle(context),
                      style: AppTypography.caption.copyWith(
                        color: isDisabled
                            ? AppColorTokens.of(context).textTertiary
                            : AppColorTokens.of(context).textSubtitle,
                      ),
                    ),
                  ],
                ),
              ),

              // 选中指示
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: ScreenUtil().setWidth(28),
                  color: _getOptionColor(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (option.type) {
      case PaymasterType.none:
        icon = Icons.account_balance_wallet;
        color = AppColorTokens.of(context).brand;
        break;
      case PaymasterType.sponsored:
        icon = Icons.card_giftcard;
        color = AppColorTokens.of(context).success;
        break;
      case PaymasterType.erc20:
        icon = Icons.token;
        color = Colors.purple;
        break;
    }

    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.brMd,
      ),
      child: Icon(icon, size: ScreenUtil().setWidth(28), color: color),
    );
  }

  String _getTitle(BuildContext context) {
    switch (option.type) {
      case PaymasterType.none:
        return S.of(context).g_key_aa_pay_with_eth;
      case PaymasterType.sponsored:
        return S.of(context).g_key_aa_sponsored;
      case PaymasterType.erc20:
        return '${S.of(context).g_key_aa_pay_with} ${option.tokenSymbol ?? 'Token'}';
    }
  }

  String _getSubtitle(BuildContext context) {
    switch (option.type) {
      case PaymasterType.none:
        return S.of(context).g_key_aa_pay_gas_yourself;
      case PaymasterType.sponsored:
        return S.of(context).g_key_aa_gas_sponsored;
      case PaymasterType.erc20:
        if (option.estimatedCost != null) {
          return '${S.of(context).g_key_aa_paymaster_est_cost}: ${option.estimatedCost}';
        }
        if (option.exchangeRate != null) {
          return '1 ETH ≈ ${option.exchangeRate!.toStringAsFixed(2)} ${option.tokenSymbol}';
        }
        return S.of(context).g_key_aa_pay_gas_with_token;
    }
  }

  Color _getOptionColor(BuildContext context) {
    switch (option.type) {
      case PaymasterType.none:
        return AppColorTokens.of(context).brand;
      case PaymasterType.sponsored:
        return AppColorTokens.of(context).success;
      case PaymasterType.erc20:
        return Colors.purple;
    }
  }
}
