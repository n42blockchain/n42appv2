import 'package:n42_wallet/src/mining_v1/pages/full_node_page.dart';
import 'package:n42_wallet/src/mining_v1/widgets/ast_mining_board.dart';
import 'package:n42_wallet/src/mining_v1/widgets/show_SKip_Confirm_Dialog.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class MiningPlans extends StatefulWidget {
  const MiningPlans({super.key});

  @override
  State<MiningPlans> createState() => _MiningPlansState();
}

class _MiningPlansState extends State<MiningPlans> {
  final PageController _controller = PageController();
  int currentPage = 0;
  List<int> depositsList = [50,100,500];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHomeTopBar(
          title: currentPage == 0
              ? S.of(context).g_mining_key_62
              : currentPage == 1
              ? S.of(context).g_mining_key_61
              : S.of(context).g_mining_key_63,
          onLeftImageClick: () {
            Scaffold.of(context).openDrawer();
          },
          onLeftImageUri: "assets/img/menu.png",
          actions: [
            GestureDetector(
              child: Text(
                // "Skip",
                S.of(context).g_mining_key_52,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30)),
              ),
              onTap: () async {
                showSKipConfirmDialog(context,() async {
                  //await MiningUtils.setMiningSkip(true);
                  //globalMiningV1.setSkipPlans(true);
                });

              },
            ),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left:ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30),
                bottom: 0,
                top: 0,
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  children: const [
                    ASTMiningBoard(
                      astNum: 50,
                    ),
                    ASTMiningBoard(
                      astNum: 100,
                    ),
                    ASTMiningBoard(
                      astNum: 500,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (currentPage > 0) {
                                  _controller.animateToPage(currentPage - 1,
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                }
                              },
                              child: Image.asset(
                                "assets/mining/zuojiantou.png",
                                width: ScreenUtil().setWidth(44),
                                fit: BoxFit.cover,
                                color: currentPage > 0
                                    ? AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name)
                                    : AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.ff888888.name),
                              ),
                            ),
                            SizedBox(
                              width: ScreenUtil().setWidth(40),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (currentPage < 2) {
                                  _controller.animateToPage(currentPage + 1,
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                }
                              },
                              child: Image.asset(
                                "assets/mining/youjiantou.png",
                                width: ScreenUtil().setWidth(44),
                                fit: BoxFit.cover,
                                color: currentPage < 2
                                    ? AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name)
                                    : AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.ff888888.name),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: ScreenUtil().setWidth(1),
                        indent: 0,
                        endIndent: 0,
                      ),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil().setWidth(148),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                        child: buttonStyle2(context, () async {
                          Navigator.pushReplacement(context,MaterialPageRoute(
                              builder: (_) => FullNodePage(
                                astNum: depositsList[currentPage],
                              )));
                        }, S.of(context).g_key_78),
                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(120),
        )
      ],
    );
  }
}
