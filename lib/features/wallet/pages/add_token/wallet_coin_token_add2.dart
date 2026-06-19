import 'dart:convert';

import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletCoinTokenAdd2 extends ConsumerStatefulWidget {
  final CoinModel coinModel;

  const WalletCoinTokenAdd2(this.coinModel, {super.key});

  @override
  ConsumerState<WalletCoinTokenAdd2> createState() =>
      _WalletCoinTokenAdd2State();
}

class _WalletCoinTokenAdd2State extends ConsumerState<WalletCoinTokenAdd2> {
  final TextEditingController inputEditingController = TextEditingController();
  List<dynamic> coinlist = [];
  List<dynamic> coinlistSeach = [];
  Load load = Load.finish;
  List<String> symbols = [];
  String addSymbol = '';
  bool removeSymbol = false;

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  double _sw(double v) => ScreenUtil().setWidth(v);

  @override
  void initState() {
    super.initState();
    getTokenList();
    init();
  }

  @override
  void dispose() {
    inputEditingController.dispose();
    super.dispose();
  }

  void init() {
    if (widget.coinModel.tokens.isNotEmpty) {
      symbols = widget.coinModel.tokens.keys.toList();
    }
  }

  bool checkSymbol(String symStr) {
    return symbols.any((e) => e.toUpperCase() == symStr.toUpperCase());
  }

  Future<void> addCoin(Map<String, dynamic> coinMap) async {
    if (coinMap['edit'] == true) return;
    setState(() => coinMap['edit'] = true);
    try {
      final wap = ref.read(wapBridgeProvider);
      final baseToken =
          json.decode(json.encode(widget.coinModel.coin))
              as Map<String, dynamic>;
      baseToken
        ..['isContract'] = true
        ..['contract'] = coinMap['contract'].toString()
        ..['contract_test'] = ''
        ..['balance'] = '0'
        ..['balance_test'] = '0'
        ..['coinPrice'] = 0.0
        ..['percentage'] = 0.0
        ..['icon'] = coinMap['icon']
        ..['name'] = coinMap['fullname']
        ..['miniName'] = coinMap['coin_name'].toString()
        ..['mKey'] = coinMap['contract'].toString().toUpperCase()
        ..['unit'] = coinMap['coin_name'].toString()
        ..['decimals'] = coinMap['decimals']
        ..['canEdit'] = true;
      addSymbol = '$addSymbol,${coinMap['coin_name']}';
      wap.addWalletChainToken(baseToken);
      setState(() {
        coinMap['isAdd'] = true;
        coinMap['edit'] = false;
      });
    } catch (e) {
      ToastUtils.show(e.toString());
      setState(() => coinMap['edit'] = false);
    }
  }

  Future<void> removeCoin(Map<String, dynamic> coinMap) async {
    if (coinMap['edit'] == true) return;
    setState(() => coinMap['edit'] = true);
    try {
      ref.read(wapBridgeProvider).removeWalletChainToken(coinMap);
      coinMap['isAdd'] = false;
      removeSymbol = true;
      setState(() => coinMap['edit'] = false);
    } catch (e) {
      ToastUtils.show(e.toString());
      setState(() => coinMap['edit'] = false);
    }
  }

  Future<void> seachCoin() async {
    if (inputEditingController.text.isNotEmpty) {
      try {
        final inputStr = inputEditingController.text.toLowerCase();
        coinlistSeach = coinlist.where((m) {
          final fullname = m['fullname'].toString().toLowerCase();
          final symbol = m['coin_name'].toString().toLowerCase();
          return fullname.contains(inputStr) || symbol.contains(inputStr);
        }).toList();
      } catch (e) {
        ToastUtils.show(e.toString());
      }
    }
    setState(() {});
  }

  Future<void> getTokenList() async {
    setState(() => load = Load.loading);
    try {
      final tokenViewApi = TokenViewApi();
      String fullname = widget.coinModel.coin['name'];
      if (fullname == 'AmazeToken') fullname = 'Amaze Chain';

      final coinsData = await tokenViewApi.getTokenListFullname(fullname);
      if (coinsData.error) {
        ToastUtils.show(coinsData.data);
        return;
      }

      coinlist = [];
      for (final Map<String, dynamic> r in coinsData.data) {
        if (r['contract'] == '') continue;
        r['isAdd'] = checkSymbol(r['contract'].toString().toUpperCase());
        r['edit'] = false;
        if (r['isAdd'] as bool) {
          coinlist.insert(0, r);
        } else {
          coinlist.add(r);
        }
      }
    } catch (e) {
      ToastUtils.show(e.toString());
    } finally {
      if (mounted) {
        setState(() => load = Load.finish);
      }
    }
  }

  void closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<bool> _pageBack() {
    if (Navigator.canPop(context)) {
      final rValue = removeSymbol || addSymbol.isNotEmpty;
      Navigator.pop(context, rValue);
    } else {
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _pageBack();
      },
      child: Scaffold(
        backgroundColor: _themeColor(AppThemeKeys.backGroundColor),
        appBar: AppBar(
          title: Text(
            S.of(context).g_key_9,
            style: AppTypography.headline.copyWith(color: _themeColor(AppThemeKeys.mainTextColor)),
          ),
          actions: [
            if (load == Load.loading)
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: _sw(30.0)),
                child: SizedBox(
                  height: _sw(40.0),
                  width: _sw(40.0),
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: InkWell(
            onTap: closeKeyboard,
            child: Container(
              padding: EdgeInsets.all(_sw(30.0)),
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(child: _buildCoinList()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: _sw(20.0)),
      margin: EdgeInsets.symmetric(vertical: _sw(20.0)),
      constraints: BoxConstraints(minHeight: _sw(100.0), maxHeight: _sw(100.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_sw(20.0)),
        color: _themeColor(AppThemeKeys.itemBgColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: inputEditingController,
              style: AppTypography.headline.copyWith(
                color: _themeColor(AppThemeKeys.mainTextColor),
                fontWeight: FontWeight.w400,
              ),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: _sw(26.0)),
                isCollapsed: true,
                hintText: S.of(context).g_key_163,
                hintStyle: AppTypography.headline.copyWith(
                  color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onSubmitted: (_) => seachCoin(),
            ),
          ),
          InkWell(
            onTap: () {
              closeKeyboard();
              seachCoin();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _sw(20.0)),
              height: _sw(60.0),
              decoration: BoxDecoration(
                color: _themeColor(AppThemeKeys.mainButtonBgColor),
                borderRadius: BorderRadius.circular(_sw(60.0)),
              ),
              alignment: Alignment.center,
              child: Text(
                S.of(context).search,
                style: AppTypography.bodySm.copyWith(color: _themeColor(AppThemeKeys.mainButtonTextColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinListView(List<dynamic> items) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (_, index) => _buildCoinItem(items[index]),
      separatorBuilder: (context, index) =>
          Divider(height: _sw(1.0), indent: 0, endIndent: 0),
    );
  }

  Widget _buildCoinList() {
    final isSearching = inputEditingController.text.isNotEmpty;

    if (!isSearching) {
      return RefreshIndicator(
        onRefresh: () async {
          if (load == Load.finish) await getTokenList();
        },
        backgroundColor: _themeColor(AppThemeKeys.mainButtonBgColor),
        color: _themeColor(AppThemeKeys.mainButtonTextColor),
        displacement: _sw(72.0),
        child: _buildCoinListView(coinlist),
      );
    }

    if (coinlistSeach.isEmpty) return const EmptyView();
    return _buildCoinListView(coinlistSeach);
  }

  Widget _buildCoinItem(Map<String, dynamic> rowValue) {
    final coinName = rowValue['coin_name'].toString();
    String icon = 'https://api.n42.ai/market/v1/r/coinImage/$coinName.png';
    if (rowValue['fullname'] == 'LoveCoin') icon = rowValue['icon'];

    final imgWidget = rowValue['fullname'] == 'N42'
        ? Image.asset('assets/img/ast.png')
        : ImageNetWork(
            imageUrl: icon,
            placeholder: 'assets/img/list_default.png',
          );

    final bool isEditing = rowValue['edit'] == true;
    final bool isAdded = rowValue['isAdd'] == true;

    return Container(
      padding: EdgeInsets.only(
        left: _sw(20.0),
        top: _sw(20.0),
        bottom: _sw(20.0),
      ),
      child: Row(
        children: [
          Container(
            width: _sw(50.0),
            height: _sw(50.0),
            margin: EdgeInsets.only(right: _sw(30.0)),
            child: imgWidget,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rowValue['fullname'],
                  style: AppTypography.headline.copyWith(
                    color: _themeColor(AppThemeKeys.mainTextColor),
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$coinName  ',
                  style: AppTypography.bodySm.copyWith(
                    color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(rowValue, isEditing, isAdded),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    Map<String, dynamic> rowValue,
    bool isEditing,
    bool isAdded,
  ) {
    if (isEditing) {
      return Container(
        padding: EdgeInsets.all(_sw(19.0)),
        width: _sw(78.0),
        height: _sw(78.0),
        child: const CircularProgressIndicator(),
      );
    }

    return InkWell(
      onTap: () => isAdded ? removeCoin(rowValue) : addCoin(rowValue),
      child: Container(
        padding: EdgeInsets.all(_sw(isAdded ? 20.0 : 19.0)),
        width: _sw(isAdded ? 80.0 : 78.0),
        height: _sw(isAdded ? 80.0 : 78.0),
        child: Icon(
          isAdded ? Icons.remove : Icons.add,
          color: _themeColor(AppThemeKeys.mainButtonBgColor),
        ),
      ),
    );
  }
}
