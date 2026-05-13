import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_output_tip.dart';
import 'package:n42_wallet/features/mining_v2/pages/share_mining.dart';
import 'package:n42_wallet/features/mining_v2/widgets/group_confrim.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/mining_v2/widgets/n_level_widget.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'mining_full_node_v2_logic.dart';
part 'mining_full_node_v2_widgets.dart';

class MiningFullNodeV2 extends ConsumerStatefulWidget {
  final int nNum;
  const MiningFullNodeV2({required this.nNum, super.key});

  @override
  ConsumerState<MiningFullNodeV2> createState() => _MiningFullNodeV2State();
}

class _MiningFullNodeV2State extends ConsumerState<MiningFullNodeV2>
    with _MiningFullNodeV2LogicMixin, _MiningFullNodeV2WidgetsMixin {

  @override
  void initState() {
    super.initState();
    _eventSubscription = eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.miningFullNode) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ShareMining(
                      fromType: _payType == 0 ? 2 : 3,
                      astValue: widget.nNum,
                    )),
          );
        }
      }
    });
    initData();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:
            "${S.current.g_mining_key_37}:${S.of(context).g_mining_key_62}",
      ),
      body: Builder(
        builder: (context) {
          final depositLoad = ref.watch(
              miningBridgeProvider.select((p) => p.depositLoad));
          return SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(30)),
                    child: Column(
                      children: [
                        Expanded(
                            child: ListView(
                          children: [
                            NLevelWidget(nNum: widget.nNum),
                            SizedBox(
                                height: ScreenUtil().setWidth(90)),
                            // 支付方式标题
                            buildSectionTitle(
                                context, S.current.g_mining_key_38),
                            SizedBox(
                                height: ScreenUtil().setWidth(20)),
                            // 支付方式选择
                            buildPayMethod(
                              "assets/mining/pay_ast.png",
                              S.of(context).g_mining_key_40,
                              isSelected: _payType == 0,
                              onTap: () {
                                setState(() {
                                  _payType = 0;
                                });
                              },
                            ),
                            SizedBox(
                                height: ScreenUtil().setWidth(20)),
                            // 提示文字
                            buildInfoTip(context),
                            SizedBox(
                                height: ScreenUtil().setWidth(50)),
                            // 支付方式标题
                            buildSectionTitle(
                                context, S.current.g_mining_key_39),
                            SizedBox(
                                height: ScreenUtil().setWidth(20)),
                            buildPayMethods(),
                            if (nBalance != null &&
                                nBalance! > widget.nNum)
                              buildPrivateKeyCard(context),
                          ],
                        )),
                        SizedBox(
                            height: ScreenUtil().setWidth(148)),
                      ],
                    ),
                  ),
                ),
                buildBottomButton(context, depositLoad),
              ],
            ),
          );
        },
      ),
    );
  }
}
