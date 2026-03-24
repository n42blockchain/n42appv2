import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/home/setting/security/security_google_download.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecurityEdit extends StatefulWidget {
  final String type;
  const SecurityEdit(this.type, {super.key});
  @override
  SecurityEditState createState() => SecurityEditState();
}

class SecurityEditState extends State<SecurityEdit> {
  static final RegExp _totpCodeRegExp = RegExp(r'^\d{6}$');
  Map<String, dynamic> securityMap = {
    "email": false,
    "google": false,
    "face": false,
  };
  bool _disableLoading = false;

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
  }

  // 保存非 google 类型的设置
  Future<void> saveSecurity() async {
    SPUtil sPUtils = SPUtil();
    Map<String, dynamic>? s = await sPUtils.getSecurity();
    s ??= {};
    s[AppGlobals.userInfo?.uuid ?? ""] = securityMap;
    await sPUtils.setSecurity(s);
    if (!mounted) return;
    setState(() {});
  }

  // 弹出 TOTP 确认对话框并调用解绑接口
  Future<void> _confirmDisableGoogle() async {
    final TextEditingController codeCtrl = TextEditingController();
    String? errorMsg;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              backgroundColor: AppThemeUtils.getColorByKey(
                ctx,
                AppThemeKeys.itemBgColor.name,
              ),
              title: Text(
                S.of(ctx).g_2fa_disable_confirm_title,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    ctx,
                    AppThemeKeys.mainTextColor.name,
                  ),
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(ctx).g_2fa_disable_confirm_hint,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        ctx,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16.0)),
                  TextField(
                    controller: codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        ctx,
                        AppThemeKeys.mainTextColor.name,
                      ),
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
                    decoration: InputDecoration(
                      hintText: S.of(ctx).google_verification_message19,
                      hintStyle: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                          ctx,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                        fontSize: ScreenUtil().setSp(26.0),
                      ),
                      counterText: '',
                      errorText: errorMsg,
                    ),
                    onChanged: (_) {
                      if (errorMsg != null) {
                        setModalState(() => errorMsg = null);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    S.of(ctx).g_key_79,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        ctx,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final code = codeCtrl.text.trim();
                    if (code.isEmpty ||
                        code.length != 6 ||
                        !_totpCodeRegExp.hasMatch(code)) {
                      setModalState(
                        () => errorMsg = S.of(ctx).g_2fa_invalid_format,
                      );
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  child: Text(
                    S.of(ctx).g_key_78,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        ctx,
                        AppThemeKeys.mainButtonBgColor.name,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final code = codeCtrl.text.trim();
    if (!mounted) return;

    setState(() => _disableLoading = true);
    final MessageModel mm = await UserInfoApi().unbindGoogle(code);
    if (!mounted) return;
    setState(() => _disableLoading = false);

    if (mm.error) {
      ToastUtils.show(S.of(context).g_2fa_disable_error);
    } else {
      // 服务器验证成功后才写入本地
      securityMap['google'] = false;
      await saveSecurity();
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_2fa_disable_success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.type == "google"
            ? S.of(context).google_verification
            : S.of(context).email_verification,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: ScreenUtil().setWidth(88.0),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20.0),
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemBgColor.name,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(40.0),
                        width: ScreenUtil().setWidth(40.0),
                        margin: EdgeInsets.only(
                          right: ScreenUtil().setWidth(10.0),
                        ),
                        child: Image.asset(
                          'assets/home/setting/scurity/item_${widget.type}.png',
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          widget.type == "google"
                              ? S.of(context).google_verification
                              : S.of(context).email_verification,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setSp(28),
                          ),
                        ),
                      ),
                      _disableLoading
                          ? SizedBox(
                              width: ScreenUtil().setWidth(40.0),
                              height: ScreenUtil().setWidth(40.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainButtonBgColor.name,
                                ),
                              ),
                            )
                          : Switch(
                              activeTrackColor: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainButtonBgColor.name,
                              ),
                              value: securityMap[widget.type],
                              onChanged: _disableLoading
                                  ? null
                                  : (bool value) {
                                      if (widget.type == "google") {
                                        if (value == false) {
                                          // 关闭 2FA：需要先验证当前 TOTP 码，服务器解绑后再本地保存
                                          _confirmDisableGoogle();
                                        } else {
                                          //跳转绑定流程
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SecurityGoogleDownload(),
                                            ),
                                          );
                                        }
                                      } else {
                                        securityMap[widget.type] = value;
                                        saveSecurity();
                                      }
                                    },
                            ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    widget.type == "google"
                        ? S.of(context).google_verification_message7
                        : S.of(context).email_verification_message1,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26.0),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
