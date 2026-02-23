// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

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
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: isSelected
              ? _getOptionColor().withAlpha(20)
              : AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isSelected
                ? _getOptionColor()
                : isDisabled
                    ? Colors.grey.withAlpha(30)
                    : AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ).withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Row(
            children: [
              // 图标
              _buildIcon(context),
              SizedBox(width: ScreenUtil().setWidth(14)),

              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getTitle(context),
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontWeight: FontWeight.w600,
                            color: isDisabled
                                ? Colors.grey
                                : AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.mainTextColor.name,
                                  ),
                          ),
                        ),
                        if (option.type == PaymasterType.sponsored) ...[
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8),
                              vertical: ScreenUtil().setWidth(2),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(30),
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                            ),
                            child: Text(
                              S.of(context).g_key_aa_free,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      isDisabled && option.unavailableReason != null
                          ? option.unavailableReason!
                          : _getSubtitle(context),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: isDisabled
                            ? Colors.grey
                            : AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name,
                              ),
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
                  color: _getOptionColor(),
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
        color = AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        );
        break;
      case PaymasterType.sponsored:
        icon = Icons.card_giftcard;
        color = Colors.green;
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
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Icon(
        icon,
        size: ScreenUtil().setWidth(28),
        color: color,
      ),
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

  Color _getOptionColor() {
    switch (option.type) {
      case PaymasterType.none:
        return const Color(0xFF5E97F6);
      case PaymasterType.sponsored:
        return Colors.green;
      case PaymasterType.erc20:
        return Colors.purple;
    }
  }
}
