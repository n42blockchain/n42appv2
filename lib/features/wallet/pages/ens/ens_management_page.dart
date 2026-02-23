// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_renew_page.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 支持 ENS 的链配置（用于域名后缀匹配与颜色展示）
class EnsChainConfig {
  final String id;
  final String name;
  final String symbol;
  final int chainId;
  final String? iconPath;
  final Color color;
  final String suffix; // ENS 域名后缀

  const EnsChainConfig({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
    this.iconPath,
    required this.color,
    required this.suffix,
  });

  static const List<EnsChainConfig> supportedChains = [
    EnsChainConfig(
      id: 'n42',
      name: 'N42',
      symbol: 'N',
      chainId: 42,
      color: Color(0xFF6366F1),
      suffix: '.n42',
    ),
    EnsChainConfig(
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'ETH',
      chainId: 1,
      color: Color(0xFF627EEA),
      suffix: '.eth',
    ),
    EnsChainConfig(
      id: 'sepolia',
      name: 'Sepolia',
      symbol: 'ETH',
      chainId: 11155111,
      color: Color(0xFF9B8AFF),
      suffix: '.eth',
    ),
    EnsChainConfig(
      id: 'base',
      name: 'Base',
      symbol: 'ETH',
      chainId: 8453,
      color: Color(0xFF0052FF),
      suffix: '.base.eth',
    ),
    EnsChainConfig(
      id: 'arbitrum',
      name: 'Arbitrum',
      symbol: 'ETH',
      chainId: 42161,
      color: Color(0xFF28A0F0),
      suffix: '.arb',
    ),
  ];

  static EnsChainConfig get defaultChain => supportedChains[1]; // Ethereum

  /// 从完整域名后缀自动推断所在链
  static EnsChainConfig fromDomainName(String name) {
    final lower = name.toLowerCase();
    // 最长后缀优先（.base.eth 比 .eth 更具体）
    final sorted = List<EnsChainConfig>.from(supportedChains)
      ..sort((a, b) => b.suffix.length.compareTo(a.suffix.length));
    for (final chain in sorted) {
      if (lower.endsWith(chain.suffix)) return chain;
    }
    return defaultChain;
  }
}

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

  bool _isValidAddress(String addr) =>
      _hexAddrRegex.hasMatch(addr.trim());

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
    setState(() => _isLoading = true);
    final result = await _ensService.setAddress(widget.ownedEns.name, addr);
    if (mounted) {
      setState(() => _isLoading = false);
      if (!result.error) {
        _showSuccess(S.of(context).g_key_ens_address_updated);
      } else {
        _showError(result.data?.toString() ?? S.of(context).g_key_error_3);
      }
    }
  }

  // ── 文本记录 ─────────────────────────────────────

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
        _showSuccess(S.of(context).g_key_185);
      } else {
        _showError(result.data?.toString() ?? S.of(context).g_key_error_3);
      }
    }
  }

  // ── 主要名称 ─────────────────────────────────────

  Future<void> _setPrimaryName() async {
    setState(() => _isLoading = true);
    final result = await _ensService.setPrimaryName(
      widget.ownedEns.name,
      widget.walletAddress,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (!result.error) {
        _showSuccess(S.of(context).g_key_ens_primary_set);
      } else {
        _showError(result.data?.toString() ?? S.of(context).g_key_error_3);
      }
    }
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
    final labelController = TextEditingController();
    final ownerController = TextEditingController(text: widget.walletAddress);
    String? labelError;
    String? ownerError;
    bool creating = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> onCreate() async {
              final label = labelController.text.trim();
              final owner = ownerController.text.trim();

              // 验证标签
              if (!_ensService.isValidSubdomainLabel(label)) {
                setSheetState(
                  () => labelError = S.of(ctx).g_key_ens_subdomain_invalid_label,
                );
                return;
              }
              // 验证所有者地址
              if (owner.isNotEmpty && !_isValidAddress(owner)) {
                setSheetState(
                  () => ownerError = S.of(ctx).g_key_ens_invalid_address,
                );
                return;
              }

              setSheetState(() {
                creating = true;
                labelError = null;
                ownerError = null;
              });

              // 在 await 前缓存依赖 context 的字符串和 Navigator
              final nav = Navigator.of(sheetCtx);
              final errorFallback = S.of(context).g_key_error_3;
              final successMsg = S.of(context).g_key_ens_subdomain_created;

              final effectiveOwner =
                  owner.isNotEmpty ? owner : widget.walletAddress;
              final result = await _ensService.createSubdomain(
                widget.ownedEns.name,
                label,
                effectiveOwner,
              );

              if (!mounted) return;

              if (result.error) {
                setSheetState(() => creating = false);
                nav.pop();
                _showError(result.data?.toString() ?? errorFallback);
              } else {
                nav.pop();
                _showSuccess(successMsg);
                _loadSubdomains();
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 标题
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(ctx).g_key_ens_subdomain_create,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            fontWeight: FontWeight.bold,
                            color: AppThemeUtils.getColorByKey(
                              ctx,
                              AppThemeKeys.mainTextColor.name,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(8)),
                    // 预览
                    if (labelController.text.trim().isNotEmpty)
                      Container(
                        margin:
                            EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(16),
                          vertical: ScreenUtil().setWidth(10),
                        ),
                        decoration: BoxDecoration(
                          color: _domainChain.color.withAlpha(20),
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(10)),
                        ),
                        child: Text(
                          '${labelController.text.trim()}.${widget.ownedEns.name}',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontWeight: FontWeight.w600,
                            color: _domainChain.color,
                          ),
                        ),
                      ),
                    SizedBox(height: ScreenUtil().setWidth(8)),
                    // 标签输入
                    TextField(
                      controller: labelController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setSheetState(() => labelError = null),
                      decoration: InputDecoration(
                        labelText: S.of(ctx).g_key_ens_subdomain_label,
                        hintText: S.of(ctx).g_key_ens_subdomain_label_hint,
                        errorText: labelError,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(12)),
                        ),
                        suffixText: '.${widget.ownedEns.name}',
                        suffixStyle: TextStyle(
                          color: _domainChain.color,
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(22),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(16)),
                    // 所有者地址
                    TextField(
                      controller: ownerController,
                      onChanged: (_) => setSheetState(() => ownerError = null),
                      decoration: InputDecoration(
                        labelText: S.of(ctx).g_key_ens_subdomain_owner,
                        hintText: S.of(ctx).g_key_ens_subdomain_owner_hint,
                        errorText: ownerError,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(12)),
                        ),
                      ),
                      style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(24)),
                    // 创建按钮
                    SizedBox(
                      height: ScreenUtil().setWidth(88),
                      child: ElevatedButton(
                        onPressed: creating ? null : onCreate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _domainChain.color,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ScreenUtil().setWidth(14)),
                          ),
                        ),
                        child: creating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                S.of(ctx).g_key_ens_subdomain_create,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(8)),
                  ],
                ),
              ),
            );
          },
        );
      },
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

    setState(() => _isLoading = true);
    final result =
        await _ensService.deleteSubdomain(widget.ownedEns.name, sub.label);
    if (mounted) {
      setState(() => _isLoading = false);
      if (!result.error) {
        _showSuccess(S.of(context).g_key_ens_subdomain_deleted);
        _loadSubdomains();
      } else {
        _showError(result.data?.toString() ?? S.of(context).g_key_error_3);
      }
    }
  }

  // ── 转移 ─────────────────────────────────────────

  Future<void> _showTransferDialog() async {
    final controller = TextEditingController();
    String? validationError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
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
                    onChanged: (_) =>
                        setDialogState(() => validationError = null),
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
                      setDialogState(() =>
                          validationError =
                              S.of(ctx).g_key_ens_invalid_address);
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(
                    S.of(ctx).g_key_ens_transfer,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _transferDomain(controller.text.trim());
    }
  }

  Future<void> _transferDomain(String newOwner) async {
    setState(() => _isLoading = true);
    final result = await _ensService.transfer(widget.ownedEns.name, newOwner);
    if (mounted) {
      setState(() => _isLoading = false);
      if (!result.error) {
        _showSuccess(S.of(context).g_key_ens_transfer_success);
        Navigator.pop(context, true);
      } else {
        _showError(result.data?.toString() ?? S.of(context).g_key_error_3);
      }
    }
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
                _buildDomainCard(),
                SizedBox(height: ScreenUtil().setWidth(20)),
                _buildQuickActions(),
                SizedBox(height: ScreenUtil().setWidth(24)),
                _buildAddressSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),
                _buildTextRecordsSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),
                _buildSubdomainSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),
                _buildAdvancedSection(),
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

  // ── 域名信息卡片 ──────────────────────────────────

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

          SizedBox(height: ScreenUtil().setWidth(8)),

          // 标签行：链标签 + 主要名称标识
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 链徽章
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(12),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: _domainChain.color.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(12)),
                  border: Border.all(
                    color: _domainChain.color.withAlpha(60),
                  ),
                ),
                child: Text(
                  _domainChain.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: _domainChain.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.ownedEns.isPrimary) ...[
                SizedBox(width: ScreenUtil().setWidth(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setWidth(4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Text(
                    S.of(context).g_key_ens_primary,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
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
        color: _domainChain.color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
      ),
      child: Center(
        child: Text(
          widget.ownedEns.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: ScreenUtil().setSp(36),
            fontWeight: FontWeight.bold,
            color: _domainChain.color,
          ),
        ),
      ),
    );
  }

  // ── 快捷操作 ─────────────────────────────────────

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
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.withAlpha(20) : color.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color:
                isDisabled ? Colors.grey.withAlpha(30) : color.withAlpha(40),
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

  // ── 解析地址 section ──────────────────────────────

  Widget _buildAddressSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_ens_resolved_address,
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
                onPressed: _saveResolvedAddress,
                child: Text(S.of(context).g_key_115),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          TextField(
            controller: _resolvedAddressController,
            decoration: InputDecoration(
              hintText: '0x...',
              prefixIcon:
                  const Icon(Icons.account_balance_wallet_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(14),
              ),
              suffixIcon: _resolvedAddressController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () =>
                          setState(() => _resolvedAddressController.clear()),
                    )
                  : null,
            ),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontFamily: 'monospace',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── 文本记录 section ──────────────────────────────

  Widget _buildTextRecordsSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
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
          ..._commonRecordKeys.map(_buildRecordField),
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
        return 'Twitter / X';
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
        return Icons.email_outlined;
      case 'url':
        return Icons.link;
      case 'com.twitter':
        return Icons.alternate_email;
      case 'com.github':
        return Icons.code;
      case 'com.discord':
        return Icons.chat_bubble_outline;
      case 'org.telegram':
        return Icons.send_outlined;
      case 'description':
        return Icons.description_outlined;
      default:
        return Icons.text_fields;
    }
  }

  // ── 子域名 section ───────────────────────────────

  Widget _buildSubdomainSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_ens_subdomains,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 刷新
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _subdomainsLoading ? null : _loadSubdomains,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                  // 创建
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    onPressed: _showCreateSubdomainSheet,
                    color: _domainChain.color,
                  ),
                ],
              ),
            ],
          ),

          // 内容区
          if (_subdomainsLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_subdomains.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: ScreenUtil().setWidth(48),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ).withAlpha(100),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(8)),
                    Text(
                      S.of(context).g_key_ens_subdomain_empty,
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
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subdomains.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => _buildSubdomainItem(_subdomains[i]),
            ),

          // "创建子域名" 按钮（底部）
          SizedBox(height: ScreenUtil().setWidth(12)),
          OutlinedButton.icon(
            onPressed: _showCreateSubdomainSheet,
            icon: Icon(
              Icons.add,
              size: ScreenUtil().setWidth(20),
              color: _domainChain.color,
            ),
            label: Text(
              S.of(context).g_key_ens_subdomain_create,
              style: TextStyle(color: _domainChain.color),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _domainChain.color.withAlpha(80)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              minimumSize:
                  Size(double.infinity, ScreenUtil().setWidth(80)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubdomainItem(SubdomainInfo sub) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
      child: Row(
        children: [
          // 图标
          Container(
            width: ScreenUtil().setWidth(40),
            height: ScreenUtil().setWidth(40),
            decoration: BoxDecoration(
              color: _domainChain.color.withAlpha(20),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Icon(
              Icons.subdirectory_arrow_right,
              size: ScreenUtil().setWidth(20),
              color: _domainChain.color,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          // 名称 + 所有者
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.fullName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                if (sub.owner.isNotEmpty)
                  Text(
                    '${sub.owner.substring(0, 6)}...${sub.owner.substring(sub.owner.length - 4)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
          // 操作按钮
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            onPressed: () => _copyToClipboard(sub.fullName),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => _deleteSubdomain(sub),
            color: Colors.red.withAlpha(180),
          ),
        ],
      ),
    );
  }

  // ── 高级操作 section ──────────────────────────────

  Widget _buildAdvancedSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
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
            contentPadding: EdgeInsets.zero,
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
