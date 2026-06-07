import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/task_item.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/chart_histogram.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:web3dart/web3dart.dart';

part 'summary_page_logic.dart';
part 'summary_page_widgets.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>
    with _SummaryPageLogicMixin, _SummaryPageWidgetsMixin {
  @override
  void initState() {
    super.initState();
    eventBusFn = eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.refreshMiningData) {
        initData(forcedRefresh: true);
      }
    });

    initData();
  }

  @override
  void dispose() {
    eventBusFn.cancel();
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
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
              bottom: ScreenUtil().setWidth(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScreenUtil().setWidth(18)),
                Text(
                  S.of(context).g_mining_key_58,
                  style: TextStyle(
                    color: AppColorTokens.of(context).textPrimary,
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(44)),
                // 柱状图展示历史7天挖矿数据
                buildBarChart(context),
                SizedBox(height: ScreenUtil().setWidth(44)),
                Text(
                  // "Summary"
                  S.current.g_mining_key_19,
                  style: TextStyle(
                    color: AppColorTokens.of(context).textPrimary,
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(44)),
                buildSummaryCard(context),
                SizedBox(height: ScreenUtil().setWidth(44)),
                Text(
                  // "Reward History"
                  S.current.g_mining_key_34,
                  style: TextStyle(
                    color: AppColorTokens.of(context).textPrimary,
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(44)),
                buildRewardHistory(context),
                SizedBox(height: ScreenUtil().setWidth(120)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
