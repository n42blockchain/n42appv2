import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/create_wallet/create/create_three.dart';
import 'package:n42appv2/src/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class CreateTwo extends StatefulWidget {
  final WalletInfo wInfo;
  const CreateTwo(this.wInfo,{super.key});

  @override
  State<CreateTwo> createState() => _CreateTwoState();
}

class _CreateTwoState extends State<CreateTwo> {
  Trustdart? trustdart;
  Trustdart get _trustdart{
    trustdart ??= Trustdart();
    return trustdart!;
  }
  bool showMnemonic=false;
  /// 助记词
  late String mnemonicWords;
  var mnemonicWordsList = [];
  int mnemonicWordsCount = 12; //助记词个数
  Future<void> resetMnemonicWordsCount({int value = 12}) async {
    mnemonicWordsCount = value;
    mnemonicWords = await _trustdart.generateMnemonic(
        length: (value * 10 + value / 3 * 2).toInt());
    if (mounted) {
      setState(() {
        mnemonicWordsList = mnemonicWords.split(" ");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //创建钱包流程埋点
    //AmplitudeUtils.screenViewedSeedPhraseBackup();

    resetMnemonicWordsCount();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    /*Container(
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
                    ),*/
                    Container(
                      margin: EdgeInsets.only(
                        top: ScreenUtil().setWidth(30),
                        bottom: ScreenUtil().setWidth(30),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c39,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        bottom: ScreenUtil().setWidth(60),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c40,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    /*Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60.0),vertical: ScreenUtil().setWidth(50.0)),
                      child: Text(
                        S.of(context).g_key_wallet_c11,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),*/
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: ScreenUtil().setWidth(164.0),
                            height: ScreenUtil().setWidth(60.0),
                            child: buttonStyle5(
                              context,
                                  (){
                                resetMnemonicWordsCount(value: 12);
                              },
                              "12",
                              AppThemeUtils.getColorByKey(context, mnemonicWordsCount==12?AppThemeKeys.mainButtonBgColor.name:AppThemeKeys.itemBgColor8.name),
                              AppThemeUtils.getColorByKey(context, mnemonicWordsCount==12?AppThemeKeys.mainButtonTextColor.name:AppThemeKeys.mainTextColor4.name),
                              circular:ScreenUtil().setWidth(24.0),
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(40.0),),
                          SizedBox(
                            width: ScreenUtil().setWidth(164.0),
                            height: ScreenUtil().setWidth(60.0),
                            child: buttonStyle5(
                              context,
                                  (){
                                resetMnemonicWordsCount(value: 24);
                              },
                              "24",
                              AppThemeUtils.getColorByKey(context, mnemonicWordsCount==24?AppThemeKeys.mainButtonBgColor.name:AppThemeKeys.itemBgColor8.name),
                              AppThemeUtils.getColorByKey(context, mnemonicWordsCount==24?AppThemeKeys.mainButtonTextColor.name:AppThemeKeys.mainTextColor4.name),
                              circular:ScreenUtil().setWidth(24.0),
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(50.0),),
                    _buildGridView(),
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(40)),
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            size: ScreenUtil().setWidth(40),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(10),),
                          Expanded(
                            flex: 1,
                            child: Text(
                              S.of(context).g_key_wallet_c41,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            size: ScreenUtil().setWidth(40),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(10),),
                          Expanded(
                            flex: 1,
                            child: Text(
                              S.of(context).g_key_wallet_c42,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: ScreenUtil().setWidth(148.0),),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(248.0),),
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
                  Container(
                    height: ScreenUtil().setWidth(148.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    width: double.infinity,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: buttonStyle6(
                      context,
                          (){
                            if(showMnemonic){
                              widget.wInfo.mnemonic=mnemonicWords;
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateThree(widget.wInfo)));
                            }
                            },
                        S.of(context).g_key_wallet_c43,
                      AppThemeUtils.getColorByKey(
                        context,
                        showMnemonic?
                        AppThemeKeys.mainButtonBgColor.name:
                        AppThemeKeys.mainButtonBgColor3.name,
                      ),
                      AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainButtonTextColor.name
                      ),
                      false,
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setWidth(100.0),
                    padding: EdgeInsets.only(bottom:ScreenUtil().setWidth(30.0)),
                    width: double.infinity,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: TextButton(
                      onPressed: (){
                        showSkipWidget();
                      },
                      child: Text(
                        S.of(context).g_key_wallet_c18,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          decoration: TextDecoration.underline,
                          decorationColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        ),
                      ),
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
  Widget _buildGridView() {
    if(showMnemonic) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        itemCount: mnemonicWordsList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
            crossAxisCount: 3,
            //纵轴间距
            mainAxisSpacing: ScreenUtil().setWidth(20.0),
            //横轴间距
            crossAxisSpacing: ScreenUtil().setWidth(20.0),
            //子组件宽高长度比例
            childAspectRatio: 2.4),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
            //height: scr.setWidth(80.0),
            //width: scr.setWidth(192.0),
            child: showMnemonic?
            Center(
              child: Text(
                mnemonicWordsList[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
            ):
            SizedBox(),
          );
        },
      );
    }
    return InkWell(
      onTap: (){
        setState(() {
          showMnemonic=true;
        });
      },
      child: Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(400),
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: ScreenUtil().setWidth(80.0),
              height: ScreenUtil().setWidth(80.0),
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
              child: Icon(
                Icons.visibility_off_outlined,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                size: ScreenUtil().setWidth(80.0),
              ),
            ),
            Text(
              S.of(context).g_key_wallet_c44,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
            ),
            Text(
              S.of(context).g_key_wallet_c45,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  /*
  _buildGridView1(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      itemCount: mnemonicWordsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //横轴元素个数
          crossAxisCount: 3,
          //纵轴间距
          mainAxisSpacing: ScreenUtil().setWidth(20.0),
          //横轴间距
          crossAxisSpacing: ScreenUtil().setWidth(20.0),
          //子组件宽高长度比例
          childAspectRatio: 2.4),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
          //height: scr.setWidth(80.0),
          //width: scr.setWidth(192.0),
          child: Center(
            child: Text(
              mnemonicWordsList[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(32.0),
              ),
            ),
          ),
        );
      },
    );
  }
  */
  Future<void> showSkipWidget()async{
    Widget child=Center(
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        ),
        constraints: BoxConstraints(
          minHeight: ScreenUtil().setWidth(472.0),
          maxHeight: ScreenUtil().setWidth(550.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${S.of(context).g_key_wallet_c18}?",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              height: ScreenUtil().setWidth(200.0),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_key_wallet_c19,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(80.0),
              child: buttonStyle2(context, (){
                Navigator.pop(context,true);
              }, S.of(context).g_mining_key62,),
            ),
            SizedBox(height: ScreenUtil().setWidth(30.0),),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(80.0),
              child: buttonStyle5(context, (){
                Navigator.pop(context,false);
              }, S.of(context).g_key_79,
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
    final flag=await tipsDialog3(context,child);
    if (!mounted) return;
    if (flag != null && flag) {
      widget.wInfo.mnemonic=mnemonicWords;
      Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateFinish(wInfo:widget.wInfo)));
    }
  }
}
