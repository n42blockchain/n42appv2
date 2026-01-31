// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/ens/ens_renew_page.dart';
import 'package:n42appv2/src/wallet/services/ens_registration_service.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// ENS 管理页面
///
/// 管理已拥有的 ENS 域名:
/// - 查看详情
/// - 编辑文本记录
/// - 续费
/// - 转移
class EnsManagementPage extends StatefulWidget {
  /// 已拥有的 ENS 信息
  final OwnedEns ownedEns;

  /// 钱包地址
  final String walletAddress;

  const EnsManagementPage({
    super.key,
    required this.ownedEns,
    required this.walletAddress,
  });

  @override
  State<EnsManagementPage> createState() => _EnsManagementPageState();
}

class _EnsManagementPageState extends State<EnsManagementPage> {
  final EnsRegistrationService _ensService = EnsRegistrationServiceProvider.instance;

  bool _isLoading = false;

  // 文本记录编辑
  final Map<String, TextEditingController> _recordControllers = {};

  // 常用记录键
  static const List<String> _commonRecordKeys = [
    'email',
    'url',
    'com.twitter',
    'com.github',
    'com.discord',
    'org.telegram',
    'description',
  ];

  @override
  void initState() {
    super.initState();
    _initRecordControllers();
  }

  void _initRecordControllers() {
    for (final key in _commonRecordKeys) {
      _recordControllers[key] = TextEditingController(
        text: widget.ownedEns.textRecords?[key] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _recordControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_119),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToRenew() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnsRenewPage(
          ownedEns: widget.ownedEns,
          walletAddress: widget.walletAddress,
        ),
      ),
    );
  }

  Future<void> _saveTextRecords() async {
    setState(() => _isLoading = true);

    final records = <String, String>{};
    for (final entry in _recordControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        records[entry.key] = entry.value.text;
      }
    }

    final result = await _ensService.setTextRecords(widget.ownedEns.name, records);

    if (mounted) {
      setState(() => _isLoading = false);

      if (!result.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_185),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data?.toString() ?? S.of(context).g_key_error_3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setPrimaryName() async {
    setState(() => _isLoading = true);

    final result = await _ensService.setPrimaryName(
      widget.ownedEns.name,
      widget.walletAddress,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (!result.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_ens_primary_set),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data?.toString() ?? S.of(context).g_key_error_3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showTransferDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).g_key_ens_transfer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).g_key_ens_transfer_warning,
              style: TextStyle(
                color: Colors.orange,
                fontSize: ScreenUtil().setSp(24),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: S.of(context).g_key_ens_new_owner,
                hintText: '0x...',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).g_key_79),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(S.of(context).g_key_ens_transfer),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _transferDomain(result);
    }
  }

  Future<void> _transferDomain(String newOwner) async {
    setState(() => _isLoading = true);

    final result = await _ensService.transfer(widget.ownedEns.name, newOwner);

    if (mounted) {
      setState(() => _isLoading = false);

      if (!result.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_ens_transfer_success),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data?.toString() ?? S.of(context).g_key_error_3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_110,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 域名信息卡片
                _buildDomainCard(),
                SizedBox(height: ScreenUtil().setWidth(24)),

                // 快捷操作
                _buildQuickActions(),
                SizedBox(height: ScreenUtil().setWidth(24)),

                // 文本记录编辑
                _buildTextRecordsSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),

                // 高级操作
                _buildAdvancedSection(),
                SizedBox(height: ScreenUtil().setWidth(40)),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDomainCard() {
    final isExpiringSoon = widget.ownedEns.isExpiringSoon;
    final isExpired = widget.ownedEns.isExpired;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [Colors.red.withAlpha(30), Colors.red.withAlpha(10)]
              : isExpiringSoon
                  ? [Colors.orange.withAlpha(30), Colors.orange.withAlpha(10)]
                  : [
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withAlpha(30),
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withAlpha(10),
                    ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        children: [
          // 头像
          if (widget.ownedEns.avatar != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
              child: Image.network(
                widget.ownedEns.avatar!,
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setWidth(80),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildDefaultAvatar(),
              ),
            )
          else
            _buildDefaultAvatar(),
          SizedBox(height: ScreenUtil().setWidth(16)),

          // 域名
          Text(
            widget.ownedEns.name,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(36),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),

          // 主要名称标识
          if (widget.ownedEns.isPrimary)
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(4),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              child: Text(
                S.of(context).g_key_ens_primary,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(height: ScreenUtil().setWidth(16)),

          // 到期信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExpired
                    ? Icons.error
                    : isExpiringSoon
                        ? Icons.warning
                        : Icons.access_time,
                size: ScreenUtil().setWidth(20),
                color: isExpired
                    ? Colors.red
                    : isExpiringSoon
                        ? Colors.orange
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
              ),
              SizedBox(width: ScreenUtil().setWidth(6)),
              Text(
                isExpired
                    ? S.of(context).g_key_ens_expired
                    : '${S.of(context).g_key_ens_expires}: ${widget.ownedEns.formattedExpiresAt}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: isExpired
                      ? Colors.red
                      : isExpiringSoon
                          ? Colors.orange
                          : AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ),
                ),
              ),
            ],
          ),

          // 剩余天数
          if (!isExpired)
            Text(
              '${widget.ownedEns.daysUntilExpiry} ${S.of(context).g_key_ens_days_left}',
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

  Widget _buildDefaultAvatar() {
    return Container(
      width: ScreenUtil().setWidth(80),
      height: ScreenUtil().setWidth(80),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ).withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
      ),
      child: Center(
        child: Text(
          widget.ownedEns.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: ScreenUtil().setSp(36),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.autorenew,
            label: S.of(context).g_key_ens_renew,
            color: const Color(0xFF66BB6A),
            onTap: _navigateToRenew,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _buildActionButton(
            icon: Icons.star,
            label: S.of(context).g_key_ens_set_primary,
            color: const Color(0xFFFFA726),
            onTap: widget.ownedEns.isPrimary ? null : _setPrimaryName,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _buildActionButton(
            icon: Icons.content_copy,
            label: S.of(context).g_key_119,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
            onTap: () => _copyToClipboard(widget.ownedEns.name),
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
  }) {
    final isDisabled = onTap == null;

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

  Widget _buildTextRecordsSection() {
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
                S.of(context).g_key_ens_text_records,
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
                onPressed: _saveTextRecords,
                child: Text(S.of(context).g_key_115),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ..._commonRecordKeys.map((key) => _buildRecordField(key)),
        ],
      ),
    );
  }

  Widget _buildRecordField(String key) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      child: TextField(
        controller: _recordControllers[key],
        decoration: InputDecoration(
          labelText: _getRecordLabel(key),
          prefixIcon: Icon(_getRecordIcon(key), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(16),
            vertical: ScreenUtil().setWidth(14),
          ),
        ),
        style: TextStyle(fontSize: ScreenUtil().setSp(26)),
      ),
    );
  }

  String _getRecordLabel(String key) {
    switch (key) {
      case 'email':
        return 'Email';
      case 'url':
        return 'Website';
      case 'com.twitter':
        return 'Twitter';
      case 'com.github':
        return 'GitHub';
      case 'com.discord':
        return 'Discord';
      case 'org.telegram':
        return 'Telegram';
      case 'description':
        return 'Description';
      default:
        return key;
    }
  }

  IconData _getRecordIcon(String key) {
    switch (key) {
      case 'email':
        return Icons.email;
      case 'url':
        return Icons.link;
      case 'com.twitter':
        return Icons.alternate_email;
      case 'com.github':
        return Icons.code;
      case 'com.discord':
        return Icons.chat;
      case 'org.telegram':
        return Icons.send;
      case 'description':
        return Icons.description;
      default:
        return Icons.text_fields;
    }
  }

  Widget _buildAdvancedSection() {
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
            S.of(context).g_key_ens_advanced,
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
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.red),
            title: Text(S.of(context).g_key_ens_transfer),
            subtitle: Text(S.of(context).g_key_ens_transfer_desc),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTransferDialog,
          ),
        ],
      ),
    );
  }
}
