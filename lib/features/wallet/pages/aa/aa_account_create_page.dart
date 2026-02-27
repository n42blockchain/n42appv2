// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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

  const AAAccountCreatePage({
    super.key,
    required this.ownerAddress,
  });

  @override
  State<AAAccountCreatePage> createState() => _AAAccountCreatePageState();
}

class _AAAccountCreatePageState extends State<AAAccountCreatePage>
    with _AAAccountCreateHelpersMixin, _AAAccountCreateFormMixin {
  @override
  void initState() {
    super.initState();
    _calculatePreviewAddress();
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  // ── Address computation ────────────────────────────────────────────────────

  /// Computes the counterfactual address via [SmartAccountFactory.computeAddressForType].
  ///
  /// Uses eth_call to the appropriate factory's view function so the result is
  /// exact (no local approximation).
  Future<void> _calculatePreviewAddress() async {
    if (!mounted) return;
    setState(() {
      isCalculating = true;
      previewAddress = null;
      addressError = null;
    });

    try {
      final config = AAConfig.getChainConfig(selectedChain);
      if (config == null) {
        if (mounted) {
          setState(() {
            isCalculating = false;
            addressError = S.of(context).g_key_aa_address_error;
          });
        }
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

      if (mounted) {
        setState(() {
          isCalculating = false;
          if (address != null) {
            previewAddress = address;
          } else {
            addressError = S.of(context).g_key_aa_address_error;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isCalculating = false;
          addressError = S.of(context).g_key_aa_address_error;
        });
      }
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

  // ── Account creation ───────────────────────────────────────────────────────

  Future<void> _createAccount() async {
    if (previewAddress == null) return;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_aa_account_created),
            backgroundColor: Colors.green,
          ),
        );
        // Pop with the SmartAccount so the caller can persist it
        Navigator.pop(context, account);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_create_account,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 账户名称
            _buildLabelInput(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 链选择  (Bug 2 fix: g_key_17 → g_key_aa_select_chain)
            _buildChainSelector(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 账户类型选择
            _buildTypeSelector(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 预览地址
            _buildPreviewSection(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 说明信息
            _buildInfoSection(),
            SizedBox(height: ScreenUtil().setWidth(32)),

            // 创建按钮
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }
}
