import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/home/setting/change_email_page.dart';
import 'package:n42_wallet/features/home/setting/security/gesture_password_page.dart';
import 'package:n42_wallet/features/home/setting/security/google_auth_setup_page.dart';
import 'package:n42_wallet/features/home/widgets/face_recognition_public.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
    "gesture": false,
    "gesturePwd": "",
    "googleSecret": "",
  };

  bool checkBiometrics = true;

  /// Whether the user has passed the page-entry biometric gate.
  /// Stays false (shows loader) until auth succeeds or face is not enabled.
  bool _pageAccessGranted = false;

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
          securityMap['gesture'] = userSecurityMap['gesture'] ?? false;
          securityMap['gesturePwd'] = userSecurityMap['gesturePwd'] ?? '';
          securityMap['google'] = userSecurityMap['google'] ?? false;
          securityMap['googleSecret'] = userSecurityMap['googleSecret'] ?? '';
        });
      }
    }
    await initFace();

    // If face/biometric lock is enabled, require auth before showing page content.
    if (securityMap['face'] == true) {
      final result = await FaceRecognitionPublic().authenticateWithBiometrics();
      if (!mounted) return;
      if (result == BiometricAuthResult.success) {
        setState(() => _pageAccessGranted = true);
      } else {
        Navigator.of(context).pop();
      }
    } else {
      if (!mounted) return;
      setState(() => _pageAccessGranted = true);
    }
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
    if (!_pageAccessGranted) {
      return Scaffold(
        appBar: AppBarWidget(text: S.of(context).s_key_11),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).s_key_11),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle('Account Security'),
              Container(
                margin: EdgeInsets.only(
                  top: AppSpacing.space4,
                  bottom: AppSpacing.space8,
                ),
                decoration: BoxDecoration(
                  color: AppColorTokens.of(context).bgSurface,
                  borderRadius: AppRadius.brMd,
                ),
                child: buildNavigationWidget(
                  title: 'Change Email',
                  subtitle:
                      AppGlobals.currentUserEmail ?? 'Update account email',
                  icon: Icons.mail_outline,
                  onTap: () {
                    // 未登录门禁:uuid/token 为空时后端请求必然无效
                    if (AppGlobals.userInfo == null) {
                      ToastUtils.show(S.of(context).g_key_error_12);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangeEmailPage(),
                      ),
                    );
                  },
                ),
              ),
              // ── 转账验证区块 ──────────────────────────────────────
              Container(
                height: ScreenUtil().setWidth(60.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  S.of(context).g_lock_key26,
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: ScreenUtil().setWidth(12.0),
                  bottom: ScreenUtil().setWidth(20.0),
                ),
                decoration: BoxDecoration(
                  color: AppColorTokens.of(context).bgSurface,
                  borderRadius: AppRadius.brMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildOpenWidget(
                      S.of(context).g_lock_key1,
                      securityMap['face'],
                      (value) async {
                        if (value) {
                          // Must pass biometric auth before enabling face lock.
                          final result = await FaceRecognitionPublic()
                              .authenticateWithBiometrics();
                          if (result != BiometricAuthResult.success) return;
                        }
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
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
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
                                style: AppTypography.body.copyWith(
                                  color: AppColorTokens.of(context).danger,
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
                                style: AppTypography.body.copyWith(
                                  color: AppColorTokens.of(context).brand,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Divider(
                      height: 1,
                      indent: ScreenUtil().setWidth(30.0),
                      endIndent: ScreenUtil().setWidth(30.0),
                    ),
                    buildOpenWidget(
                      S.of(context).g_lock_key16,
                      securityMap['gesture'] as bool,
                      (value) async {
                        if (value) {
                          final result = await Navigator.push<String?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GesturePasswordPage(),
                            ),
                          );
                          if (result != null && result.isNotEmpty) {
                            securityMap['gesture'] = true;
                            securityMap['gesturePwd'] = result;
                            saveSecurity();
                          }
                        } else {
                          securityMap['gesture'] = false;
                          securityMap['gesturePwd'] = '';
                          saveSecurity();
                        }
                        setState(() {});
                      },
                      enabled: securityMap['face'] == true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                        bottom: ScreenUtil().setWidth(20.0),
                      ),
                      child: Text(
                        S.of(context).g_lock_key29,
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ),
                    if (securityMap['gesture'] == true)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30.0),
                          right: ScreenUtil().setWidth(10.0),
                          bottom: ScreenUtil().setWidth(16.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: const SizedBox.shrink()),
                            TextButton(
                              onPressed: () async {
                                final result = await Navigator.push<String?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GesturePasswordPage(
                                      oldPassword:
                                          securityMap['gesturePwd'] as String,
                                    ),
                                  ),
                                );
                                if (result != null && result.isNotEmpty) {
                                  securityMap['gesturePwd'] = result;
                                  saveSecurity();
                                  setState(() {});
                                }
                              },
                              child: Text(
                                S.of(context).g_lock_key22,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body.copyWith(
                                  color: AppColorTokens.of(context).brand,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Divider(
                      height: 1,
                      indent: ScreenUtil().setWidth(30.0),
                      endIndent: ScreenUtil().setWidth(30.0),
                    ),
                    buildOpenWidget(
                      S.of(context).g_google_auth_key1,
                      securityMap['google'] as bool,
                      (value) async {
                        if (value) {
                          final result = await Navigator.push<String?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GoogleAuthSetupPage(),
                            ),
                          );
                          if (result != null && result.isNotEmpty) {
                            securityMap['google'] = true;
                            securityMap['googleSecret'] = result;
                            saveSecurity();
                          }
                        } else {
                          securityMap['google'] = false;
                          securityMap['googleSecret'] = '';
                          saveSecurity();
                        }
                        setState(() {});
                      },
                      enabled: securityMap['face'] == true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                        bottom: ScreenUtil().setWidth(20.0),
                      ),
                      child: Text(
                        S.of(context).g_google_auth_key5,
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
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
