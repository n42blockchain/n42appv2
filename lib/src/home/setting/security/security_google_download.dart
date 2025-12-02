import 'dart:io';

import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/home/setting/security/security_google_instructions.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecurityGoogleDownload extends StatefulWidget {
  @override
  _SecurityGoogleDownloadState createState() => _SecurityGoogleDownloadState();
}

class _SecurityGoogleDownloadState extends State<SecurityGoogleDownload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:S.of(context).google_verification_message8,
      ),
      body: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: ScreenUtil().setWidth(120.0),
                    width: ScreenUtil().setWidth(120.0),
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
                    child: Image.asset(
                      'assets/home/setting/scurity/item_google.png',
                    ),
                  ),
                  Text(
                    S.of(context).google_verification_message9,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                //跳转，下载
                String googlePath =
                    "https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2";
                if (Platform.isIOS) {
                  googlePath =
                  "https://apps.apple.com/cn/app/google-authenticator/id388497605";
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BrowserPage(googlePath,
                          //S.of(context).google_verification_message11
                        )));
              },
              child: Container(
                height: ScreenUtil().setWidth(88.0),
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16))),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/home/setting/scurity/item_google.png',
                      width: ScreenUtil().setWidth(40),
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(24),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        S.of(context).google_verification_message11,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setWidth(30.0),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      size: ScreenUtil().setWidth(40.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Container(
              height: ScreenUtil().setWidth(88.0),
              width: double.infinity,
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(6.0)),
              child: ButtonStyle2(context, () {
                //跳转
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SecurityGoogleInstructions()));
              }, S.of(context).google_verification_message10,),
            ),
          ],
        ),
      ),
    );
  }
}