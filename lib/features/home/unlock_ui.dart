// ignore_for_file: invalid_use_of_protected_member
part of 'unlock.dart';

// ── Unlock page UI widgets ───────────────────────────────────────────────────

extension on _UnlockState {
  Widget buildUnlockWidget() {
    final lockState = ref.watch(screenLockProvider);

    String textspanStr = S.of(context).g_unlock_key2;
    List<Widget> columns = [];

    if (lockState.faceEnabled && faceShow == false) {
      columns.add(const Expanded(flex: 1, child: SizedBox()));
    } else if (lockState.gestureEnabled && faceShow && gestureShow == false) {
      columns.addAll([
        Container(
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
          width: double.infinity,
          height: ScreenUtil().setWidth(120.0),
          alignment: Alignment.center,
          child: Text(
            S.of(context).g_unlock_key3,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(44.0),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (gestureErrorCount != 0)
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
            padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
            width: double.infinity,
            height: ScreenUtil().setWidth(120.0),
            alignment: Alignment.center,
            child: Text(
              S.of(context).g_unlock_key4(3 - gestureErrorCount),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                fontSize: ScreenUtil().setSp(32.0),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          flex: 1,
          child: Center(
            child: SizedBox(
              height: ScreenUtil().setWidth(480.0),
              width: ScreenUtil().setWidth(480.0),
              child: GesturePassword(
                (String value) async {
                  if (lockState.verifyGesture(stringToIntArray(value))) {
                    check = true;
                    back();
                  } else {
                    gestureErrorCount++;
                    if (gestureErrorCount >= 3) {
                      setState(() {
                        gestureShow = true;
                      });
                    }
                  }
                },
                ScreenUtil().setWidth(160.0),
                answer: lockState.gesturePassword,
              ),
            ),
          ),
        ),
      ]);
    } else if (lockState.isLocked && faceShow && gestureShow && passwordShow == false) {
      columns.addAll(_buildPasswordUI(lockState));
    } else {
      textspanStr = "";
      columns.add(
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_unlock_key10(passwordUnlock),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Show biometric retry button on gesture/PIN steps when auth failed
    if (_biometricFailed && _biometricAvailable && lockState.faceEnabled) {
      columns.add(buildBiometricRetryButton());
    }

    columns.add(_buildBottomRichText(textspanStr));

    Widget stack = Stack(
      children: [
        Positioned(
          top: ScreenUtil().setWidth(120.0),
          bottom: ScreenUtil().setWidth(120.0),
          left: ScreenUtil().setWidth(30.0),
          right: ScreenUtil().setWidth(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns,
          ),
        ),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        body: stack,
      ),
    );
  }

  List<Widget> _buildPasswordUI(ScreenLockState lockState) {
    return [
      Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
        width: double.infinity,
        height: ScreenUtil().setWidth(120.0),
        alignment: Alignment.center,
        child: Text(
          S.of(context).g_unlock_key5,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(44.0),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      if (passwordErrorCount != 0)
        Container(
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
          width: double.infinity,
          height: ScreenUtil().setWidth(120.0),
          alignment: Alignment.center,
          child: Text(
            3 - passwordErrorCount == 1
                ? S.of(context).g_unlock_key8(3 - passwordErrorCount)
                : S.of(context).g_unlock_key6(3 - passwordErrorCount),
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              fontSize: ScreenUtil().setSp(32.0),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      Container(
        height: ScreenUtil().setWidth(120),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60.0)),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, int index) {
            double width = (MediaQuery.of(context).size.width - ScreenUtil().setWidth(180.0)) / 6;
            bool isInput = inputPassword.length >= index + 1;
            return Container(
              width: width,
              height: ScreenUtil().setWidth(36.0),
              alignment: Alignment.center,
              child: Container(
                height: ScreenUtil().setWidth(36.0),
                width: ScreenUtil().setWidth(36.0),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                      context, isInput ? AppThemeKeys.mainBlueColor.name : AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(36.0))),
                ),
              ),
            );
          },
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(120.0)),
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(12, (index) {
              Widget childWidget;
              String title = "";
              if (index == 10) {
                childWidget = const SizedBox();
              } else if (index == 11) {
                childWidget = Icon(
                  Icons.close,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  size: ScreenUtil().setWidth(48.0),
                );
              } else {
                title = "${index == 9 ? 0 : index + 1}";
                childWidget = Text(
                  title,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(48.0),
                  ),
                );
              }
              return InkWell(
                onTap: () {
                  if (index == 10) {
                    // empty button — no action
                  } else if (index == 11) {
                    if (inputPassword == "") return;
                    inputPassword = inputPassword.substring(0, inputPassword.length - 1);
                  } else {
                    inputPassword = '$inputPassword$title';
                    if (inputPassword.length == 6) {
                      checkPwd();
                    }
                  }
                  setState(() {});
                },
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: childWidget,
                ),
              );
            }),
          ),
        ),
      ),
    ];
  }

  Widget _buildBottomRichText(String textspanStr) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(12.0)),
      width: double.infinity,
      alignment: Alignment.center,
      child: RichText(
        maxLines: 3,
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
            text: textspanStr,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26.0),
            ),
          ),
          TextSpan(
            text: S.of(context).g_unlock_key9,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26.0),
            ),
          ),
          TextSpan(
            text: S.of(context).g_key_login,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              fontSize: ScreenUtil().setSp(30.0),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                String tokenId = AppGlobals.userInfo?.token ?? "";
                await Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                if (AppGlobals.userInfo != null) {
                  if ((AppGlobals.userInfo?.token ?? "") != tokenId) {
                    check = true;
                    back();
                  }
                }
              },
          ),
        ]),
      ),
    );
  }
}
