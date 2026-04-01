part of 'swap_ast_home.dart';

extension _SwapAstHomeBuild on _SwapAstHomeState {
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_swap_key_33,
        actions: [
          Center(
            child: InkWell(
              onTap: () {
                closeKeyboard();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SwapAstTransactions()),
                );
              },
              child: SizedBox(
                height: ScreenUtil().setWidth(44),
                width: ScreenUtil().setWidth(44),
                child: Image.asset(
                  'assets/wallet/swap/record.png',
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          ),
          Center(
            child: InkWell(
              onTap: queryWidget,
              child: Container(
                height: ScreenUtil().setWidth(44),
                width: ScreenUtil().setWidth(44),
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  right: ScreenUtil().setWidth(30),
                  left: ScreenUtil().setWidth(10),
                ),
                child: Image.asset(
                  'assets/wallet/swap/doubt.png',
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (load == Load.finish || load == Load.error) {
                    await init();
                  }
                },
                backgroundColor: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
                displacement: ScreenUtil().setWidth(72.0),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SwapAstPayWidget(
                        payController: payTextEditingController,
                        payNode: payNode,
                        getNode: getNode,
                        youPay: youPay,
                        payCoinModel: payCoinModel,
                        token: token,
                        hasValidInput: checkPayInput(),
                        swapAstList: swapAstList,
                        regular: _regular,
                        onPayChanged: (v) => payInput(value: v),
                        onPayEditingComplete: payInput,
                        onChainSelected: _onChainSelected,
                        onAddToken: init,
                        onCloseKeyboard: closeKeyboard,
                      ),
                      SwapAstGetWidget(
                        getController: getTextEditingController,
                        getNode: getNode,
                        payNode: payNode,
                        getCoinModel: getCoinModel,
                        getLoad: getLoad,
                        onGetChanged: (v) => getInput(value: v),
                        onGetEditingComplete: getInput,
                      ),
                      SwapAstPriceWidget(
                        youPay: youPay,
                        getCoinModel: getCoinModel,
                        regular: _regular,
                      ),
                      SwapAstPercentWidget(onPercentTap: percentTap),
                      SwapAstMinerFeeWidget(
                        payCoinModel: payCoinModel,
                        totalGasPrice: totalGasPrice,
                        gasPrice: gasPrice,
                        gas: gas,
                      ),
                      SwapAstCheckWidget(
                        readStatement: readStatement,
                        onToggle: _toggleReadStatement,
                      ),
                      if (errorMessage.isNotEmpty) _errorWidget(context),
                      SizedBox(height: ScreenUtil().setWidth(130)),
                    ],
                  ),
                ),
              ),
            ),
            SwapAstPreviewButton(
              load: load,
              onPreview: _onPreviewSwap,
              onRetry: init,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
          fontSize: ScreenUtil().setSp(28),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void queryWidget() {
    sheetBottom(
      context,
      "",
      Container(
        height: ScreenUtil().setWidth(200),
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          S.of(context).g_swap_key_21,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _onPreviewSwap() async {
    closeKeyboard();
    if (load != Load.finish) return;
    if (!readStatement) return;
    if (!checkPayInput()) return;

    final bool gasOk = await estimateGasEth();
    if (!mounted) return;
    if (!gasOk || errorMessage.isNotEmpty) return;

    final bool orderOk = await newOrder();
    if (!mounted) return;
    if (!orderOk) return;
    if (!checkPayInput()) return;

    final String send = payTextEditingController.text;
    final String receive = getTextEditingController.text;
    final String balance = dec.Decimal.parse(
            (getCoinModel!.balanceDoubleAll() + double.parse(receive))
                .toString())
        .toString();
    final String date = dformat.formatDate(DateTime.now(), [
      dformat.yyyy, '/', dformat.mm, '/', dformat.dd,
      ' ', dformat.am, ' ', dformat.hh, ':', dformat.nn,
    ]);

    final bool? rData = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SwapAstSummary(
          send, receive, balance, date,
          payCoin: youPay?.payCoin ?? 'USDT',
        ),
      ),
    );
    if (!mounted) return;
    if (rData == true) {
      payTap();
    } else {
      cancelOrder();
    }
  }
}
