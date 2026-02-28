// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_chain_config.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_management_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_renew_page.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_subdomain_sheet.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

export 'package:n42_wallet/features/wallet/pages/ens/ens_chain_config.dart';

/// ENS 管理页面
///
/// 管理已拥有的 ENS 域名:
/// - 查看详情与链信息
/// - 编辑解析地址
/// - 编辑文本记录
/// - 管理子域名（列表 / 创建 / 删除）
/// - 续费
/// - 转移所有权
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

  // ── 链信息（自动从域名推断）────────────────────────
  late EnsChainConfig _domainChain;

  // ── 解析地址 ────────────────────────────────────
  late TextEditingController _resolvedAddressController;

  // ── 文本记录 ────────────────────────────────────
  final Map<String, TextEditingController> _recordControllers = {};

  static const List<String> _commonRecordKeys = [
    'email',
    'url',
    'com.twitter',
    'com.github',
    'com.discord',
    'org.telegram',
    'description',
  ];

  // ── 子域名 ───────────────────────────────────────
  List<SubdomainInfo> _subdomains = [];
  bool _subdomainsLoading = false;

  // ── 以太坊地址正则 ─────────────────────────────
  static final _hexAddrRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');

  @override
  void initState() {
    super.initState();
    _domainChain = EnsChainConfig.fromDomainName(widget.ownedEns.name);
    _resolvedAddressController = TextEditingController(
      text: widget.ownedEns.resolvedAddress ?? '',
    );
    _initRecordControllers();
    _loadSubdomains();
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
    _resolvedAddressController.dispose();
    for (final c in _recordControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── 工具方法 ─────────────────────────────────────

  bool _isValidAddress(String addr) => _hexAddrRegex.hasMatch(addr.trim());

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_119),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  /// 通用的带 loading 状态执行异步操作，处理结果并显示反馈
  Future<void> _runWithLoading({
    required Future<MessageModel> Function() action,
    required String successMessage,
    VoidCallback? onSuccess,
  }) async {
    setState(() => _isLoading = true);
    final result = await action();
    if (mounted) {
      setState(() => _isLoading = false);
      if (!result.error) {
        _showSuccess(successMessage);
        onSuccess?.call();
      } else {
        _showError(result.data?.toString() ?? S.of(context).g_key_error_3);
      }
    }
  }

  // ── 导航 ─────────────────────────────────────────

  void _navigateToRenew() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnsRenewPage(
          ownedEns: widget.ownedEns,
          walletAddress: widget.walletAddress,
        ),
      ),
    );
  }

  // ── 解析地址 ─────────────────────────────────────

  Future<void> _saveResolvedAddress() async {
    final addr = _resolvedAddressController.text.trim();
    if (addr.isNotEmpty && !_isValidAddress(addr)) {
      _showError(S.of(context).g_key_ens_invalid_address);
      return;
    }
    await _runWithLoading(
      action: () => _ensService.setAddress(widget.ownedEns.name, addr),
      successMessage: S.of(context).g_key_ens_address_updated,
    );
  }

  // ── 文本记录 ─────────────────────────────────────

  Future<void> _saveTextRecords() async {
    final records = <String, String>{};
    for (final entry in _recordControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        records[entry.key] = entry.value.text;
      }
    }
    await _runWithLoading(
      action: () => _ensService.setTextRecords(widget.ownedEns.name, records),
      successMessage: S.of(context).g_key_185,
    );
  }

  // ── 主要名称 ─────────────────────────────────────

  Future<void> _setPrimaryName() async {
    await _runWithLoading(
      action: () => _ensService.setPrimaryName(widget.ownedEns.name, widget.walletAddress),
      successMessage: S.of(context).g_key_ens_primary_set,
    );
  }

  // ── 子域名 ───────────────────────────────────────

  Future<void> _loadSubdomains() async {
    setState(() => _subdomainsLoading = true);
    final result = await _ensService.getSubdomains(widget.ownedEns.name);
    if (mounted) {
      setState(() {
        _subdomainsLoading = false;
        if (!result.error && result.data is List) {
          _subdomains = (result.data as List<SubdomainInfo>)
              .where((s) => !s.isDeleted)
              .toList();
        }
      });
    }
  }

  Future<void> _showCreateSubdomainSheet() async {
    await EnsCreateSubdomainSheet.show(
      context,
      parentName: widget.ownedEns.name,
      walletAddress: widget.walletAddress,
      domainChain: _domainChain,
      ensService: _ensService,
      onCreated: _loadSubdomains,
    );
  }

  Future<void> _deleteSubdomain(SubdomainInfo sub) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).g_key_ens_subdomain_delete),
        content: Text(S.of(ctx).g_key_ens_subdomain_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).g_key_79),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              S.of(ctx).g_key_ens_subdomain_delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _runWithLoading(
      action: () => _ensService.deleteSubdomain(widget.ownedEns.name, sub.label),
      successMessage: S.of(context).g_key_ens_subdomain_deleted,
      onSuccess: _loadSubdomains,
    );
  }

  // ── 转移 ─────────────────────────────────────────

  Future<void> _showTransferDialog() async {
    final controller = TextEditingController();
    String? validationError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(S.of(ctx).g_key_ens_transfer),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(ctx).g_key_ens_transfer_warning,
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: ScreenUtil().setSp(24),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(16)),
              TextField(
                controller: controller,
                onChanged: (_) => setDialogState(() => validationError = null),
                decoration: InputDecoration(
                  labelText: S.of(ctx).g_key_ens_new_owner,
                  hintText: '0x...',
                  errorText: validationError,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.of(ctx).g_key_79),
            ),
            ElevatedButton(
              onPressed: () {
                final addr = controller.text.trim();
                if (!_isValidAddress(addr)) {
                  setDialogState(
                    () => validationError = S.of(ctx).g_key_ens_invalid_address,
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                S.of(ctx).g_key_ens_transfer,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _transferDomain(controller.text.trim());
    }
  }

  Future<void> _transferDomain(String newOwner) async {
    await _runWithLoading(
      action: () => _ensService.transfer(widget.ownedEns.name, newOwner),
      successMessage: S.of(context).g_key_ens_transfer_success,
      onSuccess: () => Navigator.pop(context, true),
    );
  }

  // ── Build ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_110),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EnsDomainCard(
                  ownedEns: widget.ownedEns,
                  domainChain: _domainChain,
                ),
                SizedBox(height: ScreenUtil().setWidth(20)),
                EnsQuickActions(
                  ownedEns: widget.ownedEns,
                  domainChain: _domainChain,
                  onRenew: _navigateToRenew,
                  onSetPrimary: widget.ownedEns.isPrimary ? null : _setPrimaryName,
                  onCopy: () => _copyToClipboard(widget.ownedEns.name),
                ),
                SizedBox(height: ScreenUtil().setWidth(24)),
                EnsAddressSection(
                  controller: _resolvedAddressController,
                  onSave: _saveResolvedAddress,
                  onChanged: () => setState(() {}),
                ),
                SizedBox(height: ScreenUtil().setWidth(24)),
                EnsTextRecordsSection(
                  controllers: _recordControllers,
                  recordKeys: _commonRecordKeys,
                  onSave: _saveTextRecords,
                ),
                SizedBox(height: ScreenUtil().setWidth(24)),
                EnsSubdomainSection(
                  subdomains: _subdomains,
                  isLoading: _subdomainsLoading,
                  domainChain: _domainChain,
                  onRefresh: _loadSubdomains,
                  onCreate: _showCreateSubdomainSheet,
                  onCopy: (sub) => _copyToClipboard(sub.fullName),
                  onDelete: _deleteSubdomain,
                ),
                SizedBox(height: ScreenUtil().setWidth(24)),
                EnsAdvancedSection(onTransfer: _showTransferDialog),
                SizedBox(height: ScreenUtil().setWidth(40)),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
