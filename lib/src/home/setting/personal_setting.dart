import 'package:flutter/services.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/home/setting/account_logout_page.dart';
import 'package:n42_wallet/src/home/setting/change_email_page.dart';
import 'package:n42_wallet/src/home/setting/setting_share.dart';
import 'package:n42_wallet/src/wallet/services/ens_service.dart';
import 'package:n42_wallet/src/home/widgets/nav_select_image.dart';
import 'package:n42_wallet/src/home/widgets/nav_setting_item.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/image_network.dart';
import 'package:n42_wallet/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
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
  String nickNameErrorMessage = "";
  String descriptionErrorMessage = "";

  @override
  void initState() {
    super.initState();
    userInfo = AppGlobals.userInfo;
    nicknameEditingController.text = userInfo?.name ?? "";
    descriptionEditingController.text = userInfo?.desc ?? "";
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

  /// 验证字段长度，返回错误信息（空字符串表示无错误）
  String _validateLength(String? value, int maxLength) {
    if (value != null && value.isNotEmpty && value.length > maxLength) {
      return S.of(context).nicknameMessage("$maxLength");
    }
    return "";
  }

  Future<void> saveUserInfo() async {
    try {
      if (load == Load.loading) return;
      setState(() => load = Load.loading);

      final nickError = _validateLength(userInfo!.name, 50);
      final descError = _validateLength(userInfo!.desc, 1000);
      setState(() {
        nickNameErrorMessage = nickError;
        descriptionErrorMessage = descError;
      });
      if (nickError.isNotEmpty || descError.isNotEmpty) return;

      MessageModel r = await ref
          .read(userProfileProvider)
          .editUserInfo(userInfo!, imageData: imageEdit);
      if (!mounted) return;
      if (r.error == false) {
        ToastUtils.showSuccess(S.of(context).g_key_185);
        if (mounted) Navigator.pop(context);
      } else {
        ToastUtils.show(r.data);
      }
    } catch (e) {
      ToastUtils.show(e.toString());
    } finally {
      setState(() => load = Load.finish);
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

  // ── 样式辅助 ────────────────────────────────────────────────────

  BoxDecoration get _bottomBorder => BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: ScreenUtil().setWidth(1.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemLineColor.name),
          ),
        ),
      );

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
      child: Text(
        text,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainBlueColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
      ),
    );
  }

  Widget _buildErrorText(String message) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Text(
      message,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name),
        fontSize: ScreenUtil().setSp(26.0),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

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
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  _buildEditPhotoButton(),
                  // 昵称标签使用额外的顶部间距
                  Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(80.0)),
                    child: Text(
                      S.of(context).g_key_u_2,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  _buildNicknameField(),
                  _buildErrorText(nickNameErrorMessage),
                  _buildFieldLabel(S.of(context).g_key_u_3),
                  _buildDescriptionField(),
                  _buildErrorText(descriptionErrorMessage),
                  _buildFieldLabel(S.of(context).login_email),
                  _buildEmailRow(),
                  if ((userInfo?.inviteCode ?? '').isNotEmpty) ...[
                    _buildFieldLabel(S.of(context).g_referral_invite_code),
                    _buildInviteCodeRow(),
                  ],
                  _buildFieldLabel(S.of(context).g_key_uuid),
                  _buildUuidRow(),
                  if ((userInfo?.walletAddr ?? '').isNotEmpty) ...[
                    _buildFieldLabel(S.of(context).g_key_ens_name),
                    _buildEnsRow(),
                  ],
                  SizedBox(height: ScreenUtil().setWidth(240.0)),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
      child: Container(
        width: ScreenUtil().setWidth(132.0),
        height: ScreenUtil().setWidth(132.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(66.0)),
        ),
        child: imageEdit == null
            ? ImageNetWork(
                imageUrl: userInfo?.image ?? "",
                placeholder: "assets/img/person_def_1.png",
              )
            : Image.memory(imageEdit!),
      ),
    );
  }

  Widget _buildEditPhotoButton() {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          sheetBottom(
            context,
            "",
            NavSelectImage(returnImage: (img) {
              setState(() {
                imageEdit = img;
                isEdit = true;
              });
              Navigator.pop(context);
            }),
          );
        },
        child: Text(
          S.of(context).editPhoto,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            fontSize: ScreenUtil().setSp(30.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNicknameField() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: ScreenUtil().setWidth(80.0),
        maxHeight: ScreenUtil().setWidth(80.0),
      ),
      decoration: _bottomBorder,
      child: TextField(
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
          contentPadding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(10.0)),
          hintText: S.of(context).nicknameMessage("50"),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffix: Text(
            "${nicknameEditingController.text.length}/50",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
        maxLines: 1,
        onSubmitted: (_) {
          FocusScope.of(context).requestFocus(descriptionFocusNode);
        },
        onChanged: (value) {
          setState(() => userInfo!.name = value);
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: ScreenUtil().setWidth(80.0),
        maxHeight: ScreenUtil().setWidth(240.0),
      ),
      decoration: _bottomBorder,
      child: TextField(
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
          contentPadding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(10.0)),
          hintText: S.of(context).nicknameMessage("1000"),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffix: Text(
            "${descriptionEditingController.text.length}/1000",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
        maxLines: null,
        onSubmitted: (_) {
          FocusScope.of(context).requestFocus(nicknameFocusNode);
        },
        onChanged: (value) {
          setState(() => userInfo!.desc = value);
        },
      ),
    );
  }

  Widget _buildEmailRow() {
    return InkWell(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const ChangeEmailPage()),
        );
        if (changed == true && mounted) {
          setState(() => userInfo = AppGlobals.userInfo);
        }
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20.0)),
        decoration: _bottomBorder,
        child: Row(
          children: [
            Expanded(
              child: Text(
                userInfo?.email ?? '',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              size: ScreenUtil().setSp(36.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCodeRow() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingShare()),
      ),
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20.0)),
        decoration: _bottomBorder,
        child: Row(
          children: [
            Expanded(
              child: Text(
                userInfo?.inviteCode ?? '',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: userInfo?.inviteCode ?? ''));
                ToastUtils.showSuccess(S.of(context).copy);
              },
              child: Icon(
                Icons.copy,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setSp(32.0),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8.0)),
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              size: ScreenUtil().setSp(36.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUuidRow() {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(20.0)),
      decoration: _bottomBorder,
      child: Text(
        userInfo?.uuid ?? "",
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
      ),
    );
  }

  Widget _buildEnsRow() {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(20.0)),
      decoration: _bottomBorder,
      child: _ensLoading
          ? SizedBox(
              width: ScreenUtil().setSp(32.0),
              height: ScreenUtil().setSp(32.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            )
          : Text(
              _ensName ?? '—',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                  context,
                  _ensName != null
                      ? AppThemeKeys.mainBlueColor.name
                      : AppThemeKeys.itemSubtitleTextColor.name,
                ),
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: ScreenUtil().setWidth(30.0),
      right: ScreenUtil().setWidth(30.0),
      child: SafeArea(
        child: Container(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          padding:
              EdgeInsets.only(bottom: ScreenUtil().setWidth(36.0)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: buttonStyle1(
                      context,
                      () {
                        if (load == Load.loading) return;
                        Navigator.pop(context);
                      },
                      S.of(context).g_key_79,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setSp(30.0)),
                  Expanded(
                    flex: 1,
                    child: buttonStyle6(
                      context,
                      saveUserInfo,
                      S.of(context).g_key_115,
                      AppThemeUtils.getColorByKey(
                        context,
                        load == Load.finish
                            ? AppThemeKeys.mainButtonBgColor.name
                            : AppThemeKeys.mainButtonBgColor3.name,
                      ),
                      AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonTextColor.name),
                      load == Load.loading,
                    ),
                  ),
                ],
              ),
              NavSettingItem(
                path: "assets/home/setting/nav_unregister.png",
                action: S.of(context).g_key_wallet_m8,
                imgColor: Colors.blueAccent,
                callback: () {
                  if (AppGlobals.userInfo == null) {
                    ToastUtils.show(S.of(context).login_need_login);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AccountLogoutPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
