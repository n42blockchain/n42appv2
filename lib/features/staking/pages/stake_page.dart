// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/validator_list_page.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'stake_page_logic.dart';
part 'stake_page_forms.dart';
part 'stake_page_sections.dart';
part 'stake_page_widgets.dart';

/// Stake 页面
///
/// 用于质押/解除质押操作
class StakePage extends StatefulWidget {
  final StakingProtocol protocol;
  final String? userAddress;

  const StakePage({
    super.key,
    required this.protocol,
    this.userAddress,
  });

  @override
  State<StakePage> createState() => _StakePageState();
}

class _StakePageState extends State<StakePage>
    with SingleTickerProviderStateMixin, _StakeLogicMixin, _StakeFormsMixin, _StakeSectionsMixin, _StakeViewsMixin {
  @override
  late final TabController _tabController;
  @override
  late final StakingProvider _provider;
  @override
  final TextEditingController _amountController = TextEditingController();

  // 解质押专用控制器（与 stake 用的 _amountController 分开）
  @override
  final TextEditingController _unstakeAmountController = TextEditingController();

  @override
  bool _isLoading = false;
  @override
  BigInt _balance = BigInt.zero;
  @override
  String _errorMessage = '';

  // 解质押相关状态
  @override
  List<StakingPosition> _activePositions = [];
  @override
  StakingPosition? _selectedPosition;
  @override
  bool _loadingPositions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = StakingProvider();
    _provider.selectProtocol(widget.protocol);

    // 加载验证者列表并同步更新实时 APY（所有链都执行）
    _provider.loadValidators();

    _loadBalance();

    // 非流动性质押：加载用户仓位，以便解质押选择
    if (!widget.protocol.isLiquid && widget.userAddress != null) {
      _loadActivePositions();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _unstakeAmountController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.protocol.name,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 协议信息卡片
            _buildProtocolInfoCard(context),

            // Tab 栏
            _buildTabBar(context),

            // Tab 内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStakeTab(context),
                  _buildUnstakeTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
