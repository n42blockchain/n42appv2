// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/wallet/pages/aa/aa_send_page.dart';
import 'package:n42appv2/src/wallet/widgets/aa/deployment_status_indicator.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// AA 账户详情页面
class AAAccountDetailPage extends StatefulWidget {
  final SmartAccount account;
  final String walletAddress;

  const AAAccountDetailPage({
    super.key,
    required this.account,
    required this.walletAddress,
  });

  @override
  State<AAAccountDetailPage> createState() => _AAAccountDetailPageState();
}

class _AAAccountDetailPageState extends State<AAAccountDetailPage> {
  bool _isDeploying = false;

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: widget.account.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_119),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _deployAccount() async {
    setState(() => _isDeploying = true);

    // 模拟部署
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isDeploying = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_aa_deploy_started),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToSend() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AASendPage(
          account: widget.account,
          walletAddress: widget.walletAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.account.displayName,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 账户卡片
            _buildAccountCard(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 快捷操作
            _buildQuickActions(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 账户详情
            _buildDetailsSection(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 交易历史
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getAccountTypeColor().withAlpha(30),
            _getAccountTypeColor().withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAccountIcon(),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.displayName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      widget.account.type.displayName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DeploymentStatusIndicator(state: widget.account.state),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),

          // 地址
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.backGroundColor.name,
              ).withAlpha(100),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).g_key_155,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(20),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        widget.account.address,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          fontFamily: 'monospace',
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _copyAddress,
                  icon: Icon(
                    Icons.copy,
                    size: ScreenUtil().setWidth(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountIcon() {
    return Container(
      width: ScreenUtil().setWidth(64),
      height: ScreenUtil().setWidth(64),
      decoration: BoxDecoration(
        color: _getAccountTypeColor().withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(18)),
      ),
      child: Center(
        child: Icon(
          _getAccountTypeIcon(),
          size: ScreenUtil().setWidth(36),
          color: _getAccountTypeColor(),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.send,
            label: S.of(context).g_key_48,
            color: const Color(0xFF5E97F6),
            onTap: widget.account.state.canExecute ? _navigateToSend : null,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _buildActionButton(
            icon: Icons.qr_code,
            label: S.of(context).g_key_33,
            color: const Color(0xFF66BB6A),
            onTap: () {
              // 显示收款二维码
            },
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _buildActionButton(
            icon: Icons.rocket_launch,
            label: S.of(context).g_key_aa_deploy,
            color: const Color(0xFFFF9800),
            onTap: widget.account.needsDeployment && !_isDeploying
                ? _deployAccount
                : null,
            isLoading: _isDeploying,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final isDisabled = onTap == null && !isLoading;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(16),
        ),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.withAlpha(20)
              : color.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: isDisabled ? Colors.grey.withAlpha(30) : color.withAlpha(40),
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: ScreenUtil().setWidth(28),
                height: ScreenUtil().setWidth(28),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              )
            else
              Icon(
                icon,
                size: ScreenUtil().setWidth(28),
                color: isDisabled ? Colors.grey : color,
              ),
            SizedBox(height: ScreenUtil().setWidth(6)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w500,
                color: isDisabled
                    ? Colors.grey
                    : AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_aa_account_details,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildDetailRow(S.of(context).g_key_aa_chain_id, widget.account.chainId.toString()),
          _buildDetailRow(S.of(context).g_key_aa_factory, _shortenAddress(widget.account.factoryAddress)),
          _buildDetailRow(S.of(context).g_key_aa_owner, _shortenAddress(widget.account.ownerAddress)),
          _buildDetailRow(S.of(context).g_key_aa_created, _formatDate(widget.account.createdAt)),
          if (widget.account.lastActivityAt != null)
            _buildDetailRow(
              S.of(context).g_key_aa_last_activity,
              _formatDate(widget.account.lastActivityAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w500,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_tran_1,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // 查看全部交易
                },
                child: Text(S.of(context).g_key_aa_view_all),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // 空状态
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: ScreenUtil().setWidth(48),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ).withAlpha(100),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  Text(
                    S.of(context).g_key_132,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccountTypeColor() {
    switch (widget.account.type) {
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

  IconData _getAccountTypeIcon() {
    switch (widget.account.type) {
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

  String _shortenAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
