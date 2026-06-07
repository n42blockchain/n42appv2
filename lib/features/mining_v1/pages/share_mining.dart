import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class ShareMining extends StatefulWidget {
  final int fromType;
  final int? astValue;
  final String? groupName;
  final String? groupId;

  const ShareMining({
    super.key,
    this.fromType = 0,
    this.astValue,
    this.groupName,
    this.groupId,
  });

  @override
  State<ShareMining> createState() => _ShareMiningState();
}

class _ShareMiningState extends State<ShareMining> {
  String _generateTipsContent() {
    if (widget.fromType == 0 || widget.fromType == 1) {
      return S.of(context).g_mining_key60;
    }
    String topS;
    switch (widget.astValue) {
      case 50:
        topS = S.of(context).g_mining_key_67;
      case 100:
        topS = S.of(context).g_mining_key_66;
      default:
        topS = S.of(context).g_mining_key_68;
    }
    return S.of(context).g_mining_key63(topS);
  }

  String generateShareText() {
    if (widget.fromType == 0 || widget.fromType == 1) {
      final shareUrl =
          "${AppConfig.apiUrl['n42Browser']}?type=group_mining&id=${widget.groupId}";

      return "${S.of(context).g_mining_key73(widget.groupName ?? '')} $shareUrl";
    }

    final shareUrl = "${AppConfig.apiUrl['n42Browser']}?type=full_node";
    return "${S.of(context).g_mining_key74} $shareUrl";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/mining/group_share_bg.png"),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
            ),
            child: Column(
              children: [
                SizedBox(
                  height:
                      ScreenUtil().setWidth(60) +
                      MediaQuery.of(context).padding.top,
                ),
                Image.asset(
                  "assets/mining/medal_star.png",
                  width: ScreenUtil().setWidth(170),
                  fit: BoxFit.cover,
                  color: AppColorTokens.of(context).textPrimary,
                ),
                SizedBox(height: ScreenUtil().setWidth(100)),
                Text(
                  "Congratulations!",
                  style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
                ),
                SizedBox(height: ScreenUtil().setWidth(40)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(44),
                  ),
                  child: Text(
                    _generateTipsContent(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColorTokens.of(context).textPrimary,
                      height: 1.2,
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: generateShareText(),
                            subject: AppConfig.apiUrl['n42Browser'],
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            color: AppColorTokens.of(context).brand,
                          ),
                          SizedBox(height: ScreenUtil().setWidth(24)),
                          Text(
                            S.of(context).g_mining_key61,
                            style: AppTypography.body.copyWith(color: AppColorTokens.of(context).brand),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: ScreenUtil().setWidth(1),
                  indent: 0,
                  endIndent: 0,
                ),
                SafeArea(
                  child: Container(
                    height: ScreenUtil().setWidth(88),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(30),
                    ),
                    child: AppButton(
                      label: S.of(context).g_mining_key62,
                      onPressed: () {
                        if (widget.fromType == 2) {
                          globalMiningV1.setMiningType(MiningType.N);
                        }
                        globalMiningV1.setDepositsEnable(true);
                        eventBus.fire(
                          EventPublic(EventPublicType.refreshMiningData),
                        );
                        eventBus.fire(
                          EventPublic(EventPublicType.selectMiningplansPop),
                        );
                        Navigator.pop(context, true);
                      },
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
