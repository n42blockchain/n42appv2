// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';

// ─── TransferList ─────────────────────────────────────────────────────────────

/// 转账列表（含空状态提示）
class BatchTransferList extends StatelessWidget {
  final BatchTransferProvider provider;
  final String tokenSymbol;
  final VoidCallback onImportCsv;

  const BatchTransferList({
    super.key,
    required this.provider,
    required this.tokenSymbol,
    required this.onImportCsv,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.items.isEmpty) {
      return _buildEmpty(context);
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(8),
      ),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return BatchTransferListItem(
          item: item,
          index: index,
          tokenSymbol: tokenSymbol,
          formatAmount: provider.formatAmount,
          onDismiss: () => provider.removeItem(index),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.list_alt,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_batch_recipients,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          TextButton.icon(
            onPressed: onImportCsv,
            icon: const Icon(Icons.upload_file),
            label: Text(S.of(context).g_key_batch_import_csv),
          ),
        ],
      ),
    );
  }
}

// ─── TransferListItem ─────────────────────────────────────────────────────────

/// 单条转账记录（可左滑删除）
class BatchTransferListItem extends StatelessWidget {
  final BatchTransferItem item;
  final int index;
  final String tokenSymbol;
  final String Function(BigInt) formatAmount;
  final VoidCallback onDismiss;

  const BatchTransferListItem({
    super.key,
    required this.item,
    required this.index,
    required this.tokenSymbol,
    required this.formatAmount,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
          border: Border.all(
            color: batchStatusColor(item.status).withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildIndexBadge(context),
            SizedBox(width: ScreenUtil().setWidth(12)),
            _buildAddressColumn(context),
            _buildAmountColumn(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexBadge(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(32),
      height: ScreenUtil().setWidth(32),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressColumn(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shortenAddress(item.toAddress),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w500,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          if (item.memo != null && item.memo!.isNotEmpty)
            Text(
              item.memo!,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${formatAmount(item.amount)} $tokenSymbol',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        BatchStatusBadge(status: item.status),
      ],
    );
  }
}

// ─── StatusBadge ─────────────────────────────────────────────────────────────

/// 转账状态徽章
class BatchStatusBadge extends StatelessWidget {
  final BatchTransferStatus status;

  const BatchStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = batchStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(6),
        vertical: ScreenUtil().setWidth(2),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(4)),
      ),
      child: Text(
        batchStatusText(context, status),
        style: TextStyle(fontSize: ScreenUtil().setSp(18), color: color),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

/// 将地址缩短为 `0x1234...5678` 格式
String shortenAddress(String address) {
  if (address.length <= 12) return address;
  return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
}

/// 根据 [BatchTransferStatus] 返回对应的显示颜色
Color batchStatusColor(BatchTransferStatus status) {
  switch (status) {
    case BatchTransferStatus.pending:
      return Colors.grey;
    case BatchTransferStatus.processing:
      return Colors.blue;
    case BatchTransferStatus.success:
      return Colors.green;
    case BatchTransferStatus.failed:
      return Colors.red;
  }
}

/// 根据 [BatchTransferStatus] 返回本地化状态文字
String batchStatusText(BuildContext context, BatchTransferStatus status) {
  switch (status) {
    case BatchTransferStatus.pending:
      return 'Pending';
    case BatchTransferStatus.processing:
      return S.of(context).g_key_batch_broadcasting;
    case BatchTransferStatus.success:
      return S.of(context).g_key_batch_done;
    case BatchTransferStatus.failed:
      return S.of(context).g_key_175;
  }
}
