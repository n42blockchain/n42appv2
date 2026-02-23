import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/miningV1/models/mining_type.dart';
import 'package:n42_wallet/src/miningV1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class ShareMining extends StatefulWidget {
  // 0 创建群组 1 加入群组 2Ast质押 3NFT质押
  final int fromType;
  final int? astValue;
  final String? groupName;
  final String? groupId;

  const ShareMining(
      {Key? key,
        this.fromType = 0,
        this.astValue,
        this.groupName,
        this.groupId})
      : super(key: key);

  @override
  State<ShareMining> createState() => _ShareMiningState();
}

class _ShareMiningState extends State<ShareMining> {
  String _generateTipsContent() {
    if (widget.fromType == 0 || widget.fromType == 1) {
      return S.of(context).g_mining_key60;
    }
    //括号内三种级别Entry, Advanced, Pro。
    String topS = widget.astValue == 50
        ? S.of(context).g_mining_key_67
        : widget.astValue == 100
        ? S.of(context).g_mining_key_66
        : S.of(context).g_mining_key_68;
    return S.of(context).g_mining_key63(topS);
  }

  generateShareText() {
    if (widget.fromType == 0 || widget.fromType == 1) {
      final shareUrl =
          "${AppConfig.apiUrl['walletamazeBrowser']}?type=group_mining&id=${widget.groupId}";

      return "${S.of(context).g_mining_key73(widget.groupName ?? '')} $shareUrl";
    }

    final shareUrl = "${AppConfig.apiUrl['walletamazeBrowser']}?type=full_node";
    return "${S.of(context).g_mining_key74} $shareUrl";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/mining/group_share_bg.png",
                  ))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
            child: Column(
              children: [
                SizedBox(
                  height: ScreenUtil().setWidth(60) + MediaQuery.of(context).padding.top,
                ),
                Image.asset(
                  "assets/mining/medal_star.png",
                  width: ScreenUtil().setWidth(170),
                  fit: BoxFit.cover,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(100),
                ),
                Text(
                  "Congratulations!",
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30)),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(40),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(44)),
                  child: Text(
                    _generateTipsContent(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        height: 1.2,
                        fontSize: ScreenUtil().setSp(30)),
                  ),
                ),
                Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Share.share(
                            generateShareText(),
                            subject: AppConfig.apiUrl['walletamazeBrowser'],
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainBlueColor.name),
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            Text(
                              S.of(context).g_mining_key61,
                              style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainBlueColor.name),
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                          ],
                        ),
                      ),
                    )),
                Divider(
                  height: ScreenUtil().setWidth(1),
                  indent: 0,
                  endIndent: 0,
                ),
                SafeArea(
                  child: Container(
                    height: ScreenUtil().setWidth(88),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30),),
                    child: buttonStyle2(context, () async {
                      if (widget.fromType == 2) {
                        globalMiningV1
                            .setMiningType(MiningType.N);
                      }
                      globalMiningV1.setDepositsEnable(true);
                      //eventBus.fire(EventPublic(EventPublicType.finishPage));
                      eventBus.fire(EventPublic(EventPublicType.refreshMiningData));
                      eventBus.fire(EventPublic(EventPublicType.selectMiningplansPop));
                      Navigator.pop(context,true);
                      //Navigator.popUntil(context, ModalRoute.withName('/TodayMiningPage'));
                    }, S.of(context).g_mining_key62,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
