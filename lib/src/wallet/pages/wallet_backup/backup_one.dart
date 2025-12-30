import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_two.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class BackupOne extends StatefulWidget {
  WalletInfo walletInfo;
  int walletIndex;
  BackupOne(this.walletInfo,this.walletIndex,{super.key});

  @override
  State<BackupOne> createState() => _BackupOneState();
}

class _BackupOneState extends State<BackupOne> {
  bool showMnemonic=false;
  List<String> mnemonicWordsList = [];
  @override
  void initState() {
    // TODO: implement initState
    mnemonicWordsList=(widget.walletInfo.mnemonic??"").split(" ");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_c38,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(148.0),),
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
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    height: ScreenUtil().setWidth(148),
                    child: ButtonStyle6(
                      context,
                          (){
                        if(showMnemonic){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BackupTwo(widget.walletInfo,widget.walletIndex)));
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  _buildGridView() {
    if(showMnemonic)
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
    return InkWell(
      onTap: (){
        setState(() {
          showMnemonic=true;
        });
      },
      child: Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(400),
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
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
}
