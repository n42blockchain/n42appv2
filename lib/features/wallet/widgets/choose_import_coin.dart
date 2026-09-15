import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class ChooseImportCoin extends StatefulWidget {
  final Map<String, dynamic>? selectChain;
  const ChooseImportCoin({this.selectChain, super.key});

  @override
  State<ChooseImportCoin> createState() => _ChooseImportCoinState();
}

class _ChooseImportCoinState extends State<ChooseImportCoin> {
  var selectIndex = -1;
  List<String> keyList = [];
  Map<String, dynamic> mMap = {};
  @override
  void initState() {
    super.initState();
    mMap = allChainUrlMap;
    keyList = mMap.keys.toList();
    if (widget.selectChain != null) {
      selectIndex = keyList.indexWhere((e) {
        if (e == widget.selectChain!['baseInfo']['mKey']) {
          return true;
        }
        return false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_17),
      body: SafeArea(child: buildContentList(context)),
    );
  }

  Widget buildContentList(BuildContext context) {
    if (mMap.isEmpty) {
      return const Center(child: EmptyView());
    }
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.space8),
      itemCount: mMap.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildItem(context, mMap[keyList[index]], index);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: AppColorTokens.of(context).border);
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    Map<String, dynamic> cInfo,
    int index,
  ) {
    return item(
      context,
      cInfo['baseInfo']['icon'] ?? "",
      cInfo['baseInfo']['name'] ?? "",
      cInfo['baseInfo']['miniName'] ?? "",
      index == selectIndex,
      () async {
        setState(() {
          selectIndex = index;
        });
        Navigator.pop(context, cInfo);
      },
      coinPath: cInfo['baseInfo']?['path']?[cInfo['addrType']],
    );
  }

  Widget item(
    BuildContext context,
    String path,
    String g,
    String l,
    bool isSelected,
    VoidCallback callback, {
    String? coinPath,
  }) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(56),
                  height: ScreenUtil().setWidth(56),
                  child: l == CoinType.N.name
                      ? Image.asset('assets/img/ast.png')
                      : ImageNetWork(
                          imageUrl: path,
                          placeholder: "assets/img/list_default.png",
                        ),
                ),
                // NftImageNetWork(imageUrl: path,width: 28,height: 28,),
                SizedBox(width: AppSpacing.space8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l,
                      style: AppTypography.headline.copyWith(
                        color: AppColorTokens.of(context).textPrimary,
                      ),
                    ),
                    Text(
                      coinPath ?? '',
                      style: AppTypography.body.copyWith(
                        color: AppColorTokens.of(context).textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                isSelected
                    ? Icon(
                        Icons.check,
                        size: ScreenUtil().setWidth(48),
                        color: Color(0xFF448BDF),
                      )
                    : SizedBox(width: AppSpacing.space8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
