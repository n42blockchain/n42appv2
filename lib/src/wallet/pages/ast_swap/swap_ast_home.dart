import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/market_api.dart';
import 'package:n42appv2/src/wallet/api/swap_ast_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_select_chain.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_summary.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_transactions.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_1559.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/coin_gas.dart';
import 'package:n42appv2/src/wallet/widgets/arlert_widget.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:date_format/date_format.dart' as dformat;

class SwapAstHome extends ConsumerStatefulWidget {
  final double? getAstNum;
  const SwapAstHome({this.getAstNum,super.key});

  @override
  ConsumerState<SwapAstHome> createState() => _SwapAstHomeState();
}

class _SwapAstHomeState extends ConsumerState<SwapAstHome> {
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  Load load = Load.loading;
  String errorMessage = "";
  TextEditingController payTextEditingController = TextEditingController();
  TextEditingController getTextEditingController = TextEditingController();
  FocusNode payNode = FocusNode();
  FocusNode getNode = FocusNode();
  SwapAstModel? youPay;

  CoinModel? payCoinModel;
  CoinModel? getCoinModel;
  Load getLoad = Load.finish;
  Load payLoad = Load.finish;
  List<SwapAstModel> swapAstList = [];
  List<dynamic> coinMarketInfo = [];
  bool readStatement = false;
  Map<String, dynamic>? token;
  int? orderId;

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;
  SwapAstApi? _swapAstApi;
  SwapAstApi get swapAstApi{
    _swapAstApi ??= SwapAstApi();
    return _swapAstApi!;
  }
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  @override
  void initState() {
    payTextEditingController.text = "0";
    getTextEditingController.text = "${widget.getAstNum??0}";
    init();

    //埋点：用户选择交换N或查看交换N界面。
    //AmplitudeUtils.walletFundingStarted();

    super.initState();
  }

  @override
  void dispose() {
    payTextEditingController.dispose();
    getTextEditingController.dispose();
    payNode.dispose();
    getNode.dispose();
    super.dispose();
  }

  Future<void> init() async {
    getAstChainModel();
    bool ok1 = await getAstList();
    if (ok1) {
      ok1 = await getCoinPrice();
      if (ok1) {
        ok1 = await getGasPrice();
        if (ok1) {
          estimateGasEth();
          load = Load.finish;
        } else {
          load = Load.error;
        }
      } else {
        load = Load.error;
      }
    } else {
      load = Load.error;
    }
    setState(() {});
  }

  Future<void> getAstChainModel() async {
    WalletActionProvider wa = ref.read(wapBridgeProvider);
    Map<String, dynamic> astModel = wa.walletMap[CoinType.N.name];
    CoinModel cm = CoinModel.fromMap(astModel['baseInfo']);
    cm.showList = astModel['showList'];
    cm.isTest = false;
    cm.addrType = astModel['addrType'];
    cm.pathIndex = astModel['pathIndex'] ?? 0;
    getCoinModel = cm;
    await getCoinModel!.buildWallet();
    getCoinModel!.getBalanceDefault();
    setState(() {});
    getBalanceGet();
  }

  //获取商品列表
  Future<bool> getAstList() async {
    MessageModel rData = await swapAstApi.getNftOrAstList(2);
    if (rData.error) {
      setState(() {
        load = Load.error;
        errorMessage = rData.data;
      });
      return false;
    } else {
      swapAstList =
          (rData.data as List).map((e) => SwapAstModel.fromJson(e)).toList();
      if (swapAstList.isNotEmpty) {
        if (youPay != null) {
          int ypIndex = swapAstList.indexWhere((element) {
            if (youPay!.payChain == element.payChain) {
              return true;
            }
            return false;
          });
          if (ypIndex != -1) {
            youPay = swapAstList[ypIndex];
          }
        } else {
          youPay = swapAstList[0];
        }
        payCoinModel =
            getChainCoinModel((youPay?.payChain ?? "").toUpperCase());
        if (payCoinModel != null) {
          getUsdtMap(
              payCoinModel!.coin['coinType'], youPay?.payCoinContract ?? "");
        }
        errorMessage = "";
        setState(() {});
        getBalanceChainPay();
        getBalancePay();
        return true;
      }else{
        if (!mounted) return false;
        errorMessage = S.of(context).g_key_132;
        return false;
      }
    }
  }

  CoinModel? getChainCoinModel(String symbol) {
    if (symbol == "BSC") {
      symbol = CoinType.BNB.name;
    }
    List<CoinModel> rList = ref.read(wapBridgeProvider)
        .getCoinModelWithSymbols(symbols: symbol);
    if (rList.isNotEmpty) {
      return rList[0];
    }
    return null;
  }

  void getUsdtMap(String chainSymbol, String contractAddress) {
    token = null;
    if (contractAddress != "") {
      Map<String, dynamic>? txChainMap = ref.read(wapBridgeProvider)
          .walletMap[chainSymbol.toString().toUpperCase()];
      if (txChainMap != null) {
        if (txChainMap['mainnets'].length != 0) {
          token =
          txChainMap['mainnets'][contractAddress.toString().toUpperCase()];
        }
      }
    }
    setState(() {});
  }

  Future<void> getBalanceChainPay() async {
    if (payCoinModel != null) {
      if (payLoad == Load.loading) return;
      setState(() {
        payLoad = Load.loading;
      });
      MessageModel rData = await tokenViewApi.getBalance(
          payCoinModel!.coin['blockchainType'],
          payCoinModel!.coin['coinType'],
          payCoinModel!.address.toString()) ?? MessageModel.error();
      if (rData.error) {
        payCoinModel!.balance = BigInt.zero;
      } else {
        payCoinModel!.balance = rData.data;
      }
      //await getCoinModel!.getBalance(getToken: false);
      setState(() {
        payLoad = Load.finish;
      });
    }
  }

  Future<void> getBalancePay() async {
    if (youPay != null && payCoinModel != null) {
      setState(() {
        youPay!.load = Load.loading;
      });
      MessageModel rData = await tokenViewApi.getBalance(
          payCoinModel!.coin['blockchainType'],
          (payCoinModel!.coin['coinType'] ?? "").toUpperCase(),
          payCoinModel?.address ?? "",
          contract: youPay?.payCoinContract ?? "") ?? MessageModel.error();
      if (rData.error) {
        youPay!.balance = 0;
      } else {
        youPay!.balance =
            toEther(rData.data.toString(), youPay?.payCoinDecimal ?? 6).toDouble();
      }
      setState(() {
        youPay!.load = Load.finish;
      });
    }
  }

  Future<void> getBalanceGet() async {
    if (getCoinModel != null) {
      if (getLoad == Load.loading) return;
      setState(() {
        getLoad = Load.loading;
      });
      MessageModel rData = await tokenViewApi.getBalance(
          BlockchainType.Ethereum.name,
          CoinType.N.name,
          getCoinModel!.address.toString()) ?? MessageModel.error();
      if (rData.error) {
        getCoinModel!.balance = BigInt.zero;
      } else {
        getCoinModel!.balance = rData.data;
      }
      //await getCoinModel!.getBalance(getToken: false);
      setState(() {
        getLoad = Load.finish;
      });
    }
  }

  //获取旷工费
  Future<bool> getGasPrice() async {
    if (payCoinModel == null) {
      errorMessage = "Error";
      return false;
    }
    gas =
        BigInt.from(getCoinGas(payCoinModel!.coin['coinType'], contract: true));
    MessageModel mm = await tokenViewApi.getGasPrice(
        payCoinModel!.coin['blockchainType'], payCoinModel!.coin['coinType'],
        isTest: false,
      rpc: payCoinModel!.custom?payCoinModel!.coin['service']:null,
    ) ?? MessageModel.error();
    if (mm.error == false) {
      gasPrice = mm.data;
      if(get1559WithChainSymbol(payCoinModel!.coin['coinType'])){
        gasPrice=gasPrice*BigInt.from(2);
      }
    } else {
      errorMessage = mm.data.toString();
      return false;
    }
    totalGasPrice = gasPrice * gas;
    return true;
  }

  Future<bool> getCoinPrice() async {
    String keys = "n";
    keys = '$keys,${youPay!.payCoin ?? "".toLowerCase()}';
    //查询coins中的币种信息
    var list = await MarketApi().getWalletCoinsInfo(keys);
    if (!mounted) return false;
    //判断查询是否成功
    if (list['error']) {
      //查询失败，设置当前操作状态为error，并设置错误信息
      errorMessage = S.of(context).g_swap_key_15;
      return false;
    } else {
      //查询成功，将币的信息赋值到_coinslist
      coinMarketInfo = list['data']['data'];
      errorMessage = "";
      setCoinModelPrice();
      return true;
    }
  }

  void setCoinModelPrice() {
    int index = coinMarketInfo.indexWhere((element) {
      if (element['coin'] == "n") {
        return true;
      }
      return false;
    });
    Map<String, dynamic> astCoinInfo = coinMarketInfo[index];
    getCoinModel!.coinPrice = astCoinInfo['price'] * 1.0;
    int indexPay = coinMarketInfo.indexWhere((element) {
      if (element['coin'] == (youPay?.payCoin ?? "").toLowerCase()) {
        return true;
      }
      return false;
    });
    Map<String, dynamic> payCoinInfo = coinMarketInfo[indexPay];
    youPay!.price = payCoinInfo['price'] * 1.0;
    setState(() {});
  }

  void payInput({String? value}) {
    value ??= payTextEditingController.text;
    bool checkNum = regular.regularNums(value);
    bool checkDouble = regular.regularDouble(value);
    if (checkNum == false && checkDouble == false) return;
    if (value == "0") return;
    double getValue = dec.Decimal.parse(value).toDouble() *
        ((youPay?.price ?? 0) / (getCoinModel?.coinPrice ?? 0));
    getTextEditingController.text =
    '${regular.formartNumDouble(dec.Decimal.parse(getValue.toString()).toDouble(), 8, isCrop: true, isFill0: false)}';
    //dec.Decimal.parse(getValue.toString()).toString();
    setState(() {});
  }

  void getInput({String? value}) {
    value ??= getTextEditingController.text;
    bool checkNum = regular.regularNums(value);
    bool checkDouble = regular.regularDouble(value);
    if (checkNum == false && checkDouble == false) return;
    if (value == "0") return;
    double p = (getCoinModel?.coinPrice ?? 0) / (youPay?.price ?? 0);
    double payValue = double.parse(value) * p;
    payTextEditingController.text =
    '${regular.formartNumDouble(dec.Decimal.parse(payValue.toString()).toDouble(), 8, isCrop: true, isFill0: false)}';
    //dec.Decimal.parse(payValue.toString()).toString();
    setState(() {});
  }

  bool checkPayInput() {
    String value = payTextEditingController.text;
    bool checkNum = regular.regularNums(value);
    bool checkDouble = regular.regularDouble(value);
    if (checkNum == false && checkDouble == false) return false;
    double pay = double.parse(value);
    if (pay == 0) return false;
    if ((youPay?.balance ?? 0) < pay) {
      return false;
    }
    return true;
  }

  void percentTap(int value) {
    if (load == Load.finish) {
      double ypBalance = youPay?.balance ?? 0;
      if (ypBalance > 0) {
        payTextEditingController.text =
        '${regular.formartNumDouble(ypBalance * (value / 100), 8, isCrop: true, isFill0: false)}';
        //(ypBalance*(value/100)).toString();
        payInput(value: (ypBalance * (value / 100)).toString());
      }
    }
  }

  Future<bool> newOrder() async {
    if (load == Load.finish) {
      setState(() {
        load = Load.loading;
      });
      MessageModel rOrderData = await swapAstApi.postNftOrAstAddOrder(
        getCoinModel!.address.toString(),
        AppGlobals.userInfo?.uuid??"",
        youPay!.id ?? 0,
        2,
        double.parse(getTextEditingController.text),
      );
      if (rOrderData.error) {
        errorMessage = rOrderData.data;
        setState(() {
          load = Load.finish;
        });
        return false;
      } else {
        errorMessage = "";
        orderId = rOrderData.data['id'];
        double amount = (rOrderData.data['amount'] as num).toDouble();
        double price = (rOrderData.data['price'] as num).toDouble();
        getCoinModel!.coinPrice = price;
        payTextEditingController.text = amount.toString();
        payInput();
        setState(() {
          load = Load.finish;
        });
        return true;
      }
    }
    return false;
  }

  Future<void> cancelOrder() async {
    if (load == Load.finish) {
      setState(() {
        load = Load.loading;
      });
      MessageModel rOrderData = await swapAstApi.postNftOrAstCancelOrder(
        AppGlobals.userInfo?.uuid??"",
        orderId ?? 0,
      );
      if (rOrderData.error) {
        errorMessage = rOrderData.data;
      } else {
        errorMessage = "";
        orderId = null;
      }
      setState(() {
        load = Load.finish;
      });
    }
  }

  Future<void> payTap() async {
    if (load == Load.finish) {
      if (orderId == null) return;
      setState(() {
        load = Load.loading;
      });
      String? txHash = await web3Transaction();
      if (txHash != null) {

        //埋点：用户成功发送交换订单，等待N发送成功时触发事件。
        //AmplitudeUtils.walletFundingSucceeded();

        bool rData = await postOrderTxHash(orderId ?? 0, txHash);
        if (!mounted) return;
        if (rData) {
          await alertWidget(context);
          if (!mounted) return;
          Navigator.pop(context);
        }
      }
      if (!mounted) return;
      setState(() {
        load = Load.finish;
      });
    }
  }

  Future<bool> postOrderTxHash(int orderId, String txHash) async {
    MessageModel rData = await swapAstApi.postNftOrAstCommitPay(
        AppGlobals.userInfo?.uuid??"", orderId, txHash);
    if (rData.error) {
      errorMessage = rData.data;
      return false;
    } else {
      errorMessage = "";
      return true;
    }
  }

  Future<String?> web3Transaction() async {
    TransferApi transferApi=TransferApi();
    MessageModel rData = await transferApi.transfer(
      payCoinModel!.coin['coinType'],
      youPay?.payAddr ?? "",
      double.parse(payTextEditingController.text),
      fromAddress: payCoinModel!.address,
      contractAddress: youPay?.payCoinContract ?? "",
      isTest: false,
    );
    if (rData.error) {
      errorMessage = rData.data;
      return null;
    } else {
      errorMessage = "";
      return rData.data['txHash'];
    }
  }

  //eth 模拟交易
  Future<bool> estimateGasEth() async {
    if (payCoinModel!.balance == BigInt.zero) {
      errorMessage = S.of(context).g_key_t_29(payCoinModel!.coin['coinType']);
      setState(() {});
      return false;
    }
    if (payCoinModel!.coin['blockchainType'] != BlockchainType.Ethereum.name &&
        payCoinModel!.coin['blockchainType'] != BlockchainType.Tron.name) {
      return true;
    }
    try {
      setState(() {
        load = Load.loading;
      });
      bool rGasPrice = await getGasPrice();
      if (rGasPrice == false) {
        setState(() {});
        return false;
      }
      MessageModel ethMessage = await tokenViewApi.getGasEstimateEthV2(
        //EthAPI.getGasLimit(
        payCoinModel!.address,
        youPay?.payCoinContract ?? "",
        gasPrice,
        ethToWeiString(
            payTextEditingController.text, youPay!.payCoinDecimal!),
        gas,
        payCoinModel!.coin['coinType'],
        contract: youPay!.payCoinContract!,
        isTest: false,
      );
      if (!mounted) return false;
      if (ethMessage.error == false) {
        gas = ethMessage.data;
        totalGasPrice = gasPrice * gas;
        if (payCoinModel!.balance < totalGasPrice) {
          errorMessage =
              S.of(context).g_key_t_29(payCoinModel!.coin['coinType']);
          setState(() {
            load = Load.finish;
          });
          return false;
        }
        errorMessage = "";
        setState(() {
          load = Load.finish;
        });
        return true;
      } else {
        errorMessage = ethMessage.data;
        setState(() {
          load = Load.finish;
        });
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      if (mounted) {
        setState(() {
          load = Load.finish;
        });
      }
      return false;
    }
  }

  //关闭键盘
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
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
                        builder: (context) => SwapAstTransactions()));
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
              onTap: () {
                queryWidget();
              },
              child: Container(
                height: ScreenUtil().setWidth(44),
                width: ScreenUtil().setWidth(44),
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                    right: ScreenUtil().setWidth(30), left: ScreenUtil().setWidth(10)),
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
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      youPayWidget(),
                      youGetWidget(),
                      priceWidget(),
                      percentWidget(),
                      minerFeeWidget(),
                      checkWidget(),
                      if (errorMessage != "") errorWidget(),
                      SizedBox(
                        height: ScreenUtil().setWidth(130),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            previewSwapWidget(),
          ],
        ),
      ),
    );
  }

  Widget errorWidget() {
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

  Widget youPayWidget() {
    Color balanceColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.errorTextColor.name);
    if (checkPayInput() == true) {
      balanceColor =
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name);
    }
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(30),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
        bottom: ScreenUtil().setWidth(20),
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor4.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.of(context).g_swap_key_3,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${payCoinModel?.coin['name'] ?? ""}(${payCoinModel?.coin['miniName'] ?? ""})',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(100),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemTextColor.name),
                      fontSize: ScreenUtil().setWidth(50.0),
                    ),
                    controller: payTextEditingController,
                    focusNode: payNode,
                    textInputAction: TextInputAction.next,
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_44,
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setWidth(50.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.textFieldHintColor.name),
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                    ),
                    maxLines: 1,
                    onChanged: (String value) {
                      payInput(value: value);
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(getNode);
                      payInput();
                    },
                  ),
                ),
                InkWell(
                  onTap: () async {
                    closeKeyboard();
                    SwapAstModel? rModel = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SwapAstSelectChain(swapAstList)));
                    if (!mounted) return;
                    if (rModel != null) {
                      youPay = rModel;
                      payCoinModel = getChainCoinModel(
                          (youPay?.payChain ?? "").toUpperCase());
                      if (payCoinModel != null) {
                        getUsdtMap(payCoinModel!.coin['coinType'],
                            youPay?.payCoinContract ?? "");
                      }
                      setState(() {});
                      getBalanceChainPay();
                      getBalancePay();
                      bool rCoinPrice = await getCoinPrice();
                      if (!mounted) return;
                      if (rCoinPrice) {
                        bool rGasPrice = await getGasPrice();
                        if (!mounted) return;
                        if (rGasPrice) {
                          await estimateGasEth();
                        }
                      }
                    }
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(200),
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                    child: Row(
                      children: [
                        SizedBox(
                          width: ScreenUtil().setWidth(52),
                          height: ScreenUtil().setWidth(52),
                          child: ImageNetWork(imageUrl:
                              youPay?.uri ?? "",
                            placeholder: "assets/img/list_default.png",
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            youPay?.payCoin ?? "",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(40),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemBorderColor.name),
                            size: ScreenUtil().setWidth(40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (payCoinModel == null && youPay != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_swap_key_14(youPay?.payChain ?? ""),
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.errorTextColor.name),
                    fontSize: ScreenUtil().setSp(26),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    closeKeyboard();
                    bool r = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalletCoinAddAll(youPay?.payChain ?? "",)));
                    if (!mounted) return;
                    if (r) {
                      await ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
                      init();
                    }
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(50),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonBgColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(50)),
                    ),
                    child: Text(
                      S.of(context).g_key_wallet_k47,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainButtonTextColor.name),
                        fontSize: ScreenUtil().setSp(22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (payCoinModel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${S.of(context).g_key_29}:${regular.formartNumDouble(dec.Decimal.parse((youPay?.balance ?? 0).toString()).toDouble(), 14, isCrop: true, isFill0: false)}",
                  style: TextStyle(
                    color: balanceColor,
                    fontSize: ScreenUtil().setSp(26),
                  ),
                ),
                if (youPay?.load == Load.loading)
                  SizedBox(
                    width: ScreenUtil().setWidth(26),
                    height: ScreenUtil().setWidth(26),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          if (payCoinModel != null && token == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_swap_key_14(youPay?.payCoin ?? ""),
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.errorTextColor.name),
                    fontSize: ScreenUtil().setSp(26),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    closeKeyboard();
                    bool r = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalletCoinAddAll(youPay?.payCoin ?? "",
                            )));
                    if (!mounted) return;
                    if (r) {
                      await ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
                      init();
                    }
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(50),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonBgColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(50)),
                    ),
                    child: Text(
                      S.of(context).g_key_wallet_k47,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainButtonTextColor.name),
                        fontSize: ScreenUtil().setSp(22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget youGetWidget() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20),
        bottom: ScreenUtil().setWidth(30),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor5.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_swap_key_4,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemTextColor.name),
              fontSize: ScreenUtil().setSp(30),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(100),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemTextColor.name),
                      fontSize: ScreenUtil().setWidth(50.0),
                    ),
                    controller: getTextEditingController,
                    focusNode: getNode,
                    textInputAction: TextInputAction.next,
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_44,
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setWidth(50.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.textFieldHintColor.name),
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                    ),
                    maxLines: 1,
                    onChanged: (String value) {
                      getInput(value: value);
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(payNode);
                      getInput();
                    },
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(200),
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: ScreenUtil().setWidth(52),
                        height: ScreenUtil().setWidth(52),
                        child: Image.asset('assets/img/ast.png'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          CoinType.N.name,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemTextColor.name),
                            fontSize: ScreenUtil().setSp(30),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(40),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemBorderColor.name),
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${S.of(context).g_key_29}:${getCoinModel?.balanceDoubleAll()}",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(26),
                ),
              ),
              if (getLoad == Load.loading)
                SizedBox(
                  width: ScreenUtil().setWidth(26),
                  height: ScreenUtil().setWidth(26),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget priceWidget() {
    String text = "";
    double gCoinPrice = getCoinModel?.coinPrice ?? 0;
    double yPrice = youPay?.price ?? 0;

    if (gCoinPrice != 0 && yPrice != 0) {
      double pc = 0;
      pc = yPrice / gCoinPrice;
      text =
      "1${youPay?.payCoin ?? ""} = ${regular.formartNumDouble(dec.Decimal.parse(pc.toString()).toDouble(), 8, isCrop: true, isFill0: false)}${CoinType.N.name}";
    } else {
      text = "??${youPay?.payCoin ?? ""} = ??${CoinType.N.name}";
    }
    return Container(
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(30),
        ),
      ),
    );
  }

  Widget percentWidget() {
    double itemWidth =
        (MediaQuery.of(context).size.width - ScreenUtil().setWidth(60)) / 4;
    return Container(
      height: ScreenUtil().setWidth(80),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, int index) {
          int percent = 25 * (4 - index);
          return InkWell(
            onTap: () {
              percentTap(percent);
            },
            child: Container(
              height: ScreenUtil().setWidth(80),
              width: itemWidth,
              alignment: Alignment.center,
              child: Text(
                "$percent%",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget checkWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                readStatement = !readStatement;
              });
            },
            child: SizedBox(
              height: ScreenUtil().setWidth(60),
              width: ScreenUtil().setWidth(60),
              child: readStatement
                  ? Icon(
                Icons.check_box_outlined,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              )
                  : Icon(
                Icons.check_box_outline_blank,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.dividerColor.name),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(500),
            child: RichText(
              text: TextSpan(
                text: S.of(context).g_swap_key_16,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(22),
                ),
                children: [
                  TextSpan(
                      text: S.of(context).g_swap_key_17,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(24),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BrowserPage(
                                    "${AppConfig.apiUrl['walletamazeBrowser']!}/static/terms_of_use-astranet.html",
                                    //S.of(context).g_swap_key_17
                                  )));
                        }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget previewSwapWidget() {
    Color backgroundColor =
    AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name);
    if (load == Load.loading) {
      backgroundColor =
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name);
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0),
        child: load == Load.error
            ? tryAgainButton()
            : buttonStyle6(context, () async {
          closeKeyboard();
          if (load == Load.finish) {
            if (readStatement == false) return;
            if (checkPayInput() == true) {
              bool r = await estimateGasEth();
              if (!mounted) return;
              if (r == false) return;
              if (errorMessage != "") return;
              bool rOrder=await newOrder();
              if (!mounted) return;
              if(rOrder==false)return;
              if (checkPayInput() == false) {
                return;
              }
              String send = payTextEditingController.text;
              String receive = getTextEditingController.text;
              String balance = dec.Decimal.parse(
                  (getCoinModel!.balanceDoubleAll() +
                      double.parse(receive))
                      .toString())
                  .toString();
              String date = dformat.formatDate(DateTime.now(), [
                dformat.yyyy,
                '/',
                dformat.mm,
                '/',
                dformat.dd,
                ' ',
                dformat.am,
                ' ',
                dformat.hh,
                ':',
                dformat.nn
              ]);

              //埋点：用户点击预览交换按钮
              //AmplitudeUtils.walletFundingPreviewed();

              bool? rData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SwapAstSummary(
                          send, receive, balance, date)));
              if (!mounted) return;
              if (rData == true) {
                //埋点：用户点击确认交换按钮
                //AmplitudeUtils.walletFundingSubmitted();
                payTap();
              } else {
                cancelOrder();
              }
            }
          }
        },
          S.of(context).g_swap_key_5, backgroundColor,
          AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonTextColor.name),
          load == Load.loading,),
      ),
    );
  }

  //旷工费
  Widget minerFeeWidget() {
    if (payCoinModel == null) return SizedBox();
    String title = payCoinModel!.coin['coinType'];
    String totalGasPriceStr = "";
    String gasPriceStr = "";
    Color totalGasPriceColor =
    AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    Widget gasLimitWidget = Container();
    int decimals = payCoinModel!.coin['decimals'];
    if (payCoinModel!.coin['blockchainType'] == BlockchainType.Ethereum.name) {
      String unit = payCoinModel!.coin['unit'];
      decimals = payCoinModel!.coin['decimals'] ?? 0;
      //unit=payCoinModel!.coin['unit']??"";
      BigInt chainBalance = payCoinModel!.balance;
      if (totalGasPrice > chainBalance) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      totalGasPriceStr =
      '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())}$unit';
      gasPriceStr =
      '${dec.Decimal.parse(toGWei(gasPrice.toString()).toString())}Gwei';
      gasLimitWidget = Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(32.0)),
        alignment: Alignment.center,
        //padding: EdgeInsets.symmetric(horizontal: scr.setWidth(32.0),),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_101,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Text(
              "$gas",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
          ],
        ),
      );
    } else if (payCoinModel!.coin['blockchainType'] ==
        BlockchainType.Tron.name) {
      decimals = payCoinModel!.coin['decimals'] ?? 0;
      if (toEther(totalGasPrice.toString(), decimals).toDouble() >
          payCoinModel!.balanceDoubleAll()) {
        totalGasPriceColor = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
      }
      totalGasPriceStr =
      '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())} $title';
      gasPriceStr =
      '${dec.Decimal.parse(toEther(gasPrice.toString(), decimals).toString())} $title';
      gasLimitWidget = Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(32.0)),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_101,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Text(
              "$gas",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
          ],
        ),
      );
    } else {
      if (payCoinModel!.coin['isContract']) {
        decimals = payCoinModel!.coin['decimals'] ?? 0;
      }
      totalGasPriceStr =
      '${toEther(totalGasPrice.toString(), decimals)} $title';
      gasPriceStr = '${toEther(gasPrice.toString(), decimals)} $title';
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(30.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(32.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_29,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                Text(
                  '${payCoinModel!.balanceStringAll()} ${payCoinModel!.coin['unit'] ?? ""}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_t_15,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                Text(
                  gasPriceStr,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
          gasLimitWidget,
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(32.0)),
            alignment: Alignment.center,
            //padding: EdgeInsets.symmetric(horizontal: scr.setWidth(32.0),),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_t_16,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                Text(
                  totalGasPriceStr,
                  style: TextStyle(
                    color: totalGasPriceColor,
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tryAgainButton() {
    return buttonStyle2(context, () {
      init();
    }, S.of(context).g_swap_key_6,);

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
        ));
  }
}
