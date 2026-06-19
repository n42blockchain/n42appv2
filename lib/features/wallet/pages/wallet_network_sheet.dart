import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/manage_chains_page.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

void showNetworkSheet(BuildContext context, WalletActionProvider walletValue) {
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

BoxDecoration _itemBorderDecoration(BuildContext context) {
  return BoxDecoration(
    border: Border(
      bottom: BorderSide(
        width: ScreenUtil().setWidth(1.0),
        color: AppColorTokens.of(context).border,
      ),
    ),
  );
}

Widget _buildCheckIcon(BuildContext context) {
  return Icon(
    Icons.check,
    size: ScreenUtil().setWidth(40.0),
    color: AppColorTokens.of(context).brand,
  );
}

class _NetworkSheetHeader extends StatelessWidget {
  const _NetworkSheetHeader();

  @override
  Widget build(BuildContext context) {
    final scr = ScreenUtil();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scr.setWidth(20),
        vertical: scr.setWidth(8),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              S.of(context).g_token_m_key_4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: AppColorTokens.of(context).brand,
              size: scr.setWidth(40),
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
        separatorBuilder: (_, _) => Divider(height: ScreenUtil().setWidth(1.0)),
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
          final realIndex = index - 1;
          return _NetworkCoinItem(
            coinInfo: walletValue.coinModels[realIndex],
            selected: walletValue.walletInfo.networkIndex == realIndex,
            onTap: () {
              walletValue.setNetworkIndex(realIndex);
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
    final scr = ScreenUtil();
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: scr.setWidth(30.0),
          horizontal: scr.setWidth(20.0),
        ),
        decoration: _itemBorderDecoration(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                S.of(context).g_token_m_key_4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headline.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected) _buildCheckIcon(context),
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
    final scr = ScreenUtil();
    final config = coinInfo.config;
    final coinSymbol =
        (config.miniName.isNotEmpty ? config.miniName : config.coinType).trim();
    final coinName = (config.name.isNotEmpty ? config.name : coinSymbol).trim();
    final iconUrl = config.icon.trim();
    final image = coinSymbol == CoinType.N.name || iconUrl.isEmpty
        ? Image.asset('assets/img/ast.png')
        : ImageNetWork(
            imageUrl: iconUrl,
            placeholder: "assets/img/list_default.png",
          );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: scr.setWidth(30.0),
          horizontal: scr.setWidth(20.0),
        ),
        decoration: _itemBorderDecoration(context),
        child: Row(
          children: [
            SizedBox(
              width: scr.setWidth(52.0),
              height: scr.setWidth(52.0),
              child: image,
            ),
            SizedBox(width: scr.setWidth(10.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coinSymbol.isEmpty ? '--' : coinSymbol,
                    style: AppTypography.headline.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    coinName,
                    style: AppTypography.headline.copyWith(
                      color: AppColorTokens.of(context).textSubtitle,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected) _buildCheckIcon(context),
          ],
        ),
      ),
    );
  }
}
