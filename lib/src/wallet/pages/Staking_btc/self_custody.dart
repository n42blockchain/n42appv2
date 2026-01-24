import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/widgets/login_title.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelfCustody extends StatefulWidget {
  final CoinModel coinModel;
  const SelfCustody(this.coinModel,{super.key});

  @override
  State<SelfCustody> createState() => _SelfCustodyState();
}

class _SelfCustodyState extends State<SelfCustody> {
  Load load=Load.finish;
  TextEditingController valueEditingController=TextEditingController();
  TextEditingController lockupEditingController=TextEditingController();
  FocusNode valueNode=FocusNode();
  FocusNode lockupNode=FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    valueEditingController.dispose();
    lockupEditingController.dispose();
    valueNode.dispose();
    lockupNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(
        text: "Self-Custody",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: ScreenUtil().setWidth(50),
                          width: ScreenUtil().setWidth(50),
                          margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                          child: ImageNetWork(imageUrl:
                          widget.coinModel.coin['icon'] ?? "",
                            placeholder: "assets/img/list_default.png",
                          ),
                        ),
                        Text(
                          widget.coinModel.coin['name']??"",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child:Container(
                            margin: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${widget.coinModel.balanceString()}${widget.coinModel.coin['unit']}',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    textFieldStyle2(
                      context,
                      controller: valueEditingController,
                      focusNode: valueNode,
                      hintText: "Enter an amount >= 0.001",
                      height: ScreenUtil().setWidth(88),
                      bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                      keyboardType:TextInputType.numberWithOptions(decimal: true),
                      onEditingComplete: (){
                        FocusScope.of(context).requestFocus(valueNode);
                      },
                      onChanged: (value){

                      },
                    ),
                    SizedBox(height: ScreenUtil().setWidth(30),),
                    LoginTitle(title: "Lockup",color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    textFieldStyle2(
                      context,
                      controller: valueEditingController,
                      focusNode: valueNode,
                      hintText: "Enter lockup time >= 0.125 days",
                      height: ScreenUtil().setWidth(88),
                      bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                      keyboardType:TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: (){
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      onChanged: (value){

                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    height: ScreenUtil().setWidth(148),
                    child: buttonStyle6(
                      context,
                      (){

                      },
                      "Self-Custody & Mint Your proof",
                      AppThemeUtils.getColorByKey(context, load==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name),
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                      load==Load.loading,
                    ),
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
