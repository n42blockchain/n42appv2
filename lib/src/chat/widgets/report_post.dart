//提交举报内容
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/comm_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class ReportPost extends StatefulWidget {
  final String name;
  final String messageId;
  final VoidCallback? onPressed;
  final TextEditingController controller;

  const ReportPost(
      {super.key,
        required this.name,
        required this.messageId,
        this.onPressed,
        required this.controller});

  @override
  State<ReportPost> createState() => _ReportPostState();
}

class _ReportPostState extends State<ReportPost> {
  bool canClick = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final textStr = widget.controller.text.trim();
      final flag = textStr.isNotEmpty;
      if (canClick != flag) {
        canClick = flag;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets, //边距（必要）
      duration: const Duration(milliseconds: 100), //时常 （必要）
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(48),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "${S.of(context).g_chat_key_40} ${widget.name}?",
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
                  icon: Icon(
                    Icons.close,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ))
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(56),
          ),
          Text(
            S.of(context).g_chat_key_54,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(32)),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(16),
          ),
          Container(
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
            padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
            alignment: Alignment.center,
            child: CommInput(
              type: InputFieldType.account,
              hintText: "${S.of(context).g_chat_key_55}...",
              controller: widget.controller,
              maxLines: 5,
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(16),
          ),
          Text(
            S.of(context).g_chat_key_56,
            style: TextStyle(
                color:
                AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
                fontSize: ScreenUtil().setSp(28)),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(140),
          ),
          SizedBox(
            width: double.infinity,
            height: ScreenUtil().setWidth(88),
            child: buttonStyle2(context, canClick ? widget.onPressed : null, S.of(context).g_key_48),
          ),
        ],
      ),
    );
  }
}