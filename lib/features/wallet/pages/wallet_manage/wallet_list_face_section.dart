part of 'wallet_list.dart';

/// 人脸绑定区块的状态字段与方法，混入 [_WalletListState]。
mixin _WalletListFaceMixin on ConsumerState<WalletList> {
  int fbwIndex = -1;
  bool fbwCheck = true; // 验证钱包地址是否成功，默认成功
  String fbwCheckAddress = ""; // 验证钱包地址后，返回的地址

  void checkFaceBindingWallet() {
    fbwIndex = -1;
    fbwCheck = true;
    fbwCheckAddress = "";
    fbwIndex = (this as _WalletListState).walletList.indexWhere((e) {
      return e.faceBinding == true;
    });
  }

  Future<void> checkFaceBindAddress(String addr) async {
    final state = this as _WalletListState;
    state.fbwCheck = false;
    state.fbwIndex = -1;
    final walletList = state.walletList;
    for (int i = 0; i < walletList.length; i++) {
      WalletInfo info = walletList[i];
      Map coinInfo = info.coinInfo?[CoinType.N.name];
      int pathIndex = coinInfo['pathIndex'] ?? 0;
      final path =
          getPathWithIndex(coinInfo["baseInfo"]["path"]["legacy"], pathIndex);
      Map addressMap = await Trustdart().generateAddress(
        coinInfo["baseInfo"]['coinType'],
        path,
        'legacy',
        mnemonic: info.mnemonic ?? "",
        pk: info.privateKey ?? "",
      );
      if (!mounted) return;
      if (addr.toUpperCase() ==
          addressMap['legacy'].toString().toUpperCase()) {
        state.fbwCheck = true;
        state.fbwIndex = i;
        ref.read(wapBridgeProvider).setWalletFaceBinding(state.fbwIndex);
        break;
      }
    }
    state.fbwCheckAddress = addr;
    setState(() {});
  }

  Future<void> verify() async {
    final state = this as _WalletListState;
    if (state.load == Load.loading) return;
    String? rData = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => FaceMatch(2)));
    if (!mounted) return;
    if (rData != null) {
      checkFaceBindAddress(rData);
    } else {
      ToastUtils.show(S.of(context).g_face_match_key34);
    }
  }

  Future<void> unbind() async {
    final state = this as _WalletListState;
    if (state.load == Load.loading) return;

    String? rData = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => FaceMatch(2)));
    if (!mounted) return;
    if (rData == null) {
      ToastUtils.show(S.of(context).g_face_match_key34);
      return;
    }
    setState(() {
      state.load = Load.loading;
    });
    WalletInfo info = state.walletList[state.fbwIndex];
    Map coinInfo = info.coinInfo?[CoinType.N.name];
    int pathIndex = coinInfo['pathIndex'] ?? 0;
    final path =
        getPathWithIndex(coinInfo["baseInfo"]["path"]["legacy"], pathIndex);
    Map addressMap = await Trustdart().generateAddress(
      coinInfo["baseInfo"]['coinType'],
      path,
      'legacy',
      mnemonic: info.mnemonic ?? "",
      pk: info.privateKey ?? "",
    );
    MessageModel rmm =
        await FaceApi().deleteBinding(addressMap['legacy'].toString());
    if (!mounted) return;
    if (rmm.error) {
      ToastUtils.show(S.of(context).g_face_match_key35);
    } else {
      ref.read(wapBridgeProvider).setWalletFaceBinding(
            state.fbwIndex,
            faceBinding: false,
          );
      state.fbwIndex = -1;
    }
    setState(() {
      state.load = Load.finish;
    });
  }

  Future<void> bind() async {
    final state = this as _WalletListState;
    if (state.load == Load.loading) return;
    MessageModel? rData = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => FaceUserNotice()));
    if (!mounted) return;
    if (rData != null) {
      if (rData.error == false) {
        await state.initData();
      }
    }
  }

  // ── 人脸绑定区块 UI ──────────────────────────────────────────────────────

  Widget _buildFaceBind() {
    final state = this as _WalletListState;
    final List<Widget> cList = [];

    if (state.fbwIndex == -1) {
      if (state.fbwCheck) {
        // 未绑定且验证通过 → 显示绑定 + 验证按钮
        final Widget c4 = Row(
          children: [
            Expanded(
              flex: 1,
              child: faceBindButton(S.of(context).g_face_match_key13, bind),
            ),
            SizedBox(width: ScreenUtil().setWidth(30)),
            Expanded(
              flex: 1,
              child: faceBindButton(S.of(context).g_face_match_key14, verify),
            ),
          ],
        );
        cList.addAll([
          faceBindText(
            S.of(context).g_face_match_key15,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
          ),
          c4,
        ]);
      } else {
        // 验证失败 → 显示地址 + 导入 + 绑定按钮
        final Widget c1 = SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              faceBindText(
                "${S.of(context).g_key_address}:",
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
              ),
              faceBindText(
                state.fbwCheckAddress,
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
              ),
            ],
          ),
        );
        final Widget c4 = Row(
          children: [
            Expanded(
              flex: 1,
              child: faceBindButton(
                S.of(context).g_token_m_key_9,
                () async {
                  await Navigator.pushNamed(context, '/ImportOne');
                  await state.initData();
                },
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(30)),
            Expanded(
              flex: 1,
              child:
                  faceBindButton(S.of(context).g_face_match_key12, bind),
            ),
          ],
        );
        cList.addAll([
          faceBindText(
            S.of(context).g_face_match_key16,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
          ),
          c1,
          c4,
        ]);
      }
    } else {
      // 已绑定 → 显示绑定的钱包名 + 重绑 + 解绑按钮
      WalletInfo info = state.walletList[state.fbwIndex];
      final Widget c5 = Row(
        children: [
          Image.asset(
            "assets/img/ast.png",
            width: ScreenUtil().setWidth(70.0),
          ),
          SizedBox(width: ScreenUtil().setWidth(20.0)),
          Expanded(
            flex: 1,
            child: Text(
              info.walletName ?? "-",
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(40.0),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
      cList.addAll([
        c5,
        faceBindText(S.of(context).g_face_match_key17),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: faceBindButton(S.of(context).g_face_match_key12, bind),
            ),
            SizedBox(width: ScreenUtil().setWidth(30)),
            Expanded(
              flex: 1,
              child:
                  faceBindButton(S.of(context).g_face_match_key33, unbind),
            ),
          ],
        ),
      ]);
    }

    return containerStyle1(
      context,
      padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(20.0),
      ),
      child: Column(children: cList),
    );
  }

  Widget faceBindButton(String title, VoidCallback onTap) {
    return SizedBox(
      height: ScreenUtil().setWidth(80),
      width: double.infinity,
      child: buttonStyle2(context, onTap, title),
    );
  }

  Widget faceBindText(String value, {EdgeInsetsGeometry? margin}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: margin ??
          EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
      child: Text(
        value,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
      ),
    );
  }
}
