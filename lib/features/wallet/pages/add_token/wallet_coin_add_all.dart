import 'dart:async';
import 'dart:convert';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

part 'wallet_coin_add_all_data.dart';
part 'wallet_coin_add_all_logic.dart';
part 'wallet_coin_add_all_search_ui.dart';
part 'wallet_coin_add_all_import_ui.dart';
part 'wallet_coin_add_all_import_form_ui.dart';
part 'wallet_coin_add_all_network_dialog.dart';

class WalletCoinAddAll extends ConsumerStatefulWidget {
  final String? coinType;
  final String seachStr;
  const WalletCoinAddAll(this.seachStr,{this.coinType,super.key});

  @override
  ConsumerState<WalletCoinAddAll> createState() => _WalletCoinAddAllState();
}

class _WalletCoinAddAllState extends ConsumerState<WalletCoinAddAll> {
  late final Regular regular = Regular();
  TextEditingController inputEditingController = TextEditingController();
  TextEditingController tokenEditingController = TextEditingController();
  TextEditingController symbolEditingController = TextEditingController();
  TextEditingController decimalEditingController = TextEditingController();
  FocusNode tokenFocusNode = FocusNode();
  FocusNode symbolFocusNode = FocusNode();
  FocusNode decimalFocusNode = FocusNode();
  int importType = 0; //导入token类型 0，1
  bool showImportWidget = false;
  List<dynamic> coinlist = [];
  List<dynamic> coinlistSeach = [];
  List<dynamic> coinlistToken = [];
  Load load = Load.finish;

  String addSymbol = ""; //添加的主链币
  bool isEdit = false;
  late Map<String, dynamic> chainsToken;
  Map<String, dynamic>? chains; //现有的主链币
  Map<String, dynamic> netChains = {}; //api获取的主链币
  int networkIndex = -1;
  String networkName = "";
  int networkIndexToken = 0;
  String networkNameToken = "";

  // ── 热门代币推荐 ─────────────────────────────────────────────
  /// 热门代币 symbol 白名单（纯前端过滤，来源于 coinlist API 数据）
  static const _popularSymbolSet = {
    'USDT', 'USDC', 'DAI', 'WBTC', 'WETH',
    'UNI', 'LINK', 'AAVE', 'SHIB', 'PEPE',
    'ARB', 'OP', 'MATIC',
  };
  List<dynamic> _popularTokens = []; // 从 coinlist 中提取的热门代币条目

  // ── 合约自动校验 ─────────────────────────────────────────────
  /// 合约验证状态：'' | 'loading' | 'found' | 'notFound' | 'error'
  String _contractState = '';
  String _contractHint = ''; // 成功时显示 "USDT · 6 decimals"
  Timer? _contractDebounce;

  String tokenErrorMessage = "";
  String symbolErrorMessage = "";
  String decimalErrorMessage = "";

  @override
  void initState() {
    getChainList();
    inputEditingController.text = widget.seachStr;
    init();
    super.initState();
  }

  @override
  void dispose() {
    _contractDebounce?.cancel();
    inputEditingController.dispose();
    tokenEditingController.dispose();
    symbolEditingController.dispose();
    decimalEditingController.dispose();
    tokenFocusNode.dispose();
    symbolFocusNode.dispose();
    decimalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        backgroundColor:
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).g_token_m_key_3,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              ),
              InkWell(
                onTap: showChangeNetwork,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        importType == 0
                            ? (networkName == ""
                            ? S.of(context).g_token_m_key_4
                            : networkName)
                            : networkNameToken,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_sharp,
                        size: ScreenUtil().setWidth(40.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          actions: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
              child: SizedBox(
                height: ScreenUtil().setWidth(40.0),
                width: ScreenUtil().setWidth(40.0),
                child: load == Load.loading
                    ? CircularProgressIndicator()
                    : SizedBox(),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: InkWell(
            onTap: closeKeyboard,
            child: Column(
              children: [
                tagWidget(),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: ScreenUtil().setWidth(10.0),
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                        bottom: ScreenUtil().setWidth(36.0),
                        child: Visibility(
                          visible: importType == 0,
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(20.0)),
                                margin: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(20.0)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(ScreenUtil().setWidth(20.0))),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemBgColor.name),
                                ),
                                constraints: BoxConstraints(
                                  minHeight: ScreenUtil().setWidth(100.0),
                                  maxHeight: ScreenUtil().setWidth(100.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: inputEditingController,
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(
                                              context,
                                              AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setWidth(30.0),
                                        ),
                                        textInputAction: TextInputAction.search,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: ScreenUtil().setWidth(26.0)),
                                          isCollapsed: true,
                                          hintText: S.of(context).g_key_163,
                                          hintStyle: TextStyle(
                                            fontSize: ScreenUtil().setWidth(30.0),
                                            color: AppThemeUtils.getColorByKey(
                                                context,
                                                AppThemeKeys
                                                    .itemSubtitleTextColor.name),
                                          ),
                                          border: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        onChanged: (_) {},
                                        onSubmitted: (_) => seachCoin(),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () { closeKeyboard(); seachCoin(); },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil().setWidth(20.0),
                                        ),
                                        height: ScreenUtil().setWidth(60.0),
                                        decoration: BoxDecoration(
                                          color: AppThemeUtils.getColorByKey(
                                              context,
                                              AppThemeKeys.mainButtonBgColor.name),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  ScreenUtil().setWidth(60.0))),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          S.of(context).search,
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(26.0),
                                            color: AppThemeUtils.getColorByKey(
                                                context,
                                                AppThemeKeys
                                                    .mainButtonTextColor.name),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: coinListWidget())
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: ScreenUtil().setWidth(10.0),
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                        bottom: ScreenUtil().setWidth(36.0),
                        child: Visibility(
                          visible: importType == 1,
                          child: coinListTokenWidget(),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tagWidget() {
    return Container(
      height: ScreenUtil().setWidth(100.0),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: ScreenUtil().setWidth(1.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBorderColor.name)))),
      child: Row(
        children: [
          _buildTab(index: 0, label: S.of(context).search),
          _buildTab(index: 1, label: S.of(context).g_token_m_key_5),
        ],
      ),
    );
  }

  Widget _buildTab({required int index, required String label}) {
    final bool selected = importType == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (selected) return;
          setState(() => importType = index);
        },
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                    width: ScreenUtil().setWidth(2.0),
                    color: selected
                        ? AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name)
                        : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
                  ))),
          child: Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context,
                  selected
                      ? AppThemeKeys.mainBlueColor.name
                      : AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setWidth(30.0),
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
