import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskItem extends StatelessWidget {
  final String? taskId;
  final String? astValue;
  final String? time;
  final String? status;
  const TaskItem({this.taskId, this.astValue, this.time, this.status,super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        fontSize: ScreenUtil().setSp(26));
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  taskId ?? "",
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              astValue ?? "",
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time ?? "",
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
