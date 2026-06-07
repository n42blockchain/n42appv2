import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/auth/data/models/device_login_info.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/widgets/tips_dialog_3.dart';

/// 新设备登录通知弹窗
/// 返回 true 表示用户选择"修改密码"，false/null 表示"知道了"
Future<bool?> deviceLoginDialog(
  BuildContext context,
  DeviceLoginInfo info,
) async {
  return await tipsDialog3(
    context,
    Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: AppColorTokens.of(context).bgSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: ScreenUtil().setWidth(30)),
                  // 设备图标
                  Icon(
                    Icons.phone_android,
                    size: ScreenUtil().setWidth(60),
                    color: AppColorTokens.of(context).brand,
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  // 标题
                  Text(
                    S.of(context).device_login_title,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: AppColorTokens.of(context).textItem,
                    ),
                  ),
                  // 消息内容
                  Container(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(20),
                      bottom: ScreenUtil().setWidth(40),
                      left: ScreenUtil().setWidth(30),
                      right: ScreenUtil().setWidth(30),
                    ),
                    child: Text(
                      S
                          .of(context)
                          .device_login_message(
                            info.displayName,
                            info.deviceOs,
                          ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColorTokens.of(context).textItem,
                        fontSize: ScreenUtil().setSp(28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          // 双按钮: "知道了" + "修改密码"
          SizedBox(
            height: ScreenUtil().setWidth(80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).device_login_dismiss,
                        style: TextStyle(
                          color: AppColorTokens.of(context).textSubtitle,
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(color: AppColorTokens.of(context).border, width: 1),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).device_login_change_password,
                        style: TextStyle(
                          color: AppColorTokens.of(context).brand,
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
