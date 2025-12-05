import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/mining_output_pk.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/generated/l10n.dart';

class MiningOutputTip extends StatelessWidget {
  const MiningOutputTip({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 返回时传递 false（用户未完成操作）
        if (context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_mining_key_89,
        ),
        body: Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).g_mining_key_90,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(44),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(40)),
              Text(
                S.of(context).g_mining_key_91,
                style: TextStyle(fontSize: ScreenUtil().setSp(32), height: 1.5),
              ),
              Text(
                S.of(context).g_mining_key_92,
                style: TextStyle(fontSize: ScreenUtil().setSp(32), height: 1.5),
              ),
              Text(
                S.of(context).g_mining_key_93,
                style: TextStyle(fontSize: ScreenUtil().setSp(32), height: 1.5),
              ),
              Text(
                S.of(context).g_mining_key_94,
                style: TextStyle(fontSize: ScreenUtil().setSp(32), height: 1.5),
              ),
              const Spacer(),
            ],
          ),
        ),

        // 底部固定按钮
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
            width: double.infinity,
            height: ScreenUtil().setWidth(88),
            child: ButtonStyle2(context, () async {
              // 使用 push 而不是 pushReplacement，以便接收返回值
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MiningOutputPk()),
              );
              // 将结果传递回上一页
              if (context.mounted) {
                Navigator.of(context).pop(result);
              }
            }, S.of(context).g_mining_key_95,),
          ),
        ),
      ),
    );
  }
}
