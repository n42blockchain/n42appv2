import 'dart:io';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/miningV1/api/mining_api.dart';
import 'package:n42appv2/src/miningV1/api/mining_config.dart';
import 'package:n42appv2/src/miningV1/provider/mining_provider.dart';
import 'package:n42appv2/src/miningV1/provider/mining_v1_providers.dart';
import 'package:n42appv2/src/miningV1/utils/mining_plugin_utils.dart';
import 'package:n42appv2/src/miningV1/utils/mining_utils.dart';
import 'package:n42appv2/src/miningV1/widgets/item_mining_node.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
// switch_widget replaced with Flutter's built-in Switch
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiningSettings extends StatefulWidget {
  const MiningSettings({super.key});

  @override
  State<MiningSettings> createState() => _MiningSettingsState();
}

class _MiningSettingsState extends State<MiningSettings> {
  ///是否开启挖矿
  bool isSwitched = false;

  ///挖矿节点列表
  List<Map> nodeList = [];

  //当前用户选中的节点
  Map? currentNode;

  int backgroundMiningMusic=0;//0:default,1:空白
  List<String>? bgmMusicList;
  List<String> get BGMMusicList{
    if(bgmMusicList==null){
      bgmMusicList=[
        S.of(context).g_mining_key35,
        S.of(context).g_mining_key36,
      ];
    }
    return bgmMusicList!;
  }
  List<String>? netList;
  List<String> get NetList{
    if(netList==null){
      netList=[
        S.of(context).g_key_148,
        S.of(context).g_key_147,
      ];
    }
    return netList!;
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    // 获取缓存配置的挖矿节点
    // 获取挖矿是否开启
    SPUtil sPUtils=SPUtil();
    final openState = await sPUtils.getOpenMining();
    isSwitched = openState;

    int? bgmm= await sPUtils.getBackgroundMiningMusic();
    if(bgmm !=null){
      backgroundMiningMusic=bgmm;
    }

    //node list
    if (AppConfig.isMainChainMining) {
      nodeList = miningNodeMap["main"] as List<Map>;
    } else {
      nodeList = miningNodeMap["test"] as List<Map>;
    }

    Map? nodeMap = await sPUtils.getCurrNodeAddress();
    if (nodeMap != null) {
      currentNode = nodeMap;
    } else {
      currentNode = nodeList[0];
    }

    if (mounted) {
      setState(() {});
    }
  }
  networkChange(bool value)async{
    await SPUtil().setIsMainChainMining(value);
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet,intValue: globalMiningV1.walletIndex));
    initData();
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.current.g_mining_key33,
      ),
      body: ListenableBuilder(
        listenable: globalMiningV1,
        builder: (context, _) {
          return Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            child: Column(
              children: [
                wrapItem(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).g_mining_key82,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name)),
                    ),
                    Switch(
                      onChanged: (bool value) async {
                        var connectivityResult =
                        await (Connectivity().checkConnectivity());
                        debugPrint("connectivityResult ：$connectivityResult");
                        setState(() {
                          isSwitched = !isSwitched;
                          SPUtil().setMiningOpen(isSwitched);
                          if (isSwitched) {
                            MiningUtils.startMining();
                          } else {
                            MiningUtils.stopMining();
                          }
                        });
                      },
                      value: isSwitched,
                    )
                  ],
                )),
                SizedBox(
                  height: ScreenUtil().setWidth(40),
                ),
                wrapItem(Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                  child: Row(
                    children: [
                      Text(
                        S.of(context).g_mining_key83,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // 选择节点
                          sheetBottom(
                            context,
                            "",
                            _buildList(context),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              currentNode?["name"] ?? '',
                              style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainTextColor.name),
                                  fontSize: ScreenUtil().setSp(32)),
                            ),
                            const Icon(Icons.arrow_drop_down_sharp)
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                SizedBox(
                  height: ScreenUtil().setWidth(40),
                ),
                if(Platform.isIOS)
                wrapItem(Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          S.of(context).g_mining_key34,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(32),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor.name)),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(60),),
                      GestureDetector(
                        onTap: () {
                          _buildList_music();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              BGMMusicList[backgroundMiningMusic],
                              style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainTextColor.name),
                                  fontSize: ScreenUtil().setSp(32)),
                            ),
                            const Icon(Icons.arrow_drop_down_sharp)
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                if(Platform.isIOS)
                SizedBox(
                  height: ScreenUtil().setWidth(40),
                ),
                wrapItem(Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).g_mining_key84,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(32),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainTextColor.name)),
                            ),
                            Text(
                              S.of(context).g_mining_key85,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainGreyColor.name)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(60),),
                      GestureDetector(
                        onTap: () {
                          _buildList_network();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              NetList[AppConfig.isMainChainMining==true?0:1],
                              style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainTextColor.name),
                                  fontSize: ScreenUtil().setSp(32)),
                            ),
                            const Icon(Icons.arrow_drop_down_sharp)
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  _buildList(BuildContext context) {
    List<Widget> list = nodeList.map((e) {
      return ItemMiningNode(
        countryName: e["name"],
        nodeAddress: e["ipAddress"],
        socketUrl: e['socket'],
        icon: '',
        onTap: () {
          setState(() {
            currentNode = e;
          });
          // 重新设置 RPC节点
          MiningApi.setMiningNode(e["ipAddress"]);
          // 重新设置 EvmSdk 节点
          MiningPluginUtils.setRPCNodeAddress(e["socket"]);
          //设置缓存为当前节点
          SPUtil().setCurrNodeAddress(e);
          Navigator.of(context).pop();
        },
        isSelected: e['ipAddress'] == currentNode?["ipAddress"] &&
            e["socket"] == currentNode?["socket"],
      );
    }).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }

  _buildList_music() {
    Widget child=Container(
      width: double.infinity,
      child: Column(
        children: [
          InkWell(
            onTap: ()async{
              if(0 != backgroundMiningMusic){
                setState(() {
                  backgroundMiningMusic=0;
                });
                await SPUtil().setBackgroundMiningMusic(backgroundMiningMusic);
              }
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtil().setWidth(24),),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                border: Border.all(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name),width: ScreenUtil().setWidth(1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          BGMMusicList[0],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setWidth(10),),
                        Text(
                          S.of(context).g_mining_key37,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if(0==backgroundMiningMusic)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(48),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    )
                ],
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24),),
          InkWell(
            onTap: ()async{
              if(1 != backgroundMiningMusic){
                setState(() {
                  backgroundMiningMusic=1;
                });
                await SPUtil().setBackgroundMiningMusic(backgroundMiningMusic);
              }
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtil().setWidth(24),),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                border: Border.all(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name),width: ScreenUtil().setWidth(1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      BGMMusicList[1],
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                  if(1==backgroundMiningMusic)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(48),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
    sheetBottom(
      context,
      "",
      child,
    );
  }
  _buildList_network() {
    Widget child=Container(
      width: double.infinity,
      child: Column(
        children: [
          InkWell(
            onTap: ()async{
              if(AppConfig.isMainChainMining==false){
                networkChange(true);
              }
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtil().setWidth(24),),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                border: Border.all(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name),width: ScreenUtil().setWidth(1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      NetList[0],
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                  if(AppConfig.isMainChainMining==true)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(48),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    )
                ],
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24),),
          InkWell(
            onTap: ()async{
              if(AppConfig.isMainChainMining==true){
                networkChange(false);
              }
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtil().setWidth(24),),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                border: Border.all(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name),width: ScreenUtil().setWidth(1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      NetList[1],
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                  if(AppConfig.isMainChainMining==false)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(48),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
    sheetBottom(
      context,
      "",
      child,
    );
  }

  wrapItem(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
      child: child,
    );
  }
}
