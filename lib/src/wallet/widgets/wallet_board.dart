//看板类型
import 'dart:io';
import 'dart:ui';

import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/widgets/board_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletBoard extends StatefulWidget {
  final double accountPrice;
  final String? walletName;
  //swap
  final GestureTapCallback? swapTap;
  //send
  final GestureTapCallback? sendTap;
  //receive
  final GestureTapCallback? receiveTap;
  //payment code
  final GestureTapCallback? paymentCodeTap;
  //buy
  final GestureTapCallback? buyTap;
  //sell
  final GestureTapCallback? sellTap;

  const WalletBoard(
      {Key? key,
        required this.accountPrice,
        this.swapTap,
        this.walletName,
        this.receiveTap,
        this.sendTap,
        this.paymentCodeTap,
        this.buyTap,
        this.sellTap,
      })
      : super(key: key);

  @override
  State<WalletBoard> createState() => _WalletBoardState();
}

class _WalletBoardState extends State<WalletBoard> {
  final oCcy = NumberFormat("#,##0.0#", "en_US");

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              ScreenUtil().setWidth(30),
            ),
            width: double.infinity,
            child: Text(
              "\$${oCcy.format(widget.accountPrice)}",
              style: TextStyle(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(40)),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttonList(),
          ),
          SizedBox(height: ScreenUtil().setWidth(30),),
          Divider(
            height: 1,
            endIndent: 0,
            indent: 0,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          )
        ],
      ),
    );
    /*return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      //高斯模糊效果
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),//const Color(0xD0FCFFFF),//D0 = 透明度 5 %
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(width: 1,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name)),
          /*border: Border.all(color:const Color(0xffffffff),
            width: ScreenUtil().setWidth(1),
          ),
          //背景渐变
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x47D7E1FC),
                Color(0x70ABBCE9),
              ],
            ),*/
        ),
        padding: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: ScreenUtil().setWidth(40)),
                Expanded(
                  flex: 1,
                  child: Text(
                    "\$${oCcy.format(widget.accountPrice)}",
                    style: TextStyle(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(40)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: widget.type == BoardType.wallet
                      ? widget.walletOnTap
                      : null,
                  child: Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(30),top: ScreenUtil().setWidth(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.type == BoardType.wallet
                              ?"${S.of(context).g_key_6} ${widget.walletName}"
                              : S.of(context).g_key_wallet_k55,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(30)),
                        ),
                        if (widget.type == BoardType.wallet)
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
                height: ScreenUtil().setWidth(30)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: buttonList(),
            )
          ],
        ),
      ),
    );*/
  }
  List<Widget> buttonList(){
    return[
      sendWidget(),
      SizedBox(width: ScreenUtil().setWidth(30),),
      receiveWidget(),
      if(Platform.isAndroid)
        SizedBox(width: ScreenUtil().setWidth(30),),
      if(Platform.isAndroid)
        buyWidget(),
      if(Platform.isAndroid)
        SizedBox(width: ScreenUtil().setWidth(30),),
      if(Platform.isAndroid)
        sellWidget(),
      /*if(Application.userInfo !=null)
        SizedBox(width: ScreenUtil().setWidth(30),),
        if(Application.userInfo !=null)
        paymentCodeWidget(),*/
      //emptyWidget(),
      //if(Platform.isAndroid)
      //SizedBox(width: ScreenUtil().setWidth(30),),
      /*if(Platform.isAndroid)
          swapWidget(),
*/
    ];
  }
  //空按钮
  Widget emptyWidget(){
    return const Expanded(
      child:  SizedBox(),
    );
  }

  //Send
  Widget sendWidget(){
    return BoardItem(
      action: S.of(context).g_key_100,
      imagePath: 'assets/wallet/w_send.png',
      onTap: widget.sendTap,
    );
  }
  //Swap
  Widget swapWidget(){
    return BoardItem(
      action: S.of(context).g_swap_key_35,
      imagePath: 'assets/wallet/w_swap.png',
      onTap: widget.swapTap,
    );
  }
  //Receive
  Widget receiveWidget(){
    return BoardItem(
      action: S.of(context).g_key_33,
      imagePath: 'assets/wallet/w_receive.png',
      onTap: widget.receiveTap,
    );
  }
  //Payment code
  Widget paymentCodeWidget(){
    return BoardItem(
      action: "Payment code",//S.of(context).g_key_33,
      imagePath: 'assets/wallet/w_receive.png',
      onTap: widget.paymentCodeTap,
    );
  }
  Widget buyWidget(){
    return BoardItem(
      action: S.of(context).g_key_211,
      imagePath: 'assets/wallet/w_buy.png',
      onTap: widget.buyTap,
    );
  }
  Widget sellWidget(){
    return BoardItem(
      action: S.of(context).g_key_212,
      imagePath: 'assets/wallet/w_sell.png',
      onTap: widget.sellTap,
    );
  }
}