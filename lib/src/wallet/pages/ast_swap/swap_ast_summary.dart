import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapAstSummary extends StatefulWidget {
  final String send;
  final String receive;
  final String balance;
  final String date;
  const SwapAstSummary(this.send,this.receive,this.balance,this.date ,{super.key});

  @override
  State<SwapAstSummary> createState() => _SwapAstSummaryState();
}

class _SwapAstSummaryState extends State<SwapAstSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_swap_key_28,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), ScreenUtil().setWidth(30), ScreenUtil().setWidth(30), 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal:ScreenUtil().setWidth(30), vertical: ScreenUtil().setHeight(26)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(60)),
                    child: Row(
                      children: [
                        Text(
                          S.of(context).g_key_48,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(30),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${widget.send} USDT",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(60)),
                    child: Row(
                      children: [
                        Text(
                          S.of(context).g_key_33,
                          style: TextStyle(
                            color:AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(30),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${widget.receive} ${CoinType.N.name}",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(60)),
                    child: Row(
                      children: [
                        Text(
                          S.of(context).g_swap_key_29,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(30),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${widget.balance} ${CoinType.N.name}",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        S.of(context).g_swap_key_30,
                        style: TextStyle(
                          color:AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              widget.date,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                                fontSize: ScreenUtil().setSp(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(102),
            ),
            Text(
              S.of(context).g_swap_key_31(CoinType.N.name),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor3.name),
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(20),
            ),
            Text(
              S.of(context).g_swap_key_32,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor3.name),
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            Container(
              height: ScreenUtil().setWidth(88),
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(36)),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonStyle5(
                      context,
                          ()async{
                        Navigator.pop(context);
                      },
                      S.of(context).g_key_79,
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor3.name),
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(30),
                  ),
                  Expanded(
                    child: ButtonStyle2(
                      context,
                          ()async{
                        bool r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletSecurityVerification()));
                        if (!context.mounted) return;
                        if(r){
                          Navigator.pop(context,true);
                        }
                      }, S.of(context).g_key_78,),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
