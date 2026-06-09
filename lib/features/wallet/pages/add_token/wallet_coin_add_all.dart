import 'dart:async';
import 'dart:convert';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  const WalletCoinAddAll(this.seachStr, {this.coinType, super.key});

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
  int importType = 0;
  bool showImportWidget = false;
  List<dynamic> coinlist = [];
  List<dynamic> coinlistSeach = [];
  List<dynamic> coinlistToken = [];
  Load load = Load.finish;

  String addSymbol = "";
  bool isEdit = false;
  late Map<String, dynamic> chainsToken;
  Map<String, dynamic>? chains;
  Map<String, dynamic> netChains = {};
  int networkIndex = -1;
  String networkName = "";
  int networkIndexToken = 0;
  String networkNameToken = "";

  static const _popularSymbolSet = {
    'USDT',
    'USDC',
    'DAI',
    'WBTC',
    'WETH',
    'UNI',
    'LINK',
    'AAVE',
    'SHIB',
    'PEPE',
    'ARB',
    'OP',
    'MATIC',
  };
  List<dynamic> _popularTokens = [];

  String _contractState = '';
  String _contractHint = '';
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

  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  void updateView([VoidCallback? action]) {
    if (!mounted) return;
    setState(action ?? () {});
  }

  String get _currentNetworkLabel {
    if (importType == 1) return networkNameToken;
    return networkName.isEmpty ? S.of(context).g_token_m_key_4 : networkName;
  }

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        backgroundColor: _color(AppThemeKeys.backGroundColor),
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).g_token_m_key_3,
                style: AppTypography.headline.copyWith(
                  color: _color(AppThemeKeys.mainTextColor),
                ),
              ),
              InkWell(
                onTap: showChangeNetwork,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentNetworkLabel,
                      style: AppTypography.headline.copyWith(
                        fontWeight: FontWeight.w400,
                        color: _color(AppThemeKeys.mainBlueColor),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_sharp,
                      size: su.setWidth(40.0),
                      color: _color(AppThemeKeys.mainBlueColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: _color(AppThemeKeys.backGroundColor),
          actions: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: su.setWidth(30.0)),
              child: SizedBox(
                height: su.setWidth(40.0),
                width: su.setWidth(40.0),
                child: load == Load.loading
                    ? CircularProgressIndicator()
                    : SizedBox(),
              ),
            ),
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
                      _buildTabContent(
                        visible: importType == 0,
                        su: su,
                        child: Column(
                          children: [
                            _buildSearchBar(su),
                            Expanded(child: coinListWidget()),
                          ],
                        ),
                      ),
                      _buildTabContent(
                        visible: importType == 1,
                        su: su,
                        child: coinListTokenWidget(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required bool visible,
    required ScreenUtil su,
    required Widget child,
  }) {
    return Positioned(
      top: su.setWidth(10.0),
      left: su.setWidth(30.0),
      right: su.setWidth(30.0),
      bottom: su.setWidth(36.0),
      child: Visibility(visible: visible, child: child),
    );
  }

  Widget _buildSearchBar(ScreenUtil su) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: su.setWidth(20.0)),
      margin: EdgeInsets.symmetric(vertical: su.setWidth(20.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(su.setWidth(20.0)),
        color: _color(AppThemeKeys.itemBgColor),
      ),
      constraints: BoxConstraints(
        minHeight: su.setWidth(100.0),
        maxHeight: su.setWidth(100.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: inputEditingController,
              style: TextStyle(
                color: _color(AppThemeKeys.mainTextColor),
                fontSize: su.setWidth(30.0),
              ),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: su.setWidth(26.0),
                ),
                isCollapsed: true,
                hintText: S.of(context).g_key_163,
                hintStyle: TextStyle(
                  fontSize: su.setWidth(30.0),
                  color: _color(AppThemeKeys.itemSubtitleTextColor),
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
            onTap: () {
              closeKeyboard();
              seachCoin();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: su.setWidth(20.0)),
              height: su.setWidth(60.0),
              decoration: BoxDecoration(
                color: _color(AppThemeKeys.mainButtonBgColor),
                borderRadius: BorderRadius.circular(su.setWidth(60.0)),
              ),
              alignment: Alignment.center,
              child: Text(
                S.of(context).search,
                style: AppTypography.bodySm.copyWith(
                  color: _color(AppThemeKeys.mainButtonTextColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tagWidget() {
    final su = ScreenUtil();
    return Container(
      height: su.setWidth(100.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: su.setWidth(1.0),
            color: _color(AppThemeKeys.itemBorderColor),
          ),
        ),
      ),
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
    final su = ScreenUtil();
    return Expanded(
      child: InkWell(
        onTap: selected ? null : () => setState(() => importType = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: su.setWidth(2.0),
                color: _color(
                  selected
                      ? AppThemeKeys.mainBlueColor
                      : AppThemeKeys.itemLineColor,
                ),
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: _color(
                selected
                    ? AppThemeKeys.mainBlueColor
                    : AppThemeKeys.mainTextColor,
              ),
              fontSize: su.setWidth(30.0),
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
