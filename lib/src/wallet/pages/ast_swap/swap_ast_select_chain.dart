import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapAstSelectChain extends StatefulWidget {
  List<SwapAstModel> swapAsts;
  SwapAstSelectChain(this.swapAsts,{super.key});

  @override
  State<SwapAstSelectChain> createState() => _SwapAstSelectChainState();
}

class _SwapAstSelectChainState extends State<SwapAstSelectChain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_9,
      ),
      body: SafeArea(
        child: tokenListWidget(),
      ),
    );
  }

  tokenListWidget(){
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      itemBuilder: (context,int index){
        SwapAstModel sm=widget.swapAsts[index];
        return InkWell(
          onTap: (){
            Navigator.pop(context,sm);
          },
          child: Container(
            height: ScreenUtil().setWidth(126),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  height: ScreenUtil().setWidth(52),
                  width: ScreenUtil().setWidth(52),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                  child: ImageNetWork(imageUrl:
                      sm.uri??"",
                    placeholder: "assets/img/list_default.png",
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    sm.pay_coin??"",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10),),
                Text(
                  "${sm.pay_chain}",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context,int index){
        return Divider(
          height: ScreenUtil().setWidth(1),
          indent: 0,
          endIndent: 0,
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        );
      },
      itemCount: widget.swapAsts.length,
    );
  }
}
