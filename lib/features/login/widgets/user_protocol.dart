import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProtocol extends StatefulWidget {
  final ValueChanged<bool>? onChanged;
  const UserProtocol({this.onChanged, super.key});

  @override
  State<UserProtocol> createState() => _UserProtocolState();
}

class _UserProtocolState extends State<UserProtocol> {
  bool flag = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    flag = await SPUtil().getReadLoginClause();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.backGroundColor.name,
      ),
      child: Row(
        children: [
          RoundCheckBox(
            isChecked: flag,
            size: ScreenUtil().setWidth(60),
            onTap: (selected) {
              setState(() => flag = !flag);
              widget.onChanged?.call(flag);
            },
            checkedWidget: Center(
              child: Icon(
                Icons.check,
                size: ScreenUtil().setWidth(40),
                color: Colors.white,
              ),
            ),
            checkedColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
            animationDuration: const Duration(milliseconds: 50),
          ),
          SizedBox(width: ScreenUtil().setWidth(20.0)),
          Expanded(
            flex: 1,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: S.of(context).g_key_user_p1,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                      fontSize: ScreenUtil().setSp(24.0),
                    ),
                  ),
                  TextSpan(
                    text:
                        "${S.of(context).g_key_user_p2},${S.of(context).g_key_user_p3}.",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24.0),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse(
                          "${AppConfig.apiUrl['walletamazeBrowser']!}/static/terms_of_use.html",
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                  ),
                ],
              ),
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }
}
