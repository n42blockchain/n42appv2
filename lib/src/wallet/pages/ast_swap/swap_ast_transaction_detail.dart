import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/src/wallet/models/ast_swap/swap_ast_order_model.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart' as dformat;
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapAstTransactionDetail extends StatefulWidget {
  final SwapAstOrderModel orderModel;
  const SwapAstTransactionDetail(this.orderModel,{super.key});

  @override
  State<SwapAstTransactionDetail> createState() => _SwapAstTransactionDetailState();
}

class _SwapAstTransactionDetailState extends State<SwapAstTransactionDetail> {
  bool state=true;
  String stateStr="";
  Color? stateColor;
  IconData? iconData;
  String createStr="";
  late SwapAstOrderModel _orderModel;
  @override
  void initState() {
    _orderModel = widget.orderModel;  // Bug 1: 修复自赋值，改为从 widget 初始化
    // Bug 2: 在 initState 中固定时间，避免每次 rebuild 取 DateTime.now()
    final int tsMs = (_orderModel.created ?? 0) * 1000;
    createStr = dformat.formatDate(
      DateTime.fromMillisecondsSinceEpoch(tsMs),
      [dformat.yyyy, '/', dformat.mm, '/', dformat.dd, ' ', dformat.am, ' ', dformat.hh, ':', dformat.nn],
    );
    getOrderDetail();
    super.initState();
  }
  Future<void> getOrderDetail() async {
    SwapAstApi swapAstApi=SwapAstApi();
    MessageModel rData=await swapAstApi.getNftOrAstDetail(_orderModel.id??0);
    if(rData.error==false){
      _orderModel=SwapAstOrderModel.fromJson(rData.data);
      setState(() {
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_tran_4,
      ),
      body: bodyWidget(),
    );
  }
  Widget bodyWidget() {
    if(_orderModel.orderState==1){
      iconData=Icons.error;
      stateStr=S.of(context).g_swap_key_22;
      stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
      return successWidget();
    }else if(_orderModel.orderState==2){
      iconData=Icons.error;
      stateStr=S.of(context).g_key_79;
      stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
      return successWidget();
    }else if(_orderModel.orderState==0){
      int index=_orderModel.payTx?.indexOf("0x")??-1;
      if(index==-1){
        stateStr=S.of(context).g_swap_key_23;
      }else{
        stateStr=S.of(context).g_swap_key_24;
      }
      iconData=Icons.info_rounded;
      stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name);
      return processingWidget();
    }else if(_orderModel.orderState==5){
      iconData=Icons.check_circle;
      stateStr=S.of(context).g_swap_key_18;
      stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name);
      return successWidget();
    }else {
      iconData=Icons.info_rounded;
      stateStr=S.of(context).g_swap_key_25;
      stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name);
      return processingWidget();
    }
  }
  Widget processingWidget() {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30),),
      child: Column(
        children: [
          Container(
            height: ScreenUtil().setWidth(80),
            width: double.infinity,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${_orderModel.payCoin ?? 'USDT'}/${_orderModel.type==1?"NFT":CoinType.N.name}",
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(28),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "+${_orderModel.orderNum}",
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(28),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      createStr,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(24),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: ScreenUtil().setWidth(30),
                            width: ScreenUtil().setWidth(30),
                            margin: EdgeInsets.only(right: ScreenUtil().setWidth(4)),
                            child: Icon(
                              iconData,
                              color: stateColor,
                              size: ScreenUtil().setWidth(30),
                              fill: 0,
                            ),
                          ),
                          Text(
                            stateStr,
                            style: TextStyle(
                              color: stateColor,
                              fontSize: ScreenUtil().setSp(24),
                            ),
                            textAlign: TextAlign.right,
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
            height: ScreenUtil().setWidth(300),
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(40),
                  child: Column(
                    children: [
                      SizedBox(
                        height: ScreenUtil().setWidth(40),
                        width: ScreenUtil().setWidth(40),
                        child: Icon(
                          (_orderModel.orderState??0)>=3?Icons.check_circle:Icons.radio_button_unchecked,
                          color: AppThemeUtils.getColorByKey(context, (_orderModel.orderState??0)>=3?AppThemeKeys.rightTextColor.name:AppThemeKeys.dividerColor.name),
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: VerticalDivider(
                          width: ScreenUtil().setWidth(40),
                          indent: 0,
                          endIndent: 0,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(40),
                        width: ScreenUtil().setWidth(40),
                        child: Icon(
                          (_orderModel.orderState==3 || _orderModel.orderState==4)?Icons.check_circle:Icons.radio_button_unchecked,
                          color: AppThemeUtils.getColorByKey(context, (_orderModel.orderState==3 || _orderModel.orderState==4)?AppThemeKeys.rightTextColor.name:AppThemeKeys.rightTextColor.name),
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: VerticalDivider(
                          width: ScreenUtil().setWidth(40),
                          indent: 0,
                          endIndent: 0,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setWidth(40),
                        width: ScreenUtil().setWidth(40),
                        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                        child: Icon(
                          _orderModel.orderState==5?Icons.check_circle:Icons.radio_button_unchecked,
                          color: AppThemeUtils.getColorByKey(context, _orderModel.orderState==5?AppThemeKeys.rightTextColor.name:AppThemeKeys.dividerColor.name),
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(30),),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pRowWidget(_orderModel.payCoin ?? 'USDT',),
                      SizedBox(height: ScreenUtil().setWidth(60),),
                      pRowWidget("Swap"),
                      SizedBox(height: ScreenUtil().setWidth(60),),
                      pRowWidget(S.of(context).g_key_191,),
                      //SizedBox(height: scr.setWidth(10),),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget pRowWidget(String title) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ],
      ),
    );
  }
  Widget successWidget() {
    return Column(
      children: [
        Container(
          height: ScreenUtil().setWidth(300),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10),),
                child: RichText(
                  text: TextSpan(
                    text: '${_orderModel.orderPrice}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(40),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                    children: [
                      TextSpan(
                        text: CoinType.N.name,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                    ],
                  ),

                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: ScreenUtil().setWidth(40),
                      width: ScreenUtil().setWidth(40),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                      child: Icon(
                        iconData,
                        color: stateColor,
                        size: ScreenUtil().setWidth(40),
                      ),
                    ),
                    Text(
                      stateStr,
                      style: TextStyle(
                        color: stateColor,
                        fontSize: ScreenUtil().setSp(28),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10),horizontal: ScreenUtil().setWidth(200)),
                child: Text(
                  S.of(context).g_key_tran_6,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(24),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: ScreenUtil().setWidth(60),
          indent: 0,
          endIndent: 0,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
          child: Column(
            children: [
              rowWidget(S.of(context).g_key_tran_7,"${_orderModel.payNum} ${_orderModel.payCoin ?? 'USDT'}"),
              rowWidget(S.of(context).g_key_tran_8,"${_orderModel.orderNum} ${CoinType.N.name}"),
              rowWidget(S.of(context).g_key_wallet_k25,createStr),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
      ],
    );
  }
  Widget rowWidget(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(10),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(30),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
