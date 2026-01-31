// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// 批量操作类型
enum BatchOperationType {
  transfer,
  approve,
  swap,
  custom,
}

/// 批量操作数据
class BatchOperation {
  final BatchOperationType type;
  final String targetAddress;
  final String? tokenSymbol;
  final BigInt? amount;
  final int? decimals;
  final String? customData;
  final String? description;

  const BatchOperation({
    required this.type,
    required this.targetAddress,
    this.tokenSymbol,
    this.amount,
    this.decimals,
    this.customData,
    this.description,
  });

  String get formattedAmount {
    if (amount == null || decimals == null) return '0';
    final value = amount! / BigInt.from(10).pow(decimals!);
    return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
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
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: _getOperationColor().withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          // 序号
          Container(
            width: ScreenUtil().setWidth(32),
            height: ScreenUtil().setWidth(32),
            decoration: BoxDecoration(
              color: _getOperationColor().withAlpha(20),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(20),
                  fontWeight: FontWeight.bold,
                  color: _getOperationColor(),
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),

          // 操作类型图标
          _buildOperationIcon(),
          SizedBox(width: ScreenUtil().setWidth(12)),

          // 操作详情
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getOperationTitle(context),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    if (operation.amount != null && operation.tokenSymbol != null) ...[
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(8),
                          vertical: ScreenUtil().setWidth(2),
                        ),
                        decoration: BoxDecoration(
                          color: _getOperationColor().withAlpha(20),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                        ),
                        child: Text(
                          '${operation.formattedAmount} ${operation.tokenSymbol}',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            fontWeight: FontWeight.w600,
                            color: _getOperationColor(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  _shortenAddress(operation.targetAddress),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    fontFamily: 'monospace',
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                if (operation.description != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    operation.description!,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ).withAlpha(150),
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
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit,
                  size: ScreenUtil().setWidth(22),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
                constraints: BoxConstraints(
                  maxWidth: ScreenUtil().setWidth(36),
                  maxHeight: ScreenUtil().setWidth(36),
                ),
                padding: EdgeInsets.zero,
              ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  size: ScreenUtil().setWidth(22),
                  color: Colors.red,
                ),
                constraints: BoxConstraints(
                  maxWidth: ScreenUtil().setWidth(36),
                  maxHeight: ScreenUtil().setWidth(36),
                ),
                padding: EdgeInsets.zero,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperationIcon() {
    return Container(
      width: ScreenUtil().setWidth(40),
      height: ScreenUtil().setWidth(40),
      decoration: BoxDecoration(
        color: _getOperationColor().withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      child: Icon(
        _getOperationIcon(),
        size: ScreenUtil().setWidth(22),
        color: _getOperationColor(),
      ),
    );
  }

  IconData _getOperationIcon() {
    switch (operation.type) {
      case BatchOperationType.transfer:
        return Icons.send;
      case BatchOperationType.approve:
        return Icons.check_circle_outline;
      case BatchOperationType.swap:
        return Icons.swap_horiz;
      case BatchOperationType.custom:
        return Icons.code;
    }
  }

  Color _getOperationColor() {
    switch (operation.type) {
      case BatchOperationType.transfer:
        return const Color(0xFF5E97F6);
      case BatchOperationType.approve:
        return const Color(0xFF66BB6A);
      case BatchOperationType.swap:
        return const Color(0xFFFF9800);
      case BatchOperationType.custom:
        return const Color(0xFF9C27B0);
    }
  }

  String _getOperationTitle(BuildContext context) {
    switch (operation.type) {
      case BatchOperationType.transfer:
        return S.of(context).g_key_37;
      case BatchOperationType.approve:
        return S.of(context).g_key_aa_approve;
      case BatchOperationType.swap:
        return S.of(context).g_swap_key_35;
      case BatchOperationType.custom:
        return S.of(context).g_key_aa_custom;
    }
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
