// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/wallet/aa/builder/calldata_builder.dart';
import 'package:n42appv2/src/wallet/aa/core/aa_config.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/wallet/aa/provider/batch_template_provider.dart';
import 'package:n42appv2/src/wallet/api/transfer/handlers/aa_transfer_handler.dart';
import 'package:n42appv2/src/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42appv2/src/wallet/widgets/aa/gas_sponsorship_badge.dart';
import 'package:n42appv2/src/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:web3dart/web3dart.dart' show hexToBytes;

/// AA 批量交易页面
///
/// 使用 ERC-4337 UserOperation 将多个操作打包为一笔链上交易，
/// 比分别广播每笔交易节省 Gas 并保证原子性。
///
/// 功能：
/// - 真实 Gas 估算（通过 Bundler）
/// - 真实批量提交（通过 AATransferHandler）
/// - Paymaster 选择（自付 / 赞助 / ERC20 代付）
/// - 模板保存与加载（SQLite 持久化）
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
  PaymasterOption _selectedPaymaster = PaymasterOption.none;

  bool _isEstimating = false;
  bool _isSending = false;

  /// 真实 Gas 估算结果（单位：wei）
  BigInt? _estimatedTotalGas;
  BigInt? _estimatedMaxFeePerGas;
  String? _estimateError;

  String? _sendError;

  late final String _chainSymbol;
  late final AATransferHandler _handler;
  late final BatchTemplateProvider _templateProvider;

  @override
  void initState() {
    super.initState();
    _chainSymbol = _chainIdToSymbol(widget.account.chainId);
    _handler = AATransferHandler(_chainSymbol);
    _templateProvider = BatchTemplateProvider(AppDatabase());
    _templateProvider.loadTemplates(_chainSymbol);
  }

  @override
  void dispose() {
    _handler.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _chainIdToSymbol(int chainId) {
    final entry = AAConfig.chainIds.entries.firstWhere(
      (e) => e.value == chainId,
      orElse: () => const MapEntry('ETH', 1),
    );
    return entry.key;
  }

  /// 将 BatchOperation 列表转换为 ExecuteCall 列表（用于 CalldataBuilder）
  List<ExecuteCall>? _buildExecuteCalls() {
    try {
      return _operations.map((op) {
        switch (op.type) {
          case BatchOperationType.transfer:
            if (op.tokenAddress != null && op.tokenAddress!.isNotEmpty) {
              // ERC-20 transfer
              return ExecuteCall.erc20Transfer(
                token: op.tokenAddress!,
                to: op.targetAddress,
                amount: op.amount ?? BigInt.zero,
              );
            } else {
              // ETH transfer
              return ExecuteCall.ethTransfer(op.targetAddress, op.amount ?? BigInt.zero);
            }
          case BatchOperationType.approve:
            return ExecuteCall.erc20Approve(
              token: op.tokenAddress ?? op.targetAddress,
              spender: op.targetAddress,
              amount: op.amount ?? BigInt.zero,
            );
          case BatchOperationType.swap:
          case BatchOperationType.custom:
            Uint8List calldata = Uint8List(0);
            if (op.customData != null && op.customData!.startsWith('0x')) {
              final hex = op.customData!.substring(2);
              if (hex.isNotEmpty && hex.length.isEven) {
                calldata = hexToBytes(hex);
              }
            }
            return ExecuteCall.contractCall(
              contract: op.targetAddress,
              data: calldata,
              value: op.amount,
            );
        }
      }).toList();
    } catch (e) {
      return null;
    }
  }

  /// 验证所有操作，返回第一个错误消息，null 表示通过
  String? _validateOperations() {
    if (_operations.isEmpty) return S.current.g_key_aa_no_operations;
    for (int i = 0; i < _operations.length; i++) {
      if (!_operations[i].isValid()) {
        return 'Operation #${i + 1}: invalid address or amount';
      }
    }
    return null;
  }

  // ── Gas Estimation ─────────────────────────────────────────────────────────

  Future<void> _estimateGas() async {
    if (_operations.isEmpty) {
      setState(() {
        _estimatedTotalGas = null;
        _estimatedMaxFeePerGas = null;
        _estimateError = null;
      });
      return;
    }

    final validationError = _validateOperations();
    if (validationError != null) {
      setState(() => _estimateError = validationError);
      return;
    }

    final calls = _buildExecuteCalls();
    if (calls == null || calls.isEmpty) {
      setState(() => _estimateError = 'Failed to build operations');
      return;
    }

    setState(() {
      _isEstimating = true;
      _estimateError = null;
    });

    try {
      final params = AATransferParams(
        chainSymbol: _chainSymbol,
        fromAddress: widget.walletAddress,
        toAddress: widget.account.address,
        value: 0,
        smartAccount: widget.account,
        batchCalls: calls,
      );

      final estimation = await _handler.estimateGas(params);

      if (!mounted) return;

      if (estimation.errorMessage != null && estimation.errorMessage!.isNotEmpty) {
        setState(() {
          _isEstimating = false;
          _estimateError = estimation.errorMessage;
          _estimatedTotalGas = null;
          _estimatedMaxFeePerGas = null;
        });
        return;
      }

      setState(() {
        _isEstimating = false;
        _estimatedTotalGas = estimation.gasLimit;
        _estimatedMaxFeePerGas = estimation.gasPrice;
        _estimateError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isEstimating = false;
        _estimateError = e.toString();
        _estimatedTotalGas = null;
        _estimatedMaxFeePerGas = null;
      });
    }
  }

  // ── Send Batch ─────────────────────────────────────────────────────────────

  Future<void> _sendBatch() async {
    final validationError = _validateOperations();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    final calls = _buildExecuteCalls();
    if (calls == null || calls.isEmpty) {
      _showErrorSnackBar('Failed to build operations');
      return;
    }

    setState(() {
      _isSending = true;
      _sendError = null;
    });

    try {
      final params = AATransferParams(
        chainSymbol: _chainSymbol,
        fromAddress: widget.walletAddress,
        toAddress: widget.account.address,
        value: 0,
        smartAccount: widget.account,
        batchCalls: calls,
      );

      final result = await _handler.transfer(params);

      if (!mounted) return;

      if (!result.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_aa_batch_success),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isSending = false;
          _sendError = result.data?.toString() ?? S.of(context).g_key_aa_batch_failed;
        });
        _showErrorSnackBar(_sendError!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _sendError = e.toString();
      });
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ── Operations ─────────────────────────────────────────────────────────────

  void _addOperation() => _showAddOperationSheet();

  void _removeOperation(int index) {
    setState(() => _operations.removeAt(index));
    _estimateGas();
  }

  void _clearAll() {
    setState(() {
      _operations.clear();
      _estimatedTotalGas = null;
      _estimatedMaxFeePerGas = null;
      _estimateError = null;
      _sendError = null;
    });
  }

  // ── Template ───────────────────────────────────────────────────────────────

  void _showTemplatesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplatesSheet(
        provider: _templateProvider,
        onLoad: (template) {
          setState(() {
            _operations
              ..clear()
              ..addAll(template.operations);
            _estimateError = null;
            _sendError = null;
          });
          _estimateGas();
        },
      ),
    );
  }

  Future<void> _saveTemplate() async {
    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).g_key_aa_batch_save_template),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: S.of(ctx).g_key_aa_batch_template_name,
            hintText: S.of(ctx).g_key_aa_batch_template_name_hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).g_key_9),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(ctx).g_key_159),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      final saved = await _templateProvider.saveTemplate(
        name: nameController.text.trim(),
        chainSymbol: _chainSymbol,
        operations: List.unmodifiable(_operations),
      );
      if (mounted && saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_aa_batch_template_saved),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ── Paymaster Selection ────────────────────────────────────────────────────

  void _showPaymasterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymasterSelectionSheet(
        selected: _selectedPaymaster,
        onSelect: (option) {
          setState(() => _selectedPaymaster = option);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Add Operation Sheet ────────────────────────────────────────────────────

  void _showAddOperationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddOperationSheet(
        onAdd: (operation) {
          setState(() => _operations.add(operation));
          _estimateGas();
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_batch_transaction,
        actions: [
          // 模板加载按钮
          IconButton(
            onPressed: _showTemplatesSheet,
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: S.of(context).g_key_aa_batch_templates,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: ScreenUtil().setWidth(24)),
                  _buildOperationsList(),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  _buildAddButton(),
                  if (_operations.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setWidth(16)),
                    _buildSaveTemplateButton(),
                    SizedBox(height: ScreenUtil().setWidth(24)),
                    _buildPaymasterSection(),
                    SizedBox(height: ScreenUtil().setWidth(24)),
                    _buildGasSection(),
                    if (_estimateError != null) ...[
                      SizedBox(height: ScreenUtil().setWidth(8)),
                      _buildEstimateErrorRow(),
                    ],
                  ],
                  SizedBox(height: ScreenUtil().setWidth(24)),
                ],
              ),
            ),
          ),
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
              Icon(Icons.layers, size: ScreenUtil().setWidth(28), color: const Color(0xFFFF9800)),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Text(
                S.of(context).g_key_aa_batch_transaction,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_key_aa_batch_description,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
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
          Icon(icon, size: ScreenUtil().setWidth(18), color: const Color(0xFFFF9800)),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(
            text,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color:
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
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
                color:
                    AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
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
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            TextButton(
              onPressed: _clearAll,
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

  Widget _buildSaveTemplateButton() {
    return TextButton.icon(
      onPressed: _saveTemplate,
      icon: Icon(Icons.bookmark_add_outlined, size: ScreenUtil().setWidth(20)),
      label: Text(S.of(context).g_key_aa_batch_save_template),
      style: TextButton.styleFrom(
        foregroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildPaymasterSection() {
    return GestureDetector(
      onTap: _showPaymasterSheet,
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
            : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
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
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              if (_isEstimating)
                SizedBox(
                  width: ScreenUtil().setWidth(20),
                  height: ScreenUtil().setWidth(20),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_estimatedTotalGas != null)
                Text(
                  isSponsored ? S.of(context).g_key_aa_free : _formatGasCost(),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: isSponsored
                        ? Colors.green
                        : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                )
              else
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
            ],
          ),
          if (isSponsored && _estimatedTotalGas != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            GasSponsorshipBadge(isSponsored: true, savedAmount: _formatGasCost()),
          ],
        ],
      ),
    );
  }

  Widget _buildEstimateErrorRow() {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
        SizedBox(width: ScreenUtil().setWidth(6)),
        Expanded(
          child: Text(
            _estimateError!,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: Colors.orange,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    Text(
                      S.of(context).g_key_aa_batch_submitting,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
    if (_estimatedTotalGas == null || _estimatedMaxFeePerGas == null) return '-';
    final cost = _estimatedTotalGas! * _estimatedMaxFeePerGas!;
    // cost in wei → ETH
    final ethValueStr = (cost / BigInt.from(10).pow(18)).toStringAsFixed(6);
    return '$ethValueStr ETH';
  }
}

// ── Paymaster Selection Sheet ─────────────────────────────────────────────────

class _PaymasterSelectionSheet extends StatelessWidget {
  final PaymasterOption selected;
  final ValueChanged<PaymasterOption> onSelect;

  const _PaymasterSelectionSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      PaymasterOption.none,
      PaymasterOption.sponsored,
    ];

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(24))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paymaster',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            ...options.map((option) {
              final isSelected = option.type == selected.type;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
                  decoration: isSelected
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                          border: Border.all(color: const Color(0xFFFF9800), width: 2),
                        )
                      : null,
                  child: PaymasterOptionCard(option: option, isSelected: isSelected),
                ),
              );
            }),
            SizedBox(height: ScreenUtil().setWidth(8)),
          ],
        ),
      ),
    );
  }
}

// ── Templates Sheet ───────────────────────────────────────────────────────────

class _TemplatesSheet extends StatefulWidget {
  final BatchTemplateProvider provider;
  final ValueChanged<BatchTemplate> onLoad;

  const _TemplatesSheet({required this.provider, required this.onLoad});

  @override
  State<_TemplatesSheet> createState() => _TemplatesSheetState();
}

class _TemplatesSheetState extends State<_TemplatesSheet> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final templates = widget.provider.templates;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(24))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).g_key_aa_batch_templates,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color:
                          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(16)),
              if (templates.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(32)),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bookmarks_outlined,
                        size: ScreenUtil().setWidth(48),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ).withAlpha(80),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      Text(
                        S.of(context).g_key_aa_batch_no_templates,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _TemplateItem(
                        template: template,
                        onLoad: () {
                          widget.onLoad(template);
                          Navigator.pop(context);
                        },
                        onDelete: () async {
                          if (template.id != null) {
                            await widget.provider.deleteTemplate(template.id!);
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TemplateItem extends StatelessWidget {
  final BatchTemplate template;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  const _TemplateItem({
    required this.template,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color:
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  '${template.operations.length} operations · ${template.chainSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onLoad,
            child: Text(
              S.of(context).g_key_aa_batch_template_load,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              maxWidth: ScreenUtil().setWidth(36),
              maxHeight: ScreenUtil().setWidth(36),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Operation Sheet ───────────────────────────────────────────────────────

class _AddOperationSheet extends StatefulWidget {
  final Function(BatchOperation) onAdd;

  const _AddOperationSheet({required this.onAdd});

  @override
  State<_AddOperationSheet> createState() => _AddOperationSheetState();
}

class _AddOperationSheetState extends State<_AddOperationSheet> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _tokenAddressController = TextEditingController();
  final _calldataController = TextEditingController();

  BatchOperationType _selectedType = BatchOperationType.transfer;
  String _selectedToken = 'ETH';
  String? _toError;
  String? _amountError;

  static const _ethLikeTokens = ['ETH', 'BNB', 'MATIC', 'AVAX', 'ARB'];

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _tokenAddressController.dispose();
    _calldataController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _toError = null;
      _amountError = null;
    });

    bool valid = true;

    // 验证目标地址
    final addrRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');
    if (!addrRegex.hasMatch(_toController.text.trim())) {
      setState(() => _toError = 'Invalid address (0x...)');
      valid = false;
    }

    // 对于 transfer/approve，验证金额
    if (_selectedType == BatchOperationType.transfer ||
        _selectedType == BatchOperationType.approve) {
      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        setState(() => _amountError = 'Invalid amount');
        valid = false;
      }
    }

    return valid;
  }

  void _add() {
    if (!_validateInputs()) return;

    final to = _toController.text.trim();
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr) ?? 0;
    final decimals = 18;
    final amountWei = BigInt.from((amount * 1e18).round());

    final isErc20 = _selectedType == BatchOperationType.transfer &&
        !_ethLikeTokens.contains(_selectedToken) &&
        _tokenAddressController.text.trim().isNotEmpty;

    final operation = BatchOperation(
      type: _selectedType,
      targetAddress: to,
      tokenSymbol: _selectedType == BatchOperationType.custom ? null : _selectedToken,
      tokenAddress: (isErc20 || _selectedType == BatchOperationType.approve)
          ? _tokenAddressController.text.trim()
          : null,
      amount: _selectedType == BatchOperationType.custom ? null : amountWei,
      decimals: _selectedType == BatchOperationType.custom ? null : decimals,
      customData: _selectedType == BatchOperationType.custom
          ? _calldataController.text.trim()
          : null,
    );

    widget.onAdd(operation);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(24))),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).g_key_aa_add_operation,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color:
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(20)),

              // 操作类型选择
              _buildTypeSelector(context),
              SizedBox(height: ScreenUtil().setWidth(16)),

              // 目标地址
              TextField(
                controller: _toController,
                decoration: InputDecoration(
                  labelText: S.of(context).g_key_38,
                  hintText: '0x...',
                  border: const OutlineInputBorder(),
                  errorText: _toError,
                ),
                onChanged: (_) => setState(() => _toError = null),
              ),
              SizedBox(height: ScreenUtil().setWidth(16)),

              // Token 类型选择 & ERC20合约地址
              if (_selectedType != BatchOperationType.custom) ...[
                _buildTokenSelector(context),
                SizedBox(height: ScreenUtil().setWidth(16)),

                // ERC20合约地址（非原生代币时显示）
                if (!_ethLikeTokens.contains(_selectedToken) ||
                    _selectedType == BatchOperationType.approve) ...[
                  TextField(
                    controller: _tokenAddressController,
                    decoration: InputDecoration(
                      labelText: 'Token Contract (0x...)',
                      hintText: '0x...',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                ],

                // 金额输入
                TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: S.of(context).g_key_44,
                    hintText: '0.0',
                    suffixText: _selectedToken,
                    border: const OutlineInputBorder(),
                    errorText: _amountError,
                  ),
                  onChanged: (_) => setState(() => _amountError = null),
                ),
              ],

              // Custom calldata
              if (_selectedType == BatchOperationType.custom) ...[
                TextField(
                  controller: _calldataController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Calldata (hex)',
                    hintText: '0x...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              SizedBox(height: ScreenUtil().setWidth(24)),
              ElevatedButton(
                onPressed: _add,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
                child: Text(S.of(context).g_key_159),
              ),
              SizedBox(height: ScreenUtil().setWidth(16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color:
                AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        Wrap(
          spacing: ScreenUtil().setWidth(8),
          children: BatchOperationType.values.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(_typeName(context, type)),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedType = type),
              selectedColor: const Color(0xFFFF9800),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontSize: ScreenUtil().setSp(22),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTokenSelector(BuildContext context) {
    const tokens = ['ETH', 'USDT', 'USDC', 'DAI', 'WBTC'];
    return DropdownButtonFormField<String>(
      initialValue: _selectedToken,
      decoration: const InputDecoration(
        labelText: 'Token',
        border: OutlineInputBorder(),
      ),
      items: tokens
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedToken = v);
      },
    );
  }

  String _typeName(BuildContext context, BatchOperationType type) {
    switch (type) {
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
}
