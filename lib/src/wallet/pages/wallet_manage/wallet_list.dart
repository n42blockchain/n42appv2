import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/face_api.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_match.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_user_notice.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/wallet_manage.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/widgets/create_wallet_button.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_4.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletList extends StatefulWidget {
  const WalletList({super.key});

  @override
  State<WalletList> createState() => _WalletListState();
}

class _WalletListState extends State<WalletList> {
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
    walletList = Provider.of<WalletActionProvider>(context,listen: false).walletInfoLsit;
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
        Provider.of<WalletActionProvider>(context,listen: false).setWalletFaceBinding(fbwIndex);
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
      Provider.of<WalletActionProvider>(context,listen: false).setWalletFaceBinding(fbwIndex,faceBinding: false);
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

  Widget _buildList() {
    if (walletList.isEmpty) return const EmptyView();
    return ListView.builder(
      itemCount: walletList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        WalletInfo info = walletList[index];
        return GestureDetector(
          onTap: () async {
            if(info.password==""){
              jumpWalletInfoPage(info,index);
              return;
            }
            //密码验证
            final controller = TextEditingController();
            final flag = await tipsDialog4(context, null,
                controller: controller);
            if (!context.mounted) return;
            if (flag != null && flag) {
              final password = controller.text.trim();
              if (password != info.password) {
                //密码输入错误
                ToastUtils.show(S.of(context).g_key_146);
                return;
              }
              jumpWalletInfoPage(info,index);
            }
          },
          child: containerStyle1(
            context,
            padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(20.0)),
            child: Row(
              children: [
                Image.asset(
                  "assets/img/${info.mainWallet==false?'ast_h':"ast"}.png",
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
                if(info.mainWallet==true || Provider.of<WalletActionProvider>(context,listen: false).walletIndex == index)
                Icon(Icons.lock,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainGreyColor.name),
                ),
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
