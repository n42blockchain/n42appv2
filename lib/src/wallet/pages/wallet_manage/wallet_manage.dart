import 'dart:convert';

import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/event_bus.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/edit_wallet.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/edit_wallet_password.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/widgets/item_wallet.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletManage extends StatefulWidget {
  WalletInfo walletInfo;
  int walletIndex;
  WalletManage({required this.walletInfo,required this.walletIndex,super.key});

  @override
  State<WalletManage> createState() => _WalletManageState();
}

class _WalletManageState extends State<WalletManage> {
  WalletInfo? walletInfo;
  List<CoinModel>? coinList;
  //String? mnemonic;
  bool showDelete=false;
  bool deleteUnlock=false;//删除解锁
  Load load=Load.finish;
  bool showMainWallet=false;

  var eventBusFn;
  initEventBus(){
    eventBusFn=eventBus.on().listen((event) {
      if (event is EventPublic && event.type == EventPublicType.backup) {
        setState(() {
          widget.walletInfo=event.param as WalletInfo;
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
    super.dispose();
    if(eventBusFn !=null){
      eventBusFn.cancel();
    }
  }
  void initData() async {
    // final list = ProviderUtil.walletActionProvider().walletInfoLsit;
    //coinList = ProviderUtil.walletActionProvider().coinModels_main;
    walletInfo = widget.walletInfo;
    /*int index=await Provider.of<WalletActionProvider>(context,listen: false).walletInfoLsit.indexWhere((element) {
      if(walletInfo==element){
        return true;
      }else{
        return false;
      }
    });*/
    if(Provider.of<WalletActionProvider>(context,listen: false).walletIndex != widget.walletIndex){
      showDelete=true;
    }
    //mnemonic = walletInfo?.mnemonic;
    //debugPrint("mnemonic $mnemonic");
    //bomb business wage crowd also real pencil excess soldier hurdle media frost
    if(walletInfo?.mainWallet==false){
      List<String>? keys = walletInfo?.coinInfo?.keys.toList();
      if(keys !=null){
        int index=keys!.indexWhere((e)=>e.toString()==CoinType.N.name);
        if(index !=-1){
          showMainWallet=true;
        }
      }
    }
    if(showMainWallet==false){
      showDelete=false;
    }
    setCoinList();
    setState(() {});
  }
  setCoinList()async{
    List<dynamic> keym =walletInfo!.coinInfo!.keys.toList();
    coinList=[];
    for (int i = 0; i < keym.length; i++) {
      CoinModel cm = CoinModel.fromMap(walletInfo!.coinInfo![keym[i]]['baseInfo']);
      cm.isTest=walletInfo!.coinInfo![keym[i]]['isTest'];
      cm.addrType=walletInfo!.coinInfo![keym[i]]['addrType'];
      cm.pathIndex=walletInfo!.coinInfo![keym[i]]['pathIndex']==null?0:walletInfo!.coinInfo![keym[i]]['pathIndex'];
      cm.privateKey=walletInfo!.privateKey;
      await cm.buildWallet(setAddress: false,walletIndex: widget.walletIndex);
      coinList!.add(cm);
      setState(() { });
    }
  }
  deleteWallet_alert(){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text(
            S.of(context).g_face_3,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
          content: Text(
            S.of(context).g_key_192,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).g_key_79,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
            ),
            TextButton(
              onPressed: (){
                deleteWallet();
                //删除钱包埋点：
                // AmplitudeUtils.walletActive(WalletStatus.missing);
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).g_key_78,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(28.0)
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  deleteWallet()async{
    MessageModel? rmm=await Provider.of<WalletActionProvider>(context,listen: false).deleteWalletInfo(info:walletInfo);
    if(rmm==null){
      Navigator.pop(context);
    }else{
      ToastUtils.show(rmm.data);
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_manage,
        actions: [
          showDelete?
          InkWell(
            onTap: (){
              deleteWallet_alert();
            },
            child: Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(100.0),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),),
              child: Text(
                S.of(context).g_key_113,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ),
          ):SizedBox(),
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
                  _walletName(context, "${S.of(context).g_key_nft_2}: ", walletInfo!.walletName??""),
                  if(widget.walletInfo.password != "")
                    _itemWidget(S.of(context).g_key_206,()async{
                      WalletInfo? info=await Navigator.push(context,MaterialPageRoute(
                          builder: (_) => EditWalletPassword(walletInfo!,widget.walletIndex)));
                      if(info !=null){
                        setState(() {
                          widget.walletInfo=info;
                        });
                      }
                    }),
                  if(widget.walletInfo.password=="")
                    _itemWidget(S.of(context).g_key_wallet_c38,()async{
                      initEventBus();
                      await Navigator.push(context,MaterialPageRoute(
                          builder: (_) => BackupOne(walletInfo!,widget.walletIndex)));
                    }),
                  //_mnemonic(context, "${S.of(context).g_key_85}: ", mnemonic ?? ""),
                  //_buildWalletInfo(context),
                  _buildCoinList(context),
                  SizedBox(
                    height: ScreenUtil().setWidth(148.0),
                  )
                ],
              ),
            ),
          ),
          if(showMainWallet)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: ScreenUtil().setWidth(148.0),
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtil().setWidth(30.0),),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
              child: ButtonStyle2(
                context, ()async{
                  MessageModel mm=await Provider.of<WalletActionProvider>(context,listen: false).setMainWallet(widget.walletIndex);
                  if(mm.error){
                    ToastUtils.show(mm.data);
                  }else{
                    Navigator.pop(context,true);
                  }
                },
                S.of(context).g_key_15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _walletName(BuildContext context, String title, String value) {
    return InkWell(
      onTap: ()async{
        ///单独设置一个编辑页面
        final res=await Navigator.push(context,MaterialPageRoute(
            builder: (_) => EditWallet(walletInfo: walletInfo!,walletIndex: widget.walletIndex,)));
        if(res !=null){
          walletInfo=res;
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(10.0)),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),horizontal: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
            color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0),),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28.0),),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(20.0),
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(30.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ],
        ),
      ),
    );
  }
/*
  _walletPassword(BuildContext context, String title, ) {
    return InkWell(
      onTap: (){
        ///单独设置一个编辑页面
        Navigator.push(context,MaterialPageRoute(
            builder: (_) => EditWalletPassword(walletInfo!,widget.walletIndex)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(10.0)),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),horizontal: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
            color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBoxColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0),),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(30.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ],
        ),
      ),
    );
  }
  */
  _itemWidget(String title,Function onTap) {
    return InkWell(
      onTap: (){
        ///单独设置一个编辑页面
        onTap();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(10.0)),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),horizontal: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
            color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0),),
            ),),

            SizedBox(width: ScreenUtil().setWidth(10.0),),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(30.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  _mnemonic(BuildContext context, String title, String value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(10.0)),
      decoration: BoxDecoration(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),horizontal: ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(32.0),),
              ),
              TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                  },
                  style: ButtonStyle(
                    backgroundColor:  MaterialStateProperty.all(
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    ),
                    shape:MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(40.0))),
                    )),
                  ),
                  child: Text(
                    S.of(context).g_key_119,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                    ),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainGreyColor.name),
                    fontSize: ScreenUtil().setSp(28.0),),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _buildCoinList(
      BuildContext context,
      ) {
    if (coinList == null) return const EmptyView();
    return ListView.builder(
        itemCount: coinList!.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final CoinModel model = coinList![index];
          return ItemWallet(
            iconPath: model.coin['icon'] ?? "",
            coinAddress: model.address ?? "",
            coinType: model.coin['miniName'] ?? "",
            fullName: model.coin['name'] ?? "",
            onTap: () async{
              // 点击 进入详情
              bool? isEdit=await Navigator.push(context,MaterialPageRoute(
                  builder: (BuildContext context) => OneCoinWalletManage(
                    walletInfo: widget.walletInfo,
                    model: model,walletIndex: widget.walletIndex,
                  )));
              if(isEdit != null){
                initData();
              }
            },
          );
        });
  }
}
