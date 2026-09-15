import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  final String? taskId;
  final String? astValue;
  final String? time;
  final String? status;
  const TaskItem({
    this.taskId,
    this.astValue,
    this.time,
    this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.bodySm.copyWith(
      color: AppColorTokens.of(context).textPrimary,
    );
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space6),
      margin: EdgeInsets.symmetric(vertical: AppSpacing.space2),
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
                Text(time ?? "", textAlign: TextAlign.center, style: textStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
