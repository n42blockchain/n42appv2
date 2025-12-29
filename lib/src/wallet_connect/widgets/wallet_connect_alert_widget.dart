import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as walletConnect;
import 'package:n42appv2/generated/l10n.dart';
class WalletConnectAlertWidget extends StatelessWidget {
  final walletConnect.PairingMetadata metadata;
  final Map<String,dynamic> actionDataMap;
  const WalletConnectAlertWidget(this.metadata,this.actionDataMap,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: ScreenUtil().setWidth(1000),
        child: Column(
          children: [
            //metadata
            Container(
              height: ScreenUtil().setWidth(100),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageNetWork(
                    imageUrl: metadata!.icons.length!=0?metadata!.icons[0]:"",
                    height: ScreenUtil().setWidth(80),
                    width: ScreenUtil().setWidth(80),
                    placeholder: "assets/img/list_default.png",
                  ),
                  //ImageWidget(metadata!.icons.length!=0?metadata!.icons[0]:"",height: ScreenUtil().setWidth(80),width: ScreenUtil().setWidth(80),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  Text(
                    metadata.name,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28),
                    ),
                  ),
                ],
              ),
            ),
            //title
            titleWidget(context),
            dAppConnectWidget(context),
          ],
        ),
      ),
    );
  }
  titleWidget(BuildContext context){
    String title="";
    if(actionDataMap['signType']=="message"){
      title=S.of(context).g_connect_key12;
    }else{
      title=S.of(context).s_key_3;
    }
    return Container(
      height: ScreenUtil().setWidth(100.0),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        ),
      ),
    );
  }
  dAppConnectWidget(BuildContext context){
    Widget connectChild;
    if(actionDataMap['signType']=="message"){
      connectChild=messageSignOKWidget(context);
    }else{
      connectChild=transactionOKWidget(context);
    }
    return Expanded(child: connectChild);
  }
  transactionOKWidget(BuildContext context){
    return Column(
      children: [
        itemWidget(context,"Network",actionDataMap['network']??""),
        Divider(
          height: ScreenUtil().setWidth(1.0),
          indent: ScreenUtil().setWidth(30.0),
          endIndent: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget(context,"Form",actionDataMap['from']??""),
        Divider(
          height: ScreenUtil().setWidth(1.0),
          indent: ScreenUtil().setWidth(30.0),
          endIndent: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget(context,"To",actionDataMap['to']??""),
        Divider(
          height: ScreenUtil().setWidth(1.0),
          indent: ScreenUtil().setWidth(30.0),
          endIndent: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget(context,"Data",actionDataMap['data']??""),
        Divider(
          height: ScreenUtil().setWidth(1.0),
          indent: ScreenUtil().setWidth(30.0),
          endIndent: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        Spacer(),
        transactionOKButton(context),
      ],
    );
  }
  transactionOKButton(BuildContext context){
    return Container(
      height: ScreenUtil().setWidth(150.0),
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(36.0),
        top: ScreenUtil().setWidth(26.0),
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(30.0),
      ),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: buttonWidget(context,S.of(context).g_connect_key3,(){
              Provider.of<WalletConnectProvider>(context,listen: false).cancelTap(WalletConnectState.transaction);
              Navigator.pop(context);
            }),
          ),
          SizedBox(width: ScreenUtil().setWidth(30.0),),
          Expanded(
            flex: 1,
            child: buttonWidget(context,S.of(context).g_key_78,(){
              Provider.of<WalletConnectProvider>(context,listen: false).transactionSignTap();
              Navigator.pop(context);
            }),
          ),
        ],
      ),
    );
  }
  messageSignOKWidget(BuildContext context){
    return Column(
      children: [
        itemWidget(context,"Network",actionDataMap['network']??""),
        Divider(
          height: ScreenUtil().setWidth(1.0),
          indent: ScreenUtil().setWidth(30.0),
          endIndent: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget(context,"Address",actionDataMap['from']??""),
        Divider(
          height: ScreenUtil().setWidth(1.0),
          indent: ScreenUtil().setWidth(30.0),
          endIndent: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        itemWidget(context,"Data",actionDataMap['data']??""),
        Divider(
          height: ScreenUtil().setWidth(1.0),
          indent: ScreenUtil().setWidth(30.0),
          endIndent: ScreenUtil().setWidth(30.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        messageSignOKButton(context),
      ],
    );
  }
  messageSignOKButton(BuildContext context){
    return Container(
      height: ScreenUtil().setWidth(150.0),
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(36.0),
        top: ScreenUtil().setWidth(26.0),
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(30.0),
      ),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: buttonWidget(context,S.of(context).g_connect_key3,(){
              Provider.of<WalletConnectProvider>(context,listen: false).cancelTap(WalletConnectState.messageSign);
              Navigator.pop(context);
            }),
          ),
          SizedBox(width: ScreenUtil().setWidth(30.0),),
          Expanded(
            flex: 1,
            child: buttonWidget(context,S.of(context).g_key_78,(){
              Provider.of<WalletConnectProvider>(context,listen: false).messageSignTap();
              Navigator.pop(context);
            }),
          ),
        ],
      ),
    );
  }
  buttonWidget(BuildContext context,String title,dynamic onTap){
    return Container(
      width: double.infinity,
      height: ScreenUtil().setWidth(88.0),
      child: ButtonStyle2(context, (){
        onTap();
      }, title),
    );
  }
  itemWidget(BuildContext context,String title,String value){
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0),),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20.0),),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
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