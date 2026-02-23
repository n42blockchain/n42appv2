import 'package:n42_wallet/src/miningV1/pages/full_node_page.dart';
import 'package:n42_wallet/src/miningV1/widgets/ast_mining_board.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
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
  //bool pageDataLoading = false;

  //bool canDeposits50Ast = false;
  //bool canDeposits100Ast = false;
  //bool canDeposits500Ast = false;

  List<int> depositsList = [50,100,500];
  var eventBusFn;
  @override
  void initState() {
    super.initState();
    eventBusFn=eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.selectMiningplansPop) {
        Navigator.pop(context);
      }
    });
    //checkDepositsEnable();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    eventBusFn.cancel();
    super.dispose();
  }
/*
  checkDepositsEnable() async {
    try {
      setState(() {
        pageDataLoading = true;
      });
      final data = await MiningApi.getDepositRemain();
      debugPrint("getDepositRemain data: $data");
      if (data != null && data is List) {
        for (int i = 0; i < data.length; i++) {
          if (i == 0 && data[i] > BigInt.zero) {
            canDeposits50Ast = true;
            depositsList.add(50);
          } else if (i == 1 && data[i] > BigInt.zero) {
            canDeposits100Ast = true;
            depositsList.add(100);
          } else if (i == 2 && data[i] > BigInt.zero) {
            canDeposits500Ast = true;
            depositsList.add(500);
          }
        }
      }
    } catch (err) {
      debugPrint("getDepositRemain err： ${err.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          pageDataLoading = false;
        });
      }
    }
  }
*/
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
                  SizedBox(height: ScreenUtil().setWidth(148),),
                  /*SizedBox(
              height: ScreenUtil().setWidth(120),
            )*/
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
