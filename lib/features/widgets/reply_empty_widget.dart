import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReplyEmptyWidget extends StatelessWidget {
  final String? userName;

  const ReplyEmptyWidget({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColorTokens.of(context).bgSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(4)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16)),
                    bottomLeft: Radius.circular(ScreenUtil().setWidth(4)),
                    bottomRight: Radius.circular(ScreenUtil().setWidth(16)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xff104B9E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScreenUtil().setWidth(4)),
                          bottomLeft: Radius.circular(ScreenUtil().setWidth(4)),
                        ),
                      ),
                      width: 4,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(14),
                          vertical: ScreenUtil().setWidth(14),
                        ),
                        child: _buildMessageView(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "[${S.of(context).g_chat_key_67}]",
          maxLines: 2,
          style: TextStyle(
            color: AppColorTokens.of(context).textPrimary,
            fontSize: ScreenUtil().setSp(28),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
