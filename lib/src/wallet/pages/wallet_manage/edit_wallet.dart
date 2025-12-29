import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/comm_input.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EditWallet extends StatefulWidget {
  WalletInfo walletInfo;
  int walletIndex;
  EditWallet({required this.walletInfo,required this.walletIndex,super.key});

  @override
  State<EditWallet> createState() => _EditWalletState();
}

class _EditWalletState extends State<EditWallet> {
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
          onTap: () =>  FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
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
                child: ButtonStyle2(context, ()async{
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
                  Navigator.of(context).pop(widget.walletInfo);
                }, S.of(context).g_key_115,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
