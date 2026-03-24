part of 'wallet_list.dart';

mixin _WalletListFaceMixin on ConsumerState<WalletList> {
  int fbwIndex = -1;
  bool fbwCheck = true;
  String fbwCheckAddress = "";

  _WalletListState get _state => this as _WalletListState;

  void checkFaceBindingWallet() {
    fbwIndex = -1;
    fbwCheck = true;
    fbwCheckAddress = "";
    fbwIndex = _state.walletList.indexWhere(
      (e) => e.faceBinding == true && walletSupportsFaceBinding(e),
    );
  }

  Future<String?> _generateLegacyAddress(WalletInfo info) async {
    final coinInfo = faceBindingChainConfig(info);
    if (coinInfo == null) return null;
    final pathIndex = coinInfo['pathIndex'] ?? 0;
    final path = getPathWithIndex(
      coinInfo["baseInfo"]["path"]["legacy"],
      pathIndex,
    );
    final addressMap = await Trustdart().generateAddress(
      coinInfo["baseInfo"]['coinType'],
      path,
      'legacy',
      mnemonic: info.mnemonic ?? "",
      pk: info.privateKey ?? "",
    );
    final address = addressMap['legacy']?.toString() ?? '';
    if (address.isEmpty) return null;
    return address;
  }

  Future<String?> _matchFace() async {
    if (_state.load == Load.loading) return null;
    final rData = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => FaceMatch(2)),
    );
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
      if (legacyAddr == null) continue;
      if (addr.toUpperCase() == legacyAddr.toUpperCase()) {
        _state.fbwCheck = true;
        _state.fbwIndex = i;
        ref.read(wapBridgeProvider).setWalletFaceBinding(_state.fbwIndex);
        break;
      }
    }
    _state.fbwCheckAddress = addr;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> verify() async {
    final rData = await _matchFace();
    if (rData == null) return;
    await checkFaceBindAddress(rData);
  }

  Future<void> unbind() async {
    final rData = await _matchFace();
    if (rData == null) return;

    setState(() {
      _state.load = Load.loading;
    });
    final legacyAddr = await _generateLegacyAddress(
      _state.walletList[_state.fbwIndex],
    );
    if (legacyAddr == null) {
      if (!mounted) return;
      ToastUtils.show(
        S
            .of(context)
            .g_face_match_key32(
              _state.walletList[_state.fbwIndex].walletName ?? '',
            ),
      );
      setState(() {
        _state.load = Load.finish;
        _state.fbwIndex = -1;
      });
      return;
    }
    final rmm = await FaceApi().deleteBinding(legacyAddr);
    if (!mounted) return;
    if (rmm.error) {
      ToastUtils.show(S.of(context).g_face_match_key35);
    } else {
      ref
          .read(wapBridgeProvider)
          .setWalletFaceBinding(_state.fbwIndex, faceBinding: false);
      _state.fbwIndex = -1;
    }
    setState(() {
      _state.load = Load.finish;
    });
  }

  Future<void> bind() async {
    if (_state.load == Load.loading) return;
    final rData = await Navigator.push<MessageModel>(
      context,
      MaterialPageRoute(builder: (context) => FaceUserNotice()),
    );
    if (!mounted) return;
    if (rData != null && !rData.error) {
      if (!mounted) return;
      await _state.initData();
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  Widget _faceButtonRow(
    String leftLabel,
    VoidCallback onLeft,
    String rightLabel,
    VoidCallback onRight,
  ) {
    return Row(
      children: [
        Expanded(child: faceBindButton(leftLabel, onLeft)),
        SizedBox(width: ScreenUtil().setWidth(30)),
        Expanded(child: faceBindButton(rightLabel, onRight)),
      ],
    );
  }

  Widget _buildFaceBind() {
    final List<Widget> cList = [];

    if (_state.fbwIndex == -1) {
      if (_state.fbwCheck) {
        cList.addAll([
          faceBindText(
            S.of(context).g_face_match_key15,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
          ),
          _faceButtonRow(
            S.of(context).g_face_match_key13,
            bind,
            S.of(context).g_face_match_key14,
            verify,
          ),
        ]);
      } else {
        cList.addAll([
          faceBindText(
            S.of(context).g_face_match_key16,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
          ),
          SizedBox(
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
          ),
          _faceButtonRow(
            S.of(context).g_token_m_key_9,
            () async {
              await Navigator.pushNamed(context, '/ImportOne');
              if (!mounted) return;
              await _state.initData();
            },
            S.of(context).g_face_match_key12,
            bind,
          ),
        ]);
      }
    } else {
      WalletInfo info = _state.walletList[_state.fbwIndex];
      cList.addAll([
        Row(
          children: [
            Image.asset(
              "assets/img/ast.png",
              width: ScreenUtil().setWidth(70.0),
            ),
            SizedBox(width: ScreenUtil().setWidth(20.0)),
            Expanded(
              child: Text(
                info.walletName ?? "-",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemTextColor.name,
                  ),
                  fontSize: ScreenUtil().setSp(40.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        faceBindText(S.of(context).g_face_match_key17),
        _faceButtonRow(
          S.of(context).g_face_match_key12,
          bind,
          S.of(context).g_face_match_key33,
          unbind,
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
      margin:
          margin ?? EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
      child: Text(
        value,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemSubtitleTextColor.name,
          ),
        ),
      ),
    );
  }
}
