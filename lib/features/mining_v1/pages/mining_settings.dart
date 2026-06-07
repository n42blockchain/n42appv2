import 'dart:io';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_config.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/item_mining_node.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
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
  bool isSwitched = true;

  ///挖矿节点列表
  List<Map> nodeList = [];

  //当前用户选中的节点
  Map? currentNode;

  int backgroundMiningMusic = 0; //0:default,1:空白
  late final List<String> bgmMusicOptions;
  late final List<String> networkOptions;
  bool _optionsInitialized = false;

  void _ensureOptions() {
    if (_optionsInitialized) return;
    _optionsInitialized = true;
    bgmMusicOptions = [
      S.of(context).g_mining_key35,
      S.of(context).g_mining_key36,
    ];
    networkOptions = [S.of(context).g_key_148, S.of(context).g_key_147];
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final sp = SPUtil();
    isSwitched = await sp.getOpenMining();
    backgroundMiningMusic =
        await sp.getBackgroundMiningMusic() ?? backgroundMiningMusic;

    final key = AppConfig.isMainChainMining ? "main" : "test";
    nodeList = miningNodeMap[key] as List<Map>;
    currentNode = await sp.getCurrNodeAddress() ?? nodeList[0];

    if (mounted) setState(() {});
  }

  Future<void> networkChange(bool value) async {
    await SPUtil().setIsMainChainMining(value);
    if (!mounted) return;
    eventBus.fire(
      EventPublic(
        EventPublicType.selectMiningWallet,
        intValue: globalMiningV1.walletIndex,
      ),
    );
    initData();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _ensureOptions();
    return Scaffold(
      appBar: AppBarWidget(text: S.current.g_mining_key33),
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

  Color _mainTextColor() => AppColorTokens.of(context).textPrimary;

  Color _greyColor() =>
      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainGreyColor.name);

  Widget _buildSwitchItem() {
    return wrapItem(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              S.of(context).g_mining_key82,
              style: AppTypography.headline.copyWith(color: _mainTextColor()),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Switch(
            onChanged: (bool value) async {
              var connectivityResult = await (Connectivity()
                  .checkConnectivity());
              if (!mounted) return;
              AppLogger.d(
                'MiningSettings',
                'connectivityResult: $connectivityResult',
              );
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required Widget label,
    required String value,
    required VoidCallback onTap,
  }) {
    final textColor = _mainTextColor();
    return wrapItem(
      Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
        child: Row(
          children: [
            Expanded(child: label),
            SizedBox(width: ScreenUtil().setWidth(60)),
            Flexible(
              child: GestureDetector(
                onTap: onTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: AppTypography.headline.copyWith(color: textColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_sharp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeSelector() {
    return _buildDropdownRow(
      label: Text(
        S.of(context).g_mining_key83,
        style: AppTypography.headline.copyWith(color: _mainTextColor()),
      ),
      value: currentNode?["name"] ?? '',
      onTap: () => sheetBottom(context, "", _buildNodeList(context)),
    );
  }

  Widget _buildBgmSelector() {
    return _buildDropdownRow(
      label: Text(
        S.of(context).g_mining_key34,
        style: AppTypography.headline.copyWith(color: _mainTextColor()),
      ),
      value: bgmMusicOptions[backgroundMiningMusic],
      onTap: _showMusicSheet,
    );
  }

  Widget _buildNetworkSelector() {
    return _buildDropdownRow(
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_mining_key84,
            style: AppTypography.headline.copyWith(color: _mainTextColor()),
          ),
          Text(
            S.of(context).g_mining_key85,
            style: AppTypography.body.copyWith(color: _greyColor()),
          ),
        ],
      ),
      value: networkOptions[AppConfig.isMainChainMining ? 0 : 1],
      onTap: _showNetworkSheet,
    );
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
        isSelected:
            e['ipAddress'] == currentNode?["ipAddress"] &&
            e["socket"] == currentNode?["socket"],
      );
    }).toList();
    return Column(mainAxisSize: MainAxisSize.min, children: list);
  }

  /// Reusable option item for bottom sheets (music / network selectors).
  Widget _buildOptionItem({
    required String label,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textColor = _mainTextColor();
    final labelText = Text(
      label,
      style: AppTypography.body.copyWith(color: textColor));

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemBorderColor.name,
            ),
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
                        labelText,
                        SizedBox(height: ScreenUtil().setWidth(10)),
                        Text(
                          subtitle,
                          style: AppTypography.bodySm.copyWith(color: AppColorTokens.of(context).textSubtitle),
                        ),
                      ],
                    )
                  : labelText,
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: ScreenUtil().setWidth(48),
                color: AppColorTokens.of(context).brand,
              ),
          ],
        ),
      ),
    );
  }

  void _selectBgmOption(int index) async {
    if (index != backgroundMiningMusic) {
      setState(() => backgroundMiningMusic = index);
      await SPUtil().setBackgroundMiningMusic(backgroundMiningMusic);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showMusicSheet() {
    sheetBottom(
      context,
      "",
      SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            _buildOptionItem(
              label: bgmMusicOptions[0],
              subtitle: S.of(context).g_mining_key37,
              isSelected: backgroundMiningMusic == 0,
              onTap: () => _selectBgmOption(0),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            _buildOptionItem(
              label: bgmMusicOptions[1],
              isSelected: backgroundMiningMusic == 1,
              onTap: () => _selectBgmOption(1),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkSheet() {
    sheetBottom(
      context,
      "",
      SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            _buildOptionItem(
              label: networkOptions[0],
              isSelected: AppConfig.isMainChainMining,
              onTap: () {
                if (!AppConfig.isMainChainMining) networkChange(true);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            _buildOptionItem(
              label: networkOptions[1],
              isSelected: !AppConfig.isMainChainMining,
              onTap: () {
                if (AppConfig.isMainChainMining) networkChange(false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget wrapItem(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(24),
        vertical: ScreenUtil().setWidth(24),
      ),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: child,
    );
  }
}
