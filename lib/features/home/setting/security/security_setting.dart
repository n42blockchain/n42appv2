import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/home/setting/security/gesture_password_setting.dart';
import 'package:n42_wallet/features/home/setting/security/lock_screen_resetpassword.dart';
import 'package:n42_wallet/features/home/setting/security/security_edit.dart';
import 'package:n42_wallet/features/home/widgets/face_recognition_public.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'security_setting_widgets.dart';

class SecuritySetting extends ConsumerStatefulWidget {
  const SecuritySetting({super.key});

  @override
  ConsumerState<SecuritySetting> createState() => _SecuritySettingState();
}

class _SecuritySettingState extends ConsumerState<SecuritySetting> {
  List<String> lockTimeList = [
    "10",
    "30",
    "60",
    "120",
    "180",
    "240",
    "300",
    "600",
  ];

  /// 将秒数格式化为人类可读形式：< 60 显示秒，>= 60 显示分钟
  String _formatLockTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    return '${minutes}min';
  }

  Map<String, dynamic> securityMap = {
    "email": false,
    "google": false,
    "face": false,
  };

  bool checkBiometrics = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    Map<String, dynamic>? s = await SPUtil().getSecurity();
    if (!mounted) return;
    if (s != null) {
      Map<String, dynamic>? userSecurityMap =
          s[AppGlobals.userInfo?.uuid ?? ""];
      if (userSecurityMap != null) {
        setState(() {
          securityMap['email'] = userSecurityMap['email'];
          securityMap['google'] = userSecurityMap['google'];
          securityMap['face'] = userSecurityMap['face'] ?? false;
        });
      }
    }
    initFace();
  }

  Future<void> initFace() async {
    FaceRecognitionPublic frp = FaceRecognitionPublic();
    checkBiometrics = await frp.checkBiometrics();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> saveSecurity() async {
    SPUtil sPUtils = SPUtil();
    Map<String, dynamic>? s = await sPUtils.getSecurity();
    s ??= {};
    s[AppGlobals.userInfo?.uuid ?? ""] = securityMap;
    await sPUtils.setSecurity(s);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).s_key_11),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(20.0),
                ),
                child: Text(
                  S.of(context).google_verification_message5,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
                child: Text(
                  S.of(context).google_verification_message6,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
              ),
              buildRowItemNew(
                S.of(context).email_verification,
                securityMap['email'],
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecurityEdit('email'),
                    ),
                  );
                  if (!mounted) return;
                  init();
                },
              ),
              Container(
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemBgColor.name,
                  ),
                  borderRadius: BorderRadius.circular(
                    ScreenUtil().setWidth(16.0),
                  ),
                ),
                child: Column(
                  children: [
                    buildOpenWidget(
                      S.of(context).g_lock_key1,
                      securityMap['face'],
                      (value) async {
                        if (checkBiometrics) {
                          securityMap['face'] = value;
                          saveSecurity();
                        }
                        setState(() {});
                      },
                    ),
                    if (checkBiometrics == false)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30.0),
                          right: ScreenUtil().setWidth(10.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                S.of(context).g_lock_key7,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  color: AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.errorTextColor.name,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await openAppSettings();
                                if (!mounted) return;
                                initFace();
                              },
                              child: Text(
                                S.of(context).g_face_5,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  color: AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.mainBlueColor.name,
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
              Builder(
                builder: (context) {
                  final screenLockState = ref.watch(screenLockProvider);
                  return Column(
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(60.0),
                        margin: EdgeInsets.only(
                          top: ScreenUtil().setWidth(40.0),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S.of(context).g_lock_key15,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                        ),
                      ),
                      buildOpenLockScreenWidget(screenLockState),
                      buildOpenGesturePasswordWidget(screenLockState),
                      buildOpenFaceWidget(screenLockState),
                    ],
                  );
                },
              ),
              SizedBox(height: ScreenUtil().setWidth(100)),
            ],
          ),
        ),
      ),
    );
  }
}
