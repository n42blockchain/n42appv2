import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n42_wallet/src/mining_v2/api/mining_api.dart';
import 'package:n42_wallet/src/mining_v2/pages/mining_full_node_v2.dart';
import 'package:n42_wallet/src/mining_v2/utils/mining_utils.dart';
import 'package:n42_wallet/src/mining_v2/widgets/mining_board_widget.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';

class MiningPlansV2 extends StatefulWidget {
  const MiningPlansV2({super.key});

  @override
  State<MiningPlansV2> createState() => _MiningPlansV2State();
}

class _MiningPlansV2State extends State<MiningPlansV2> {
  late final StreamSubscription _eventSubscription;
  late final MiningApi _miningApi=MiningApi.init();
  int cReward=0;
  @override
  void initState() {
    super.initState();
    _eventSubscription=eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.selectMiningplansPop) {
        if(mounted){
          Navigator.pop(context);
        }
      }
    });
    calculateReward();
  }
  Future<void> calculateReward() async {
    MessageModel rmm=await _miningApi.getTotalEffectiveBalance();
    if(rmm.error==false){
      int t=rmm.data;
      cReward=miningCalculateReward(t);
      if(mounted){
        setState(() {});
      }
    }
  }
  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        // text: "Select Plans",
        text: S.current.g_mining_key_31,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30)),
                child: Column(
                  children: [
                    MiningBoardWidget(
                      nNum: 32,cReward: cReward,
                    ),
                    Spacer(),
                    SizedBox(height: ScreenUtil().setWidth(148),),
                    /*SizedBox(
              height: ScreenUtil().setWidth(120),
            )*/
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setWidth(148),
                    padding: EdgeInsets.all( ScreenUtil().setWidth(30)),
                    child: buttonStyle2(context, ()async {
                      Navigator.push(context,MaterialPageRoute(
                          builder: (_) => MiningFullNodeV2(
                            nNum: 32,
                          )));
                    },
                      S.of(context).g_key_78,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),),
    );
  }
}
