import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/home/widgets/face_recognition_public.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
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
              // ── 转账验证区块 ──────────────────────────────────────
              Container(
                height: ScreenUtil().setWidth(60.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  S.of(context).g_lock_key26,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: ScreenUtil().setWidth(12.0),
                  bottom: ScreenUtil().setWidth(20.0),
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildOpenWidget(
                      S.of(context).g_lock_key1,
                      securityMap['face'],
                      (value) async {
                        securityMap['face'] = value;
                        saveSecurity();
                        setState(() {});
                      },
                      enabled: checkBiometrics,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                        bottom: ScreenUtil().setWidth(20.0),
                      ),
                      child: Text(
                        S.of(context).g_lock_key27,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24.0),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                    ),
                    if (checkBiometrics == false)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30.0),
                          right: ScreenUtil().setWidth(10.0),
                          bottom: ScreenUtil().setWidth(16.0),
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
              SizedBox(height: ScreenUtil().setWidth(100)),
            ],
          ),
        ),
      ),
    );
  }
}
