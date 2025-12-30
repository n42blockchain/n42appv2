import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExportKeystorePage extends StatefulWidget {
  final String keystoreJson;
  const ExportKeystorePage({required this.keystoreJson,super.key});

  @override
  State<ExportKeystorePage> createState() => _ExportKeystorePageState();
}

class _ExportKeystorePageState extends State<ExportKeystorePage> {
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_ex_keystore,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildItem(context, S.of(context).g_key_ex_keystore_5,
                      S.of(context).g_key_ex_keystore_6),
                  buildItem(context, S.of(context).g_key_ex_keystore_7,
                      S.of(context).g_key_ex_keystore_8),
                  buildItem(context, S.of(context).g_key_ex_keystore_9,
                      S.of(context).g_key_ex_keystore_10),
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemBgColor.name)),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(24)),
                    margin: EdgeInsets.symmetric( vertical: ScreenUtil().setWidth(24)),
                    child: Text(
                      widget.keystoreJson,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemTextColor.name),
                        fontSize: ScreenUtil().setSp(28),
                      ),
                      textAlign: TextAlign.start,

                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(148),),
                ],
              ),
            ),),
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
                      height: ScreenUtil().setWidth(148),
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        ScreenUtil().setWidth(30),
                      ),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                      child: ButtonStyle2(context, () {
                        if (flag) {
                          Clipboard.setData(ClipboardData(text: widget.keystoreJson));
                          ToastUtils.show(S.of(context).g_key_ex_keystore_11);
                        } else {
                          Clipboard.setData(const ClipboardData(text: ""));
                          ToastUtils.show(S.of(context).g_key_ex_keystore_11);
                        }
                        flag = !flag;
                        setState(() {});
                      },
                          flag ? S.of(context).g_key_119 : S.of(context).g_key_ex_keystore_12)
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  buildItem(BuildContext context, String title, String action) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20),),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: ScreenUtil().setWidth(12),),
          Text(
            action,
            style: TextStyle(
              color:
              AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ],
      ),
    );
  }
}
