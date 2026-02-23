import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_two.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class CreateOne extends ConsumerStatefulWidget {
  const CreateOne({super.key});

  @override
  ConsumerState<CreateOne> createState() => _CreateOneState();
}

class _CreateOneState extends ConsumerState<CreateOne> {
  bool checkOne=false;
  bool checkTow=false;
  bool checkThree=false;
  late WalletInfo wInfo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        title: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(width: ScreenUtil().setWidth(130.0),),
        ],
        leadingWidth: ScreenUtil().setWidth(130.0),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0),bottom: ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0),),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_key_wallet_c8,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        height: ScreenUtil().setWidth(450),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Image.asset("assets/home/splash_2.png",
                          width: ScreenUtil().setWidth(350),
                          height: ScreenUtil().setWidth(350),
                          fit: BoxFit.contain,
                        )
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60.0)),
                      child: Text(
                        S.of(context).g_key_wallet_c9,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(100),),
                    checkWidget(S.of(context).w_item_1,
                      checkOne,
                          (selected){
                        setState(() {
                          checkOne= selected!;
                        });
                      },
                    ),
                    checkWidget(S.of(context).w_item_2,
                      checkTow,
                          (selected){
                        setState(() {
                          checkTow= selected!;
                        });
                      },),
                    checkWidget(S.of(context).w_item_3,
                      checkThree,
                          (selected){
                        setState(() {
                          checkThree= selected!;
                        });
                      },
                    ),
                    SizedBox(height: ScreenUtil().setWidth(180.0),),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: ScreenUtil().setWidth(148.0),
                          padding: EdgeInsets.only(left:ScreenUtil().setWidth(30.0),
                            top: ScreenUtil().setWidth(30.0),
                            bottom: ScreenUtil().setWidth(30.0),
                          ),
                          width: double.infinity,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                          child: buttonStyle6(context,
                                  ()async{
                                if(checkOne && checkTow && checkThree){
                                  wInfo=WalletInfo(
                                    walletName: "",
                                    password: "",
                                    walletUuid: ref.read(wapBridgeProvider).userUUID,
                                  );
                                  await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateTwo(wInfo)));
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                }
                              },
                              S.of(context).g_key_wallet_c10,
                              AppThemeUtils.getColorByKey(context, (checkOne && checkTow && checkThree)?AppThemeKeys.mainButtonBgColor.name:AppThemeKeys.mainButtonBgColor3.name),
                              AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                              false
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(30.0),),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: ScreenUtil().setWidth(148.0),
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              right:ScreenUtil().setWidth(30.0),
                            top: ScreenUtil().setWidth(30.0),
                            bottom: ScreenUtil().setWidth(30.0),
                          ),
                          child: buttonStyle5(context,
                                ()async{
                              await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateFinish()));
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                            S.of(context).g_key_wallet_c21,
                            AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            borderColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          ),
                        ),

                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget checkWidget(String value,bool check,dynamic onTap){
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),),
      child: Row(
        children: [
          RoundCheckBox(
            isChecked: check,
            size: ScreenUtil().setWidth(50),
            onTap: (selected) {
              onTap(selected);
            },
            checkedWidget: Center(
              child: Icon(
                Icons.check,
                size: ScreenUtil().setWidth(32),
                color: Colors.white,
              ),
            ),
            checkedColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            animationDuration: const Duration(
              milliseconds: 50,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20.0),),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          )
        ],
      ),
    );
  }
}
