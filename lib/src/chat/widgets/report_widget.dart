
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class ReportWidget extends StatelessWidget {
  final String name;
  final GestureTapCallback? reportCallBack;
  final GestureTapCallback? reportAndBlockCallBack;

  const ReportWidget(
      {super.key,
        required this.name,
        this.reportCallBack,
        this.reportAndBlockCallBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(48),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "${S.of(context).g_chat_key_40} $name?",
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(36)),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close))
          ],
        ),
        SizedBox(
          height: ScreenUtil().setWidth(56),
        ),
        Container(
          decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
          alignment: Alignment.center,
          child: Text(
            S.of(context).g_chat_key_45,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28)),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(18),
        ),
        Container(
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24))),
            alignment: Alignment.center,
            child: Column(
              children: [
                if(reportAndBlockCallBack != null)
                  GestureDetector(
                    onTap: reportAndBlockCallBack,
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).g_chat_key_44,
                              style: TextStyle(
                                  color: Color(0xffFE3B30), fontSize: ScreenUtil().setSp(32)),
                            ),
                            Image.asset("assets/chat/front_hand.png",
                                width: ScreenUtil().setWidth(48), fit: BoxFit.cover)
                          ],
                        ),
                      ),
                    ),
                  ),
                if(reportAndBlockCallBack != null)
                  Divider(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemLineColor.name),
                    endIndent: 1,
                    indent: 1,
                  ),
                GestureDetector(
                  onTap: reportCallBack,
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).g_chat_key_40,
                            style: TextStyle(
                                color: Color(0xffFE3B30), fontSize: ScreenUtil().setSp(32)),
                          ),
                          Image.asset("assets/chat/report.png",
                              width: ScreenUtil().setWidth(48), fit: BoxFit.cover)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}