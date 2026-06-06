import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_setting.dart';

import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/mining_v2/widgets/plans_widget.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_status_widget.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_risk_card.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_data_broad.dart';
import 'package:n42_wallet/features/mining_v2/widgets/background_mining_widget.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/chart_histogram.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'mining_today_v2_logic.dart';
part 'mining_today_v2_widgets.dart';

class MiningTodayV2 extends ConsumerStatefulWidget {
  const MiningTodayV2({super.key});

  @override
  ConsumerState<MiningTodayV2> createState() => _MiningTodayV2State();
}

class _MiningTodayV2State extends ConsumerState<MiningTodayV2>
    with
        AutomaticKeepAliveClientMixin,
        _MiningTodayV2LogicMixin,
        _MiningTodayV2WidgetsMixin {
  @override
  void initState() {
    super.initState();
    _eventSubscription = eventBus.on().listen((event) async {
      if (event is! EventPublic) return;
      if (event.type == EventPublicType.selectWallet) {
        await initDataWallet(EventPublicType.selectWallet);
      }
      if (event.type == EventPublicType.selectMiningWallet) {
        await initDataWallet(EventPublicType.selectMiningWallet);
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopBar(context),
            if (AppConfig.isMainChainMining == false)
              buildTestnetWarning(context),
            Expanded(
              flex: 1,
              child: DetailRefreshWidget(
                callback: () async {
                  await initData();
                },
                childWidget: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(30),
                    right: ScreenUtil().setWidth(30),
                  ),
                  child: Builder(
                    builder: (context) {
                      final mpValue = ref.watch(miningBridgeProvider);
                      return Column(
                        children: [
                          // 顶部渐变 Banner
                          buildMiningBanner(context, mpValue),
                          //没有质押展示 选择plans
                          if (mpValue.depositsEnable == false)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: ScreenUtil().setWidth(18)),
                                PlansWidget(onTap: null),
                                SizedBox(height: ScreenUtil().setWidth(10)),
                              ],
                            ),
                          MiningStatusWidget(mpValue: mpValue),
                          if (mpValue.depositsEnable == true)
                            MiningRiskCard(mpValue: mpValue),
                          if (mpValue.depositsEnable == true)
                            buildBarChart(context, mpValue),
                          if (mpValue.depositsEnable == true)
                            SizedBox(height: ScreenUtil().setWidth(20)),
                          BackgroundMiningWidget(mpValue: mpValue),
                          buildDataBroadRows(context, mpValue),
                          buildRedemptionSection(context, mpValue),
                          SizedBox(height: ScreenUtil().setWidth(140)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
