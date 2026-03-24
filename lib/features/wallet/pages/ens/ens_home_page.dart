// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_search_page.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_management_page.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_owned_name_filter.dart';
import 'package:n42_wallet/features/wallet/services/ens_expiry_reminder_service.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_owned_list_item.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

// 引入链配置
export 'package:n42_wallet/features/wallet/pages/ens/ens_management_page.dart'
    show EnsChainConfig;

part 'ens_home_page_logic.dart';
part 'ens_home_page_widgets.dart';

/// ENS 功能主页
///
/// 提供 ENS 功能入口:
/// - 搜索和注册新域名
/// - 查看已拥有的域名列表
/// - 管理域名记录和续费
class EnsHomePage extends StatefulWidget {
  /// 当前钱包地址
  final String walletAddress;

  const EnsHomePage({super.key, required this.walletAddress});

  @override
  State<EnsHomePage> createState() => _EnsHomePageState();
}

class _EnsHomePageState extends State<EnsHomePage>
    with _EnsHomeLogicMixin, _EnsHomeWidgetsMixin {
  @override
  void initState() {
    super.initState();
    loadOwnedNames();
    // 进入 ENS 首页时检查所有域名的到期提醒
    EnsExpiryReminderService.checkAndNotify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_ens_title),
      body: RefreshIndicator(onRefresh: loadOwnedNames, child: _buildContent()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _hasWalletAddress ? navigateToSearch : _showUnsupportedSnack,
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
        buildChainSelector(),
        SizedBox(height: ScreenUtil().setWidth(20)),

        // 顶部说明卡片
        buildHeaderCard(),
        SizedBox(height: ScreenUtil().setWidth(24)),

        // 功能快捷入口
        buildQuickActions(),
        SizedBox(height: ScreenUtil().setWidth(24)),

        // 已拥有的域名列表
        buildOwnedNamesSection(),
      ],
    );
  }
}
