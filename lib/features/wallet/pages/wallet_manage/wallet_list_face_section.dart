part of 'wallet_list.dart';

/// 人脸绑定区块的状态字段与方法，混入 [_WalletListState]。
mixin _WalletListFaceMixin on ConsumerState<WalletList> {
  int fbwIndex = -1;
  bool fbwCheck = true; // 验证钱包地址是否成功，默认成功
  String fbwCheckAddress = ""; // 验证钱包地址后，返回的地址

  _WalletListState get _state => this as _WalletListState;

  void checkFaceBindingWallet() {
    fbwIndex = -1;
    fbwCheck = true;
    fbwCheckAddress = "";
    fbwIndex = _state.walletList.indexWhere((e) => e.faceBinding == true);
  }

  /// 根据钱包信息生成 legacy 地址
  Future<String> _generateLegacyAddress(WalletInfo info) async {
    final Map coinInfo = info.coinInfo?[CoinType.N.name];
    final pathIndex = coinInfo['pathIndex'] ?? 0;
    final path =
        getPathWithIndex(coinInfo["baseInfo"]["path"]["legacy"], pathIndex);
    final addressMap = await Trustdart().generateAddress(
      coinInfo["baseInfo"]['coinType'],
      path,
      'legacy',
      mnemonic: info.mnemonic ?? "",
      pk: info.privateKey ?? "",
    );
    return addressMap['legacy'].toString();
  }

  /// 人脸匹配导航，返回 null 表示匹配失败或未返回
  Future<String?> _matchFace() async {
    if (_state.load == Load.loading) return null;
    final rData = await Navigator.push<String>(
        context, MaterialPageRoute(builder: (context) => FaceMatch(2)));
    if (!mounted) return null;
    if (rData == null) {
      ToastUtils.show(S.of(context).g_face_match_key34);
    }
    return rData;
  }

  Future<void> checkFaceBindAddress(String addr) async {
    _state.fbwCheck = false;
    _state.fbwIndex = -1;
    final walletList = _state.walletList;
    for (int i = 0; i < walletList.length; i++) {
      final legacyAddr = await _generateLegacyAddress(walletList[i]);
      if (!mounted) return;
      if (addr.toUpperCase() == legacyAddr.toUpperCase()) {
        _state.fbwCheck = true;
        _state.fbwIndex = i;
        ref.read(wapBridgeProvider).setWalletFaceBinding(_state.fbwIndex);
        break;
      }
    }
    _state.fbwCheckAddress = addr;
    setState(() {});
  }

  Future<void> verify() async {
    final rData = await _matchFace();
    if (rData == null) return;
    checkFaceBindAddress(rData);
  }

  Future<void> unbind() async {
    final rData = await _matchFace();
    if (rData == null) return;

    setState(() {
      _state.load = Load.loading;
    });
    final legacyAddr =
        await _generateLegacyAddress(_state.walletList[_state.fbwIndex]);
    final rmm = await FaceApi().deleteBinding(legacyAddr);
    if (!mounted) return;
    if (rmm.error) {
      ToastUtils.show(S.of(context).g_face_match_key35);
    } else {
      ref.read(wapBridgeProvider).setWalletFaceBinding(
            _state.fbwIndex,
            faceBinding: false,
          );
      _state.fbwIndex = -1;
    }
    setState(() {
      _state.load = Load.finish;
    });
  }

  Future<void> bind() async {
    if (_state.load == Load.loading) return;
    final rData = await Navigator.push<MessageModel>(
        context, MaterialPageRoute(builder: (context) => FaceUserNotice()));
    if (!mounted) return;
    if (rData != null && !rData.error) {
      await _state.initData();
    }
  }

  // ── 人脸绑定区块 UI ──────────────────────────────────────────────────────

  Widget _buildFaceBind() {
    final List<Widget> cList = [];

    if (_state.fbwIndex == -1) {
      if (_state.fbwCheck) {
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
                _state.fbwCheckAddress,
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
                  await _state.initData();
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
      WalletInfo info = _state.walletList[_state.fbwIndex];
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
