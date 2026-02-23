// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/wallet/models/wallet_info.dart';
import 'package:n42_wallet/src/wallet/pages/face_matching/face_binding.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/container_widget.dart';
import 'package:n42_wallet/src/widgets/empty.dart';
import 'package:n42_wallet/src/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// 人脸绑定：选择要绑定的钱包页面。
///
/// 用户选中某个钱包后进入 FaceBinding(type=1)，
/// 绑定完成（无论成功或失败）结果透传给上层页面。
class SelectWallet extends ConsumerStatefulWidget {
  const SelectWallet({super.key});

  @override
  ConsumerState<SelectWallet> createState() => _SelectWalletState();
}

class _SelectWalletState extends ConsumerState<SelectWallet> {
  List<WalletInfo> walletList = [];
  Load _load = Load.loading; // 初始显示加载中

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final list = ref.read(wapBridgeProvider).walletInfoLsit;
    if (!mounted) return;
    setState(() {
      walletList = list;
      _load = Load.finish;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_face_match_key31,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _buildContent(),
            if (_load == Load.loading) const LoadingPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_load == Load.loading) {
      return const SizedBox.shrink(); // LoadingPage 已覆盖
    }
    if (walletList.isEmpty) {
      return const EmptyView();
    }
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: walletList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final WalletInfo info = walletList[index];
        return GestureDetector(
          onTap: () => _onWalletTap(info, index),
          child: containerStyle1(
            context,
            padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
            margin: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30.0),
              vertical: ScreenUtil().setWidth(20.0),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/img/ast.png',
                  width: ScreenUtil().setWidth(70.0),
                ),
                SizedBox(width: ScreenUtil().setWidth(20.0)),
                Text(
                  info.walletName ?? '-',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(40.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onWalletTap(WalletInfo info, int index) async {
    final Map? coinInfo = info.coinInfo?[CoinType.N.name];
    if (coinInfo == null) {
      if (!mounted) return;
      ToastUtils.show(
          S.of(context).g_face_match_key32(info.walletName ?? ''));
      return;
    }

    final int pathIndex = coinInfo['pathIndex'] ?? 0;
    final path = getPathWithIndex(
        coinInfo['baseInfo']['path']['legacy'], pathIndex);

    final Map addressMap = await Trustdart().generateAddress(
      coinInfo['baseInfo']['coinType'],
      path,
      'legacy',
      mnemonic: info.mnemonic ?? '',
      pk: info.privateKey ?? '',
    );
    if (!mounted) return;

    final rData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FaceBinding(
          1,
          address: addressMap['legacy'] as String?,
          walletIndex: index,
        ),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, rData);
  }
}
