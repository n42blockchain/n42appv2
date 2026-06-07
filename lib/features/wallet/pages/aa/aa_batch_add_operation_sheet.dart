// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

class AddOperationSheet extends StatefulWidget {
  final ValueChanged<BatchOperation> onAdd;

  const AddOperationSheet({super.key, required this.onAdd});

  @override
  State<AddOperationSheet> createState() => _AddOperationSheetState();
}

class _AddOperationSheetState extends State<AddOperationSheet> {
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

    if (!FeatureAddressUtils.isValidEvmAddress(_toController.text.trim())) {
      setState(() => _toError = 'Invalid address (0x...)');
      valid = false;
    }

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
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    const decimals = 18;
    final amountWei = ethToWeiString(amount.toString(), 18);
    final isCustom = _selectedType == BatchOperationType.custom;

    final isErc20 =
        _selectedType == BatchOperationType.transfer &&
        !_ethLikeTokens.contains(_selectedToken) &&
        _tokenAddressController.text.trim().isNotEmpty;

    final needsTokenAddress =
        isErc20 || _selectedType == BatchOperationType.approve;

    final operation = BatchOperation(
      type: _selectedType,
      targetAddress: to,
      tokenSymbol: isCustom ? null : _selectedToken,
      tokenAddress: needsTokenAddress
          ? _tokenAddressController.text.trim()
          : null,
      amount: isCustom ? null : amountWei,
      decimals: isCustom ? null : decimals,
      customData: isCustom ? _calldataController.text.trim() : null,
    );

    widget.onAdd(operation);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(24)),
          ),
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
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(20)),
              _buildTypeSelector(context),
              SizedBox(height: ScreenUtil().setWidth(16)),
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
              if (_selectedType != BatchOperationType.custom) ...[
                _buildTokenSelector(context),
                SizedBox(height: ScreenUtil().setWidth(16)),
                if (!_ethLikeTokens.contains(_selectedToken) ||
                    _selectedType == BatchOperationType.approve) ...[
                  TextField(
                    controller: _tokenAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Token Contract (0x...)',
                      hintText: '0x...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                ],
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(16),
                  ),
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
            color: AppColorTokens.of(context).textSubtitle,
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

  String _typeName(BuildContext context, BatchOperationType type) =>
      switch (type) {
        BatchOperationType.transfer => S.of(context).g_key_37,
        BatchOperationType.approve => S.of(context).g_key_aa_approve,
        BatchOperationType.swap => S.of(context).g_swap_key_35,
        BatchOperationType.custom => S.of(context).g_key_aa_custom,
      };
}
