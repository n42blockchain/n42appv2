import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class ChatDeleteDialog extends StatelessWidget {
  final GestureTapCallback? deleteCallBack;
  const ChatDeleteDialog({super.key, this.deleteCallBack});

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
                  "${S.of(context).g_chat_key_48}?",
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
            alignment: Alignment.center,
            child: Column(
              children: [
                GestureDetector(
                  onTap: deleteCallBack,
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                        child: Row(
                          children: [
                            Text(
                              S.of(context).g_chat_key_49,
                              style: TextStyle(
                                  color: Color(0xffFE3B30), fontSize: ScreenUtil().setSp(32)),
                            ),
                          ],
                        )),
                  ),
                ),
                Divider(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemLineColor.name),
                  endIndent: 1,
                  indent: 1,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).g_key_79,
                            style:  TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name), fontSize: ScreenUtil().setSp(32)),
                          ),
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