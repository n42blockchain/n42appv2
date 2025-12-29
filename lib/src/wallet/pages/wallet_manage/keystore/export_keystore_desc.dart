import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/keystore/export_keystore_page.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExportKeystoreDesc extends StatefulWidget {
  final String keystoreJson;
  const ExportKeystoreDesc({required this.keystoreJson,super.key});

  @override
  State<ExportKeystoreDesc> createState() => _ExportKeystoreDescState();
}

class _ExportKeystoreDescState extends State<ExportKeystoreDesc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: "",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).g_key_ex_keystore_1,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(36),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(24),
                  ),
                  Text(
                    S.of(context).g_key_ex_keystore_2,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  Divider(
                    height: ScreenUtil().setWidth(40),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Text(
                    "1. ${S.of(context).g_key_ex_keystore_3}",
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(24),
                  ),
                  Text(
                    "2. ${S.of(context).g_key_ex_keystore_4}",
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  const Spacer(),
                  SizedBox(height: ScreenUtil().setWidth(148),),
                ],
              ),
            ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setWidth(148),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30),),
                    child: ButtonStyle2(context, () {
                      Navigator.push(context,MaterialPageRoute(
                          builder: (_) => ExportKeystorePage(
                            keystoreJson: widget.keystoreJson,
                          )));
                    }, S.of(context).next),
                  ),
                ],
              ),
            )
          ],
        ),

      )
    );
  }
}
