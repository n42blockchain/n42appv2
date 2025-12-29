import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class ChatBottomDialog extends StatelessWidget {
  final GestureTapCallback? photoCallBack;
  final GestureTapCallback? videoCallBack;
  final GestureTapCallback? fileCallBack;

  const ChatBottomDialog(
      {super.key, this.photoCallBack, this.videoCallBack, this.fileCallBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: photoCallBack,
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                      child: Row(
                        children: [
                          Image.asset("assets/chat/gallery.png",
                              width: ScreenUtil().setWidth(48), fit: BoxFit.cover),
                          SizedBox(
                            width: ScreenUtil().setWidth(42),
                          ),
                          Text(
                            S.of(context).g_chat_key_47,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(32)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemLineColor.name),
                  endIndent: 1,
                  indent: 1,
                ),
                GestureDetector(
                  onTap: videoCallBack,
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                      child: Row(
                        children: [
                          Image.asset("assets/chat/video.png",
                              width: ScreenUtil().setWidth(48), fit: BoxFit.cover),
                          SizedBox(
                            width: ScreenUtil().setWidth(42),
                          ),
                          Text(
                            S.of(context).g_chat_key_46,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(32)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Divider(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemLineColor.name),
                  endIndent: 1,
                  indent: 1,
                ),
                GestureDetector(
                  onTap: fileCallBack,
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                      child: Row(
                        children: [
                          Image.asset("assets/chat/document.png",
                              width: ScreenUtil().setWidth(48), fit: BoxFit.cover),
                          SizedBox(
                            width: ScreenUtil().setWidth(42),
                          ),
                          Text(
                            S.of(context).file,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(32)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(16),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.backGroundColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
              ),
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(34)),
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_key_79,
                style: TextStyle(
                    color: Color(0xff007AFF),
                    fontSize: ScreenUtil().setSp(38),
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}