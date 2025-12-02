import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletConnectPage extends StatefulWidget {
  String uri;
  WalletConnectPage(this.uri,{super.key});

  @override
  State<WalletConnectPage> createState() => _WalletConnectPageState();
}

class _WalletConnectPageState extends State<WalletConnectPage> {
  @override
  void initState() {
    // TODO: implement initState
    if(widget.uri !=""){
      Provider.of<WalletConnectProvider>(context,listen: false).pageOpen=true;
      Provider.of<WalletConnectProvider>(context,listen: false).viewState_deal(WalletConnectState.loading,params: widget.uri);
    }
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    Provider.of<WalletConnectProvider>(context,listen: false).pageOpen=false;
    super.dispose();
  }
  //扫码
  scan() async {
    String? scanValue = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScanPage()));
    if (scanValue != null) {
      return scanValue;
    } else {
      return "";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<WalletConnectProvider>(builder: (context,connectV2,child){
      return Scaffold(
        appBar: AppBarWidget(
          text: connectV2.metadata==null?"Wallet Connect":connectV2.metadata!.name,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: dAppConnectWidget(connectV2)),
              if(connectV2.load==Load.loading)
                Positioned.fill(child: LoadingPage()),
            ],
          ),
        ),
      );
    },);
  }
  dAppConnectWidget(WalletConnectProvider connectV2){
    Widget connectChild=Container();
    String title="";
    Widget? titleRightWidget;
    switch(connectV2.walletConnectState){
      case WalletConnectState.loading:
        connectChild=partWidget();
        break;
      case WalletConnectState.selectChain:
        connectChild=selectChainWidget(connectV2);
        title=S.of(context).g_connect_key11;
        titleRightWidget=InkWell(
          onTap: ()async{
            bool r = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WalletCoinAddAll("")));
            if (r) {
              await Provider.of<WalletActionProvider>(context,listen: false).init_wallet(initCoinInfo: true);
            }
          },
          child: Container(
            height: ScreenUtil().setWidth(80),
            width: ScreenUtil().setWidth(80),
            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
            child: Icon(
              Icons.add_circle_outline_outlined,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            ),
          ),
        );
        break;
      case WalletConnectState.connectOK:
        connectChild=connectOKWidget(connectV2);
        break;
      case WalletConnectState.connect:
        connectChild=connectWidget(connectV2);
        break;
      case WalletConnectState.disconnect:
        connectChild=disconnectWidget(connectV2);
        break;
      case WalletConnectState.reconnect:
        break;
      case WalletConnectState.transactionOK:
      case WalletConnectState.transaction:
        connectChild=transactionOKWidget(connectV2);
        title=S.of(context).s_key_3;
        break;
      case WalletConnectState.messageSignOK:
      case WalletConnectState.messageSign:
        connectChild=messageSignOKWidget(connectV2);
        title=S.of(context).g_connect_key12;
        break;
      case WalletConnectState.error:
        connectChild=errorWidget(connectV2);
        break;
    }
    return Column(
      children: [
        dAppWidget(connectV2),
        if(title !="")
          titleWidget(title),
        Expanded(child: connectChild),
      ],
    );
  }
  loadingWidget(){
    return LoadingPage();
  }
  partWidget(){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(30.0),
          alignment: Alignment.center,
          child: Text(
            S.of(context).g_connect_key14,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(32.0),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        LoadingPage(),
      ],
    );
  }
  dAppWidget(WalletConnectProvider connectV2){
    String iconUrl="";
    String dAppName="";
    String dAppWebUrl="";
    String dAppDesc="";
    if(connectV2.metadata !=null){
      iconUrl=connectV2.metadata!.icons.length!=0?connectV2.metadata!.icons[0]:"";
      dAppName=connectV2.metadata!.name;
      dAppWebUrl=connectV2.metadata!.url;
      dAppDesc=connectV2.metadata!.description;
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(iconUrl !="")
            Container(
              height: ScreenUtil().setWidth(90),
              width: ScreenUtil().setWidth(90),
              child: ImageNetWork(imageUrl:
                  iconUrl,
                placeholder: "assets/wallet/WalletConnect.png",
              ),
            ),
          if(dAppName !="")
            Container(
              height: ScreenUtil().setWidth(60),
              width: double.infinity,
              child: Text(
                dAppName,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(36),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          if(dAppDesc !="")
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
              alignment: Alignment.center,
              child: Text(
                dAppDesc,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(26),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          if(dAppWebUrl !="")
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserPage(dAppWebUrl,
                  //dAppName
                )));
              },
              child: Container(
                height: ScreenUtil().setWidth(60),
                width: double.infinity,
                child: Text(
                  dAppWebUrl,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(26),
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
  titleWidget(String title,{Widget? rightWidget}){
    return Container(
      height: ScreenUtil().setWidth(100),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(36),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if(rightWidget !=null)
            rightWidget,
        ],
      ),
    );
  }
  selectChainWidget(WalletConnectProvider connectV2){
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
            itemBuilder: (context,int index){
              CoinModel cm=connectV2.coinModels[index];
              Widget iconWidget;
              if(cm.coin['coinType']==CoinType.N.name){
                iconWidget=Image.asset("assets/img/ast.png");
              }else{
                iconWidget=ImageNetWork(
                  imageUrl: cm.coin['icon'],
                  placeholder: "assets/img/list_default.png",
                );
              }
              return Container(
                height: ScreenUtil().setWidth(120),
                width: double.infinity,
                child: Row(
                  children: [
                    Container(
                      height: ScreenUtil().setWidth(60),
                      width: ScreenUtil().setWidth(60),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                      child: iconWidget,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        cm.coin['name'],
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          color: AppThemeUtils.getColorByKey(
                            context,AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context,int index){
              return Divider(
                height: ScreenUtil().setWidth(1),
                endIndent: 0,
                indent: 1,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
              );
            },
            itemCount: connectV2.coinModels.length,
          ),
        ),
        selectChainButton(connectV2),
      ],
    );
  }
  selectChainButton(WalletConnectProvider connectV2){
    return Container(
      height: ScreenUtil().setWidth(150),
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(36.0),
        top: ScreenUtil().setWidth(26.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: buttonWidget(
              S.of(context).g_key_79, (){
              connectV2.cleanData();
              Navigator.pop(context,false);
            },
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(30),),
          Expanded(
            flex: 1,
            child: buttonWidget(
              S.of(context).g_connect_key1, (){
              connectV2.viewState_deal(WalletConnectState.connectOK);
            },
            ),
          ),
        ],
      ),
    );
  }
  connectOKWidget(WalletConnectProvider connectV2){
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        buttonLoadingWidget("${S.of(context).g_connect_key13}..."),
      ],
    );
  }
  connectWidget(WalletConnectProvider connectV2){
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        connectButton(connectV2),
      ],
    );
  }
  connectButton(WalletConnectProvider connectV2){
    return Container(
      height: ScreenUtil().setWidth(150),
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(36.0),
        top: ScreenUtil().setWidth(26.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      child: buttonWidget(S.of(context).g_connect_key2,(){
        connectV2.disconnectOnTap();
        //viewState_deal(WalletConnectV2State.disconnect);
      }),
    );
  }
  disconnectWidget(WalletConnectProvider connectV2){
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              height: ScreenUtil().setWidth(160),
              width: ScreenUtil().setWidth(160),
              child: Image.asset("assets/wallet/icon_net.png",color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),),
            ),
          ),
        ),
        disconnectButton(connectV2),
      ],
    );
  }
  disconnectButton(WalletConnectProvider connectV2){
    return Container(
      height: ScreenUtil().setWidth(150),
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(36.0),
        top: ScreenUtil().setWidth(26.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: buttonWidget(
              S.of(context).g_key_79, (){
              connectV2.cleanData();
              Navigator.pop(context,false);
            },
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(30),),
          Expanded(
            flex: 1,
            child: buttonWidget(
              S.of(context).g_key_4, ()async{
              String scanStr=await scan();
              if(scanStr.contains('relay-protocol') && scanStr.contains('symKey')){
                connectV2.viewState_deal(WalletConnectState.loading,params: scanStr);
              }else{
                ToastUtils.show(S.of(context).g_key_203);
              }
            },
            ),
          ),
        ],
      ),
    );
  }
  transactionOKWidget(WalletConnectProvider connectV2){
    return Column(
      children: [
        itemWidget("Network",connectV2.actionDataMap?['network']??""),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: ScreenUtil().setWidth(30),
          endIndent: ScreenUtil().setWidth(30),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget("Form",connectV2.actionDataMap?['from']??""),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: ScreenUtil().setWidth(30),
          endIndent: ScreenUtil().setWidth(30),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget("To",connectV2.actionDataMap?['to']??""),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: ScreenUtil().setWidth(30),
          endIndent: ScreenUtil().setWidth(30),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget("Data",connectV2.actionDataMap?['data']??""),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: ScreenUtil().setWidth(30),
          endIndent: ScreenUtil().setWidth(30),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        transactionOKButton(connectV2),
      ],
    );
  }
  transactionOKButton(WalletConnectProvider connectV2){
    if(connectV2.walletConnectState==WalletConnectState.transactionOK)
      return Container(
        height: ScreenUtil().setWidth(150),
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: ScreenUtil().setWidth(36.0),
          top: ScreenUtil().setWidth(26.0),
          left: ScreenUtil().setWidth(30),
          right: ScreenUtil().setWidth(30),
        ),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: buttonWidget(S.of(context).g_connect_key3,(){
                connectV2.cancelTap(WalletConnectState.transaction);
              }),
            ),
            SizedBox(width: ScreenUtil().setWidth(30),),
            Expanded(
              flex: 1,
              child: buttonWidget(S.of(context).g_key_78,(){
                connectV2.transactionSignTap();
              }),
            ),
          ],
        ),
      );
    if(connectV2.walletConnectState==WalletConnectState.transaction)
      return buttonLoadingWidget("${S.of(context).g_key_106}...");
  }
  messageSignOKWidget(WalletConnectProvider connectV2){
    return Column(
      children: [
        itemWidget("Network",connectV2.actionDataMap?['network']??""),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: ScreenUtil().setWidth(30),
          endIndent: ScreenUtil().setWidth(30),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget("Address",connectV2.actionDataMap?['from']??""),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: ScreenUtil().setWidth(30),
          endIndent: ScreenUtil().setWidth(30),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget("Data",connectV2.actionDataMap?['data']??""),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: ScreenUtil().setWidth(30),
          endIndent: ScreenUtil().setWidth(30),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        messageSignOKButton(connectV2),
      ],
    );
  }
  messageSignOKButton(WalletConnectProvider connectV2){
    if(connectV2.walletConnectState==WalletConnectState.messageSignOK)
      return Container(
        height: ScreenUtil().setWidth(150),
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: ScreenUtil().setWidth(36.0),
          top: ScreenUtil().setWidth(26.0),
          left: ScreenUtil().setWidth(30),
          right: ScreenUtil().setWidth(30),
        ),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: buttonWidget(S.of(context).g_connect_key3,(){
                connectV2.cancelTap(WalletConnectState.messageSign);
              }),
            ),
            SizedBox(width: ScreenUtil().setWidth(30),),
            Expanded(
              flex: 1,
              child: buttonWidget(S.of(context).g_key_78,(){
                connectV2.messageSignTap();
              }),
            ),
          ],
        ),
      );
    if(connectV2.walletConnectState==WalletConnectState.messageSign)
      return buttonLoadingWidget("${S.of(context).g_key_106}...");
  }
  errorWidget(WalletConnectProvider connectV2){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(ScreenUtil().setWidth(60)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(60)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Text(
            connectV2.errorMessage,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: SizedBox()),
        Container(
          height: ScreenUtil().setWidth(150),
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: ScreenUtil().setWidth(36.0),
            top: ScreenUtil().setWidth(26.0),
            left: ScreenUtil().setWidth(30),
            right: ScreenUtil().setWidth(30),
          ),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
          child: buttonWidget(
            S.of(context).g_key_nft_220, (){
            connectV2.cleannData_loginout();
            Navigator.pop(context,false);
          },
          ),
        ),
      ],
    );
  }
  buttonWidget(String title,dynamic onTap){
    return Container(
      width: double.infinity,
      height: ScreenUtil().setWidth(88.0),
      child: ButtonStyle2(context, (){
        onTap();
      }, title),
    );
  }
  buttonLoadingWidget(String title){
    return Container(
        height: ScreenUtil().setWidth(150),
        width: double.infinity,
        padding: EdgeInsets.only(
          bottom: ScreenUtil().setWidth(36.0),
          top: ScreenUtil().setWidth(26.0),
          left: ScreenUtil().setWidth(30),
          right: ScreenUtil().setWidth(30),
        ),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        child: Container(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Text(
            title,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(30.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name)
            ),
          ),
        )
    );
  }
  itemWidget(String title,String value){
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30),),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20),),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
