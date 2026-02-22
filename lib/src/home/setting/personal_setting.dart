import 'dart:typed_data';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/home/setting/account_logout_page.dart';
import 'package:n42appv2/src/home/setting/change_email_page.dart';
import 'package:n42appv2/src/wallet/services/ens_service.dart';
import 'package:n42appv2/src/home/widgets/nav_select_image.dart';
import 'package:n42appv2/src/home/widgets/nav_setting_item.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalSetting extends ConsumerStatefulWidget {
  const PersonalSetting({super.key});

  @override
  ConsumerState<PersonalSetting> createState() => _PersonalSettingState();
}

class _PersonalSettingState extends ConsumerState<PersonalSetting> {
  Uint8List? imageEdit;
  bool isEdit = false;
  UserInfo? userInfo;
  Load load = Load.finish;
  String? _ensName;
  bool _ensLoading = false;

  TextEditingController nicknameEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  FocusNode nicknameFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  String nickNameErrorMessage="";
  String descriptionErrorMessage="";

  @override
  void initState() {
    super.initState();
    userInfo = AppGlobals.userInfo;
    nicknameEditingController.text = userInfo?.name??"";
    descriptionEditingController.text = userInfo?.desc??"";
    _resolveEnsName();
  }

  Future<void> _resolveEnsName() async {
    final addr = userInfo?.walletAddr ?? '';
    if (addr.isEmpty) return;
    setState(() => _ensLoading = true);
    try {
      final name = await EnsServiceProvider.instance.resolveAddress(addr);
      if (mounted && name != null && name.isNotEmpty) {
        setState(() => _ensName = name);
      }
    } catch (_) {
      // ENS 解析失败不影响页面正常使用
    } finally {
      if (mounted) setState(() => _ensLoading = false);
    }
  }

  Future<void> saveUserInfo() async {
    try {
      if (load == Load.loading) return;
      setState(() {
        load = Load.loading;
      });
      if(userInfo!.name != null && userInfo!.name !=""){
        if(userInfo!.name!.length > 50){
          setState(() {
            nickNameErrorMessage=S.of(context).nicknameMessage("50");
          });
          return;
        }else{
          setState(() {nickNameErrorMessage="";});
        }
      }
      if(userInfo!.desc != null && userInfo!.desc !=""){
        if(userInfo!.desc!.length>1000){
          setState(() {
            descriptionErrorMessage=S.of(context).nicknameMessage("1000");
          });
          return;
        }else{
          setState(() {descriptionErrorMessage="";});

        }
      }
      MessageModel r = await ref.read(userProfileProvider).editUserInfo(userInfo!, imageData: imageEdit);
      if (!mounted) return;
      if (r.error == false) {
        ToastUtils.showSuccess(S.of(context).g_key_185);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        ToastUtils.show(r.data);
      }
    } catch (e) {
      ToastUtils.show(e.toString());
    } finally {
      setState(() {
        load=Load.finish;
      });
    }
  }

  @override
  void dispose() {
    nicknameFocusNode.dispose();
    descriptionFocusNode.dispose();
    nicknameEditingController.dispose();
    descriptionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(
        text: S.of(context).personalInformation,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(60.0),
                    ),
                    child: Container(
                      width: ScreenUtil().setWidth(132.0),
                      height: ScreenUtil().setWidth(132.0),
                      //超出部分，可裁剪
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(66.0)),
                      ),
                      child: imageEdit == null
                          ? ImageNetWork(
                        imageUrl: userInfo?.image??"",
                        placeholder: "assets/img/person_def_1.png",
                      )
                          : Image.memory(imageEdit!),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        ///更换头像
                        sheetBottom(context, "", NavSelectImage(returnImage: (img) {
                          setState(() {
                            imageEdit = img;
                            isEdit = true;
                          });
                          Navigator.pop(context);
                        }));
                      },
                      child: Text(
                        S.of(context).editPhoto,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(30.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(80.0),
                    ),
                    child: Text(
                      S.of(context).g_key_u_2, //昵称
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: ScreenUtil().setWidth(80.0),
                      maxHeight: ScreenUtil().setWidth(80.0),
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              width: ScreenUtil().setWidth(1.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemLineColor.name),
                            ))),
                    child: TextField(
                      //key: _toKey,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                      ),
                      controller: nicknameEditingController,
                      focusNode: nicknameFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),),
                        hintText: S.of(context).nicknameMessage("50"),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffix: Text(
                          "${nicknameEditingController.text.length}/${50}",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20.0),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                      ),
                      maxLines: 1,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(descriptionFocusNode);
                      },
                      onChanged: (value) {
                        setState(() {
                          userInfo!.name = value;
                        });
                      },
                    ),
                  ),
                  if(nickNameErrorMessage != "")
                    Text(
                      nickNameErrorMessage,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                        fontSize: ScreenUtil().setSp(26.0),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(40.0),
                    ),
                    child: Text(
                      S.of(context).g_key_u_3, //昵称
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    //alignment: Alignment.centerLeft,
                    constraints: BoxConstraints(
                      minHeight: ScreenUtil().setWidth(80.0),
                      maxHeight: ScreenUtil().setWidth(240.0),
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              width: ScreenUtil().setWidth(1.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemLineColor.name),
                            ))),
                    child: TextField(
                      //key: _toKey,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                      ),
                      controller: descriptionEditingController,
                      focusNode: descriptionFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                        hintText: S.of(context).nicknameMessage("1000"),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffix: Text(
                          "${descriptionEditingController.text.length}/${1000}",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20.0),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(nicknameFocusNode);
                      },
                      onChanged: (value) {
                        setState(() {
                          userInfo!.desc = value;
                        });
                      },
                    ),
                  ),
                  if(descriptionErrorMessage != "")
                    Text(
                      descriptionErrorMessage,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                        fontSize: ScreenUtil().setSp(26.0),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(40.0),
                    ),
                    child: Text(
                      S.of(context).login_email, //昵称
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangeEmailPage()),
                      );
                      if (changed == true && mounted) {
                        setState(() {
                          userInfo = AppGlobals.userInfo;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(20.0)),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                width: ScreenUtil().setWidth(1.0),
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.itemLineColor.name),
                              ))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              userInfo?.email ?? '',
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(context,
                                    AppThemeKeys.itemSubtitleTextColor.name),
                                fontSize: ScreenUtil().setSp(30.0),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                            size: ScreenUtil().setSp(36.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(40.0),
                    ),
                    child: Text(
                      "UUID", //昵称
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              width: ScreenUtil().setWidth(1.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemLineColor.name),
                            ))),
                    child: Text(
                      userInfo?.uuid??"",
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  // ── ENS Name ────────────────────────────────────────────
                  if ((userInfo?.walletAddr ?? '').isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(40.0),
                      ),
                      child: Text(
                        "ENS Name",
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(20.0)),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                width: ScreenUtil().setWidth(1.0),
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.itemLineColor.name),
                              ))),
                      child: _ensLoading
                          ? SizedBox(
                              width: ScreenUtil().setSp(32.0),
                              height: ScreenUtil().setSp(32.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppThemeUtils.getColorByKey(context,
                                    AppThemeKeys.mainBlueColor.name),
                              ),
                            )
                          : Text(
                              _ensName ?? '—',
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context,
                                    _ensName != null
                                        ? AppThemeKeys.mainBlueColor.name
                                        : AppThemeKeys
                                            .itemSubtitleTextColor.name),
                                fontSize: ScreenUtil().setSp(30.0),
                              ),
                            ),
                    ),
                  ],
                  SizedBox(
                    height: ScreenUtil().setWidth(240.0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(30.0),
              child: SafeArea(
                child: Container(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                  padding: EdgeInsets.only(
                    bottom: ScreenUtil().setWidth(36.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: buttonStyle1(context, (){
                              if(load==Load.loading)return;
                              Navigator.pop(context);
                            },
                              S.of(context).g_key_79,),
                          ),
                          SizedBox(
                            width: ScreenUtil().setSp(30.0),
                          ),
                          Expanded(
                            flex: 1,
                            child: buttonStyle6(
                                context, (){
                              saveUserInfo();
                            },
                                S.of(context).g_key_115,
                                AppThemeUtils.getColorByKey(context, load==Load.finish?AppThemeKeys.mainButtonBgColor.name:AppThemeKeys.mainButtonBgColor3.name),
                                AppThemeUtils.getColorByKey(context,AppThemeKeys.mainButtonTextColor.name),
                              load==Load.loading,
                            ),
                          ),
                        ],
                      ),
                      //账号注销
                      NavSettingItem(
                        path: "assets/home/setting/nav_unregister.png",
                        action: S.of(context).g_key_wallet_m8,
                        imgColor: Colors.blueAccent,
                        callback: () {
                          //钱包不存在或者未登录
                          if (AppGlobals.userInfo ==null){
                            ToastUtils.show(S.of(context).login_need_login);
                            return;
                          }
                          Navigator
                              .push(context,MaterialPageRoute(
                              builder: (_) => const AccountLogoutPage()));
                        },
                      ),
                    ],
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}
