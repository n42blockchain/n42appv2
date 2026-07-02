// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/aa/account/smart_account_factory.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'aa_account_create_form.dart';
part 'aa_account_create_helpers.dart';

/// AA 账户创建页面
///
/// Pops with a [SmartAccount] on success so the caller can persist it.
class AAAccountCreatePage extends StatefulWidget {
  /// 所有者地址 (EOA)
  final String ownerAddress;

  const AAAccountCreatePage({super.key, required this.ownerAddress});

  @override
  State<AAAccountCreatePage> createState() => _AAAccountCreatePageState();
}

class _AAAccountCreatePageState extends State<AAAccountCreatePage>
    with _AAAccountCreateHelpersMixin, _AAAccountCreateFormMixin {
  int _previewRequestId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _calculatePreviewAddress();
    });
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _finishCalculation({String? address, String? error}) {
    if (!mounted) return;
    setState(() {
      isCalculating = false;
      previewAddress = address;
      addressError = error;
    });
  }

  Future<void> _calculatePreviewAddress() async {
    final requestId = ++_previewRequestId;
    if (!mounted) return;
    setState(() {
      isCalculating = true;
      previewAddress = null;
      addressError = null;
    });
    final addressErrorMessage = S.of(context).g_key_aa_address_error;

    try {
      final config = AAConfig.getChainConfig(selectedChain);
      if (config == null) {
        _finishCalculation(error: addressErrorMessage);
        return;
      }

      final factory = SmartAccountFactory(
        ownerAddress: widget.ownerAddress,
        chainId: config.chainId,
        config: config,
      );

      final address = await factory.computeAddressForType(
        selectedType,
        salt: BigInt.zero,
      );
      if (!mounted || requestId != _previewRequestId) return;

      _finishCalculation(
        address: address,
        error: address == null ? addressErrorMessage : null,
      );
    } catch (_) {
      if (!mounted || requestId != _previewRequestId) return;
      _finishCalculation(error: addressErrorMessage);
    }
  }

  void _onChainChanged(String chain) {
    setState(() => selectedChain = chain);
    _calculatePreviewAddress();
  }

  void _onTypeChanged(SmartAccountType type) {
    setState(() => selectedType = type);
    _calculatePreviewAddress();
  }

  Future<void> _createAccount() async {
    if (previewAddress == null) return;
    var completedWithExit = false;
    setState(() => isCreating = true);

    try {
      final config = AAConfig.getChainConfig(selectedChain);
      if (config == null) throw Exception('Unsupported chain: $selectedChain');

      final factory = SmartAccountFactory(
        ownerAddress: widget.ownerAddress,
        chainId: config.chainId,
        config: config,
      );

      final account = factory.createAccount(
        type: selectedType,
        address: previewAddress,
        salt: BigInt.zero,
        label: labelController.text.trim().isEmpty
            ? null
            : labelController.text.trim(),
      );

      if (mounted) {
        _showSnackBar(
          S.of(context).g_key_aa_account_created,
          AppColorTokens.of(context).success,
        );
        completedWithExit = true;
        Navigator.pop(context, account);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString(), AppColorTokens.of(context).danger);
      }
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_aa_create_account),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabelInput(),
            SizedBox(height: AppSpacing.space6),
            _buildChainSelector(),
            SizedBox(height: AppSpacing.space6),
            _buildTypeSelector(),
            SizedBox(height: AppSpacing.space6),
            _buildPreviewSection(),
            SizedBox(height: AppSpacing.space6),
            _buildInfoSection(),
            SizedBox(height: AppSpacing.space8),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }
}
