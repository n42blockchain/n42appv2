part of 'create_finish.dart';

mixin _CreateFinishContentMixin on ConsumerState<CreateFinish> {

  // 以下字段由 _CreateFinishState 声明，mixin 通过 abstract getter 访问
  Load get load;
  bool get exportKeystore;
  set exportKeystore(bool value);
  String get pageName;

  Widget _buildProgressIndicator() {
    if (load == Load.finish) return SizedBox();

    final isImport = widget.createMetod == "Import" || widget.createMetod == "PrivateKey";
    if (isImport) {
      return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _progressDot(width: 144.0),
            SizedBox(width: ScreenUtil().setWidth(20.0)),
            _progressDot(width: 144.0),
          ],
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _progressDot(width: 88.0),
          SizedBox(width: ScreenUtil().setWidth(20.0)),
          _progressDot(width: 88.0),
          SizedBox(width: ScreenUtil().setWidth(20.0)),
          _progressDot(width: 88.0),
          SizedBox(width: ScreenUtil().setWidth(20.0)),
          _progressDot(width: 88.0),
        ],
      ),
    );
  }

  Widget _progressDot({required double width}) {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(width),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        Positioned.fill(
          child: Visibility(
            visible: load==Load.loading,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0),bottom: ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0),),
                  alignment: Alignment.center,
                  child: Text(
                    (widget.createMetod=="Import" || widget.createMetod=="PrivateKey")?S.of(context).g_key_wallet_c13:S.of(context).g_key_wallet_c14,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(40.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(160.0),
                        width: ScreenUtil().setWidth(160.0),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(80.0)),
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: SizedBox(
                                height: ScreenUtil().setWidth(100.0),
                                width: ScreenUtil().setWidth(100.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                height: ScreenUtil().setWidth(100.0),
                                width: ScreenUtil().setWidth(100.0),
                                alignment: Alignment.center,
                                child: Container(
                                  height: ScreenUtil().setWidth(48.0),
                                  width: ScreenUtil().setWidth(48.0),
                                  decoration: BoxDecoration(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24.0)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset("assets/home/money.png",width: ScreenUtil().setWidth(28.0),height: ScreenUtil().setWidth(28.0),),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
        if(widget.createMetod=="Import" || widget.createMetod=="PrivateKey")
          Positioned.fill(
            child: Visibility(
              visible:load==Load.finish,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: ScreenUtil().setWidth(560.0),
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            "assets/wallet/create_finish.gif",
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: ScreenUtil().setWidth(50.0),
                          child: Container(
                            height: ScreenUtil().setWidth(200.0),
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/home/ast_big.png",
                              height: ScreenUtil().setWidth(200.0),
                              width: ScreenUtil().setWidth(200.0),
                              //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),

                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
                    child: Text(
                      S.of(context).g_key_wallet_c15,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(56.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                    child: Text(
                      S.of(context).g_key_wallet_c16,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor6.name),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        if(widget.createMetod=="Create")
          Positioned.fill(
            child: Visibility(
              visible: load==Load.finish,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: ScreenUtil().setWidth(320.0),
                    width: ScreenUtil().setWidth(320.0),
                    margin:EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
                    child: Image.asset(
                      "assets/home/create_successful.png",
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
                    child: Text(
                      widget.createMetod=="Create"?
                      S.of(context).g_key_wallet_c22:
                      S.of(context).g_key_wallet_c15,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(56.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                    child: Text(
                      widget.createMetod=="Create"?
                      S.of(context).g_key_wallet_c23:
                      S.of(context).g_key_wallet_c16,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor6.name),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(248),)
                  //Spacer(),
                  /*UserProtocol(
                  onChanged: (value) {
                    isSelectedUserProtocol = value;
                    setState(() {});
                  },
                ),*/
                ],
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Visibility(
            visible: load==Load.finish,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                Container(
                  height: ScreenUtil().setWidth(148.0),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                  width: double.infinity,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                  child: buttonStyle2(context,
                        (){
                      //eventBus.fire(EventPublic(EventPublicType.finishPage));
                          Navigator.popUntil(context,ModalRoute.withName(pageName));
                    },
                    S.of(context).g_key_wallet_c17,
                  ),
                ),
                if(widget.createMetod=="Create")
                  InkWell(
                    onTap: (){
                      setState(() {
                        exportKeystore=true;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(60.0)),
                      child: Text(
                        S.of(context).g_key_wallet_c24,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          decoration: TextDecoration.underline,
                          decorationColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportKeystoreContent() {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil().setWidth(320.0),
                width: ScreenUtil().setWidth(320.0),
                margin:EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
                child: Image.asset(
                  "assets/wallet/illustration.png",
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
                child: Text(
                  S.of(context).g_key_wallet_c25,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(56.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                child: Text(
                  S.of(context).g_key_wallet_c26,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor6.name),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).g_key_wallet_c27,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor7.name),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        S.of(context).g_key_wallet_c28,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor7.name),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        S.of(context).g_key_wallet_c29,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor7.name),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
              ),
              SizedBox(height: ScreenUtil().setWidth(248),)
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Visibility(
            visible: load==Load.finish,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                Container(
                  height: ScreenUtil().setWidth(148.0),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                  width: double.infinity,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                  child: buttonStyle2(context,
                        ()async{
                      await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletList()));
                      if (!mounted) return;
                      //eventBus.fire(EventPublic(EventPublicType.finishPage));
                      Navigator.popUntil(context,ModalRoute.withName(pageName));
                    },
                    S.of(context).g_key_wallet_c30,
                  ),
                ),
                InkWell(
                  onTap: (){
                    //eventBus.fire(EventPublic(EventPublicType.finishPage));
                    Navigator.popUntil(context,ModalRoute.withName(pageName));
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(60.0)),
                    child: Text(
                      S.of(context).g_key_wallet_c31,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        decoration: TextDecoration.underline,
                        decorationColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
