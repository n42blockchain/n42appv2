import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/mining_import.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/mining_key_list.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:provider/provider.dart';

class MiningSetting extends StatefulWidget {
  const MiningSetting({super.key});

  @override
  State<MiningSetting> createState() => _MiningSettingState();
}

class _MiningSettingState extends State<MiningSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:S.of(context).g_key_94,
      ),
      bottomNavigationBar: SafeArea(child: Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(88),
        margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: ButtonStyle2(
          context, (){
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MiningImport()));
        },
          //"导入验证者",
          S.of(context).g_mining_key_82,
        ),
      ),),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(30),
          right: ScreenUtil().setWidth(30),
          //bottom: ScreenUtil().setWidth(30),
        ),
        child: Consumer<MiningV2Provider>(
          builder: (context, mpValue, child) {
            return Column(
              children: [
                ContainerStyle1(
                  context,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          //"验证者列表",
                          S.of(context).g_mining_key_81,
                          style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                        ),),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        size: ScreenUtil().setWidth(40),
                      ),
                    ],
                  ),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MiningKeyList()));
                  }
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
