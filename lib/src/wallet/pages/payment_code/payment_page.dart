import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/market_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String? amount;
  final String? address;
  final String? coinType;
  final String? uuid;
  const PaymentPage(this.amount,this.uuid,this.coinType,this.address,{super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String amount="";
  String address="";
  String coinType="";
  String uuid="";
  UserInfo? userInfo;
  Map<String,dynamic>? usdtInfo;
  String usdtAmount="";
  List<CoinModel> coinModels=[];
  CoinModel? coinMain;
  int coinModelIndex=-1;
  Load load=Load.refresh;
  String errorMessage="";
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  // 复用同一实例，避免每次方法调用创建新对象
  final UserInfoApi _userInfoApi = UserInfoApi();
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  /// UUID v4 格式正则（仅接受标准格式，防止注入任意字符串）
  static final _uuidRe = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  void initState() {
    if(widget.amount!=null){
      // 校验 amount：必须为正有限数，防止注入 NaN/Infinity/负数
      final double? parsedAmount = double.tryParse(widget.amount!);
      if (parsedAmount != null && parsedAmount.isFinite && parsedAmount > 0) {
        amount = widget.amount!;
      }
      address  = widget.address  ?? "";
      coinType = widget.coinType ?? "";
      // 校验 UUID 格式，非标准格式则不使用（不发 push，不发 API）
      final String rawUuid = widget.uuid ?? "";
      uuid = _uuidRe.hasMatch(rawUuid) ? rawUuid : "";
    }
    initData();
    super.initState();
  }
  Future<void> initData()async{
    initUserInfo();
    await initCoinInfo();
    initCoinModel();
  }
  Future<void> initUserInfo() async {
    if (uuid.isEmpty) {
      setState(() {});
      return;
    }
    MessageModel mm = await _userInfoApi.getUserInfoWithUUID(uuid);
    if (mm.error == false && mm.data != null) {
      try {
        userInfo = UserInfo.fromJson(Map<String, dynamic>.from(mm.data as Map));
      } catch (e) {
        debugPrint('initUserInfo parse error: $e');
      }
    }
    if (mounted) setState(() {});
  }
  Future<void> initCoinInfo()async{
    usdtInfo=ref.read(wapBridgeProvider).getCoinPriceWithUnit("usdt");
    //查询coins中的币种信息
    var list = await MarketApi().getWalletCoinsInfo("usdt");
    //判断查询是否成功
    if (list['error']) {
      //查询失败，设置当前操作状态为error，并设置错误信息
      //ToastUtils.show(S.current.g_key_5);
      errorMessage=S.current.g_key_5;
      setState(() {
        load=Load.finish;
      });
    } else {
      //查询成功，将币的信息赋值到_coinslist
      List<dynamic> coinMarketInfo = list['data']['data'];
      String keyStr = "usdt";
      for (var element in coinMarketInfo) {
        if (element['coin'].toString().toLowerCase() == keyStr) {
          Map<String,dynamic> rMap={};
          rMap["icon"] = element['image'];
          //设置币价
          rMap['coinPrice']=Decimal.parse(element['price'].toString()).toDouble();
          rMap['percentage']=Decimal.parse(element['price_change_per_24h'].toString()).toDouble();
          usdtInfo= rMap;
          break;
        }
      }
    }
    double uAmount=0;
    double coinPrice=usdtInfo?['coinPrice']??0.0;
    final double amountVal = double.tryParse(amount) ?? 0.0;
    if(coinPrice>1){
      uAmount=amountVal*coinPrice;
    }else{
      uAmount=amountVal+amountVal*(1-coinPrice);
    }
    usdtAmount=DataUtils().formatNum(uAmount,2);
    setState(() {});
  }
  void initCoinModel(){
    WalletActionProvider wap =ref.read(wapBridgeProvider);
    for(CoinModel cm in wap.coinList){
      if(cm.coin['coinType'].toString().toLowerCase()==coinType.toLowerCase()){
        if(cm.coin['miniName'].toString().toLowerCase()=="usdt"){
          coinModels.add(cm);
        }
      }
    }
    if(coinModels.isNotEmpty){
      coinModelIndex=0;
      double c1=coinModels[coinModelIndex].balanceDoubleAll();
      double c2=double.parse(usdtAmount);
      if(c1<c2){
        errorMessage=S.current.g_key_payment_usdt_insufficient;
      }
      initCoinMainModel();
    }else{
      errorMessage=S.current.g_key_payment_usdt_not_found;
    }
    setState(() {
      load=Load.finish;
    });
  }
  Future<void> initCoinMainModel()async{
    WalletActionProvider wap=ref.read(wapBridgeProvider);
    int cIndex=wap.coinModels.indexWhere((element){
      if(element.coin['coinType']==coinModels[coinModelIndex].coin['coinType']){
        if(coinModels[coinModelIndex].privateKey !=null){
          if(element.privateKey==coinModels[coinModelIndex].privateKey){
            return true;
          }else{
            return false;
          }
        }else{
          return true;
        }
      }
      return false;
    });
    if(cIndex !=-1){
      coinMain=wap.coinModels[cIndex];
      await coinMain?.getBalance();
      if(coinMain!.balance==BigInt.zero){
        errorMessage=S.current.g_key_payment_native_insufficient;
      }
    }else{
      errorMessage=S.current.g_key_payment_native_not_found;
    }
    setState(() {});
  }

  Future<void> web3Transaction() async {
    setState(() { load = Load.loading; });
    try {
      final CoinModel payToken = coinModels[coinModelIndex];
      // 优先使用 USDT 等值金额；tryParse 防止 NaN/Infinity 崩溃
      final double transferAmount = usdtAmount.isNotEmpty
          ? (double.tryParse(usdtAmount) ?? 0.0)
          : (double.tryParse(amount) ?? 0.0);
      // 二次守卫：金额必须为正有限数
      if (!transferAmount.isFinite || transferAmount <= 0) {
        errorMessage = S.current.g_key_payment_amount_invalid;
        setState(() { load = Load.finish; });
        return;
      }
      TransferApi transferApi = TransferApi();
      MessageModel rData = await transferApi.transfer(
        payToken.coin['coinType'],
        address,
        transferAmount,
        fromAddress: payToken.address,
        // 修复：根据 isTest 选择正确的合约地址
        contractAddress: payToken.isTest
            ? (payToken.coin['contract_test'] ?? payToken.coin['contract'])
            : payToken.coin['contract'],
        // 修复：isTest 不再硬编码 false
        isTest: payToken.isTest,
      );
      if (rData.error) {
        errorMessage = rData.data;
        setState(() { load = Load.finish; });
      } else {
        errorMessage = "";
        setState(() { load = Load.finish; });
        // 通知收款方（fire-and-forget，不阻塞支付成功 UX）
        if (uuid.isNotEmpty) {
          _notifyPayee(
            txHash: rData.data?.toString() ?? "",
            coinType: payToken.coin['coinType'],
          );
        }
        ToastUtils.show(S.current.g_key_payment_success);
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      errorMessage = e.toString();
      setState(() { load = Load.finish; });
    }
  }

  /// 向收款方发送"已收款"通知（fire-and-forget，不阻塞 UI）
  void _notifyPayee({required String txHash, required String coinType}) {
    _userInfoApi.sendPaymentReceipt(
      toUuid: uuid,
      txHash: txHash,
      amount: amount,
      tokenAmount: usdtAmount,
      coinType: coinType,
      tokenName: "USDT",
    ).catchError((Object e) {
      debugPrint('sendPaymentReceipt error: $e');
      return MessageModel.error();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(
        text: S.of(context).g_key_payment_title,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30),),
                      decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16),)
                      ),
                      child: Column(
                        children: [
                          if((userInfo?.name??"") != "")
                            Text(
                              userInfo?.name??"",
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(30),
                              ),
                            ),
                          Text(
                            address,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$ $amount",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(100),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            S.of(context).g_key_payment_approx_usdt(usdtAmount),
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(60),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    walletWidget(),
                    if(coinMain !=null)
                      mainCoin(),
                    if(coinModelIndex !=-1)
                      usdtCoin(),
                    if(errorMessage !="")
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30),),
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(30),),
                        decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16),)
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                            fontSize: ScreenUtil().setSp(26),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: ScreenUtil().setWidth(148),),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    padding: EdgeInsets.all( ScreenUtil().setWidth(30.0)),
                    height: ScreenUtil().setWidth(148.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: buttonStyle6(
                      context, ()async{
                        if(errorMessage !="" && load !=Load.refresh)return;
                      bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletSecurityVerification()));
                      if(r==true){
                        web3Transaction();
                      }
                    },
                      load==Load.loading?'Paying...':load==Load.refresh?"Loading...":"Payment",
                      AppThemeUtils.getColorByKey(
                        context, load==Load.finish?
                      AppThemeKeys.mainButtonBgColor.name:
                      AppThemeKeys.mainButtonBgColor3.name,
                      ),
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                      (load==Load.loading || load==Load.refresh),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget usdtCoin() {
    return Expanded(
      flex: 1,
      child: coinModels.isEmpty?
      EmptyView():
      ListView.builder(
        itemCount: coinModels.length,
        itemBuilder: (context,index){
          CoinModel coinInfo=coinModels[index];
          String balanceStr = "";
          double balance = coinInfo.value;
          if (balance >= 1000000000) {
            balanceStr = regular.getMoneyAbbreviation(balance);
          }else if(balance>0 && balance <0.0000000009){
            balanceStr=regular.getMoneyAbbreviationDecimal(balance);
          } else {
            balanceStr = oCcy.format(balance);
          }
          String valueBalanceStr="";
          double valueBalance=coinInfo.balanceDoubleAll();
          if(valueBalance>1000000000){
            valueBalanceStr=regular.getMoneyAbbreviation(valueBalance);
          }else if(valueBalance>0 && valueBalance <0.0000000009){
            valueBalanceStr=regular.getMoneyAbbreviationDecimal(valueBalance);
          }else{
            valueBalanceStr=coinInfo.balanceString();
          }
          Widget? mainImage;
          Widget image;
          if (coinInfo.coin['icon'] == "") {
            image = Image.asset("assets/img/list_default.png");
          } else {
            image = ImageNetWork(imageUrl:
            coinInfo.coin['icon'] ?? "",
              placeholder: "assets/img/list_default.png",
            );
          }
          if (coinInfo.coin['isContract']) {
            mainImage = ImageNetWork(imageUrl:
            coinInfo.mainCoinIcon ?? "",
              placeholder: "assets/img/list_default.png",
            );
          }
          return InkWell(
            onTap: () {
              if(index !=coinModelIndex){
                setState(() {
                  coinModelIndex=index;
                });
                initCoinMainModel();
              }
            },
            child:Container(
              height: ScreenUtil().setWidth(140.0),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
              decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16),),
                border: index==coinModelIndex?
                Border.all(
                  width:ScreenUtil().setWidth(1),
                  color:AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ):null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(52.0),
                    height: ScreenUtil().setWidth(72.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                    child: Stack(
                      children: [
                        Positioned(
                          top: ScreenUtil().setWidth(10.0),
                          bottom: ScreenUtil().setWidth(10.0),
                          left: 0,
                          right: 0,
                          child: image,
                        ),
                        if (mainImage != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            height: ScreenUtil().setWidth(22.0),
                            width: ScreenUtil().setWidth(22.0),
                            child: mainImage,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${coinInfo.coin['miniName']}(${coinInfo.coin['coinType']})",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),
                                    color: AppThemeUtils.getColorByKey(
                                        context, "mainTextColor"),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(valueBalanceStr,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30.0),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainTextColor.name),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "\$${coinInfo.coinPriceString()}",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(30.0),
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.itemSubtitleTextColor.name),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Expanded(flex: 1, child: SizedBox()),
                            Text("\$$balanceStr",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30.0),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemSubtitleTextColor.name),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget mainCoin(){
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Text(
        "${coinMain!.balanceString()} ${coinType.toUpperCase()}",
        style: TextStyle(
          fontSize: ScreenUtil().setSp(26),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        ),
      ),
    );
  }
  Widget walletWidget(){
    return Container(
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30),),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16),)
      ),
      child: Row(
        children: [
          Text(
            S.of(context).g_key_payment_wallet,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              ref.read(wapBridgeProvider).walletInfo.walletName??"",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),

    );
  }
}
