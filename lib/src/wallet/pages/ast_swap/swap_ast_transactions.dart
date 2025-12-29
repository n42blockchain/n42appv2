import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/swap_ast_api.dart';
import 'package:n42appv2/src/wallet/models/ast_swap/swap_ast_order_model.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_transaction_detail.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/base_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:date_format/date_format.dart' as dformat;

class SwapAstTransactions extends StatefulWidget {
  const SwapAstTransactions({super.key});

  @override
  State<SwapAstTransactions> createState() => _SwapAstTransactionsState();
}

class _SwapAstTransactionsState extends State<SwapAstTransactions> {
  SwapAstApi? _swapAstApi;
  SwapAstApi get swapAstApi{
    if(_swapAstApi==null){
      _swapAstApi=SwapAstApi();
    }
    return _swapAstApi!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_tran_1,
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: BaseList(
          buildItem: (BuildContext context, List<dynamic> results, int index) {
            SwapAstOrderModel orderModel=results[index];
            String stateStr="";
            Color stateColor;
            IconData iconData;
            if(orderModel.order_state==1){
              iconData=Icons.error;
              stateStr=S.of(context).g_swap_key_22;
              stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
            }else if(orderModel.order_state==2){
              iconData=Icons.error;
              stateStr=S.of(context).g_key_79;
              stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
            }else if(orderModel.order_state==0){
              int index=orderModel.pay_tx?.indexOf("0x")??-1;
              if(index==-1){
                stateStr=S.of(context).g_swap_key_23;
              }else{
                stateStr=S.of(context).g_swap_key_24;
              }
              iconData=Icons.info_rounded;
              stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name);
            }else if(orderModel.order_state==5){
              iconData=Icons.check_circle;
              stateStr=S.of(context).g_swap_key_18;
              stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name);
            }else {
              iconData=Icons.info_rounded;
              stateStr=S.of(context).g_swap_key_25;
              stateColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name);
            }
            String createStr=dformat.formatDate(
                DateTime.fromMillisecondsSinceEpoch(orderModel.created??0), [
              dformat.yyyy,
              '/',
              dformat.mm,
              '/',
              dformat.dd,
              ' ',
              dformat.am,
              ' ',
              dformat.hh,
              ':',
              dformat.nn
            ]);
            return InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SwapAstTransactionDetail(orderModel)));
                },
                child: Container(
                  height: ScreenUtil().setWidth(80),
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "USDT/${CoinType.N.name}",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(28),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "+${orderModel.order_num}",
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
                )
            );
          },
          getData: (int page, int pageSize) async {
            MessageModel rData=await swapAstApi.getNftOrAstOrderList(2, AppGlobals.userInfo?.uuid??"",page: page,page_size: pageSize);
            if(rData.error==false){
              return (rData.data as List).map((e) => SwapAstOrderModel.fromJson(e)).toList();
            }
            return Future.value([]);

          },
          firstRefresh: true,
          pageIndex: 1,
          pageSize: 15,
        ),
      ),
    );
  }
}
