import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_binding.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class SelectWallet extends StatefulWidget {
  const SelectWallet({super.key});

  @override
  State<SelectWallet> createState() => _SelectWalletState();
}

class _SelectWalletState extends State<SelectWallet> {
  List<WalletInfo> walletList = [];
  @override
  void initState() {
    super.initState();
    initData();
  }
  initData() async {
    walletList = Provider.of<WalletActionProvider>(context,listen: false).walletInfoLsit;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_face_match_key31,
      ),
      body: SafeArea(
        child: _buildList(),
      ),
    );
  }
  _buildList() {
    if (walletList.isEmpty) return const EmptyView();
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: walletList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        WalletInfo info = walletList[index];
        return GestureDetector(
          onTap: () async {
            Map? coinInfo=info.coinInfo?[CoinType.N.name];
            if(coinInfo==null){
              ToastUtils.show(S.of(context).g_face_match_key32(info.walletName??""));
              return;
            }
            int pathIndex = coinInfo['pathIndex'] ?? 0;
            final path = getPathWithIndex(coinInfo["baseInfo"]["path"]["legacy"], pathIndex);
            Map addressMap=await Trustdart().generateAddress(
                coinInfo["baseInfo"]['coinType'],
                path,
                'legacy',
                mnemonic: info.mnemonic??"",
                pk:info.privateKey??"",
            );
            final rdata=await Navigator.of(context).push(MaterialPageRoute(builder: (_) => FaceBinding(1,address: addressMap['legacy'],walletIndex: index,)));
            Navigator.pop(context,rdata);
          },
          child: ContainerStyle1(
            context,
            padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(20.0)),
            child: Row(
              children: [
                Image.asset(
                  "assets/img/ast.png",
                  width: ScreenUtil().setWidth(70.0),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(20.0),
                ),
                Text(
                  info.walletName ?? "-",
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(40.0),
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(Icons.chevron_right,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name)),
              ],
            ),
          ),
        );
      },
    );
  }
}
