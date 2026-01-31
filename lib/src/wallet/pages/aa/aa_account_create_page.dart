// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/aa/core/aa_config.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// AA 账户创建页面
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

class _AAAccountCreatePageState extends State<AAAccountCreatePage> {
  final TextEditingController _labelController = TextEditingController();

  SmartAccountType _selectedType = SmartAccountType.simpleAccount;
  String _selectedChain = 'ETH';
  String? _previewAddress;
  bool _isCalculating = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _calculatePreviewAddress();
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _calculatePreviewAddress() async {
    setState(() => _isCalculating = true);

    // 模拟计算 counterfactual 地址
    // 实际实现应使用 SmartAccountFactory.calculateSimpleAccountAddress
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isCalculating = false;
        // 模拟的预览地址
        _previewAddress = '0x${_generateMockAddress()}';
      });
    }
  }

  String _generateMockAddress() {
    // 生成模拟地址用于预览
    const chars = '0123456789abcdef';
    final buffer = StringBuffer();
    for (int i = 0; i < 40; i++) {
      buffer.write(chars[DateTime.now().microsecond % chars.length]);
    }
    return buffer.toString();
  }

  void _onChainChanged(String chain) {
    setState(() => _selectedChain = chain);
    _calculatePreviewAddress();
  }

  void _onTypeChanged(SmartAccountType type) {
    setState(() => _selectedType = type);
    _calculatePreviewAddress();
  }

  Future<void> _createAccount() async {
    setState(() => _isCreating = true);

    // 模拟创建账户
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isCreating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_aa_account_created),
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

            // 链选择
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

  Widget _buildLabelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_aa_account_name,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextField(
          controller: _labelController,
          decoration: InputDecoration(
            hintText: S.of(context).g_key_aa_account_name_hint,
            prefixIcon: const Icon(Icons.label_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(16),
              vertical: ScreenUtil().setWidth(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChainSelector() {
    final chains = AAConfig.supportedChains.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_17,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Wrap(
          spacing: ScreenUtil().setWidth(12),
          runSpacing: ScreenUtil().setWidth(12),
          children: chains.map((chain) {
            final isSelected = _selectedChain == chain;
            return GestureDetector(
              onTap: () => _onChainChanged(chain),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                  vertical: ScreenUtil().setWidth(12),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        )
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemBgColor.name,
                        ),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          )
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ).withAlpha(30),
                  ),
                ),
                child: Text(
                  chain,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      SmartAccountType.simpleAccount,
      SmartAccountType.safe,
      SmartAccountType.kernel,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_aa_account_type,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        ...types.map((type) => _buildTypeOption(type)),
      ],
    );
  }

  Widget _buildTypeOption(SmartAccountType type) {
    final isSelected = _selectedType == type;
    final isAvailable = type == SmartAccountType.simpleAccount;

    return GestureDetector(
      onTap: isAvailable ? () => _onTypeChanged(type) : null,
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: isSelected
              ? _getTypeColor(type).withAlpha(15)
              : AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
          border: Border.all(
            color: isSelected
                ? _getTypeColor(type)
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ).withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withAlpha(25),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  size: ScreenUtil().setWidth(24),
                  color: _getTypeColor(type),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontWeight: FontWeight.w600,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                          ),
                        ),
                        if (!isAvailable) ...[
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8),
                              vertical: ScreenUtil().setWidth(2),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(30),
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                            ),
                            child: Text(
                              S.of(context).g_key_aa_coming_soon,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      _getTypeDescription(type),
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
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: ScreenUtil().setWidth(28),
                  color: _getTypeColor(type),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ).withAlpha(15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ).withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_aa_preview_address,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          if (_isCalculating)
            Center(
              child: SizedBox(
                width: ScreenUtil().setWidth(24),
                height: ScreenUtil().setWidth(24),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_previewAddress != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _previewAddress!,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      fontFamily: 'monospace',
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _previewAddress!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).g_key_119),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.copy,
                    size: ScreenUtil().setWidth(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_aa_counterfactual_note,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
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

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: Colors.amber.withAlpha(40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: ScreenUtil().setWidth(22),
            color: Colors.amber[700],
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              S.of(context).g_key_aa_deployment_note,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.amber[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isCreating ? null : _createAccount,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isCreating
          ? SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              S.of(context).g_key_aa_create_account,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Color _getTypeColor(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return const Color(0xFF5E97F6);
      case SmartAccountType.simple7702Account:
        return const Color(0xFF9333EA);
      case SmartAccountType.safe:
        return const Color(0xFF12A87B);
      case SmartAccountType.kernel:
        return const Color(0xFF8B5CF6);
      case SmartAccountType.biconomy:
        return const Color(0xFFFF6B4A);
      case SmartAccountType.custom:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getTypeIcon(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return Icons.account_balance_wallet;
      case SmartAccountType.simple7702Account:
        return Icons.flash_on;
      case SmartAccountType.safe:
        return Icons.security;
      case SmartAccountType.kernel:
        return Icons.memory;
      case SmartAccountType.biconomy:
        return Icons.auto_awesome;
      case SmartAccountType.custom:
        return Icons.code;
    }
  }

  String _getTypeDescription(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return S.of(context).g_key_aa_simple_desc;
      case SmartAccountType.simple7702Account:
        return S.of(context).g_key_aa_eip7702_desc;
      case SmartAccountType.safe:
        return S.of(context).g_key_aa_safe_desc;
      case SmartAccountType.kernel:
        return S.of(context).g_key_aa_kernel_desc;
      case SmartAccountType.biconomy:
      case SmartAccountType.custom:
        return '';
    }
  }
}
