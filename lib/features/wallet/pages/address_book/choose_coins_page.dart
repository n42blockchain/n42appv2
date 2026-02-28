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
  final controller = TextEditingController();
  List<CoinModel> mList = [];
  List<CoinModel> allList = [];

  @override
  void initState() {
    super.initState();
    allList = ref.read(wapBridgeProvider).coinModels;
    mList = allList;

    controller.addListener(() {
      if (controller.text.trim().isEmpty) {
        setState(() => mList = allList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scr = ScreenUtil();
    return Scaffold(
      appBar: AppBar(
        title: isSearch
            ? _buildSearchField(scr)
            : Text(
                S.of(context).g_key_address_6,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: scr.setSp(32.0),
                ),
              ),
        centerTitle: true,
        backgroundColor:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        actions: [
          IconButton(
            onPressed: () {
              if (isSearch) {
                _searchData(controller.text.trim());
              } else {
                setState(() => isSearch = true);
              }
            },
            icon: Icon(Icons.search, size: scr.setWidth(48.0)),
          )
        ],
      ),
      body: mList.isEmpty
          ? const Center(child: EmptyView())
          : ListView.builder(
              itemCount: mList.length,
              itemBuilder: (_, index) => _buildCoinItem(index),
            ),
    );
  }

  Widget _buildSearchField(ScreenUtil scr) {
    return CupertinoTextField(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(scr.setWidth(30.0)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: scr.setWidth(16.0),
        horizontal: scr.setWidth(24.0),
      ),
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        fontSize: scr.setSp(32.0),
      ),
      placeholder: S.of(context).g_key_address_7,
      placeholderStyle: TextStyle(
        color: const Color(0xffcccccc),
        fontSize: scr.setSp(32.0),
      ),
      controller: controller,
      inputFormatters: [LengthLimitingTextInputFormatter(32)],
    );
  }

  Widget _buildCoinItem(int index) {
    final model = mList[index];
    final coin = model.coin;
    final miniName = coin['miniName'] ?? '';
    final scr = ScreenUtil();
    final isSelected = index == selectIndex;

    return GestureDetector(
      onTap: () {
        setState(() => selectIndex = index);
        Navigator.of(context).pop(model);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(height: scr.setWidth(26.0)),
            Row(
              children: [
                SizedBox(width: scr.setWidth(36.0)),
                SizedBox(
                  width: scr.setWidth(56.0),
                  height: scr.setWidth(56.0),
                  child: miniName == CoinType.N.name
                      ? Image.asset('assets/img/ast.png')
                      : ImageNetWork(
                          imageUrl: coin['icon'] ?? '',
                          placeholder: "assets/img/list_default.png",
                        ),
                ),
                SizedBox(width: scr.setWidth(30.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin['name'] ?? '',
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: scr.setSp(32.0),
                      ),
                    ),
                    SizedBox(height: scr.setWidth(20.0)),
                    Text(
                      miniName,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: scr.setWidth(32.0),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: scr.setWidth(48.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  )
                else
                  SizedBox(width: scr.setWidth(48.0)),
                SizedBox(width: scr.setWidth(40.0)),
              ],
            ),
            SizedBox(height: scr.setWidth(26.0)),
            Divider(
              height: scr.setWidth(1.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.dividerColor.name),
            ),
          ],
        ),
      ),
    );
  }

  void _searchData(String text) {
    if (text.isEmpty) return;
    final results = allList
        .where((e) => (e.coin['name'] as String).contains(text))
        .toList();
    if (results.isNotEmpty) {
      setState(() {
        mList = results;
        isSearch = false;
      });
    }
  }
}
