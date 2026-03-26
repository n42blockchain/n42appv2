// ignore_for_file: invalid_use_of_protected_member
part of 'security_setting.dart';

// ── Security setting widget components ───────────────────────────────────────

extension on _SecuritySettingState {
  Widget buildRowItemNew(String title, bool open, Function callback) {
    return InkWell(
      onTap: () => callback(),
      child: Container(
        height: ScreenUtil().setWidth(88.0),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemBgColor.name,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
              child: Image.asset(
                "assets/home/setting/scurity/${open ? "open" : "closs"}.png",
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                  fontSize: ScreenUtil().setSp(26.0),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(40.0),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOpenLockScreenWidget(ScreenLockState screenLockState) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(ScreenUtil().setWidth(8.0)),
        ),
      ),
      constraints: BoxConstraints(minHeight: ScreenUtil().setWidth(88.0)),
      child: Column(
        children: [
          buildOpenWidget(S.of(context).g_lock_key3, screenLockState.isLocked, (
            bool value,
          ) async {
            if (!screenLockState.isLocked) {
              bool? r = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LockScreenResetPassword(0),
                ),
              );
              if (!mounted) return;
              if (r == true) {
                ref.read(screenLockProvider.notifier).setLockEnabled(value);
              }
            } else {
              ref.read(screenLockProvider.notifier).setLockEnabled(value);
            }
          }),
          if (screenLockState.isLocked) buildLockTime(screenLockState),
          if (screenLockState.isLocked)
            buildResetPassword(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LockScreenResetPassword(1),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget buildOpenGesturePasswordWidget(ScreenLockState screenLockState) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(ScreenUtil().setWidth(8.0)),
        ),
      ),
      constraints: BoxConstraints(minHeight: ScreenUtil().setWidth(88.0)),
      child: Column(
        children: [
          buildOpenWidget(
            S.of(context).g_lock_key16,
            screenLockState.gestureEnabled,
            (bool value) async {
              if (!screenLockState.gestureEnabled) {
                String? r = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GesturePasswordSetting(0),
                  ),
                );
                if (!mounted) return;
                if (r != null) {
                  ref.read(screenLockProvider.notifier).setGestureEnabled(true);
                  final passwordList = r.split(',').map(int.parse).toList();
                  ref
                      .read(screenLockProvider.notifier)
                      .setGesturePassword(passwordList);
                }
              } else {
                ref.read(screenLockProvider.notifier).setGestureEnabled(value);
              }
            },
          ),
          if (screenLockState.gestureEnabled)
            buildResetPassword(() async {
              String? r = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GesturePasswordSetting(
                    1,
                    oldPassword: screenLockState.gesturePassword.join(','),
                  ),
                ),
              );
              if (!mounted) return;
              if (r != null) {
                final passwordList = r.split(',').map(int.parse).toList();
                ref
                    .read(screenLockProvider.notifier)
                    .setGesturePassword(passwordList);
              }
            }),
        ],
      ),
    );
  }

  Widget buildOpenFaceWidget(ScreenLockState screenLockState) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(ScreenUtil().setWidth(8.0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildOpenWidget(
            S.of(context).g_lock_key1,
            screenLockState.faceEnabled,
            (bool value) {
              if (checkBiometrics) {
                ref.read(screenLockProvider.notifier).setFaceEnabled(value);
              }
              setState(() {});
            },
          ),
          if (checkBiometrics == false) _buildBiometricUnavailableHint(),
        ],
      ),
    );
  }

  Widget _buildBiometricUnavailableHint() {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              S.of(context).g_lock_key7,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.errorTextColor.name,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              if (!mounted) return;
              initFace();
            },
            child: Text(
              S.of(context).g_face_5,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOpenWidget(String title, bool value, Function valueChange) {
    return Container(
      height: ScreenUtil().setWidth(88.0),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
          ),
          Switch(
            activeTrackColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonBgColor.name,
            ),
            value: value,
            onChanged: (v) => valueChange(v),
          ),
        ],
      ),
    );
  }

  Widget buildLockTime(ScreenLockState screenLockState) {
    return InkWell(
      onTap: () => showLockTimeSheet(screenLockState),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                S.of(context).g_lock_key4,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
            ),
            Text(
              _formatLockTime(screenLockState.lockTimeSeconds),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_sharp,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
              size: ScreenUtil().setWidth(40.0),
            ),
          ],
        ),
      ),
    );
  }

  void showLockTimeSheet(ScreenLockState screenLockState) {
    sheetBottom(
      context,
      S.of(context).g_lock_key4,
      Container(
        margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0 * lockTimeList.length),
        child: ListView.separated(
          itemCount: lockTimeList.length,
          itemBuilder: (context, int index) {
            String title = lockTimeList[index];
            Color titleColor = AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            );
            bool isSame = false;
            if (title == screenLockState.lockTimeSeconds.toString()) {
              titleColor = AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              );
              isSame = true;
            }
            return InkWell(
              onTap: () {
                if (title != screenLockState.lockTimeSeconds.toString()) {
                  ref
                      .read(screenLockProvider.notifier)
                      .setLockTime(int.parse(title));
                }
                Navigator.pop(context);
              },
              child: SizedBox(
                height: ScreenUtil().setWidth(88.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatLockTime(int.parse(title)),
                      style: TextStyle(
                        color: titleColor,
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                    if (isSame)
                      SizedBox(
                        height: ScreenUtil().setWidth(40.0),
                        width: ScreenUtil().setWidth(40.0),
                        child: Icon(
                          Icons.check,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, int index) {
            return Divider(
              indent: 0,
              endIndent: 0,
              height: ScreenUtil().setWidth(1.0),
            );
          },
        ),
      ),
    );
  }

  Widget buildResetPassword(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                S.of(context).g_lock_key9,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
              size: ScreenUtil().setWidth(30.0),
            ),
          ],
        ),
      ),
    );
  }
}
