import 'dart:async';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_background.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_task_list.dart';
import 'package:n42_wallet/features/mining_v1/pages/task_detail_page.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/select_plan.dart';
import 'package:n42_wallet/features/mining_v1/widgets/task_item.dart';
import 'package:n42_wallet/features/mining_v1/widgets/task_value_bar.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/custom_popup_menu_wrap.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'today_mining_page_logic.dart';
part 'today_mining_page_widgets.dart';
part 'today_mining_page_sections.dart';

class TodayMiningPage extends StatefulWidget {
  const TodayMiningPage({super.key});

  @override
  State<TodayMiningPage> createState() => _TodayMiningPageState();
}

class _TodayMiningPageState extends State<TodayMiningPage>
    with _LogicMixin, _WidgetsMixin, _SectionsMixin {
  @override
  void initState() {
    super.initState();
    initEventBus();
    startTimer();
    initData();
  }

  @override
  void dispose() {
    disposeLogic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DetailRefreshWidget(
          callback: () async {
            initData();
          },
          childWidget: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
            ),
            child: ListenableBuilder(
              listenable: globalMiningV1,
              builder: (context, _) {
                final mpValue = globalMiningV1;
                return Column(
                  children: [
                    if (mpValue.miningType == null)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: ScreenUtil().setWidth(18)),
                          SelectPlan(onTap: null),
                          SizedBox(height: ScreenUtil().setWidth(10)),
                        ],
                      ),
                    miningStatusWidget(mpValue),

                    SizedBox(height: ScreenUtil().setWidth(20)),
                    dayMiningTimeWidget(mpValue),
                    SizedBox(height: ScreenUtil().setWidth(20)),
                    backgroundMiningWidget(mpValue),
                    Row(
                      children: [
                        miningDataBroad(S.of(context).g_mining_key_10,
                            "${lastCycleMiningTimes[0]}:${lastCycleMiningTimes[1]}:${lastCycleMiningTimes[2]}",
                            imagePath: "assets/mining/broad_bg_3.png"),
                        SizedBox(width: ScreenUtil().setWidth(20)),
                        miningDataBroad(
                            S.of(context).g_mining_key_11,
                            "${dataUtils.formatNum(lastCycleRewardsValue, 4)} ${CoinType.N.name}",
                            imagePath: "assets/mining/broad_bg_4.png",
                            tipsText: S.of(context).g_mining_key_12,
                            showTips: true),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20)),
                    Row(
                      children: [
                        miningDataBroad(
                          S.of(context).g_mining_key_13,
                          '${dataUtils.doubleFixed(totalValue, 2)} ${CoinType.N.name}',
                          imagePath: "assets/mining/broad_bg_1.png",
                        ),
                        SizedBox(width: ScreenUtil().setWidth(20)),
                        miningDataBroad(S.of(context).g_mining_key_14,
                            "\$${NumberFormat("#,##0.0#", "en_US").format((astPrice * totalValue))}",
                            imagePath: "assets/mining/broad_bg_2.png",
                            tipsText: S.of(context).g_mining_key_15,
                            showTips: true),
                      ],
                    ),
                    miningActivityWidget(mpValue),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
