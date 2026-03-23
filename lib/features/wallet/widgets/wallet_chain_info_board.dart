import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletChainInfoBoard extends StatelessWidget {
  final String? address;//地址
  final String? coinType; // 链类型（用于 ENS 解析）
  final String? balanceStr;//token 余额
  final String? balanceDollarStr;//美元余额
  final String? marketValueStr;//市值
  final String? lockAmountStr;//锁定额度
  final GestureTapCallback? xmlLockInfoTap;// xml(ripple)锁定额度详情点击事件
  final GestureTapCallback? sendTap;//交易点击
  final GestureTapCallback? receiveTap;//收款码点击
  final GestureTapCallback? browserTap;//浏览器点击
  const WalletChainInfoBoard({required this.address,
    this.coinType,
    required this.balanceStr,
    required this.balanceDollarStr,
    required this.marketValueStr,
    required this.lockAmountStr,
    required this.sendTap,
    required this.receiveTap,
    required this.browserTap,
    required this.xmlLockInfoTap,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0),),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EnsAddressDisplay(
            address: address ?? "",
            coinType: coinType ?? 'ETH',
            style: EnsDisplayStyle.compact,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(26.0),
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
                SizedBox(
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
              Expanded(child: buttonWidgetV2(context,S.of(context).g_key_48,sendTap)),
              SizedBox(width: ScreenUtil().setWidth(20),),
              Expanded(child: buttonWidgetV2(context,S.of(context).g_key_33,receiveTap)),
              SizedBox(width: ScreenUtil().setWidth(20),),
              Expanded(child: buttonWidgetV2(context,S.of(context).g_key_196,browserTap)),
            ],
          ),
        ],
      ),
    );

  }

  Widget buttonWidgetV2(BuildContext context,String lable,GestureTapCallback? tap){
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            lable,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
        ),
      ),
    );
  }
}
