// ignore_for_file: invalid_use_of_protected_member
part of 'personal_setting.dart';

// ── Personal setting field widgets ───────────────────────────────────────────

extension on _PersonalSettingState {
  // ── 主题色快捷访问 ──────────────────────────────────────────────────────────
  Color get _blueColor =>
      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
  Color get _mainTextColor =>
      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
  Color get _subtitleColor =>
      AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);

  // ── 复用样式 ────────────────────────────────────────────────────────────────
  TextStyle get _subtitleStyle => TextStyle(
        color: _subtitleColor,
        fontSize: ScreenUtil().setSp(30.0),
      );

  // ── Avatar ──────────────────────────────────────────────────────────────────

  Widget buildAvatar() {
    final size = ScreenUtil().setWidth(132.0);
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
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
            color: _blueColor,
            fontSize: ScreenUtil().setSp(30.0),
          ),
        ),
      ),
    );
  }

  // ── Text fields (nickname / description) ────────────────────────────────────

  Widget buildNicknameField() => _buildTextField(
        controller: nicknameEditingController,
        focusNode: nicknameFocusNode,
        maxLimit: 50,
        maxHeight: ScreenUtil().setWidth(80.0),
        maxLines: 1,
        onSubmitted: () =>
            FocusScope.of(context).requestFocus(descriptionFocusNode),
        onChanged: (v) => setState(() => userInfo!.name = v),
      );

  Widget buildDescriptionField() => _buildTextField(
        controller: descriptionEditingController,
        focusNode: descriptionFocusNode,
        maxLimit: 1000,
        maxHeight: ScreenUtil().setWidth(240.0),
        maxLines: null,
        onSubmitted: () =>
            FocusScope.of(context).requestFocus(nicknameFocusNode),
        onChanged: (v) => setState(() => userInfo!.desc = v),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required int maxLimit,
    required double maxHeight,
    required int? maxLines,
    required VoidCallback onSubmitted,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: ScreenUtil().setWidth(80.0),
        maxHeight: maxHeight,
      ),
      decoration: _bottomBorder,
      child: TextField(
        style: TextStyle(color: _mainTextColor),
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(10.0)),
          hintText: S.of(context).nicknameMessage("$maxLimit"),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffix: Text(
            "${controller.text.length}/$maxLimit",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20.0),
              color: _subtitleColor,
            ),
          ),
        ),
        maxLines: maxLines,
        onSubmitted: (_) => onSubmitted(),
        onChanged: onChanged,
      ),
    );
  }

  // ── Info rows ───────────────────────────────────────────────────────────────

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
      child: _buildInfoRowContainer(
        child: Row(
          children: [
            Expanded(child: Text(userInfo?.email ?? '', style: _subtitleStyle)),
            Icon(Icons.chevron_right, color: _subtitleColor,
                size: ScreenUtil().setSp(36.0)),
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
      child: _buildInfoRowContainer(
        child: Row(
          children: [
            Expanded(
              child: Text(userInfo?.inviteCode ?? '', style: _subtitleStyle),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: userInfo?.inviteCode ?? ''));
                ToastUtils.showSuccess(S.of(context).copy);
              },
              child: Icon(Icons.copy, color: _blueColor,
                  size: ScreenUtil().setSp(32.0)),
            ),
            SizedBox(width: ScreenUtil().setWidth(8.0)),
            Icon(Icons.chevron_right, color: _subtitleColor,
                size: ScreenUtil().setSp(36.0)),
          ],
        ),
      ),
    );
  }

  Widget buildUuidRow() {
    return _buildInfoRowContainer(
      child: Text(userInfo?.uuid ?? "", style: _subtitleStyle),
    );
  }

  Widget buildEnsRow() {
    return _buildInfoRowContainer(
      child: _ensLoading
          ? SizedBox(
              width: ScreenUtil().setSp(32.0),
              height: ScreenUtil().setSp(32.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _blueColor,
              ),
            )
          : Text(
              _ensName ?? '\u2014',
              style: TextStyle(
                color: _ensName != null ? _blueColor : _subtitleColor,
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),
    );
  }

  /// 信息行统一容器（底部分隔线 + 内边距 + 左对齐）
  Widget _buildInfoRowContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
      decoration: _bottomBorder,
      child: child,
    );
  }

  // ── Bottom buttons ──────────────────────────────────────────────────────────

  Widget buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: ScreenUtil().setWidth(30.0),
      right: ScreenUtil().setWidth(30.0),
      child: SafeArea(
        child: Container(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(36.0)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
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
