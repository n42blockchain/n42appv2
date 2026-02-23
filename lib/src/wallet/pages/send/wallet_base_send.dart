import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/goplus_security_result.dart';
import 'package:n42_wallet/core/security/goplus_security_service.dart';
import 'package:n42_wallet/core/security/tx_simulation_result.dart';
import 'package:n42_wallet/core/security/tx_simulation_service.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/src/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/prompt_widget.dart';
import 'package:n42_wallet/src/widgets/contract_security_card.dart';
import 'package:n42_wallet/src/widgets/tx_simulation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletBaseSend extends StatefulWidget {
  final TransationRecordModel? transationRecordModel;
  final BtcTransactionRecodeModel? btcTransactionRecodeModel;
  final String mainCoinUnit;
  final bool isNft;
  const WalletBaseSend(
      this.transationRecordModel,
      this.btcTransactionRecodeModel,
      this.mainCoinUnit,
      {this.isNft=false,super.key});

  @override
  State<WalletBaseSend> createState() => _WalletBaseSendState();
}

class _WalletBaseSendState extends State<WalletBaseSend> {
  Map<String,dynamic> coinInfo={};
  String gasPrice="";
  TxSimulationResult _simResult = TxSimulationResult.simulating();

  // GoPlus 合约安全检查结果
  GoplusSecurityResult? _goplResult;
  bool _goplLoading = false;

  //账号安全
  Map<String,dynamic> securityMap={
    "email":false,
    //"google":false,
    "face":false,
  };
  @override
  void initState() {
    super.initState();
    if(widget.btcTransactionRecodeModel!=null){
      coinInfo=widget.btcTransactionRecodeModel!.coin;
    }
    if(widget.transationRecordModel!=null){
      coinInfo=widget.transationRecordModel!.coin;
    }
    init();
    initSecurity();
    _runSimulation();
    _runGoplusCheck();
  }
  void init(){
    //计算gasPrice
    BlockchainType bt=BlockchainType.values.firstWhere((element) => element.name==coinInfo['blockchainType']?true:false);
    switch(bt){
      case BlockchainType.Bitcoin:
        gasPrice='${toEther(widget.btcTransactionRecodeModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Ethereum:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Solana:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 9)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Tron:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Ripple:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Algorand:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Tezos:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Cosmos:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Filecoin:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Polkadot:
        gasPrice="0";
      case BlockchainType.Aptos:
        gasPrice="0";
      case BlockchainType.Sui:
        gasPrice="0";
      case BlockchainType.TheOpenNetwork:
        gasPrice="0";
      case BlockchainType.Stellar:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 7)} ${widget.mainCoinUnit}';
      case BlockchainType.VeChain:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
      case BlockchainType.Harmony:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
      case BlockchainType.IoTeX:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
      case BlockchainType.Near:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 24)} ${widget.mainCoinUnit}';
      case BlockchainType.Zilliqa:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 12)} ${widget.mainCoinUnit}';
      case BlockchainType.Theta:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
      case BlockchainType.Cardano:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
      case BlockchainType.MultiversX:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
      case BlockchainType.Starknet:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
      case BlockchainType.EOSIO:
        gasPrice='0 ${widget.mainCoinUnit}'; // EOS uses resource model
      case BlockchainType.Waves:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
      case BlockchainType.Neo:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
      case BlockchainType.Ontology:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 9)} ${widget.mainCoinUnit}';
      case BlockchainType.NEM:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
      case BlockchainType.Nano:
        gasPrice='0 ${widget.mainCoinUnit}'; // Nano is feeless
      case BlockchainType.Decred:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
      case BlockchainType.ICON:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
      case BlockchainType.IOST:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
      case BlockchainType.Ark:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
      case BlockchainType.Qtum:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
      case BlockchainType.Hive:
        gasPrice='0 ${widget.mainCoinUnit}'; // Hive uses resource credits
    }

  }
  Future<void> initSecurity()async{
    Map<String,dynamic>? s=await SPUtil().getSecurity();
    if(s!=null){
      Map<String,dynamic>? userSecurityMap=s[AppGlobals.userInfo?.uuid??""];
      if(userSecurityMap!=null){
        setState(() {
          securityMap=userSecurityMap;
        });
      }
    }
  }

  Future<void> _runSimulation() async {
    final bt = coinInfo['blockchainType'] as String? ?? '';
    // Only EVM chains support eth_call simulation
    if (bt != 'Ethereum') {
      if (mounted) setState(() => _simResult = TxSimulationResult.unavailable());
      return;
    }

    final m = widget.transationRecordModel;
    if (m == null) {
      if (mounted) setState(() => _simResult = TxSimulationResult.unavailable());
      return;
    }

    final coinType = coinInfo['coinType'] as String? ?? '';
    final isTest = m.isTest == 1;
    final data = _buildCalldata(m);
    // Native transfer: forward value (m.price is already BigInt).
    // Token transfer: value stays null — amount is encoded in calldata.
    final BigInt? value =
        (m.contract.isEmpty && m.price > BigInt.zero) ? m.price : null;

    final result = await TxSimulationService.simulate(
      coinType: coinType,
      from: m.from1,
      to: m.to1,
      data: data,
      value: value,
      isTest: isTest,
    );
    if (mounted) setState(() => _simResult = result);
  }

  /// GoPlus 合约安全检查（仅 EVM + ERC-20 合约，fail-open 设计）
  Future<void> _runGoplusCheck() async {
    final bt = coinInfo['blockchainType'] as String? ?? '';
    if (bt != 'Ethereum') return;

    final m = widget.transationRecordModel;
    if (m == null || m.contract.isEmpty) return;

    final coinType = coinInfo['coinType'] as String? ?? '';
    if (!GoplusSecurityService.supportsChain(coinType)) return;

    if (mounted) setState(() => _goplLoading = true);

    final result =
        await GoplusSecurityService.checkToken(coinType, m.contract);
    if (mounted) {
      setState(() {
        _goplResult = result;
        _goplLoading = false;
      });
    }
  }

  /// Reconstruct calldata from [TransationRecordModel]:
  /// - Native transfer (contract empty) → "0x"
  /// - ERC-20 transfer(address,uint256) → "0xa9059cbb" + padded address + padded amount
  /// - NFT or unknown contract call → "0x" (degraded, no revert detection)
  String _buildCalldata(TransationRecordModel m) {
    if (m.contract.isEmpty) {
      // Native token transfer — no calldata
      return '0x';
    }
    if (widget.isNft) {
      // Cannot reconstruct NFT calldata without full ABI — degrade gracefully
      return '0x';
    }
    // Standard ERC-20 transfer(address,uint256)
    // m.to1 may or may not have a leading "0x" — strip it safely.
    final raw = m.to1.toLowerCase();
    final toAddress = raw.startsWith('0x') ? raw.substring(2) : raw;
    final paddedTo = toAddress.padLeft(64, '0');
    // m.price is already BigInt — no toString/parse round-trip needed.
    final paddedAmount = m.price.toRadixString(16).padLeft(64, '0');
    return '0xa9059cbb$paddedTo$paddedAmount';
  }

  @override
  void dispose() {
    super.dispose();
  }
  //关闭键盘
  void closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  Future<bool> _pageBack(){
    if(Navigator.canPop(context)){
      Navigator.pop(context,false);
    }else{
      SystemNavigator.pop();
    }
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    String from="";
    String to="";
    String price="";
    if(widget.btcTransactionRecodeModel!=null){
      from=widget.btcTransactionRecodeModel!.address;
      to=widget.btcTransactionRecodeModel!.to1;
      price='${widget.btcTransactionRecodeModel!.priceDouble()} ${coinInfo['unit']}';
    }
    if(widget.transationRecordModel!=null){
      from=widget.transationRecordModel!.from1;
      to=widget.transationRecordModel!.to1;
      if(widget.isNft){
        price='${int.parse(widget.transationRecordModel!.priceDouble().toString())}';
      }else{
        price='${widget.transationRecordModel!.priceDouble()} ${coinInfo['unit']}';
      }
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child:Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).s_key_3,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: (){
              closeKeyboard();
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TxSimulationCard(result: _simResult),
                        if (_goplLoading) ...[
                          SizedBox(height: ScreenUtil().setWidth(8)),
                          const ContractSecurityCard.loading(),
                        ] else if (_goplResult != null) ...[
                          SizedBox(height: ScreenUtil().setWidth(8)),
                          ContractSecurityCard.result(result: _goplResult!),
                        ],
                        SizedBox(height: ScreenUtil().setWidth(16)),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: ScreenUtil().setWidth(30.0),
                          ),
                          child: Text(
                            S.of(context).g_key_202,
                            style: TextStyle(
                              fontSize: ScreenUtil().setWidth(28.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16.0),horizontal: ScreenUtil().setWidth(30.0)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAddressLabel(S.of(context).g_key_75, from),
                              _buildAddressLabel(S.of(context).g_key_38, to),
                              tapLabelWidget(S.of(context).g_key_44,price,),
                              tapLabelWidget(S.of(context).g_key_t_16,gasPrice,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Divider(
                        height: ScreenUtil().setWidth(1),
                        indent: 0,
                        endIndent: 0,
                      ),
                      Container(
                        padding: EdgeInsets.all( ScreenUtil().setWidth(30.0)),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                        height: ScreenUtil().setWidth(148),
                        child: Row(
                          children: [
                            Expanded(child: SizedBox(
                              width: double.infinity,
                              height: ScreenUtil().setWidth(88.0),
                              child: buttonStyle5(context, (){
                                Navigator.pop(context,false);
                              },
                                S.of(context).g_key_79,
                                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                borderColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                              ),
                            ),),
                            SizedBox(width: ScreenUtil().setWidth(30.0),),
                            Expanded(child: SizedBox(
                              width: double.infinity,
                              height: ScreenUtil().setWidth(88.0),
                              child: buttonStyle2(context, ()async{
                                bool r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletSecurityVerification()));
                                if (!context.mounted) return;
                                if(r){
                                  Navigator.pop(context,true);
                                }
                              }, S.of(context).g_key_t_31,),
                            ),),
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
      ),
    );
  }

  //带标签的label 控件
  /// 构建地址标签（支持 ENS 显示）
  Widget _buildAddressLabel(String title, String address) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(16.0),
        top: ScreenUtil().setWidth(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0)),
          EnsAddressDisplay(
            address: address,
            coinType: coinInfo['coinType'] ?? 'ETH',
            style: EnsDisplayStyle.full,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(28.0),
          ),
        ],
      ),
    );
  }

  Widget tapLabelWidget(String title,String value,{bool copy=false}){
    return Container(
      margin: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(16.0),
        top: ScreenUtil().setWidth(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
              if(copy)
                InkWell(
                  onTap: (){
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: value));
                    ToastUtils.showFtToast(child:successViewV1(S.of(context).copy),duration: 3);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20.0)),
                    width: ScreenUtil().setWidth(40.0),
                    height: ScreenUtil().setWidth(40.0),
                    child: Icon(
                      Icons.copy,
                      size: ScreenUtil().setWidth(40.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Divider(
            height: ScreenUtil().setWidth(1.0),
            indent: 0,
            endIndent: 0,
          ),
        ],
      ),
    );
  }
}
