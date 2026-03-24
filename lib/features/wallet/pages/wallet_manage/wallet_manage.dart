import 'dart:async';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_password.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_manage_flags_utils.dart';
import 'package:n42_wallet/features/wallet/widgets/item_wallet.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletManage extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const WalletManage({
    required this.walletInfo,
    required this.walletIndex,
    super.key,
  });

  @override
  ConsumerState<WalletManage> createState() => _WalletManageState();
}

class _WalletManageState extends ConsumerState<WalletManage> {
  WalletInfo? walletInfo;
  List<CoinModel>? coinList;
  bool showDelete = false;
  bool showMainWallet = false;

  StreamSubscription? eventBusFn;

  void initEventBus() {
    eventBusFn?.cancel();
    eventBusFn = eventBus.on().listen((event) {
      if (event is EventPublic && event.type == EventPublicType.backup) {
        if (!mounted) return;
        setState(() {
          walletInfo = event.param as WalletInfo;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    eventBusFn?.cancel();
    super.dispose();
  }

  Future<void> initData() async {
    walletInfo = widget.walletInfo;
    final hasN42Coin =
        walletInfo?.mainWallet == false &&
        (walletInfo?.coinInfo?.keys.any(
              (e) => e.toString() == CoinType.N.name,
            ) ??
            false);
    showMainWallet = hasN42Coin;
    showDelete = ref.read(wapBridgeProvider).walletIndex != widget.walletIndex;
    await _buildCoinModels();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _buildCoinModels() async {
    final builtCoinList = <CoinModel>[];
    final walletCoinInfo = walletInfo?.coinInfo;
    if (walletCoinInfo == null) {
      coinList = builtCoinList;
      return;
    }
    for (final key in walletCoinInfo.keys) {
      final info = walletCoinInfo[key];
      if (info is! Map || info['baseInfo'] is! Map) {
        continue;
      }
      try {
        final cm =
            CoinModel.fromMap(Map<String, dynamic>.from(info['baseInfo']))
              ..isTest = info['isTest']
              ..addrType = info['addrType']
              ..pathIndex = info['pathIndex'] ?? 0
              ..privateKey = walletInfo?.privateKey;
        await cm.buildWallet(
          setAddress: false,
          walletIndex: widget.walletIndex,
        );
        builtCoinList.add(cm);
      } catch (err) {
        debugPrint('WalletManage._buildCoinModels skip $key: $err');
      }
    }
    coinList = builtCoinList;
  }

  void deleteWalletAlert() {
    showDialog(
      context: context,
      builder: (ctx) {
        final s = S.of(ctx);
        final mainText = AppThemeUtils.getColorByKey(
          ctx,
          AppThemeKeys.mainTextColor.name,
        );
        final blueColor = AppThemeUtils.getColorByKey(
          ctx,
          AppThemeKeys.mainBlueColor.name,
        );
        final actionStyle = TextStyle(
          color: blueColor,
          fontSize: ScreenUtil().setSp(28.0),
        );

        return AlertDialog(
          title: Text(
            s.g_face_3,
            style: TextStyle(
              color: mainText,
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
          content: Text(
            s.g_key_192,
            style: TextStyle(
              color: mainText,
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.g_key_79, style: actionStyle),
            ),
            TextButton(
              onPressed: () {
                deleteWallet();
                Navigator.pop(ctx);
              },
              child: Text(s.g_key_78, style: actionStyle),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteWallet() async {
    final rmm = await ref
        .read(wapBridgeProvider)
        .deleteWalletInfo(info: walletInfo);
    if (!mounted) return;
    if (rmm == null) {
      Navigator.pop(context);
    } else {
      ToastUtils.show(rmm.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_manage,
        actions: [
          if (showDelete)
            InkWell(
              onTap: deleteWalletAlert,
              child: Container(
                alignment: Alignment.center,
                height: ScreenUtil().setWidth(100.0),
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0),
                ),
                child: Text(
                  S.of(context).g_key_113,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: walletInfo == null
          ? const EmptyView()
          : Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _walletName(
                          context,
                          '${S.of(context).g_key_nft_2}: ',
                          walletInfo!.walletName ?? '',
                        ),
                        if (walletHasUserPassword(walletInfo!))
                          _itemWidget(S.of(context).g_key_206, () async {
                            final info = await Navigator.push<WalletInfo>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditWalletPassword(
                                  walletInfo!,
                                  widget.walletIndex,
                                ),
                              ),
                            );
                            if (!mounted || info == null) return;
                            setState(() => walletInfo = info);
                          }),
                        if (walletCanBackupFromManage(walletInfo!))
                          _itemWidget(S.of(context).g_key_wallet_c38, () async {
                            if (!walletHasBackupableMnemonic(walletInfo!)) {
                              ToastUtils.show(
                                walletBackupPhraseUnavailableMessage,
                              );
                              return;
                            }
                            initEventBus();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BackupOne(walletInfo!, widget.walletIndex),
                              ),
                            );
                          }),
                        _buildCoinList(context),
                        SizedBox(height: ScreenUtil().setWidth(148.0)),
                      ],
                    ),
                  ),
                ),
                if (showMainWallet)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: ScreenUtil().setWidth(148.0),
                      width: double.infinity,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.backGroundColor.name,
                      ),
                      child: buttonStyle2(context, () async {
                        final mm = ref
                            .read(wapBridgeProvider)
                            .setMainWallet(widget.walletIndex);
                        if (!context.mounted) return;
                        if (mm.error) {
                          ToastUtils.show(mm.data);
                        } else {
                          Navigator.pop(context, true);
                        }
                      }, S.of(context).g_key_15),
                    ),
                  ),
              ],
            ),
    );
  }

  BoxDecoration get _tileDecoration => BoxDecoration(
    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
  );

  EdgeInsets get _tileMargin => EdgeInsets.symmetric(
    horizontal: ScreenUtil().setWidth(30.0),
    vertical: ScreenUtil().setWidth(10.0),
  );

  EdgeInsets get _tilePadding => EdgeInsets.symmetric(
    vertical: ScreenUtil().setWidth(20.0),
    horizontal: ScreenUtil().setWidth(30.0),
  );

  Widget _walletName(BuildContext context, String title, String value) {
    final mainText = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );

    return InkWell(
      onTap: () async {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditWallet(
              walletInfo: walletInfo!,
              walletIndex: widget.walletIndex,
            ),
          ),
        );
        if (!mounted || res == null) return;
        walletInfo = res;
        setState(() {});
      },
      child: Container(
        margin: _tileMargin,
        padding: _tilePadding,
        decoration: _tileDecoration,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: mainText,
                fontSize: ScreenUtil().setSp(32.0),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: mainText,
                  fontSize: ScreenUtil().setSp(28.0),
                ),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(20.0)),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(30.0),
              color: mainText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemWidget(String title, VoidCallback onTap) {
    final mainText = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: _tileMargin,
        padding: _tilePadding,
        decoration: _tileDecoration,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: mainText,
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(10.0)),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(30.0),
              color: mainText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinList(BuildContext context) {
    if (coinList == null) return const EmptyView();
    return ListView.builder(
      itemCount: coinList!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final model = coinList![index];
        return ItemWallet(
          iconPath: model.coin['icon'] ?? '',
          coinAddress: model.address ?? '',
          coinType: model.coin['miniName'] ?? '',
          fullName: model.coin['name'] ?? '',
          onTap: () async {
            final isEdit = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => OneCoinWalletManage(
                  walletInfo: widget.walletInfo,
                  model: model,
                  walletIndex: widget.walletIndex,
                ),
              ),
            );
            if (isEdit != null) initData();
          },
        );
      },
    );
  }
}
