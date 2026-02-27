import 'dart:io';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_config.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/item_mining_node.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
// switch_widget replaced with Flutter's built-in Switch
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
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

  int backgroundMiningMusic = 0; //0:default,1:空白
  List<String>? bgmMusicList;
  List<String> get bgmMusicOptions {
    bgmMusicList ??= [
      S.of(context).g_mining_key35,
      S.of(context).g_mining_key36,
    ];
    return bgmMusicList!;
  }

  List<String>? netList;
  List<String> get networkOptions {
    netList ??= [
      S.of(context).g_key_148,
      S.of(context).g_key_147,
    ];
    return netList!;
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    // 获取缓存配置的挖矿节点
    // 获取挖矿是否开启
    SPUtil sPUtils = SPUtil();
    final openState = await sPUtils.getOpenMining();
    isSwitched = openState;

    int? bgmm = await sPUtils.getBackgroundMiningMusic();
    if (bgmm != null) {
      backgroundMiningMusic = bgmm;
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

  Future<void> networkChange(bool value) async {
    await SPUtil().setIsMainChainMining(value);
    eventBus.fire(EventPublic(EventPublicType.selectMiningWallet,
        intValue: globalMiningV1.walletIndex));
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
                _buildSwitchItem(),
                SizedBox(height: ScreenUtil().setWidth(40)),
                _buildNodeSelector(),
                SizedBox(height: ScreenUtil().setWidth(40)),
                if (Platform.isIOS) _buildBgmSelector(),
                if (Platform.isIOS) SizedBox(height: ScreenUtil().setWidth(40)),
                _buildNetworkSelector(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchItem() {
    return wrapItem(Row(
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
    ));
  }

  Widget _buildNodeSelector() {
    return wrapItem(Padding(
      padding:
          EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
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
              sheetBottom(context, "", _buildNodeList(context));
            },
            child: Row(
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
    ));
  }

  Widget _buildBgmSelector() {
    return wrapItem(Padding(
      padding:
          EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
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
          SizedBox(width: ScreenUtil().setWidth(60)),
          GestureDetector(
            onTap: () => _showMusicSheet(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  bgmMusicOptions[backgroundMiningMusic],
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
    ));
  }

  Widget _buildNetworkSelector() {
    return wrapItem(Padding(
      padding:
          EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
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
          SizedBox(width: ScreenUtil().setWidth(60)),
          GestureDetector(
            onTap: () => _showNetworkSheet(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  networkOptions[AppConfig.isMainChainMining == true ? 0 : 1],
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
    ));
  }

  Widget _buildNodeList(BuildContext context) {
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

  /// Reusable option item for bottom sheets (music / network selectors).
  Widget _buildOptionItem({
    required String label,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBorderColor.name),
            width: ScreenUtil().setWidth(1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: subtitle != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setWidth(10)),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: ScreenUtil().setWidth(48),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
          ],
        ),
      ),
    );
  }

  void _showMusicSheet() {
    final child = SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          _buildOptionItem(
            label: bgmMusicOptions[0],
            subtitle: S.of(context).g_mining_key37,
            isSelected: backgroundMiningMusic == 0,
            onTap: () async {
              if (0 != backgroundMiningMusic) {
                setState(() {
                  backgroundMiningMusic = 0;
                });
                await SPUtil().setBackgroundMiningMusic(backgroundMiningMusic);
              }
              Navigator.pop(context);
            },
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          _buildOptionItem(
            label: bgmMusicOptions[1],
            isSelected: backgroundMiningMusic == 1,
            onTap: () async {
              if (1 != backgroundMiningMusic) {
                setState(() {
                  backgroundMiningMusic = 1;
                });
                await SPUtil().setBackgroundMiningMusic(backgroundMiningMusic);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    sheetBottom(context, "", child);
  }

  void _showNetworkSheet() {
    final child = SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          _buildOptionItem(
            label: networkOptions[0],
            isSelected: AppConfig.isMainChainMining == true,
            onTap: () async {
              if (AppConfig.isMainChainMining == false) {
                networkChange(true);
              }
              Navigator.pop(context);
            },
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          _buildOptionItem(
            label: networkOptions[1],
            isSelected: AppConfig.isMainChainMining == false,
            onTap: () async {
              if (AppConfig.isMainChainMining == true) {
                networkChange(false);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    sheetBottom(context, "", child);
  }

  Widget wrapItem(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(24),
          vertical: ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
      child: child,
    );
  }
}
