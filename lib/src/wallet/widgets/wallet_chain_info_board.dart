import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletChainInfoBoard extends StatelessWidget {
  String? address;//地址
  String? balanceStr;//token 余额
  String? balanceDollarStr;//美元余额
  String? marketValueStr;//市值
  String? lockAmountStr;//锁定额度
  GestureTapCallback? xmlLockInfoTap;// xml(ripple)锁定额度详情点击事件
  GestureTapCallback? sendTap;//交易点击
  GestureTapCallback? receiveTap;//收款码点击
  GestureTapCallback? browserTap;//浏览器点击
  GestureTapCallback? tokenAddTap;//添加代币按钮
  GestureTapCallback? swapAddTap;//添加兑换按钮
  GestureTapCallback? sellAddTap;//卖按钮
  WalletChainInfoBoard({@required this.address,
    @required this.balanceStr,
    @required this.balanceDollarStr,
    @required this.marketValueStr,
    @required this.lockAmountStr,
    @required this.sendTap,
    @required this.receiveTap,
    @required this.browserTap,
    @required this.tokenAddTap,
    @required this.swapAddTap,
    @required this.sellAddTap,
    @required this.xmlLockInfoTap,
    super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0),),
      //padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),horizontal: ScreenUtil().setWidth(30.0),),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: Text(
                address??"",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),),
              InkWell(
                onTap: (){
                  ToastUtils.init(context);
                  Clipboard.setData(ClipboardData(text: address ?? ""));
                  ToastUtils.showFtToast(child:SuccessViewV1(S.of(context).copy),duration: 3);
                },
                child: Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                  width: ScreenUtil().setWidth(60.0),
                  height: ScreenUtil().setWidth(60.0),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                  child: Icon(
                    Icons.copy,
                    size: ScreenUtil().setWidth(36.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Text(
            balanceStr??"",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(40.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
            maxLines: 2,
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
            child: Text(
              marketValueStr??"",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 2,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0),),
            child: Text(
              balanceDollarStr??"",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 2,
            ),
          ),
          if(xmlLockInfoTap !=null)
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: ScreenUtil().setWidth(40),
                  child: Text(
                    "${S.of(context).g_key_xml_0}: ${lockAmountStr??""} ",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                ),
                InkWell(
                  onTap: xmlLockInfoTap,
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(30.0)),
                    width: ScreenUtil().setWidth(40.0),
                    height: ScreenUtil().setWidth(40.0),
                    child: Icon(
                      Icons.info_outline,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      size: ScreenUtil().setWidth(40.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(40.0),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //buttonWidget(context,'assets/wallet/w_send.png',S.of(context).g_key_48,sendTap),
              Expanded(child: buttonWidgetV2(context,S.of(context).g_key_48,sendTap)),
              SizedBox(width: ScreenUtil().setWidth(20),),
              //buttonWidget(context,'assets/wallet/w_receive.png',S.of(context).g_key_33,receiveTap),
              Expanded(child: buttonWidgetV2(context,S.of(context).g_key_33,receiveTap)),
              SizedBox(width: ScreenUtil().setWidth(20),),
              //buttonWidget(context,'assets/wallet/mainnet.png',S.of(context).g_key_196,browserTap),
              Expanded(child: buttonWidgetV2(context,S.of(context).g_key_196,browserTap)),
            ],
          ),
          /*
          SizedBox(height: ScreenUtil().setWidth(30),),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buttonWidgetV2(context,S.of(context).g_key_211,swapAddTap),
              SizedBox(width: ScreenUtil().setWidth(30),),
              buttonWidgetV2(context,S.of(context).g_key_212,sellAddTap),
              if(tokenAddTap !=null)
                SizedBox(width: ScreenUtil().setWidth(30),),
              if(tokenAddTap !=null)
                buttonWidgetV2(context,S.of(context).g_token_m_key_11,tokenAddTap),
              //buttonWidget(context,'assets/wallet/addToken.png',S.of(context).g_token_m_key_11,tokenAddTap),
            ],
          ),
          */
        ],
      ),
    );

  }
  /*
  buttonWidget(context,String img,String lable,GestureTapCallback? tap){
    return InkWell(
      onTap: tap,
      child: Container(
        width: ScreenUtil().setWidth(150.0),
        child: Column(
          children: [
            Container(
              height: ScreenUtil().setWidth(64.0),
              width: ScreenUtil().setWidth(64.0),
              padding: EdgeInsets.all(6.0),
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16.0)),
              decoration: BoxDecoration(
                  color: Color(0xff4791FA).withOpacity(0.15),
                  borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10.0)))
              ),
              child: Image.asset(
                img,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            Text(
              lable,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
  */
  buttonWidgetV2(context,String lable,GestureTapCallback? tap){
    return InkWell(
      onTap: tap,
      child: Container(
        height: ScreenUtil().setWidth(80),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16),),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30),),
        ),
        child: Text(
          lable,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
            fontSize: ScreenUtil().setSp(26),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
