import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditWallet extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const EditWallet({
    required this.walletInfo,
    required this.walletIndex,
    super.key,
  });

  @override
  ConsumerState<EditWallet> createState() => _EditWalletState();
}

class _EditWalletState extends ConsumerState<EditWallet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.walletInfo.walletName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_edit,
        /*actions: [
          TextButton(
              onPressed: () async {
                widget.walletInfo.walletName = _controller.text.trim();
                //保存钱包
                // Map<String,dynamic>? walletAll=await SPUtils.getWallsetInfo();
                // if(walletAll==null){
                //   await SPUtils.setWalletInfo({AppGlobals.userInfo!.uuid:[widget.walletInfo.toJson()]});
                // }else{
                //   walletAll[AppGlobals.userInfo!.uuid]=[widget.walletInfo.toJson()];
                // }
                await Provider.of<WalletActionProvider>(context,listen: false).saveWalletInfo(widget.walletInfo,widget.walletIndex);
                //await SPUtils.setWalletInfo({AppGlobals.userInfo!.uuid:[widget.walletInfo.toJson()]});

                ///更新一下provider中的数据
                //Provider.of<WalletActionProvider>(context,listen: false).updateWalletInfo(widget.walletInfo);
                Navigator.of(context).pop();
              },
              child:  Text(
                S.of(context).g_key_115,
                style: TextStyle(fontSize: ScreenUtil().setSp(36),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)),
              ))
        ],*/
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
                child: CommInput(
                  type: InputFieldType.account,
                  controller: _controller,
                  autofocus: true,
                  maxLength: AppConfig.walletNameMaxLength,
                ),
              ),
              Spacer(),
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
              ),
              Container(
                height: ScreenUtil().setWidth(148),
                width: double.infinity,
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: buttonStyle2(context, () async {
                  widget.walletInfo.walletName = resolveEditedWalletName(
                    input: _controller.text,
                    existingName: widget.walletInfo.walletName ?? '',
                    walletIndex: widget.walletIndex,
                  );
                  //保存钱包
                  // Map<String,dynamic>? walletAll=await SPUtils.getWallsetInfo();
                  // if(walletAll==null){
                  //   await SPUtils.setWalletInfo({AppGlobals.userInfo!.uuid:[widget.walletInfo.toJson()]});
                  // }else{
                  //   walletAll[AppGlobals.userInfo!.uuid]=[widget.walletInfo.toJson()];
                  // }
                  await ref
                      .read(wapBridgeProvider)
                      .saveWalletInfo(widget.walletInfo, widget.walletIndex);
                  //await SPUtils.setWalletInfo({AppGlobals.userInfo!.uuid:[widget.walletInfo.toJson()]});

                  ///更新一下provider中的数据
                  //Provider.of<WalletActionProvider>(context,listen: false).updateWalletInfo(widget.walletInfo);
                  if (!context.mounted) return;
                  Navigator.of(context).pop(widget.walletInfo);
                }, S.of(context).g_key_115),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
