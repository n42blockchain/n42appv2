import 'package:n42_wallet/features/mining_v1/pages/full_node_page.dart';
import 'package:n42_wallet/features/mining_v1/widgets/ast_mining_board.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectMiningPlans extends StatefulWidget {
  const SelectMiningPlans({super.key});

  @override
  State<SelectMiningPlans> createState() => _SelectMiningPlansState();
}

class _SelectMiningPlansState extends State<SelectMiningPlans> {
  final PageController _controller = PageController();
  int currentPage = 0;
  final List<int> depositsList = [50, 100, 500];
  late final dynamic eventBusFn;

  @override
  void initState() {
    super.initState();
    eventBusFn = eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.selectMiningplansPop) {
        if (!mounted) return;
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    eventBusFn.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        // text: "Select Plans",
        text: S.current.g_mining_key_31,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30)),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      children: depositsList
                          .map((e) => ASTMiningBoard(
                        astNum: e,
                      ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
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
                            if (currentPage < depositsList.length - 1) {
                              _controller.animateToPage(currentPage + 1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            }
                          },
                          child: Image.asset(
                            "assets/mining/youjiantou.png",
                            width: ScreenUtil().setWidth(44),
                            fit: BoxFit.cover,
                            color: currentPage < depositsList.length - 1
                                ? AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name)
                                : AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.ff888888.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(148)),
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
                  padding: EdgeInsets.all( ScreenUtil().setWidth(30)),
                  child: buttonStyle2(context, ()async {
                    Navigator.push(context,MaterialPageRoute(
                        builder: (_) => FullNodePage(
                          astNum: depositsList[currentPage],
                        )));
                  },
                    S.of(context).g_key_78,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
