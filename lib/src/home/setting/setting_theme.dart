import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class SettingTheme extends StatefulWidget {
  const SettingTheme({super.key});

  @override
  State<SettingTheme> createState() => _SettingThemeState();
}

class _SettingThemeState extends State<SettingTheme> {
  int themeModeType = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    int? tmt = await SPUtil().getThemeMode();
    if(tmt != null) {
      setState(() {
        themeModeType = tmt;
      });
    }
  }

  swichTheme(int i) {
    Provider.of<PublicProvider>(context,listen: false).switchTheme(i);
    setState(() {
      themeModeType = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_126,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              buildItem(context, "assets/home/setting/dark_model.png",
                  S.of(context).g_key_129, themeModeType == 2, () {
                    swichTheme(2);
                  },backGroundColor:const Color(0xff1E1E1E),fontColor: const Color(0xffffffff)),
              buildItem(context, "assets/home/setting/light_model.png",
                  S.of(context).g_key_128, themeModeType == 1, () {
                    swichTheme(1);
                  },backGroundColor:const Color(0xffffffff),fontColor: const Color(0xff121212)),
              buildItem(context, "assets/home/setting/sys_m.png",
                  S.of(context).g_key_127, themeModeType == 0, () {
                    swichTheme(0);
                  },backGroundColor:const Color(0xffBEBEBE),fontColor: const Color(0xff373739)),
            ],
          )
        ],
      ),
    );
  }

  buildItem(BuildContext context, String path, String model, bool isSelected,
      VoidCallback callback,{Color? backGroundColor,Color? fontColor}) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(10)),
        decoration: BoxDecoration(
          // color: AppThemeUtils.getColorByKey(
          //     context, AppThemeKeys.mainBoxColor),
            color: backGroundColor,
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),

        child: Column(
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(34),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(36),
                ),
                Image.asset(
                  path,
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                  fit: BoxFit.cover,
                  color: fontColor,
                ),
                // Container(width: 16,color: Colors.red,height: 20,),
                SizedBox(
                  width: ScreenUtil().setWidth(30),
                ),
                Text(
                  model,
                  style: TextStyle(
                    // color: AppThemeUtils.getColorByKey(
                    //     context, AppThemeKeys.mainTextColor),
                      color: fontColor,
                      fontSize: ScreenUtil().setSp(32)),
                ),
                const Spacer(),
                isSelected
                    ? Icon(
                  Icons.check,
                  size: ScreenUtil().setWidth(48),
                  color: Color(0xFF448BDF),
                )
                    : SizedBox(
                  width: ScreenUtil().setWidth(48),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(40),
                )
              ],
            ),
            SizedBox(
              height: ScreenUtil().setWidth(34),
            ),
          ],
        ),
      ),
    );
  }
}
