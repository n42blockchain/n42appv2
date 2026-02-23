import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/add_watch_wallet_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_keystore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class CreateWalletButton extends StatefulWidget {
  final dynamic onTapBack;
  const CreateWalletButton({this.onTapBack,super.key});

  @override
  State<CreateWalletButton> createState() => _CreateWalletButtonState();
}

class _CreateWalletButtonState extends State<CreateWalletButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Container(
            height: ScreenUtil().setWidth(80),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context).g_key_wallet_c32,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(36.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
          ),
          InkWell(
            onTap: ()async{
              await Navigator.pushNamed(this.context, '/CreateOne');
              if (!mounted) return;
              Navigator.of(this.context).pop();
              if(widget.onTapBack!=null){
                widget.onTapBack();
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
              await Navigator.pushNamed(this.context, '/ImportOne');
              if (!mounted) return;
              Navigator.of(this.context).pop();
              if(widget.onTapBack!=null){
                widget.onTapBack();
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
              await Navigator.of(this.context).push(MaterialPageRoute(
                  builder: (_) => ImportKeystore()));
              if (!mounted) return;
              Navigator.of(this.context).pop();
              if(widget.onTapBack!=null){
                widget.onTapBack();
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
          // ── iCloud / Google Drive 加密备份导入 ──────────────────────────
          InkWell(
            onTap: () async {
              await Navigator.of(this.context).push(MaterialPageRoute(
                  builder: (_) => const ImportCloudBackup()));
              if (!mounted) return;
              Navigator.of(this.context).pop();
              if (widget.onTapBack != null) {
                widget.onTapBack();
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
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                    child: Icon(
                      Icons.cloud_download_outlined,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
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
                          'Cloud Backup',
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(36),
                          ),
                        ),
                        Text(
                          'Import from iCloud / Google Drive',
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(26),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: ScreenUtil().setWidth(30),
            endIndent: ScreenUtil().setWidth(30),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
          // ── 观察钱包 ──────────────────────────────────────────────────────
          InkWell(
            onTap: () async {
              final ok = await Navigator.of(this.context).push<bool>(
                  MaterialPageRoute(builder: (_) => const AddWatchWalletPage()));
              if (!mounted) return;
              Navigator.of(this.context).pop();
              if (ok == true && widget.onTapBack != null) {
                widget.onTapBack();
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
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                    child: Icon(
                      Icons.visibility_outlined,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
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
                          S.of(context).g_key_watch_wallet,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(36),
                          ),
                        ),
                        Text(
                          S.of(context).g_key_watch_wallet_desc,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: ScreenUtil().setWidth(30),
            endIndent: ScreenUtil().setWidth(30),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
          InkWell(
            onTap: ()async{
              await Navigator.pushNamed(this.context, '/ImportPrivatekey');
              if (!mounted) return;
              Navigator.of(this.context).pop();
              if(widget.onTapBack!=null){
                widget.onTapBack();
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
    );
  }
}
