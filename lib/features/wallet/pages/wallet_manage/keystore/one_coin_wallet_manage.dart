import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/export_keystore_desc.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/keystore_export_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:n42_wallet/shared/widgets/tips_dialog_3.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_4.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';

part 'one_coin_wallet_manage_widgets.dart';

class OneCoinWalletManage extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final CoinModel model;
  final int walletIndex;
  const OneCoinWalletManage({
    required this.walletInfo,
    required this.model,
    required this.walletIndex,
    super.key,
  });

  @override
  ConsumerState<OneCoinWalletManage> createState() =>
      _OneCoinWalletManageState();
}

class _OneCoinWalletManageState extends ConsumerState<OneCoinWalletManage>
    with _OneCoinWalletManageWidgetsMixin {
  @override
  String? mnemonic;
  @override
  String? coinPath;
  @override
  String? addrType;
  @override
  String? pk;
  @override
  int pathIndex = 0;
  @override
  List<dynamic> pathList = [0];
  @override
  Load load = Load.finish;

  /// Shortcut to access the current coin's info map.
  Map<String, dynamic> get _coinInfo =>
      widget.walletInfo.coinInfo![widget.model.coin['coinType']];

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    mnemonic = widget.walletInfo.mnemonic;
    addrType = _coinInfo['addrType'];
    coinPath = _coinInfo['baseInfo']['path'][addrType];
    pathList = _coinInfo['pathList'] ?? [0];
    pathIndex = _coinInfo['pathIndex'] ?? 0;
    pk = widget.walletInfo.privateKey;
    setState(() {});
  }

  @override
  void addPath() {
    if (pathList.length >= 10) return;
    pathList.add(pathList[pathList.length - 1] + 1);
    setState(() {});
  }

  @override
  void removePath(int index) {
    pathList.removeAt(index);
    setState(() {});
  }

  @override
  void chagePath(int index) {
    pathIndex = pathList[index];
    setState(() {});
  }

  Future<void> saveCoin() async {
    _coinInfo['pathList'] = pathList;
    _coinInfo['pathIndex'] = pathIndex;
    _coinInfo['addrType'] = addrType;
    await ref
        .read(wapBridgeProvider)
        .saveWalletInfo(widget.walletInfo, widget.walletIndex);
    if (!mounted) return;
    if (ref.read(wapBridgeProvider).walletIndex == widget.walletIndex) {
      ref
          .read(wapBridgeProvider)
          .reBuildCoin(widget.walletInfo, widget.model.coin['coinType']);
    }
    Navigator.pop(context, true);
  }

  @override
  Future<void> jumpExportKeystoreDescPage({String? password}) async {
    setState(() => load = Load.loading);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      password ??= widget.walletInfo.password ?? "";
      final keystoreJson = await Trustdart().getKeyStore(
        widget.model.coin['coinType']!,
        getPathWithIndex(coinPath!, _coinInfo['pathIndex'] ?? 0),
        _coinInfo['addrType'],
        password,
        mnemonic: mnemonic ?? "",
        pk: pk ?? "",
      );
      if (!mounted) return;
      final normalized = normalizeExportableKeystore(keystoreJson);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExportKeystoreDesc(keystoreJson: normalized),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_key_keystore_21);
    } finally {
      if (mounted) {
        setState(() => load = Load.finish);
      }
    }
  }

  @override
  void showChangeAddress() {
    final Map<String, dynamic> paths = widget.model.coin['path'];
    final keyList = paths.keys.toList();
    final children = keyList.map((key) {
      final isSelected = widget.model.addrType == key;
      final textColor = AppThemeUtils.getColorByKey(
        context,
        isSelected
            ? AppThemeKeys.mainButtonBgColor.name
            : AppThemeKeys.mainTextColor.name,
      );
      return InkWell(
        onTap: () async {
          if (!isSelected) {
            widget.model.addrType = key;
            addrType = key;
            widget.model.address = null;
            await widget.model.buildWallet();
            if (!mounted) return;
            coinPath = widget.model.coin['path'][widget.model.addrType];
            setState(() {});
          }
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
          alignment: Alignment.center,
          child: Text(
            key,
            style: TextStyle(
              color: textColor,
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
        ),
      );
    }).toList();
    sheetBottom(context, "", Column(children: children));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_110),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildWalletInfo(),
                    if (widget.walletInfo.privateKey == null) _buildExport(),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    height: ScreenUtil().setWidth(148),
                    width: double.infinity,
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.backGroundColor.name,
                    ),
                    child: buttonStyle2(
                      context,
                      saveCoin,
                      S.of(context).g_key_115,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
