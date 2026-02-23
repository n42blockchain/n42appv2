import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/wallet/api/face_api.dart';
import 'package:n42_wallet/src/wallet/models/wallet_info.dart';
import 'package:n42_wallet/src/wallet/pages/face_matching/face_match.dart';
import 'package:n42_wallet/src/wallet/pages/face_matching/face_user_notice.dart';
import 'package:n42_wallet/src/wallet/pages/wallet_manage/wallet_manage.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/wallet/widgets/create_wallet_button.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/container_widget.dart';
import 'package:n42_wallet/src/widgets/dialog_widget/tips_dialog_4.dart';
import 'package:n42_wallet/src/widgets/empty.dart';
import 'package:n42_wallet/src/widgets/loading_page.dart';
import 'package:n42_wallet/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletList extends ConsumerStatefulWidget {
  const WalletList({super.key});

  @override
  ConsumerState<WalletList> createState() => _WalletListState();
}

class _WalletListState extends ConsumerState<WalletList> {
  List<WalletInfo> walletList = [];
  int fbwIndex=-1;
  bool fbwCheck=true;//验证钱包地址是否成功，默认成功
  String fbwCheckAddress="";//验证钱包地址后，返回的地址
  Load load=Load.finish;
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    walletList = ref.read(wapBridgeProvider).walletInfoLsit;
    checkFaceBindingWallet();
    setState(() {});
  }
  void checkFaceBindingWallet() {
    fbwIndex=-1;
    fbwCheck=true;//验证钱包地址是否成功，默认成功
    fbwCheckAddress="";//验证钱包地址后，返回的地址
    fbwIndex=walletList.indexWhere((e){
      if(e.faceBinding==true){
        return true;
      }
      return false;
    });
  }
  Future<void> jumpWalletInfoPage(WalletInfo info, int index) async {
    //本应用创建的钱包
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WalletManage(
          walletInfo: info,
          walletIndex: index,
        )));
    initData();
  }
  Future<void> checkFaceBindAddress(String addr) async {
    fbwCheck=false;
    fbwIndex=-1;
    for(int i=0;i<walletList.length;i++){
      WalletInfo info=walletList[i];
      Map coinInfo=info.coinInfo?[CoinType.N.name];
      int pathIndex = coinInfo['pathIndex'] ?? 0;
      final path =
      getPathWithIndex(coinInfo["baseInfo"]["path"]["legacy"], pathIndex);
      Map addressMap=await Trustdart().generateAddress(
          coinInfo["baseInfo"]['coinType'],
          path,
          'legacy',
          mnemonic: info.mnemonic??"",
          pk:info.privateKey??"",
      );
      if (!mounted) return;
      if(addr.toUpperCase()==addressMap['legacy'].toString().toUpperCase()){
        fbwCheck=true;
        fbwIndex=i;
        ref.read(wapBridgeProvider).setWalletFaceBinding(fbwIndex);
        break;
      }
    }
    fbwCheckAddress=addr;
    setState(() {});
  }
  Future<void> verify() async {
    if(load==Load.loading)return;
    String? rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>FaceMatch(2)));
    if (!mounted) return;
    if(rData !=null){
      checkFaceBindAddress(rData);
    }else{
      ToastUtils.show(S.of(context).g_face_match_key34);
    }
  }
  Future<void> unbind() async {
    if(load==Load.loading)return;

    String? rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>FaceMatch(2)));
    if (!mounted) return;
    if(rData ==null) {
      ToastUtils.show(S.of(context).g_face_match_key34);
      return;
    }
    setState(() {
      load=Load.loading;
    });
    WalletInfo info=walletList[fbwIndex];
    Map coinInfo=info.coinInfo?[CoinType.N.name];
    int pathIndex = coinInfo['pathIndex'] ?? 0;
    final path =
    getPathWithIndex(coinInfo["baseInfo"]["path"]["legacy"], pathIndex);
    Map addressMap=await Trustdart().generateAddress(
      coinInfo["baseInfo"]['coinType'],
      path,
      'legacy',
      mnemonic: info.mnemonic??"",
      pk:info.privateKey??"",
    );
    MessageModel rmm=await FaceApi().deleteBinding(addressMap['legacy'].toString());
    if (!mounted) return;
    if(rmm.error){
      ToastUtils.show(S.of(context).g_face_match_key35);
    }else{
      ref.read(wapBridgeProvider).setWalletFaceBinding(fbwIndex,faceBinding: false);
      fbwIndex=-1;
    }
    setState(() {
      load=Load.finish;
    });
  }
  Future<void> bind() async {
    if(load==Load.loading)return;
    MessageModel? rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>FaceUserNotice()));
    if (!mounted) return;
    if(rData !=null){
      if(rData.error==false){
        initData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_manage,
        actions: [
          IconButton(
              onPressed: () async {
                sheetBottom(context, "", CreateWalletButton(
                  onTapBack: (){
                    initData();
                  },
                ),);
              },
              icon: Icon(Icons.add_circle_outline,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),)),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),
                            bottom: ScreenUtil().setWidth(10.0),
                            left: ScreenUtil().setWidth(30.0)),
                        child: Text(
                          S.of(context).g_face_match_key6,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(32.0)),
                        ),
                      ),
                      _buildFaceBind(),
                      Padding(
                        padding: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),
                            bottom: ScreenUtil().setWidth(10.0),
                            left: ScreenUtil().setWidth(30.0)),
                        child: Text(
                          S.of(context).g_key_ex_keystore_13,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(32.0)),
                        ),
                      ),
                      _buildList(),

                      ///外部导入的钱包
                      //_buildImportWalletView(context)
                    ],
                  ),
                ),
            ),
            Positioned.fill(
              child: Visibility(
                visible: load==Load.loading,
                child: LoadingPage(),
              ),
            ),
          ],
        ),

      ),
    );
  }
/*
  _buildImportWalletView(context) {
    return Consumer(
      builder:
          (BuildContext context, WalletActionProvider value, Widget? child) {
        final list = value.importWalletList;
        if (list.isEmpty) return const SizedBox();
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: scr.setWidth(20.0),bottom: scr.setWidth(10.0),left: scr.setWidth(30.0)),
              child: Text(
                S.of(context).g_key_ex_keystore_14,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor),
                    fontSize: scr.setSp(32.0)),
              ),
            ),
            ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  WalletInfo info = list[index];
                  ImportWalletInfo? item = info.importWallet;
                  return ItemWallet(
                    iconPath: item?.coinIcon ?? "",
                    coinAddress: item?.address ?? "",
                    coinType: item?.coin?['baseInfo']["miniName"] ?? "",
                    fullName: item?.coin?['baseInfo']['name'] ?? "",
                    onTap: () async {
                      // 点击 进入详情
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ImportWalletDetail(
                            walletInfo: info,
                          )));
                    },
                  );
                })
          ],
        );
      },
    );
  }
*/
  Widget _buildFaceBind() {
    List<Widget> cList=[];
    if(fbwIndex==-1){
      //未绑定
      if(fbwCheck){
        //横向排列c2和c3
        Widget c4=Row(
          children: [
            Expanded(
              flex: 1,
              child: faceBindButton(
                S.of(context).g_face_match_key13,
                bind,),
            ),
            SizedBox(width: ScreenUtil().setWidth(30),),
            Expanded(
              flex: 1,
              child: faceBindButton(
                S.of(context).g_face_match_key14,
                verify,),
            ),
          ],
        );
        cList.addAll([
          faceBindText(
            S.of(context).g_face_match_key15,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),),
          c4]);
      }
      else{
        Widget c1=SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              faceBindText(
                "${S.of(context).g_key_address}:",
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
              ),
              faceBindText(
                fbwCheckAddress,
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
              ),
            ],
          ),
        );
        //横向排列c2和c3
        Widget c4=Row(
          children: [
            Expanded(
              flex: 1,
              child: faceBindButton(
                S.of(context).g_token_m_key_9, ()async{
                await Navigator.pushNamed(context, '/ImportOne');
                initData();
              },),
            ),
            SizedBox(width: ScreenUtil().setWidth(30),),
            Expanded(
              flex: 1,
              child: faceBindButton(
                S.of(context).g_face_match_key12, bind,),
            ),
          ],
        );
        cList.addAll([
          faceBindText(
            S.of(context).g_face_match_key16,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),),
          c1,
          c4,
        ]);
      }
    }else {
      WalletInfo info = walletList[fbwIndex];
      //钱包信息
      Widget c5=Row(
        children: [
          Image.asset(
            "assets/img/ast.png",
            width: ScreenUtil().setWidth(70.0),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(20.0),
          ),
          Expanded(
            flex: 1,
            child: Text(
              info.walletName ?? "-",
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(40.0),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
      cList.addAll([c5,
        faceBindText(S.of(context).g_face_match_key17,),
        Row(
          children: [
            Expanded(
                flex: 1,
                child: faceBindButton(
                  S.of(context).g_face_match_key12, bind,
                ),
            ),
            SizedBox(width: ScreenUtil().setWidth(30),),
            Expanded(
              flex: 1,
              child: faceBindButton(
                S.of(context).g_face_match_key33, unbind,
              ),
            ),
          ],
        ),


      ]);
    }
    return containerStyle1(
      context,
      padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(20.0)),
      child: Column(
        children: cList,
      ),
    );
  }
  Widget faceBindButton(String title, VoidCallback onTap) {
    return SizedBox(
      height: ScreenUtil().setWidth(80),
      width: double.infinity,
      child: buttonStyle2(context, onTap, title),
    );
  }
  Widget faceBindText(String value, {EdgeInsetsGeometry? margin}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: margin??EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
      child: Text(
        value,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
      ),
    );
  }

  // ── 钱包列表（含分组 + 侧滑操作） ──────────────────────────────

  Widget _buildList() {
    if (walletList.isEmpty) return const EmptyView();

    // 分组：助记词 HD 钱包 vs 单链导入钱包
    final hdWallets = <_IndexedWallet>[];
    final singleWallets = <_IndexedWallet>[];
    for (var i = 0; i < walletList.length; i++) {
      final w = _IndexedWallet(walletList[i], i);
      if (walletList[i].hasMnemonic) {
        hdWallets.add(w);
      } else {
        singleWallets.add(w);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hdWallets.isNotEmpty) ...[
          _groupHeader('HD Wallet  ·  助记词钱包'),
          ...hdWallets.map((w) => _walletTile(w.info, w.index)),
          SizedBox(height: ScreenUtil().setWidth(10)),
        ],
        if (singleWallets.isNotEmpty) ...[
          _groupHeader('Single-Chain  ·  单链导入'),
          ...singleWallets.map((w) => _walletTile(w.info, w.index)),
        ],
      ],
    );
  }

  Widget _groupHeader(String label) => Padding(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(30),
          top: ScreenUtil().setWidth(10),
          bottom: ScreenUtil().setWidth(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(24),
            letterSpacing: 0.4,
          ),
        ),
      );

  /// 单个钱包磁贴，带侧滑操作。
  ///
  /// UX：
  ///   - Tap 非当前钱包 → 直接切换（无需密码，切换不暴露私钥）
  ///   - Tap 当前钱包   → 进管理页（可能需要密码）
  ///   - 左滑           → 显示「编辑」+「删除」
  Widget _walletTile(WalletInfo info, int index) {
    final activeIndex = ref.read(wapBridgeProvider).walletIndex;
    final isActive = (activeIndex == index);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(8),
      ),
      child: Slidable(
        key: ValueKey('wallet_$index'),
        // 左滑 → 右侧操作区（编辑 + 删除）
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (_) => _onManage(info, index),
              backgroundColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: S.of(context).g_key_wallet_manage,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                bottomLeft: Radius.circular(ScreenUtil().setWidth(12)),
              ),
            ),
            // 只有非当前、非主钱包可以删除
            if (!isActive && info.mainWallet != true)
              SlidableAction(
                onPressed: (_) => _onDelete(info),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: S.of(context).g_key_113,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(ScreenUtil().setWidth(12)),
                  bottomRight: Radius.circular(ScreenUtil().setWidth(12)),
                ),
              ),
          ],
        ),
        child: _walletCard(info, index, isActive),
      ),
    );
  }

  Widget _walletCard(WalletInfo info, int index, bool isActive) {
    final coinKeys = info.coinInfo?.keys.toList() ?? [];

    return GestureDetector(
      onTap: () {
        if (isActive) {
          // 已是当前钱包 → 管理
          _onManage(info, index);
        } else {
          // 非当前钱包 → 直接切换
          _switchWallet(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20),
          vertical: ScreenUtil().setWidth(18),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name)
                  .withValues(alpha: 0.08)
              : AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
          border: isActive
              ? Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  width: 1.5,
                )
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 头像 / 图标
            Image.asset(
              'assets/img/${isActive ? "ast" : "ast_h"}.png',
              width: ScreenUtil().setWidth(56),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),

            // 名称 + 链信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.walletName ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    // 显示持有的链列表，最多 3 个
                    coinKeys.take(3).join(' · ') +
                        (coinKeys.length > 3
                            ? ' +${coinKeys.length - 3}'
                            : ''),
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(24),
                    ),
                  ),
                ],
              ),
            ),

            // 激活标志 或 右箭头
            if (isActive)
              Icon(
                Icons.check_circle,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(40),
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                size: ScreenUtil().setWidth(36),
              ),
          ],
        ),
      ),
    );
  }

  // ── 操作方法 ────────────────────────────────────────────────

  /// 直接切换（Tap 非当前钱包 / 右滑）
  void _switchWallet(int index) {
    final mm = ref.read(wapBridgeProvider).setMainWallet(index);
    if (mm.error) {
      ToastUtils.show(mm.data);
    } else {
      setState(() {});
      ToastUtils.show(S.of(context).g_key_15);
    }
  }

  /// 打开管理页（需密码验证）
  Future<void> _onManage(WalletInfo info, int index) async {
    if (info.password == '') {
      await jumpWalletInfoPage(info, index);
      return;
    }
    final controller = TextEditingController();
    final flag = await tipsDialog4(context, null, controller: controller);
    if (!mounted) return;
    if (flag == true) {
      if (controller.text.trim() != info.password) {
        final msg = S.of(context).g_key_146;
        ToastUtils.show(msg);
        return;
      }
      await jumpWalletInfoPage(info, index);
    }
  }

  /// 删除钱包（与原 deleteWalletAlert 逻辑一致）
  Future<void> _onDelete(WalletInfo info) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          S.of(ctx).g_face_3,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                ctx, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(32),
          ),
        ),
        content: Text(
          S.of(ctx).g_key_192,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                ctx, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).g_key_79,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        ctx, AppThemeKeys.mainBlueColor.name))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(ctx).g_key_78,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        ctx, AppThemeKeys.mainBlueColor.name))),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final rmm = await ref.read(wapBridgeProvider).deleteWalletInfo(info: info);
    if (!mounted) return;
    if (rmm != null) {
      ToastUtils.show(rmm.data);
    }
    initData();
  }
}

/// 内部辅助：带原始索引的钱包信息（用于分组后保持索引正确）
class _IndexedWallet {
  final WalletInfo info;
  final int index;
  const _IndexedWallet(this.info, this.index);
}
