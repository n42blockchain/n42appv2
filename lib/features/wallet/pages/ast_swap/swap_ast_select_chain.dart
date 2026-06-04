import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapAstSelectChain extends StatefulWidget {
  final List<SwapAstModel> swapAsts;
  const SwapAstSelectChain(this.swapAsts,{super.key});

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

  Widget tokenListWidget() {
    return ListView.separated(
      padding: AppSpacing.pageHorizontal,
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
                  margin: EdgeInsets.only(right: AppSpacing.space2),
                  child: ImageNetWork(imageUrl:
                      sm.uri??"",
                    placeholder: "assets/img/list_default.png",
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    sm.payCoin??"",
                    style: AppTypography.body.copyWith(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.space2,),
                Text(
                  "${sm.payChain}",
                  style: AppTypography.body.copyWith(
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
