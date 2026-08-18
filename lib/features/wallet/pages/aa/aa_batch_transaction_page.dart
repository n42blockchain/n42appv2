// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/aa/builder/calldata_builder.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/provider/batch_template_provider.dart';
import 'package:n42_wallet/features/wallet/api/sender/aa_transfer_handler.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_add_operation_sheet.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_paymaster_sheet.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_templates_sheet.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_transaction_body.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
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
      return _operations.map(_operationToCall).toList();
    } catch (e) {
      return null;
    }
  }

  static ExecuteCall _operationToCall(BatchOperation op) {
    final amount = op.amount ?? BigInt.zero;
    return switch (op.type) {
      BatchOperationType.transfer when op.tokenAddress?.isNotEmpty == true =>
        ExecuteCall.erc20Transfer(
          token: op.tokenAddress!,
          to: op.targetAddress,
          amount: amount,
        ),
      BatchOperationType.transfer => ExecuteCall.ethTransfer(
        op.targetAddress,
        amount,
      ),
      BatchOperationType.approve => ExecuteCall.erc20Approve(
        token: op.tokenAddress ?? op.targetAddress,
        spender: op.targetAddress,
        amount: amount,
      ),
      BatchOperationType.swap ||
      BatchOperationType.custom => ExecuteCall.contractCall(
        contract: op.targetAddress,
        data: _parseCalldata(op.customData),
        value: op.amount,
      ),
    };
  }

  static Uint8List _parseCalldata(String? data) {
    if (data == null || !data.startsWith('0x')) return Uint8List(0);
    final hex = data.substring(2);
    if (hex.isEmpty || hex.length.isOdd) return Uint8List(0);
    return hexToBytes(hex);
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

  // ── Shared helper ──────────────────────────────────────────────────────────

  /// 校验操作列表并构建 ExecuteCall，返回 null 表示失败（已通过 [onError] 报告）。
  List<ExecuteCall>? _validateAndBuildCalls({
    required void Function(String) onError,
  }) {
    final validationError = _validateOperations();
    if (validationError != null) {
      onError(validationError);
      return null;
    }
    final calls = _buildExecuteCalls();
    if (calls == null || calls.isEmpty) {
      onError('Failed to build operations');
      return null;
    }
    return calls;
  }

  AATransferParams _buildTransferParams(List<ExecuteCall> calls) {
    return AATransferParams(
      chainSymbol: _chainSymbol,
      fromAddress: widget.walletAddress,
      toAddress: widget.account.address,
      value: 0,
      smartAccount: widget.account,
      batchCalls: calls,
    );
  }

  void _clearGasEstimation() {
    _estimatedTotalGas = null;
    _estimatedMaxFeePerGas = null;
    _estimateError = null;
  }

  // ── Gas Estimation ─────────────────────────────────────────────────────────

  Future<void> _estimateGas() async {
    if (_operations.isEmpty) {
      setState(_clearGasEstimation);
      return;
    }

    final calls = _validateAndBuildCalls(
      onError: (msg) => setState(() => _estimateError = msg),
    );
    if (calls == null) return;

    setState(() {
      _isEstimating = true;
      _estimateError = null;
    });

    try {
      final estimation = await _handler.estimateGas(
        _buildTransferParams(calls),
      );
      if (!mounted) return;

      final hasError = estimation.errorMessage?.isNotEmpty == true;
      setState(() {
        _isEstimating = false;
        _estimateError = hasError ? estimation.errorMessage : null;
        _estimatedTotalGas = hasError ? null : estimation.gasLimit;
        _estimatedMaxFeePerGas = hasError ? null : estimation.gasPrice;
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
    final calls = _validateAndBuildCalls(onError: _showErrorSnackBar);
    if (calls == null) return;

    // Sign+broadcast of the batch UserOperation must pass identity
    // verification, mirroring the single-transfer path
    // (aa_send_page_logic._sendTransaction). This page shares the same real
    // signing channel (AATransferHandler.transfer), so without this gate a
    // batch could be signed and broadcast on an unlocked device with no wallet
    // password / biometric.
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const WalletSecurityVerification()),
    );
    if (!mounted || verified != true) return;

    setState(() => _isSending = true);

    try {
      final result = await _handler.transfer(_buildTransferParams(calls));
      if (!mounted) return;

      if (!result.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_aa_batch_success),
            backgroundColor: AppColorTokens.of(context).success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final errorMsg =
            result.data?.toString() ?? S.of(context).g_key_aa_batch_failed;
        setState(() => _isSending = false);
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColorTokens.of(context).danger,
      ),
    );
  }

  // ── Operations ─────────────────────────────────────────────────────────────

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
    });
  }

  // ── Template ───────────────────────────────────────────────────────────────

  void _showTemplatesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BatchTemplatesSheet(
        provider: _templateProvider,
        onLoad: (template) {
          if (!mounted) return;
          setState(() {
            _operations
              ..clear()
              ..addAll(template.operations);
            _estimateError = null;
          });
          _estimateGas();
        },
      ),
    );
  }

  Future<void> _saveTemplate() async {
    final nameController = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(S.of(ctx).g_key_aa_batch_save_template),
          content: SingleChildScrollView(
            child: TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: S.of(ctx).g_key_aa_batch_template_name,
                hintText: S.of(ctx).g_key_aa_batch_template_name_hint,
                border: const OutlineInputBorder(),
              ),
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
              backgroundColor: AppColorTokens.of(context).success,
            ),
          );
        }
      }
    } finally {
      nameController.dispose();
    }
  }

  // ── Paymaster Selection ────────────────────────────────────────────────────

  void _showPaymasterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymasterSelectionSheet(
        selected: _selectedPaymaster,
        onSelect: (option) {
          if (!mounted) return;
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
      builder: (context) => AddOperationSheet(
        onAdd: (operation) {
          if (!mounted) return;
          setState(() => _operations.add(operation));
          _estimateGas();
        },
      ),
    );
  }

  // ── Gas Cost Formatter ─────────────────────────────────────────────────────

  String _formatGasCost() {
    if (_estimatedTotalGas == null || _estimatedMaxFeePerGas == null) {
      return '-';
    }
    final cost = _estimatedTotalGas! * _estimatedMaxFeePerGas!;
    // cost in wei → ETH
    final ethValueStr = (cost / BigInt.from(10).pow(18)).toStringAsFixed(6);
    return '$ethValueStr ETH';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AABatchTransactionBody(
      operations: _operations,
      selectedPaymaster: _selectedPaymaster,
      isEstimating: _isEstimating,
      isSending: _isSending,
      estimatedTotalGas: _estimatedTotalGas,
      estimateError: _estimateError,
      formatGasCost: _formatGasCost,
      onShowTemplates: _showTemplatesSheet,
      onAddOperation: _showAddOperationSheet,
      onSaveTemplate: _saveTemplate,
      onShowPaymaster: _showPaymasterSheet,
      onSendBatch: _sendBatch,
      onRemoveOperation: _removeOperation,
      onClearAll: _clearAll,
    );
  }
}
