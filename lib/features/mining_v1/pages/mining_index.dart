import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_settings.dart';
import 'package:n42_wallet/features/mining_v1/pages/summary_page.dart';
import 'package:n42_wallet/features/mining_v1/pages/today_mining_page.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/features/widgets/keep_state_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiningIndex extends StatefulWidget {
  const MiningIndex({super.key});

  @override
  State<MiningIndex> createState() => _MiningIndexState();
}

class _MiningIndexState extends State<MiningIndex>
    with SingleTickerProviderStateMixin {
  int selectIndex = 0;
  late TabController _tabController;

  List<String> get tabs => [S.current.g_mining_key_1, S.current.g_mining_key_2];

  final pages = const [
    KeepStateWidget(wantKeepAlive: true, child: TodayMiningPage()),
    KeepStateWidget(wantKeepAlive: true, child: SummaryPage()),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHomeTopBar(
              title: S.current.g_home_key3,
              titleChild: InkWell(
                onTap: () => showChangeAddress(),
                child: Container(
                  height: ScreenUtil().setWidth(80),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            globalMiningV1.walletName,
                            style: AppTypography.body.copyWith(
                              color: AppColorTokens.of(context).brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!AppConfig.isMainChainMining)
                            Text(
                              S.of(context).g_key_147,
                              style: AppTypography.captionSm.copyWith(
                                color: AppColorTokens.of(context).brand,
                              ),
                            ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColorTokens.of(context).brand,
                        size: ScreenUtil().setWidth(40),
                      ),
                    ],
                  ),
                ),
              ),
              onLeftImageClick: () => Scaffold.of(context).openDrawer(),
              onLeftImageUri: "assets/wallet/menu.png",
              actions: [
                SizedBox(width: AppSpacing.space2),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MiningSettings()),
                    );
                  },
                  child: Image.asset(
                    "assets/mining/set.png",
                    width: ScreenUtil().setWidth(40),
                    color: AppColorTokens.of(context).brand,
                  ),
                ),
              ],
            ),
            if (!AppConfig.isMainChainMining)
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(AppSpacing.space8),
                margin: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
                decoration: BoxDecoration(
                  color: AppColorTokens.of(context).dangerBg,
                  borderRadius: AppRadius.brSm,
                ),
                child: Text(
                  "The test chain is being upgraded and blocks cannot be verified temporarily.",
                  style: AppTypography.bodySm.copyWith(
                    color: AppColorTokens.of(context).danger,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const BoxDecoration(),
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(15),
              ),
              labelStyle: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: AppTypography.bodySm,
              labelColor: AppColorTokens.of(context).textPrimary,
              unselectedLabelColor: AppColorTokens.of(context).textSubtitle,
              tabs: List.generate(tabs.length, (i) {
                final isSelected = selectIndex == i;
                return Container(
                  margin: EdgeInsets.symmetric(
                    vertical: AppSpacing.space6,
                    horizontal: ScreenUtil().setWidth(15),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space6,
                    vertical: AppSpacing.space6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.brXl,
                    color: isSelected
                        ? AppColorTokens.of(context).brand
                        : AppColorTokens.of(context).bgSurface,
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: isSelected
                          ? AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainWhiteColor.name,
                            )
                          : AppColorTokens.of(context).textSubtitle,
                    ),
                  ),
                );
              }),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: pages),
            ),
          ],
        ),
      ),
    );
  }

  void showChangeAddress() {
    final walletValue = globalWapAdapter;
    final miningValue = globalMiningV1;

    sheetBottom(
      context,
      "",
      Column(
        children: [
          Container(
            height: ScreenUtil().setWidth(80),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context).g_key_16,
              style: AppTypography.title.copyWith(
                color: AppColorTokens.of(context).textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            color: AppColorTokens.of(context).border,
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: ScreenUtil().setWidth(500.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
            ),
            child: ListView.builder(
              itemCount: walletValue.walletInfoLsit.length,
              itemBuilder: (context, int index) {
                final wInfo = walletValue.walletInfoLsit[index];
                if (wInfo.coinInfo?[CoinType.N.name] == null) {
                  return const SizedBox.shrink();
                }
                final isSelected = index == miningValue.walletIndex;
                final walletColor = isSelected
                    ? AppColorTokens.of(context).brand
                    : AppColorTokens.of(context).textSubtitle;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (!isSelected) {
                          miningValue.setWalletIndex(index);
                        }
                      },
                      child: Container(
                        height: ScreenUtil().setWidth(80.0),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              wInfo.mainWallet
                                  ? S.of(context).g_key_14
                                  : S.of(context).g_key_6,
                              style: AppTypography.title.copyWith(
                                color: walletColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(width: AppSpacing.space4),
                            Text(
                              wInfo.walletName ?? "",
                              style: AppTypography.title.copyWith(
                                color: walletColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: ScreenUtil().setWidth(1)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
