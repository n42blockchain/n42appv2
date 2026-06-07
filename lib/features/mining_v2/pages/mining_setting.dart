import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_import.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_key_list.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';

class MiningSetting extends StatefulWidget {
  const MiningSetting({super.key});

  @override
  State<MiningSetting> createState() => _MiningSettingState();
}

class _MiningSettingState extends State<MiningSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_94),
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          height: ScreenUtil().setWidth(88),
          margin: EdgeInsets.all(AppSpacing.space8),
          child: AppButton(
            label: S.of(context).g_mining_key_82,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MiningImport()));
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(30),
          right: ScreenUtil().setWidth(30),
          //bottom: ScreenUtil().setWidth(30),
        ),
        child: Column(
          children: [
            containerStyle1(
              context,
              padding: EdgeInsets.all(AppSpacing.space8),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      //"验证者列表",
                      S.of(context).g_mining_key_81,
                      style: AppTypography.headline.copyWith(color: AppColorTokens.of(context).textItem),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColorTokens.of(context).textSubtitle,
                    size: ScreenUtil().setWidth(40),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MiningKeyList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
