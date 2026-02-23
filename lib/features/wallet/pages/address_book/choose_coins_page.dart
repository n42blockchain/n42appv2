import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChooseCoinsPage extends ConsumerStatefulWidget {
  const ChooseCoinsPage({super.key});

  @override
  ConsumerState<ChooseCoinsPage> createState() => _ChooseCoinsPageState();
}

class _ChooseCoinsPageState extends ConsumerState<ChooseCoinsPage> {
  var selectIndex = -1;
  var isSearch = false;
  var cleanable = true;
  final controller = TextEditingController();
  List<CoinModel> mList = [];
  List<CoinModel> allList = [];

  @override
  void initState() {
    super.initState();
    initData();

    controller.addListener(() {
      final text = controller.text.trim();
      if (text.isEmpty) {
        mList = allList;
        setState(() {});
      }
    });
  }

  Future<void> initData() async {
    List<CoinModel> list =
        ref.read(wapBridgeProvider)
            .coinModels;
    allList = list;
    mList = list;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearch
            ? buildSearch()
            : Text(
          S.of(context).g_key_address_6,
          style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(32.0)),
        ),
        centerTitle: true,
        backgroundColor:
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        actions: [
          IconButton(
            onPressed: () {
              if (isSearch) {
                final text = controller.text.trim();
                searchData(text);
              } else {
                setState(() {
                  isSearch = true;
                });
              }
            },
            icon: Icon(
              Icons.search,
              size: ScreenUtil().setWidth(48.0),
            ),
          )
        ],
      ),
      body: buildContentList(context),
    );
  }

  /// 搜索框
  Row buildSearch() {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30.0)),
            ),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16.0), horizontal: ScreenUtil().setWidth(24.0)),
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0)),
            placeholder: S.of(context).g_key_address_7,
            placeholderStyle: TextStyle(color: Color(0xffcccccc), fontSize: ScreenUtil().setSp(32.0)),
            controller: controller,
            inputFormatters: [LengthLimitingTextInputFormatter(32)],
          ),
        ),
      ],
    );
  }

  Widget buildContentList(BuildContext context) {
    if (mList.isEmpty) {
      return const Center(
        child: EmptyView(),
      );
    }
    return ListView.builder(
        itemCount: mList.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildItem(context, index, mList);
        });
  }

  Widget _buildItem(BuildContext context, int index, List<CoinModel> list) {
    CoinModel model = list[index];
    return item(context, model.coin['icon'] ?? "", model.coin['name'] ?? "",
        model.coin['miniName'] ?? "", index == selectIndex, () {
          setState(() {
            selectIndex = index;
            Navigator.of(context).pop(model);
          });
        });
  }

  Widget item(BuildContext context, String path, String g, String l, bool isSelected,
      VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(26.0),
            ),
            Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(36.0),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(56.0),
                  height: ScreenUtil().setWidth(56.0),
                  child: l==CoinType.N.name?Image.asset('assets/img/ast.png'):
                  ImageNetWork(imageUrl:
                    path,
                    placeholder: "assets/img/list_default.png",
                  ),
                ),
                // NftImageNetWork(imageUrl: path,width: 28,height: 28,),
                SizedBox(
                  width: ScreenUtil().setWidth(30.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32.0)),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(20.0),
                    ),
                    Text(
                      l,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setWidth(32.0)),
                    )
                  ],
                ),
                const Spacer(),
                isSelected
                    ? Icon(
                  Icons.check,
                  size: ScreenUtil().setWidth(48.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                )
                    : SizedBox(
                  width: ScreenUtil().setWidth(48.0),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(40.0),
                )
              ],
            ),
            SizedBox(
              height: ScreenUtil().setWidth(26.0),
            ),
            Divider(
              height: ScreenUtil().setWidth(1.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.dividerColor.name),
            )
          ],
        ),
      ),
    );
  }

  /// 根据name 进行匹配
  void searchData(String text) {
    debugPrint("text $text");
    if (text.isEmpty) {
      return;
    }
    mList = allList.where((element) {
      final name = element.coin["name"];
      debugPrint("key $text name $name");
      if ((name as String).contains(text)) {
        return true;
      }
      return false;
    }).toList();
    debugPrint("mList size ${mList.length}");
    if (mList.isNotEmpty) {
      isSearch = false;
      setState(() {});
    }
  }
}
