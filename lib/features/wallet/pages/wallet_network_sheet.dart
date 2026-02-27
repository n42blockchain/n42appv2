import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/manage_chains_page.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

// ── 切换网络底部弹窗 ─────────────────────────────────────────────────────────

/// 展示网络选择列表的底部弹窗。
void showNetworkSheet(
  BuildContext context,
  WalletActionProvider walletValue,
) {
  sheetBottom(
    context,
    "",
    Column(
      children: [
        _NetworkSheetHeader(),
        _NetworkList(walletValue: walletValue),
      ],
    ),
  );
}

class _NetworkSheetHeader extends StatelessWidget {
  const _NetworkSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(8),
      ),
      child: Row(
        children: [
          Text(
            S.of(context).g_token_m_key_4,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              size: ScreenUtil().setWidth(40),
            ),
            tooltip: S.of(context).g_key_manage_chains,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageChainsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NetworkList extends StatelessWidget {
  const _NetworkList({required this.walletValue});

  final WalletActionProvider walletValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: ScreenUtil().setWidth(600.0)),
      child: ListView.separated(
        itemCount: walletValue.coinModels.length + 1,
        separatorBuilder: (context, index) =>
            Divider(height: ScreenUtil().setWidth(1.0)),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _NetworkAllItem(
              selected: walletValue.walletInfo.networkIndex == -1,
              onTap: () {
                walletValue.setNetworkIndex(-1);
                Navigator.pop(context);
              },
            );
          }
          final coinInfo = walletValue.coinModels[index - 1];
          final selected = walletValue.walletInfo.networkIndex == index - 1;
          return _NetworkCoinItem(
            coinInfo: coinInfo,
            selected: selected,
            onTap: () {
              walletValue.setNetworkIndex(index - 1);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class _NetworkAllItem extends StatelessWidget {
  const _NetworkAllItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(30.0),
          horizontal: ScreenUtil().setWidth(20.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: ScreenUtil().setWidth(1.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemLineColor.name),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_token_m_key_4,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30.0),
                color: AppThemeUtils.getColorByKey(context, "mainTextColor"),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selected)
              Icon(
                Icons.check,
                size: ScreenUtil().setWidth(40.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
          ],
        ),
      ),
    );
  }
}

class _NetworkCoinItem extends StatelessWidget {
  const _NetworkCoinItem({
    required this.coinInfo,
    required this.selected,
    required this.onTap,
  });

  final CoinModel coinInfo;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget image = coinInfo.coin['miniName'] == CoinType.N.name
        ? Image.asset('assets/img/ast.png')
        : ImageNetWork(
            imageUrl: coinInfo.coin['icon'],
            placeholder: "assets/img/list_default.png",
          );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(30.0),
          horizontal: ScreenUtil().setWidth(20.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: ScreenUtil().setWidth(1.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemLineColor.name),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: ScreenUtil().setWidth(52.0),
              height: ScreenUtil().setWidth(52.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
              child: image,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coinInfo.coin['miniName'],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30.0),
                      color: AppThemeUtils.getColorByKey(
                          context, "mainTextColor"),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    coinInfo.coin['name'],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check,
                size: ScreenUtil().setWidth(40.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
          ],
        ),
      ),
    );
  }
}
