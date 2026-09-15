import 'package:n42_wallet/features/mining_v1/pages/full_node_page.dart';
import 'package:n42_wallet/features/mining_v1/widgets/ast_mining_board.dart';
import 'package:n42_wallet/features/mining_v1/widgets/show_skip_confirm_dialog.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  final List<int> depositsList = [50, 100, 500];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _titleForPage(int page) => switch (page) {
    0 => S.of(context).g_mining_key_62,
    1 => S.of(context).g_mining_key_61,
    _ => S.of(context).g_mining_key_63,
  };

  @override
  Widget build(BuildContext context) {
    final lastPage = depositsList.length - 1;
    return Column(
      children: [
        AppHomeTopBar(
          title: _titleForPage(currentPage),
          onLeftImageClick: () {
            Scaffold.of(context).openDrawer();
          },
          onLeftImageUri: "assets/img/menu.png",
          actions: [
            GestureDetector(
              child: Text(
                S.of(context).g_mining_key_52,
                style: AppTypography.body.copyWith(
                  color: AppColorTokens.of(context).brand,
                ),
              ),
              onTap: () async {
                showSKipConfirmDialog(context, () async {});
              },
            ),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: ScreenUtil().setWidth(30),
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
                  children: depositsList
                      .map((e) => ASTMiningBoard(astNum: e))
                      .toList(),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppColorTokens.of(context).bgBase,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.space8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (currentPage > 0) {
                                  _controller.animateToPage(
                                    currentPage - 1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Image.asset(
                                "assets/mining/zuojiantou.png",
                                width: ScreenUtil().setWidth(44),
                                fit: BoxFit.cover,
                                color: currentPage > 0
                                    ? AppColorTokens.of(context).textPrimary
                                    : AppThemeUtils.getColorByKey(
                                        context,
                                        AppThemeKeys.ff888888.name,
                                      ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.space12),
                            GestureDetector(
                              onTap: () {
                                if (currentPage < lastPage) {
                                  _controller.animateToPage(
                                    currentPage + 1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Image.asset(
                                "assets/mining/youjiantou.png",
                                width: ScreenUtil().setWidth(44),
                                fit: BoxFit.cover,
                                color: currentPage < lastPage
                                    ? AppColorTokens.of(context).textPrimary
                                    : AppThemeUtils.getColorByKey(
                                        context,
                                        AppThemeKeys.ff888888.name,
                                      ),
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
                        padding: EdgeInsets.all(AppSpacing.space8),
                        child: AppButton(
                          label: S.of(context).g_key_78,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullNodePage(
                                  astNum: depositsList[currentPage],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(120)),
      ],
    );
  }
}
