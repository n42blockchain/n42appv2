import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/select_wallet.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class FaceUserNotice extends StatefulWidget {
  const FaceUserNotice({super.key});

  @override
  State<FaceUserNotice> createState() => _FaceUserNoticeState();
}

class _FaceUserNoticeState extends State<FaceUserNotice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_face_match_key18,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
                ),
                padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(178)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40.0)),
                      child: Text(
                        S.of(context).g_face_match_key18,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(36),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                        ),
                      ),
                    ),
                    textWidget(S.of(context).g_face_match_key19),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    textWidget(S.of(context).g_face_match_key20),
                    textWidget(S.of(context).g_face_match_key21),
                    SizedBox(height: ScreenUtil().setWidth(50),),
                    textWidget(S.of(context).g_face_match_key22),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    textWidget(S.of(context).g_face_match_key23),
                    SizedBox(height: ScreenUtil().setWidth(50),),
                    textWidget(S.of(context).g_face_match_key24),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    textWidget(S.of(context).g_face_match_key25),
                    SizedBox(height: ScreenUtil().setWidth(50),),
                    textWidget(S.of(context).g_face_match_key26),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    textWidget(S.of(context).g_face_match_key27),
                    SizedBox(height: ScreenUtil().setWidth(50),),
                    textWidget(S.of(context).g_face_match_key28),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    textWidget(S.of(context).g_face_match_key29),
                    SizedBox(height: ScreenUtil().setWidth(50),),
                  ],
                ),
              ),
            ),),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: ScreenUtil().setWidth(148),
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                width: double.infinity,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                child: ButtonStyle2(
                  context, ()async{
                  final rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectWallet()));
                  if (!context.mounted) return;
                  Navigator.pop(context,rData);
                  },
                  S.of(context).g_face_match_key30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  textWidget(String value){
    return Text(
      value,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(28),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
      ),
    );
  }
}
