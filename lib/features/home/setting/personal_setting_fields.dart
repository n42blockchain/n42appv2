// ignore_for_file: invalid_use_of_protected_member
part of 'personal_setting.dart';

// ── Personal setting field widgets ───────────────────────────────────────────

extension on _PersonalSettingState {
  Widget buildAvatar() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
      child: Container(
        width: ScreenUtil().setWidth(132.0),
        height: ScreenUtil().setWidth(132.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(66.0)),
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

  Widget buildEditPhotoButton() {
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

  Widget buildNicknameField() {
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

  Widget buildDescriptionField() {
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

  Widget buildEmailRow() {
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

  Widget buildInviteCodeRow() {
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

  Widget buildUuidRow() {
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

  Widget buildEnsRow() {
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
              _ensName ?? '\u2014',
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

  Widget buildBottomButtons() {
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
