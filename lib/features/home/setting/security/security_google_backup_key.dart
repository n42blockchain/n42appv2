import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/home/setting/security/security_google_vedification.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class SecurityGoogleBackupKey extends StatefulWidget{
  const SecurityGoogleBackupKey({super.key});

  @override
  SecurityGoogleBackupKeyState createState()=>SecurityGoogleBackupKeyState();
}
class SecurityGoogleBackupKeyState extends State<SecurityGoogleBackupKey>{
  String googleAuthStr="";
  Load load=Load.finish;

  @override
  void initState() {
    super.initState();
    bindGoogleVerification();
  }

  // 将密钥按 4 字符一组分割，方便人工抄写核对
  String get _formattedSecret {
    if (googleAuthStr.isEmpty) return '';
    final buf = StringBuffer();
    for (int i = 0; i < googleAuthStr.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(googleAuthStr[i]);
    }
    return buf.toString();
  }

  // 标准 otpauth URI：issuer:account?secret=&issuer=
  String get _otpauthUri {
    final issuer = 'N42Wallet';
    final account = Uri.encodeComponent(AppGlobals.userInfo?.email ?? issuer);
    final secret = Uri.encodeComponent(googleAuthStr);
    return 'otpauth://totp/$issuer:$account?secret=$secret&issuer=$issuer';
  }

  //绑定谷歌验证
  Future<void> bindGoogleVerification()async{
    if(load==Load.loading)return;
    load=Load.loading;
    UserInfoApi userInfoAPI=UserInfoApi();
    MessageModel mm=await userInfoAPI.bindGoogle();
    if (!mounted) return;
    if(mm.error){
      ToastUtils.show(S.of(context).google_verification_message3);
    }else{
      googleAuthStr=mm.data;
    }
    load=Load.finish;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).google_verification_message17,
      ),
      body: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
              alignment: Alignment.center,
              child: Text(
                S.of(context).google_verification_message18,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            googleAuthStr==""?Container(
              alignment: Alignment.center,
              width: ScreenUtil().setWidth(500.0),
              height: ScreenUtil().setWidth(500.0),
              child: InkWell(
                onTap: (){
                  bindGoogleVerification();
                },
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                  width: ScreenUtil().setWidth(90.0),
                  height: ScreenUtil().setWidth(90.0),
                  child: Image.asset("assets/img/shuaxin.png",
                    color:AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),),
                ),
              ),
            ):
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(50.0)),
              width: ScreenUtil().setWidth(500.0),
              height: ScreenUtil().setWidth(500.0),
              child: QrImageView(
                backgroundColor: const Color(0xffffffff),
                data: _otpauthUri,
                version: QrVersions.min + 7,
              ),
            ),
            // 密钥显示区（4 字符分组 + 复制 + 分享按钮）
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30.0),
                vertical: ScreenUtil().setWidth(14.0),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).g_2fa_backup_hint,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(22.0),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(8.0)),
                  // 分组显示密钥
                  Text(
                    _formattedSecret,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(12.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 复制按钮
                      InkWell(
                        onTap: (){
                          ToastUtils.init(context);
                          Clipboard.setData(ClipboardData(text: googleAuthStr));
                          ToastUtils.showFtToast(child:successViewV1(S.of(context).copy),duration: 3);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(8.0),
                            horizontal: ScreenUtil().setWidth(20.0),
                          ),
                          child: Text(
                            S.of(context).g_key_119,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(8.0)),
                      // 分享按钮
                      InkWell(
                        onTap: () async {
                          if (googleAuthStr.isEmpty) return;
                          await SharePlus.instance.share(
                            ShareParams(
                              text: '${S.of(context).g_2fa_backup_share_text}\n\n$googleAuthStr',
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(8.0),
                            horizontal: ScreenUtil().setWidth(20.0),
                          ),
                          child: Text(
                            S.of(context).g_2fa_backup_share,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              height: ScreenUtil().setWidth(88.0),
              width: double.infinity,
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(6.0)),
              child: buttonStyle2(
                context,
                    (){
                  //跳转
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SecurityGoogleVedification()));
                },
                S.of(context).google_verification_message10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
