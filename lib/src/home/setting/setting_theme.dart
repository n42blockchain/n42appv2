import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

/// Setting Theme Page - Migrated to Riverpod
/// 
/// This page demonstrates Riverpod integration:
/// - Uses ConsumerWidget instead of StatefulWidget
/// - Watches themeModeProvider for current theme
/// - Updates theme via ref.read(themeModeProvider.notifier).setTheme()
class SettingTheme extends ConsumerWidget {
  const SettingTheme({super.key});

  /// Convert ThemeMode to int for legacy compatibility
  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from Riverpod
    final themeMode = ref.watch(themeModeProvider);
    final themeModeType = _themeModeToInt(themeMode);
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
              _buildItem(
                context, 
                ref,
                "assets/home/setting/dark_model.png",
                S.of(context).g_key_129, 
                themeModeType == 2, 
                () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
                backGroundColor: const Color(0xff1E1E1E),
                fontColor: const Color(0xffffffff),
              ),
              _buildItem(
                context, 
                ref,
                "assets/home/setting/light_model.png",
                S.of(context).g_key_128, 
                themeModeType == 1, 
                () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
                backGroundColor: const Color(0xffffffff),
                fontColor: const Color(0xff121212),
              ),
              _buildItem(
                context, 
                ref,
                "assets/home/setting/sys_m.png",
                S.of(context).g_key_127, 
                themeModeType == 0, 
                () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system),
                backGroundColor: const Color(0xffBEBEBE),
                fontColor: const Color(0xff373739),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, WidgetRef ref, String path, String model, bool isSelected,
      VoidCallback callback, {Color? backGroundColor, Color? fontColor}) {
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
