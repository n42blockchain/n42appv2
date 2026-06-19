// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page_logic.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page_widgets.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page_sections.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 跨链桥主页面
class BridgeHomePage extends ConsumerStatefulWidget {
  const BridgeHomePage({super.key});

  @override
  ConsumerState<BridgeHomePage> createState() => _BridgeHomePageState();
}

class _BridgeHomePageState extends ConsumerState<BridgeHomePage>
    with BridgeHomeLogicMixin, BridgeHomeWidgetsMixin, BridgeHomeSectionsMixin {
  @override
  void initState() {
    super.initState();
    bridgeProvider = BridgeProvider();
    // 注册状态变化回调（在终态时弹出通知）
    bridgeProvider.onStatusChanged = handleStatusChange;
    bridgeProvider.initialize();
  }

  @override
  void dispose() {
    // 清除回调，防止 provider 在 widget 销毁后触发野回调
    bridgeProvider.onStatusChanged = null;
    amountController.dispose();
    bridgeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_bridge_title,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: openHistory),
        ],
      ),
      body: ListenableBuilder(
        listenable: bridgeProvider,
        builder: (context, _) {
          final provider = bridgeProvider;
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.space8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 源链选择卡
                        buildChainCard(context, provider, isFrom: true),

                        // 交换方向按钮
                        buildSwapButton(context, provider),

                        // 目标链选择卡
                        buildChainCard(context, provider, isFrom: false),

                        SizedBox(height: AppSpacing.space6),

                        // 滑点选择器（有报价后显示）
                        if (provider.quoteResponse?.hasRoutes == true) ...[
                          buildSlippageSelector(context, provider),
                          SizedBox(height: AppSpacing.space6),
                        ],

                        // 全部路由对比卡（有报价时显示）
                        if (provider.quoteResponse != null)
                          buildAllRoutesSection(context, provider),

                        // 错误提示
                        if (provider.errorMessage != null)
                          buildErrorMessage(context, provider),
                      ],
                    ),
                  ),
                ),

                // 底部操作按钮
                buildBottomButton(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }
}
