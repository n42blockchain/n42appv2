import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/keystore/import_keystore.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42appv2/src/wallet/widgets/Choose_import_coin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class CreateWalletButton extends StatelessWidget {
  dynamic onTap_back;
  CreateWalletButton({this.onTap_back=null,super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: ScreenUtil().setWidth(80),
            width: double.infinity,
            child: Text(
              S.of(context).g_key_wallet_c32,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(36.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.centerLeft,
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          ),
          InkWell(
            onTap: ()async{
              await Navigator.pushNamed(context, '/CreateOne');
              Navigator.of(context).pop();
              if(onTap_back!=null){
                onTap_back();
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                    child: Icon(
                      Icons.create_new_folder_outlined,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      size: ScreenUtil().setWidth(50),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).g_key_7,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(36),
                          ),
                        ),
                        Text(
                          S.of(context).g_key_wallet_c33,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: ScreenUtil().setWidth(30),
            endIndent: ScreenUtil().setWidth(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          ),
          InkWell(
            onTap: ()async{
              await Navigator.pushNamed(context, '/ImportOne');
              Navigator.of(context).pop();
              if(onTap_back!=null){
                onTap_back();
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                    child: Icon(
                      Icons.import_contacts,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      size: ScreenUtil().setWidth(50),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).g_token_m_key_9,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(36),
                          ),
                        ),
                        Text(
                          S.of(context).w_key_8,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ],
                    ),

                  )
                ],
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: ScreenUtil().setWidth(30),
            endIndent: ScreenUtil().setWidth(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          ),
          InkWell(
            onTap: ()async{
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ImportKeystore()));
              Navigator.of(context).pop();
              if(onTap_back!=null){
                onTap_back();
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                    child: Icon(
                      Icons.key,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      size: ScreenUtil().setWidth(50),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).g_key_keystore_22,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(36),
                          ),
                        ),
                        Text(
                          S.of(context).g_key_ex_keystore_15,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: ScreenUtil().setWidth(30),
            endIndent: ScreenUtil().setWidth(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          ),
          InkWell(
            onTap: ()async{
              await Navigator.pushNamed(context, '/ImportPrivatekey');
              Navigator.of(context).pop();
              if(onTap_back!=null){
                onTap_back();
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                    child: Icon(
                      Icons.key,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      size: ScreenUtil().setWidth(50),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).g_key_209,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(36),
                          ),
                        ),
                        Text(
                          S.of(context).g_key_209,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
