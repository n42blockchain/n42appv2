// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42appv2/src/wallet/widgets/aa/gas_sponsorship_badge.dart';
import 'package:n42appv2/src/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// AA 批量交易页面
class AABatchTransactionPage extends StatefulWidget {
  final SmartAccount account;
  final String walletAddress;

  const AABatchTransactionPage({
    super.key,
    required this.account,
    required this.walletAddress,
  });

  @override
  State<AABatchTransactionPage> createState() => _AABatchTransactionPageState();
}

class _AABatchTransactionPageState extends State<AABatchTransactionPage> {
  final List<BatchOperation> _operations = [];
  final PaymasterOption _selectedPaymaster = PaymasterOption.none;
  bool _isEstimating = false;
  bool _isSending = false;

  BigInt? _totalEstimatedGas;
  BigInt? _maxFeePerGas;

  void _addOperation() {
    _showAddOperationDialog();
  }

  void _removeOperation(int index) {
    setState(() {
      _operations.removeAt(index);
    });
    _estimateGas();
  }

  void _showAddOperationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddOperationSheet(
        onAdd: (operation) {
          setState(() {
            _operations.add(operation);
          });
          _estimateGas();
        },
      ),
    );
  }

  Future<void> _estimateGas() async {
    if (_operations.isEmpty) {
      setState(() {
        _totalEstimatedGas = null;
        _maxFeePerGas = null;
      });
      return;
    }

    setState(() => _isEstimating = true);

    // 模拟 Gas 估算
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isEstimating = false;
        // 批量交易的 Gas 通常比单独执行更省
        _totalEstimatedGas = BigInt.from(100000 + 50000 * _operations.length);
        _maxFeePerGas = BigInt.from(50 * 1e9);
      });
    }
  }

  Future<void> _sendBatch() async {
    setState(() => _isSending = true);

    // 模拟发送交易
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_140),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_batch_transaction,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 说明
                  _buildInfoCard(),
                  SizedBox(height: ScreenUtil().setWidth(24)),

                  // 操作列表
                  _buildOperationsList(),
                  SizedBox(height: ScreenUtil().setWidth(16)),

                  // 添加操作按钮
                  _buildAddButton(),
                  SizedBox(height: ScreenUtil().setWidth(24)),

                  // Paymaster 选择
                  if (_operations.isNotEmpty) ...[
                    _buildPaymasterSection(),
                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // Gas 估算
                    _buildGasSection(),
                  ],
                ],
              ),
            ),
          ),
          // 发送按钮
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withAlpha(20),
            const Color(0xFFFF9800).withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.layers,
                size: ScreenUtil().setWidth(28),
                color: const Color(0xFFFF9800),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Text(
                S.of(context).g_key_aa_batch_transaction,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_key_aa_batch_description,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildFeatureRow(Icons.savings, S.of(context).g_key_aa_batch_save_gas),
          _buildFeatureRow(Icons.bolt, S.of(context).g_key_aa_batch_atomic),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ScreenUtil().setWidth(18),
            color: const Color(0xFFFF9800),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(
            text,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsList() {
    if (_operations.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(30),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: ScreenUtil().setWidth(56),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ).withAlpha(100),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              S.of(context).g_key_aa_no_operations,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(4)),
            Text(
              S.of(context).g_key_aa_add_first_operation,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ).withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${S.of(context).g_key_aa_operations} (${_operations.length})',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _operations.clear());
                _estimateGas();
              },
              child: Text(
                S.of(context).g_key_aa_clear_all,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        ...List.generate(_operations.length, (index) {
          return BatchOperationItem(
            operation: _operations[index],
            index: index,
            onRemove: () => _removeOperation(index),
          );
        }),
      ],
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton.icon(
      onPressed: _addOperation,
      icon: const Icon(Icons.add),
      label: Text(S.of(context).g_key_aa_add_operation),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
      ),
    );
  }

  Widget _buildPaymasterSection() {
    return GestureDetector(
      onTap: () {
        // 选择 Paymaster
      },
      child: PaymasterOptionCard(
        option: _selectedPaymaster,
        isSelected: true,
      ),
    );
  }

  Widget _buildGasSection() {
    final isSponsored = _selectedPaymaster.type == PaymasterType.sponsored;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: isSponsored
            ? Colors.green.withAlpha(15)
            : AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemBgColor.name,
              ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isSponsored ? Border.all(color: Colors.green.withAlpha(30)) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_aa_total_gas,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              if (_isEstimating)
                SizedBox(
                  width: ScreenUtil().setWidth(20),
                  height: ScreenUtil().setWidth(20),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_totalEstimatedGas != null)
                Text(
                  isSponsored ? S.of(context).g_key_aa_free : _formatGasCost(),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: isSponsored ? Colors.green : AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
            ],
          ),
          if (isSponsored && _totalEstimatedGas != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            GasSponsorshipBadge(
              isSponsored: true,
              savedAmount: _formatGasCost(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSend = _operations.isNotEmpty && !_isEstimating && !_isSending;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canSend ? _sendBatch : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          child: _isSending
              ? SizedBox(
                  width: ScreenUtil().setWidth(24),
                  height: ScreenUtil().setWidth(24),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  '${S.of(context).g_key_aa_execute_batch} (${_operations.length})',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatGasCost() {
    if (_totalEstimatedGas == null || _maxFeePerGas == null) return '-';
    final cost = _totalEstimatedGas! * _maxFeePerGas!;
    final ethValue = cost / BigInt.from(10).pow(18);
    return '${ethValue.toStringAsFixed(6)} ETH';
  }
}

/// 添加操作 Sheet
class _AddOperationSheet extends StatefulWidget {
  final Function(BatchOperation) onAdd;

  const _AddOperationSheet({required this.onAdd});

  @override
  State<_AddOperationSheet> createState() => _AddOperationSheetState();
}

class _AddOperationSheetState extends State<_AddOperationSheet> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final BatchOperationType _selectedType = BatchOperationType.transfer;
  final String _selectedToken = 'ETH';

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _add() {
    if (_toController.text.isEmpty || _amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final operation = BatchOperation(
      type: _selectedType,
      targetAddress: _toController.text,
      tokenSymbol: _selectedToken,
      amount: BigInt.from(amount * 1e18),
      decimals: 18,
    );

    widget.onAdd(operation);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).g_key_aa_add_operation,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          TextField(
            controller: _toController,
            decoration: InputDecoration(
              labelText: S.of(context).g_key_38,
              hintText: '0x...',
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: S.of(context).g_key_44,
              hintText: '0.0',
              suffixText: _selectedToken,
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          ElevatedButton(
            onPressed: _add,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
            ),
            child: Text(S.of(context).g_key_159),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
        ],
      ),
    );
  }
}
