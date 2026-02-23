// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/pages/ens/ens_search_page.dart';
import 'package:n42_wallet/src/wallet/pages/ens/ens_management_page.dart';
import 'package:n42_wallet/src/wallet/services/ens_expiry_reminder_service.dart';
import 'package:n42_wallet/src/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/src/wallet/widgets/ens/ens_owned_list_item.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

// 引入链配置
export 'package:n42_wallet/src/wallet/pages/ens/ens_management_page.dart' show EnsChainConfig;

/// ENS 功能主页
///
/// 提供 ENS 功能入口:
/// - 搜索和注册新域名
/// - 查看已拥有的域名列表
/// - 管理域名记录和续费
class EnsHomePage extends StatefulWidget {
  /// 当前钱包地址
  final String walletAddress;

  const EnsHomePage({
    super.key,
    required this.walletAddress,
  });

  @override
  State<EnsHomePage> createState() => _EnsHomePageState();
}

class _EnsHomePageState extends State<EnsHomePage> {
  final EnsRegistrationService _ensService = EnsRegistrationServiceProvider.instance;

  List<OwnedEns> _ownedNames = [];
  bool _isLoading = true;
  String? _errorMessage;

  // 当前选择的链，默认 N42
  EnsChainConfig _selectedChain = EnsChainConfig.defaultChain;

  @override
  void initState() {
    super.initState();
    _loadOwnedNames();
    // 进入 ENS 首页时检查所有域名的到期提醒
    EnsExpiryReminderService.checkAndNotify();
  }

  Future<void> _loadOwnedNames() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _ensService.getOwnedNames(widget.walletAddress);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!result.error && result.data != null) {
          _ownedNames = result.data!;
        } else {
          _errorMessage = S.of(context).g_key_5;
        }
      });
    }
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnsSearchPage(
          walletAddress: widget.walletAddress,
        ),
      ),
    ).then((_) => _loadOwnedNames());
  }

  void _navigateToManagement(OwnedEns ens) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnsManagementPage(
          ownedEns: ens,
          walletAddress: widget.walletAddress,
        ),
      ),
    ).then((_) => _loadOwnedNames());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_ens_title,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOwnedNames,
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSearch,
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        icon: const Icon(Icons.search, color: Colors.white),
        label: Text(
          S.of(context).g_key_ens_search,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      children: [
        // 链选择器
        _buildChainSelector(),
        SizedBox(height: ScreenUtil().setWidth(20)),

        // 顶部说明卡片
        _buildHeaderCard(),
        SizedBox(height: ScreenUtil().setWidth(24)),

        // 功能快捷入口
        _buildQuickActions(),
        SizedBox(height: ScreenUtil().setWidth(24)),

        // 已拥有的域名列表
        _buildOwnedNamesSection(),
      ],
    );
  }

  Widget _buildChainSelector() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: _selectedChain.color.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                size: ScreenUtil().setWidth(18),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(6)),
              Text(
                S.of(context).g_key_aa_chain,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: _selectedChain.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Text(
                  _selectedChain.suffix,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: _selectedChain.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: EnsChainConfig.supportedChains.map((chain) {
                final isSelected = _selectedChain.id == chain.id;
                return Padding(
                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedChain.id != chain.id) {
                        setState(() {
                          _selectedChain = chain;
                        });
                        _loadOwnedNames();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(14),
                        vertical: ScreenUtil().setWidth(8),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? chain.color.withAlpha(25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                        border: Border.all(
                          color: isSelected
                              ? chain.color
                              : AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.itemSubtitleTextColor.name,
                                ).withAlpha(40),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(24),
                            height: ScreenUtil().setWidth(24),
                            decoration: BoxDecoration(
                              color: chain.color.withAlpha(30),
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                            ),
                            child: Center(
                              child: Text(
                                chain.symbol.substring(0, 1),
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(16),
                                  fontWeight: FontWeight.bold,
                                  color: chain.color,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Text(
                            chain.name,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(24),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected
                                  ? chain.color
                                  : AppThemeUtils.getColorByKey(
                                      context,
                                      AppThemeKeys.mainTextColor.name,
                                    ),
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: ScreenUtil().setWidth(6)),
                            Icon(
                              Icons.check_circle,
                              size: ScreenUtil().setWidth(18),
                              color: chain.color,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(40),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(56),
                height: ScreenUtil().setWidth(56),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withAlpha(30),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                ),
                child: Center(
                  child: Text(
                    'ENS',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).g_key_ens_service,
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
                      S.of(context).g_key_ens_description,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.search_rounded,
            title: S.of(context).g_key_ens_search,
            subtitle: S.of(context).g_key_ens_search_desc,
            color: const Color(0xFF5E97F6),
            onTap: _navigateToSearch,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(16)),
        Expanded(
          child: _buildActionCard(
            icon: Icons.autorenew_rounded,
            title: S.of(context).g_key_ens_renew,
            subtitle: S.of(context).g_key_ens_renew_desc,
            color: const Color(0xFF66BB6A),
            onTap: () {
              if (_ownedNames.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).g_key_ens_no_domains),
                  ),
                );
              } else {
                // 导航到续费页面
                _navigateToManagement(_ownedNames.first);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: color.withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ScreenUtil().setWidth(44),
              height: ScreenUtil().setWidth(44),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              child: Icon(
                icon,
                size: ScreenUtil().setWidth(24),
                color: color,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(4)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnedNamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_ens_my_domains,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            if (_ownedNames.isNotEmpty)
              Text(
                '${_ownedNames.length}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
        if (_isLoading)
          _buildLoadingState()
        else if (_errorMessage != null)
          _buildErrorState()
        else if (_ownedNames.isEmpty)
          _buildEmptyState()
        else
          _buildOwnedNamesList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtil().setWidth(48),
            color: Colors.red,
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          TextButton(
            onPressed: _loadOwnedNames,
            child: Text(S.of(context).g_swap_key_6),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ).withAlpha(30),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.domain_rounded,
            size: ScreenUtil().setWidth(64),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_ens_no_domains,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w500,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_ens_get_started,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          ElevatedButton.icon(
            onPressed: _navigateToSearch,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.of(context).g_key_ens_search_register),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
                vertical: ScreenUtil().setWidth(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedNamesList() {
    return Column(
      children: _ownedNames.map((ens) {
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
          child: EnsOwnedListItem(
            ownedEns: ens,
            onTap: () => _navigateToManagement(ens),
          ),
        );
      }).toList(),
    );
  }
}
