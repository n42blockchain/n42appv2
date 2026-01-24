import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:rate_us_on_store/rate_us_on_store.dart';

class CheckVersionAlert extends StatelessWidget {
  final String newVersion;
  final String introduction;
  final int isForce;

  const CheckVersionAlert(
      {super.key,
        required this.newVersion,
        required this.introduction,
        required this.isForce});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isForce != 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 强制更新时阻止返回
      },
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        backgroundColor:
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        content: Container(
          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(36)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: ScreenUtil().setWidth(52),
              ),
              Image.asset(
                "assets/img/huojian.png",
                width: ScreenUtil().setWidth(112),
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: ScreenUtil().setWidth(34),
              ),
              Text(
                S.of(context).g_key_v_k1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
              ),
              Text(
                'V$newVersion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(36),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(20)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
                child: Text(
                  introduction,
                  style: TextStyle(
                    height: ScreenUtil().setWidth(4),
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(36)),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    RateUsOnStore(
                        androidPackageName: "com.walletamaze.nftwallet",
                        appstoreAppId: "1622941204").launch();
                    /*await OpenStore.instance.open(
                      appStoreId: '1622941204',
                      androidAppBundleId: 'com.walletamaze.nftwallet',
                    );*/
                    if(isForce != 1){
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(88),
                    decoration: BoxDecoration(
                      color: const Color(0xff448BDF),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(44)),
                      // border: Border.all(color: _color, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).g_key_v_k2,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
