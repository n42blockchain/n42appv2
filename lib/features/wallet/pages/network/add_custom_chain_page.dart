// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/network/custom_chain_service.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// Page to add a custom EVM chain.
///
/// Supports two modes:
/// 1. Manual input: RPC URL + Chain ID + Symbol + Explorer
/// 2. Chain ID lookup: enter Chain ID → auto-fill from chainlist.org
class AddCustomChainPage extends StatefulWidget {
  const AddCustomChainPage({super.key});

  @override
  State<AddCustomChainPage> createState() => _AddCustomChainPageState();
}

class _AddCustomChainPageState extends State<AddCustomChainPage> {
  final _formKey = GlobalKey<FormState>();
  final _chainIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _rpcController = TextEditingController();
  final _symbolController = TextEditingController();
  final _explorerController = TextEditingController();

  bool _loading = false;
  bool _lookingUp = false;
  String? _error;
  String? _rpcStatus; // 'valid', 'invalid', null

  @override
  void dispose() {
    _chainIdController.dispose();
    _nameController.dispose();
    _rpcController.dispose();
    _symbolController.dispose();
    _explorerController.dispose();
    super.dispose();
  }

  /// Look up chain metadata from chainlist.org.
  Future<void> _lookupChain() async {
    final chainId = int.tryParse(_chainIdController.text.trim());
    if (chainId == null) return;

    setState(() => _lookingUp = true);

    final info = await CustomChainService.lookupChain(chainId);
    if (info != null && mounted) {
      _nameController.text = info.name;
      _symbolController.text = info.symbol;
      if (info.rpcUrls.isNotEmpty) {
        _rpcController.text = info.rpcUrls.first;
      }
      if (info.explorerUrl != null) {
        _explorerController.text = info.explorerUrl!;
      }
    }

    if (mounted) setState(() => _lookingUp = false);
  }

  /// Validate the RPC endpoint.
  Future<void> _validateRpc() async {
    final chainId = int.tryParse(_chainIdController.text.trim());
    final rpcUrl = _rpcController.text.trim();
    if (chainId == null || rpcUrl.isEmpty) return;

    setState(() => _rpcStatus = null);

    final valid = await CustomChainService.validateRpc(rpcUrl, chainId);
    if (mounted) {
      setState(() => _rpcStatus = valid ? 'valid' : 'invalid');
    }
  }

  /// Submit and add the custom chain.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final chainId = int.tryParse(_chainIdController.text.trim());
    if (chainId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final chain = CustomChain(
        chainId: chainId,
        name: _nameController.text.trim(),
        rpcUrl: _rpcController.text.trim(),
        symbol: _symbolController.text.trim(),
        explorerUrl: _explorerController.text.trim().isNotEmpty
            ? _explorerController.text.trim()
            : null,
      );

      await CustomChainService.addChain(chain);

      if (mounted) {
        Navigator.pop(context, chain);
      }
    } on CustomChainException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Custom Network',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(34),
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
        backgroundColor: AppColorTokens.of(context).bgBase,
        elevation: 0,
      ),
      backgroundColor: AppColorTokens.of(context).bgBase,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chain ID + lookup
              _buildLabel('Chain ID'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _chainIdController,
                      hint: 'e.g. 42220',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Must be a number';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.space4),
                  SizedBox(
                    height: ScreenUtil().setWidth(88),
                    child: ElevatedButton(
                      onPressed: _lookingUp ? null : _lookupChain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorTokens.of(context).brand,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.brMd,
                        ),
                      ),
                      child: _lookingUp
                          ? SizedBox(
                              width: ScreenUtil().setWidth(32),
                              height: ScreenUtil().setWidth(32),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Lookup',
                              style: AppTypography.bodySm.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.space4),

              // Network Name
              _buildLabel('Network Name'),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Celo Mainnet',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),

              SizedBox(height: AppSpacing.space4),

              // RPC URL + validate
              _buildLabel('RPC URL'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _rpcController,
                      hint: 'https://...',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!v.startsWith('https://')) return 'Must use HTTPS';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.space4),
                  SizedBox(
                    height: ScreenUtil().setWidth(88),
                    child: ElevatedButton(
                      onPressed: _validateRpc,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rpcStatus == 'valid'
                            ? Colors.green
                            : _rpcStatus == 'invalid'
                            ? Colors.red
                            : AppColorTokens.of(context).bgSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.brMd,
                        ),
                      ),
                      child: Icon(
                        _rpcStatus == 'valid'
                            ? Icons.check
                            : _rpcStatus == 'invalid'
                            ? Icons.close
                            : Icons.wifi,
                        color: _rpcStatus != null ? Colors.white : null,
                        size: ScreenUtil().setWidth(36),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.space4),

              // Currency Symbol
              _buildLabel('Currency Symbol'),
              _buildTextField(
                controller: _symbolController,
                hint: 'e.g. CELO',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),

              SizedBox(height: AppSpacing.space4),

              // Block Explorer (optional)
              _buildLabel('Block Explorer URL (optional)'),
              _buildTextField(
                controller: _explorerController,
                hint: 'https://explorer.celo.org',
              ),

              SizedBox(height: AppSpacing.space4),

              // Error
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: AppRadius.brSm,
                  ),
                  child: Text(
                    _error!,
                    style: AppTypography.caption.copyWith(color: Colors.red),
                  ),
                ),

              SizedBox(height: AppSpacing.space8),

              // Submit
              SizedBox(
                width: double.infinity,
                height: ScreenUtil().setWidth(88),
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorTokens.of(context).brand,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Add Network',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
      child: Text(
        text,
        style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColorTokens.of(context).textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.body.copyWith(
        color: AppColorTokens.of(context).textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColorTokens.of(context).textSubtitle),
        filled: true,
        fillColor: AppColorTokens.of(context).bgSurface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemBorderColor.name,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemBorderColor.name,
            ),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
      ),
    );
  }
}
