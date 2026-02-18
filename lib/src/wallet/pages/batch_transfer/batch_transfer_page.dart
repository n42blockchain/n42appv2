// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/batch_transfer_model.dart';
import 'package:n42appv2/src/wallet/provider/batch_transfer_provider.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/pages/batch_transfer/csv_import_page.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';

/// 批量转账页面
class BatchTransferPage extends ConsumerStatefulWidget {
  final String chainSymbol;
  final String rpcUrl;
  final int chainId;
  final String fromAddress;
  final String? tokenAddress;
  final String tokenSymbol;
  final int decimals;
  final BigInt balance;
  final BatchTransferProvider batchTransferProvider;

  const BatchTransferPage({
    super.key,
    required this.chainSymbol,
    required this.rpcUrl,
    required this.chainId,
    required this.fromAddress,
    this.tokenAddress,
    required this.tokenSymbol,
    required this.decimals,
    required this.balance,
    required this.batchTransferProvider,
  });

  @override
  ConsumerState<BatchTransferPage> createState() => _BatchTransferPageState();
}

class _BatchTransferPageState extends ConsumerState<BatchTransferPage> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.batchTransferProvider.initialize(
        chainSymbol: widget.chainSymbol,
        rpcUrl: widget.rpcUrl,
        chainId: widget.chainId,
        fromAddress: widget.fromAddress,
        tokenAddress: widget.tokenAddress,
        tokenSymbol: widget.tokenSymbol,
        decimals: widget.decimals,
      );
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).g_key_batch_title),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importCsv,
            tooltip: S.of(context).g_key_batch_import_csv,
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.batchTransferProvider,
        builder: (context, _) {
          final provider = widget.batchTransferProvider;
          return Column(
            children: [
              // 顶部信息栏
              _buildInfoCard(provider),

              // 添加转账项表单
              _buildAddItemForm(provider),

              // 转账列表
              Expanded(
                child: _buildTransferList(provider),
              ),

              // 底部汇总和操作
              _buildBottomBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BatchTransferProvider provider) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Token: ${widget.tokenSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  'Chain: ${widget.chainSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          if (provider.supportsMulticall)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(10),
                vertical: ScreenUtil().setWidth(4),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flash_on, color: Colors.green, size: ScreenUtil().setWidth(20)),
                  SizedBox(width: ScreenUtil().setWidth(4)),
                  Text(
                    'Multicall',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddItemForm(BatchTransferProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Recipient',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),

          // 地址输入
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: '0x...',
              labelText: 'Address',
              suffixIcon: IconButton(
                icon: Icon(Icons.paste),
                onPressed: _pasteAddress,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),

          // 金额输入
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    labelText: 'Amount',
                    suffixText: widget.tokenSymbol,
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              // 备注输入
              Expanded(
                child: TextField(
                  controller: _memoController,
                  decoration: InputDecoration(
                    hintText: 'Optional',
                    labelText: 'Memo',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),

          // 添加按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addItem,
              icon: Icon(Icons.add),
              label: Text(S.of(context).g_key_159), // Add
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferList(BatchTransferProvider provider) {
    if (provider.items.isEmpty) {
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
              onPressed: _importCsv,
              icon: Icon(Icons.upload_file),
              label: Text(S.of(context).g_key_batch_import_csv),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(8),
      ),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return _buildTransferItem(item, index, provider);
      },
    );
  }

  Widget _buildTransferItem(BatchTransferItem item, int index, BatchTransferProvider provider) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.removeItem(index),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
          border: Border.all(
            color: _getStatusColor(item.status).withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 序号
            Container(
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
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),

            // 地址和备注
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shortenAddress(item.toAddress),
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
            ),

            // 金额
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${provider.formatAmount(item.amount)} ${widget.tokenSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BatchTransferStatus status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);

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
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(18),
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(BatchTransferStatus status) {
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

  String _getStatusText(BatchTransferStatus status) {
    switch (status) {
      case BatchTransferStatus.pending:
        return 'Pending';
      case BatchTransferStatus.processing:
        return 'Processing';
      case BatchTransferStatus.success:
        return 'Success';
      case BatchTransferStatus.failed:
        return 'Failed';
    }
  }

  Widget _buildBottomBar(BatchTransferProvider provider) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 汇总信息
            if (provider.items.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recipients:',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                  Text(
                    '${provider.recipientCount}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                  Text(
                    '${provider.formatAmount(provider.totalAmount)} ${widget.tokenSymbol}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                ],
              ),
              if (provider.gasEstimate != null) ...[
                SizedBox(height: ScreenUtil().setWidth(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Gas:',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                    Text(
                      _formatGasFee(provider.gasEstimate!.totalFee),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: ScreenUtil().setWidth(16)),
            ],

            // 错误信息
            if (provider.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(12)),
            ],

            // 操作按钮
            Row(
              children: [
                if (provider.items.isNotEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.clearItems,
                      child: Text(S.of(context).g_key_batch_clear_all),
                    ),
                  ),
                if (provider.items.isNotEmpty)
                  SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: provider.items.isEmpty ? null : _proceedToConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                    ),
                    child: _buildButtonContent(provider),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContent(BatchTransferProvider provider) {
    switch (provider.state) {
      case BatchTransferState.estimatingGas:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(S.of(context).g_key_batch_estimating_gas),
          ],
        );
      case BatchTransferState.signing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(S.of(context).g_key_batch_signing),
          ],
        );
      case BatchTransferState.broadcasting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(S.of(context).g_key_batch_broadcasting),
          ],
        );
      case BatchTransferState.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: ScreenUtil().setWidth(24)),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(S.of(context).g_key_batch_done),
          ],
        );
      default:
        return Text(S.of(context).g_key_batch_continue);
    }
  }

  void _pasteAddress() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _addressController.text = data!.text!;
    }
  }

  void _addItem() {
    final address = _addressController.text.trim();
    final amountStr = _amountController.text.trim();
    final memo = _memoController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an address')),
      );
      return;
    }

    if (!address.startsWith('0x') || address.length != 42 ||
        !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid address format')),
      );
      return;
    }

    if (amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = _parseAmount(amountStr);
    if (amount <= BigInt.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    // 检查累计转账总额是否超过余额
    if (widget.batchTransferProvider.totalAmount + amount > widget.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_batch_insufficient_balance(widget.tokenSymbol)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    widget.batchTransferProvider.addItem(
      address,
      amount,
      memo: memo.isEmpty ? null : memo,
    );

    // 清除输入
    _addressController.clear();
    _amountController.clear();
    _memoController.clear();
  }

  BigInt _parseAmount(String amountStr) {
    try {
      amountStr = amountStr.replaceAll(',', '');
      if (amountStr.contains('.')) {
        final parts = amountStr.split('.');
        final intPart = parts[0];
        var decPart = parts[1];
        if (decPart.length > widget.decimals) {
          decPart = decPart.substring(0, widget.decimals);
        } else {
          decPart = decPart.padRight(widget.decimals, '0');
        }
        return BigInt.parse('$intPart$decPart');
      } else {
        return BigInt.parse(amountStr) * BigInt.from(10).pow(widget.decimals);
      }
    } catch (e) {
      return BigInt.zero;
    }
  }

  void _importCsv() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CsvImportPage(
          tokenSymbol: widget.tokenSymbol,
          decimals: widget.decimals,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      widget.batchTransferProvider.parseCsv(result);
    }
  }

  void _proceedToConfirm() async {
    final provider = widget.batchTransferProvider;

    // 先估算 Gas
    await provider.estimateGas();

    if (!mounted) return;
    if (provider.gasEstimate == null) return;

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildConfirmDialog(provider),
    );

    if (confirmed == true) {
      _executeTransfer();
    }
  }

  Widget _buildConfirmDialog(BatchTransferProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text(
        S.of(context).g_key_batch_confirm_title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.of(context).g_key_batch_recipients}: ${provider.recipientCount}',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            '${S.of(context).g_key_batch_total_amount}: ${provider.formatAmount(provider.totalAmount)} ${widget.tokenSymbol}',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Gas: ${_formatGasFee(provider.gasEstimate!.totalFee)}',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.of(context).importantNotice,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            S.of(context).g_key_79, // Cancel
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          child: Text(
            S.of(context).g_key_78, // Confirm
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _executeTransfer() async {
    final provider = widget.batchTransferProvider;
    final walletProvider = ref.read(wapBridgeProvider);

    // 在 async 操作之前捕获本地化字符串
    final l10n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 获取钱包信息
    final walletInfo = walletProvider.walletInfo;
    final mnemonic = walletInfo.mnemonic ?? '';
    final privateKey = walletInfo.privateKey ?? '';

    if (mnemonic.isEmpty && privateKey.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.g_key_210)), // 钱包信息错误
      );
      return;
    }

    // 构建交易
    final txData = await provider.buildTransaction();
    if (txData == null) {
      return;
    }

    // 设置签名状态
    provider.setSigningState();

    try {
      // 获取 derivation path
      final coinInfo = walletProvider.walletMap[widget.chainSymbol];
      if (coinInfo == null) {
        provider.setError('Chain not supported');
        return;
      }

      final pathMap = coinInfo['baseInfo']['path'] as Map<String, dynamic>;
      final pathIndex = coinInfo['pathIndex'] ?? 0;
      final path = getPathWithIndex(pathMap['legacy'] ?? "m/44'/60'/0'/0/0", pathIndex);

      // 调用 trustdart 签名
      final trustdart = Trustdart();
      final signedTx = await trustdart.signTransaction(
        widget.chainSymbol,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
      );

      if (signedTx.isEmpty) {
        provider.setError(l10n.g_key_175); // Transaction failed
        return;
      }

      // 广播交易
      final success = await provider.broadcastTransaction(signedTx);

      if (success && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.g_key_140), // 交易成功
            backgroundColor: Colors.green,
          ),
        );
        // 返回上一页
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      provider.setError(e.toString());
    }
  }

  void _showHelp() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          S.of(context).g_key_batch_help_title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).g_key_batch_send_multiple,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).g_key_batch_csv_format,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.grey).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'address,amount,memo\n0x123...,1.5,Note 1\n0xabc...,2.0,Note 2',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              SizedBox(height: 8),
              Text('• ${S.of(context).g_key_batch_swipe_remove}', style: TextStyle(color: textColor)),
              Text('• ${S.of(context).g_key_batch_memo_optional}', style: TextStyle(color: textColor)),
              Text('• ${S.of(context).g_key_batch_multicall_tip}', style: TextStyle(color: textColor)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).g_key_burn_got_it,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  String _formatGasFee(BigInt fee) {
    // 转换为 ETH (18 decimals)
    final divisor = BigInt.from(10).pow(18);
    final ethValue = fee ~/ divisor;
    final remainder = fee % divisor;
    final decimalStr = remainder.toString().padLeft(18, '0').substring(0, 6);
    return '$ethValue.$decimalStr ${widget.chainSymbol}';
  }
}
