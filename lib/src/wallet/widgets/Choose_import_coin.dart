import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/keystore/import_keystore.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/all_chain.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class ChooseImportCoin extends StatefulWidget {
  Map<String,dynamic>? selectChain;
  ChooseImportCoin({this.selectChain,super.key});

  @override
  State<ChooseImportCoin> createState() => _ChooseImportCoinState();
}

class _ChooseImportCoinState extends State<ChooseImportCoin> {
  var selectIndex = -1;
  var isSearch = false;
  var cleanable = true;
  List<String> keyList = [];
  Map<String,dynamic> mMap={};
  @override
  void initState() {
    super.initState();
    mMap=allChainUrlMap;
    keyList=mMap.keys.toList();
    if(widget.selectChain !=null){
      selectIndex=keyList.indexWhere((e){
        if(e==widget.selectChain!['baseInfo']['mKey']){
          return true;
        }
        return false;
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_17,
      ),
      body: SafeArea(
        child: buildContentList(context),
      ),
    );
  }

  buildContentList(BuildContext context) {
    if (mMap.isEmpty) {
      return const Center(
        child: EmptyView(),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: mMap.length,
      itemBuilder: (BuildContext context, int index) {

        return _buildItem(context, mMap[keyList[index]],index);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          );
        },
    );
  }

  _buildItem(BuildContext context, Map<String,dynamic> cInfo,int index) {
    return item(context, cInfo['baseInfo']['icon'] ?? "", cInfo['baseInfo']['name'] ?? "",
        cInfo['baseInfo']['miniName'] ?? "", index == selectIndex, () async{
          setState(() {
            selectIndex = index;
          });
          Navigator.pop(context,cInfo);
        },coinPath: cInfo['baseInfo']['path']![cInfo['addrType']]);
  }

  item(BuildContext context, String path, String g, String l, bool isSelected,
      VoidCallback callback,{String? coinPath}) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(56),
                  height: ScreenUtil().setWidth(56),
                  child: l == CoinType.N.name
                      ? Image.asset('assets/img/ast.png')
                      : ImageNetWork(imageUrl:
                    path,
                    placeholder: "assets/img/list_default.png",
                  ),
                ),
                // NftImageNetWork(imageUrl: path,width: 28,height: 28,),
                SizedBox(
                  width: ScreenUtil().setWidth(30),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32)),
                    ),
                    Text(
                      coinPath ?? '',
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(30)),
                    )
                  ],
                ),
                const Spacer(),
                isSelected
                    ? Icon(
                  Icons.check,
                  size: ScreenUtil().setWidth(48),
                  color: Color(0xFF448BDF),
                )
                    : SizedBox(
                  width: ScreenUtil().setWidth(28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
