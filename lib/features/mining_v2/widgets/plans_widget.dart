import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_plans_v2.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';

class PlansWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const PlansWidget({this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    String title1 = S.of(context).g_mining_key_6;
    String buttonTitle = S.of(context).g_mining_key_7;
    return GestureDetector(
      onTap: () {
        if(onTap!=null){
          onTap!();
        }else{
          Navigator.push(context,MaterialPageRoute(
            builder: (_) => const MiningPlansV2(),
          ));
        }
      },
      child: Container(
        height: ScreenUtil().setWidth(290),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xff87A1FF),
              Color(0xff3C85FF),
              Color(0xff1976F9),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: ScreenUtil().setWidth(48),
              bottom: ScreenUtil().setWidth(18),
              right: ScreenUtil().setWidth(26),
              child: Image.asset('assets/mining/miningv3_coin.png'),
            ),
            Positioned(
              top: ScreenUtil().setWidth(20),
              bottom: ScreenUtil().setWidth(18),
              left: ScreenUtil().setWidth(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(400),
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(4)),
                    child: Text(
                      title1,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainWhiteColor.name),
                        fontSize: ScreenUtil().setSp(30),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    //margin: EdgeInsets.only(top: scr.setWidth(16)),
                    height: ScreenUtil().setWidth(56),
                    child: buttonStyle3(
                      context, null,
                      buttonTitle,
                      AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainWhiteColor.name),
                      AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonTextColor3.name),
                      fontSize: ScreenUtil().setSp(22),
                      borderRadius: ScreenUtil().setWidth(56),
                      height: ScreenUtil().setWidth(56),
                      paddingV:ScreenUtil().setWidth(12.0),
                      paddingH: ScreenUtil().setWidth(32.0),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}