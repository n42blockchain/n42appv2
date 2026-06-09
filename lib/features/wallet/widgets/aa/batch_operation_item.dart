// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// 批量操作类型
enum BatchOperationType { transfer, approve, swap, custom }

/// 批量操作数据
class BatchOperation {
  final BatchOperationType type;
  final String targetAddress;
  final String? tokenSymbol;

  /// ERC-20 合约地址；ETH 转账时为 null
  final String? tokenAddress;
  final BigInt? amount;
  final int? decimals;
  final String? customData;
  final String? description;

  const BatchOperation({
    required this.type,
    required this.targetAddress,
    this.tokenSymbol,
    this.tokenAddress,
    this.amount,
    this.decimals,
    this.customData,
    this.description,
  });

  /// 序列化为 JSON（用于模板持久化）
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'targetAddress': targetAddress,
    if (tokenSymbol != null) 'tokenSymbol': tokenSymbol,
    if (tokenAddress != null) 'tokenAddress': tokenAddress,
    if (amount != null) 'amount': amount!.toString(),
    if (decimals != null) 'decimals': decimals,
    if (customData != null) 'customData': customData,
    if (description != null) 'description': description,
  };

  /// 从 JSON 反序列化（用于模板加载）
  factory BatchOperation.fromJson(Map<String, dynamic> json) {
    return BatchOperation(
      type: BatchOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BatchOperationType.transfer,
      ),
      targetAddress: json['targetAddress'] as String,
      tokenSymbol: json['tokenSymbol'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
      amount: json['amount'] != null
          ? BigInt.tryParse(json['amount'] as String)
          : null,
      decimals: json['decimals'] as int?,
      customData: json['customData'] as String?,
      description: json['description'] as String?,
    );
  }

  static final RegExp _evmAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// 验证操作是否可以提交
  bool isValid() {
    if (!_evmAddressRegExp.hasMatch(targetAddress)) return false;
    // transfer/approve 需要金额 > 0
    if (type == BatchOperationType.transfer ||
        type == BatchOperationType.approve) {
      if (amount == null || amount! <= BigInt.zero) return false;
    }
    // ERC-20 操作需要合约地址
    if (type == BatchOperationType.approve && tokenAddress == null)
      return false;
    // custom 操作需要 calldata
    if (type == BatchOperationType.custom &&
        (customData == null || customData!.isEmpty)) {
      return false;
    }
    return true;
  }

  static final RegExp _trailingZeros = RegExp(r'\.?0+$');

  String get formattedAmount {
    if (amount == null || decimals == null) return '0';
    final divisor = BigInt.from(10).pow(decimals!);
    final wholePart = amount! ~/ divisor;
    final fracPart = (amount! % divisor).abs();
    if (fracPart == BigInt.zero) return wholePart.toString();
    final fracStr = fracPart.toString().padLeft(decimals!, '0');
    final trimmed = '$wholePart.$fracStr'.replaceAll(_trailingZeros, '');
    return trimmed.isEmpty ? '0' : trimmed;
  }
}

/// 批量操作项
class BatchOperationItem extends StatelessWidget {
  final BatchOperation operation;
  final int index;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final bool isEditable;

  const BatchOperationItem({
    super.key,
    required this.operation,
    required this.index,
    this.onRemove,
    this.onEdit,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final opColor = _getOperationColor(context);
    final subtitleColor = AppColorTokens.of(context).textSubtitle;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: opColor.withAlpha(30)),
      ),
      child: Row(
        children: [
          // 序号
          Container(
            width: ScreenUtil().setWidth(32),
            height: ScreenUtil().setWidth(32),
            decoration: BoxDecoration(
              color: opColor.withAlpha(20),
              borderRadius: AppRadius.brSm,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTypography.captionSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: opColor,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),

          // 操作类型图标
          _buildOperationIcon(opColor),
          SizedBox(width: AppSpacing.space4),

          // 操作详情
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getOperationTitle(context),
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorTokens.of(context).textPrimary,
                      ),
                    ),
                    if (operation.amount != null &&
                        operation.tokenSymbol != null) ...[
                      SizedBox(width: AppSpacing.space2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.space2,
                          vertical: AppSpacing.space2,
                        ),
                        decoration: BoxDecoration(
                          color: opColor.withAlpha(20),
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Text(
                          '${operation.formattedAmount} ${operation.tokenSymbol}',
                          style: AppTypography.captionSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: opColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  _shortenAddress(operation.targetAddress),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    fontFamily: 'monospace',
                    color: subtitleColor,
                  ),
                ),
                if (operation.description != null) ...[
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    operation.description!,
                    style: AppTypography.captionSm.copyWith(
                      color: subtitleColor.withAlpha(150),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 操作按钮
          if (isEditable) ...[
            if (onEdit != null)
              _buildActionButton(
                onPressed: onEdit!,
                icon: Icons.edit,
                color: AppColorTokens.of(context).brand,
              ),
            if (onRemove != null)
              _buildActionButton(
                onPressed: onRemove!,
                icon: Icons.delete_outline,
                color: AppColorTokens.of(context).danger,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperationIcon(Color opColor) {
    return Container(
      width: ScreenUtil().setWidth(40),
      height: ScreenUtil().setWidth(40),
      decoration: BoxDecoration(
        color: opColor.withAlpha(20),
        borderRadius: AppRadius.brSm,
      ),
      child: Icon(
        _getOperationIcon(),
        size: ScreenUtil().setWidth(22),
        color: opColor,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: ScreenUtil().setWidth(22), color: color),
      constraints: BoxConstraints(
        maxWidth: ScreenUtil().setWidth(36),
        maxHeight: ScreenUtil().setWidth(36),
      ),
      padding: EdgeInsets.zero,
    );
  }

  IconData _getOperationIcon() => switch (operation.type) {
    BatchOperationType.transfer => Icons.send,
    BatchOperationType.approve => Icons.check_circle_outline,
    BatchOperationType.swap => Icons.swap_horiz,
    BatchOperationType.custom => Icons.code,
  };

  Color _getOperationColor(BuildContext context) {
    final c = AppColorTokens.of(context);
    return switch (operation.type) {
      BatchOperationType.transfer => c.brand,
      BatchOperationType.approve => c.success,
      BatchOperationType.swap => c.warning,
      BatchOperationType.custom => const Color(0xFF9C27B0),
    };
  }

  String _getOperationTitle(BuildContext context) => switch (operation.type) {
    BatchOperationType.transfer => S.of(context).g_key_37,
    BatchOperationType.approve => S.of(context).g_key_aa_approve,
    BatchOperationType.swap => S.of(context).g_swap_key_35,
    BatchOperationType.custom => S.of(context).g_key_aa_custom,
  };

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
