import 'dart:async';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/trx_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_match.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_1559.dart';
import 'package:n42appv2/src/wallet/utils/chain_eth_layer2.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/coin_gas.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:n42appv2/src/widgets/text_field_widget.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42appv2/src/wallet/utils/address_validator.dart';
import 'package:n42appv2/src/wallet/api/gas_tracker_api.dart';
import 'package:n42appv2/src/wallet/models/gas_estimate_model.dart';
import 'package:n42appv2/src/wallet/pages/gas/gas_settings_page.dart';
import 'package:n42appv2/src/wallet/widgets/gas_selector_widget.dart';
import 'package:n42appv2/src/wallet/widgets/ens_confirm_dialog.dart';
import 'package:n42appv2/src/wallet/widgets/ens_address_field.dart';
import 'package:n42appv2/src/wallet/services/ens_service.dart';
import 'package:n42appv2/src/wallet/pages/send/send_utils.dart';
import 'package:n42appv2/src/wallet/services/recent_address_service.dart';

class WalletChainSend extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainSend(this.coinModel,{super.key});

  @override
  ConsumerState<WalletChainSend> createState() => _WalletChainSendState();
}

class _WalletChainSendState extends ConsumerState<WalletChainSend> {
  CoinModel? chainModel;
  Regular? regular;
  Regular get _regular{
    regular ??= Regular();
    return regular!;
  }
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }
  final oCcy =  NumberFormat("#,##0.00########", "en_US");
  TextEditingController toTextEditingController=TextEditingController();
  TextEditingController valueTextEditingController=TextEditingController();
  TextEditingController noteTextEditingController=TextEditingController();
  FocusNode toNode=FocusNode();
  FocusNode valueNode=FocusNode();
  FocusNode noteNode=FocusNode();

  String toErrorMessage="";
  String noteErrorMessage="";
  String amountErrorMessage="";
  String errorMessage="";

  BigInt totalGasPrice=BigInt.zero;
  BigInt gasPrice=BigInt.zero;
  BigInt gasPriceEth=BigInt.zero;
  BigInt gas=BigInt.zero;
  BigInt gasEth=BigInt.zero;
  BigInt transferValue=BigInt.zero;//转账金额

  // Gas 优化相关
  GasEstimateModel? _gasEstimate;
  bool _useAdvancedGas = false;

  Load load=Load.loading;
  Load gasLimitLoad=Load.finish;
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  @override
  void initState() {
    super.initState();
    valueTextEditingController.text="0";
    // 监听地址输入，对 ENS 名称做实时解析
    toTextEditingController.addListener(_onToAddressInputChanged);
    initData();
  }
  @override
  void dispose() {
    toTextEditingController.removeListener(_onToAddressInputChanged);
    _ensDebounceTimer?.cancel();
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    noteTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    noteNode.dispose();
    super.dispose();
  }

  Future<void> initData()async{
    //判断是否是代币
    if(widget.coinModel.coin['isContract']){
      WalletActionProvider wap=ref.read(wapBridgeProvider);
      int cIndex=wap.coinModels.indexWhere((element){
        if(element.coin['coinType']==widget.coinModel.coin['coinType']){
          if(widget.coinModel.privateKey !=null){
            if(element.privateKey==widget.coinModel.privateKey){
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
      chainModel=wap.coinModels[cIndex];
      await chainModel?.getBalance();
      setState(() {});
    }
    gas=BigInt.from(getCoinGas(widget.coinModel.coin['coinType'],contract:widget.coinModel.coin['isContract']));
    await getBalance();
    await getGasPrice();
    if(getEthLayer2(widget.coinModel.coin['coinType'])){
      gasEth=BigInt.from(getCoinGas(CoinType.ETH.name));
      await getGasPriceLayer2();
    }
  }
  //获取余额
  Future<void> getBalance()async{
    setState(() {
      load=Load.loading;
    });
    bool isOk=await widget.coinModel.getBalance(getToken: false);
    if(isOk==false){
      load=Load.finish;
      errorMessage=S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState((){});
      return;
    }
  }
  //获取旷工费
  Future<void> getGasPrice()async{
    setState(() {
      load=Load.loading;
    });

    // 尝试获取高级 Gas 估算（仅 EVM 链）
    if (widget.coinModel.coin['blockchainType'] == BlockchainType.Ethereum.name) {
      await _fetchAdvancedGasEstimate();
    }

    // 传统方式获取 gas price（作为后备）
    String? rpc=widget.coinModel.coin['custom']==true?widget.coinModel.isTest?widget.coinModel.coin['service_test']:widget.coinModel.coin['service']:null;
    MessageModel mm=await tokenViewApi.getGasPrice(
        widget.coinModel.coin['blockchainType'],
        widget.coinModel.coin['coinType'],
        isTest:widget.coinModel.isTest,
      rpc: rpc,
    ) ?? MessageModel.error();
    if(mm.error==false){
      gasPrice=mm.data;
      if(get1559WithChainSymbol(widget.coinModel.coin['coinType']) && widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
        gasPrice=gasPrice*BigInt.from(2);
      }
    }else{
      errorMessage=mm.data.toString();
      ToastUtils.show(errorMessage);
    }

    // 如果有高级 Gas 估算，使用它的值
    if (_gasEstimate != null && _useAdvancedGas) {
      totalGasPrice = _gasEstimate!.currentTotalFee;
      gasPrice = _gasEstimate!.currentOption.effectiveGasPrice;
      gas = _gasEstimate!.gasLimit;
    } else {
      totalGasPrice=gasPrice*gas;
    }

    load=Load.finish;
    setState(() {});
  }

  /// 获取高级 Gas 估算数据
  Future<void> _fetchAdvancedGasEstimate() async {
    final gasTracker = GasTrackerApi();
    final result = await gasTracker.getGasEstimate(
      coinType: widget.coinModel.coin['coinType'],
      isTest: widget.coinModel.isTest,
      isContract: widget.coinModel.coin['isContract'] ?? false,
    );

    if (!result.error && result.data is GasEstimateModel) {
      _gasEstimate = result.data as GasEstimateModel;
      _useAdvancedGas = true;
    }
  }

  /// 打开 Gas 设置页面
  Future<void> _openGasSettings() async {
    if (_gasEstimate == null) return;

    final result = await Navigator.push<GasEstimateModel>(
      context,
      MaterialPageRoute(
        builder: (context) => GasSettingsPage(gasEstimate: _gasEstimate!),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _gasEstimate = result;
        totalGasPrice = _gasEstimate!.currentTotalFee;
        gasPrice = _gasEstimate!.currentOption.effectiveGasPrice;
        gas = _gasEstimate!.gasLimit;
      });
    }
  }
  //获取旷工费 ETH链，当操作的是ETH Layer2的时候调用
  Future<void> getGasPriceLayer2()async{
    setState(() {
      load=Load.loading;
    });
    String rpc=chainUrlMap[CoinType.ETH.name]?['baseInfo']?[widget.coinModel.isTest?'service_test':'service']??"";
    MessageModel mm=await tokenViewApi.getGasPrice(
      widget.coinModel.coin['blockchainType'],
      CoinType.ETH.name,
      isTest:false,
      rpc: rpc,
    ) ?? MessageModel.error();
    if(mm.error==false){
      gasPriceEth=mm.data;
    }else{
      errorMessage=mm.data.toString();
      ToastUtils.show(errorMessage);
    }

    totalGasPrice=totalGasPrice+BigInt.from((100 * gasPriceEth.toInt() * 2100)/16);
    load=Load.finish;
    setState(() {});
  }
  //eth 模拟交易
  Future<dynamic> estimateGasEthLocal({bool checkAddress=true})async{
    closeKeyboard();
    if(gasLimitLoad==Load.loading)return;
    setState(() {
      gasLimitLoad=Load.loading;
    });
    if(widget.coinModel.coin['blockchainType'] != BlockchainType.Ethereum.name && widget.coinModel.coin['blockchainType'] !=BlockchainType.Tron.name){
      return;
    }
    try{
      String? toAddr;
      if(checkAddress){
        if(amountErrorMessage !="")return;
        toAddr=await toAddressCheck(toTextEditingController.text.trim());
        if(toAddr==null){
          return;
        }
      }else{
        toAddr=toTextEditingController.text.trim();
      }
      if(toErrorMessage !="")return;
      String price=valueTextEditingController.text;
      if(price==""){
        return;
      }
      bool addLatest=true;
      if(widget.coinModel.coin['coinType']==CoinType.OKT.name
          || widget.coinModel.coin['coinType']==CoinType.MTR.name
          || widget.coinModel.coin['coinType']==CoinType.METIS.name
          || widget.coinModel.coin['coinType']==CoinType.VIC.name
          || widget.coinModel.coin['coinType']==CoinType.BOBA.name
          || widget.coinModel.coin['coinType']==CoinType.OP.name
          || widget.coinModel.coin['coinType']==CoinType.GO.name){
        addLatest=false;
      }
      //await getGasPrice();
      BigInt gaslimit=BigInt.from(getCoinGas(widget.coinModel.coin['coinType'],contract:widget.coinModel.coin['isContract']));
      MessageModel ethMessage;
      if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Tron.name){
        TrxApi trxApi=TrxApi();
        ethMessage=await trxApi.getGasEstimateTrx(
          widget.coinModel.address,
          toAddr,
          gasPrice,
          ethToWeiString(price,widget.coinModel.coin['decimals']),
          gaslimit,
          contract: widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'],
          isTest:widget.coinModel.isTest,
        );
      }
      else{
        String rpc;
        if(widget.coinModel.isTest){
          rpc=widget.coinModel.coin['service_test'];
        }else{
          rpc=widget.coinModel.coin['service'];
        }
        EthAPI ethAPI=EthAPI.init(null, rpc, null);
        ethMessage=await ethAPI.getGasLimit(
          widget.coinModel.address,
          toAddr,
          gasPrice,
          ethToWeiString(price,widget.coinModel.coin['decimals']),
          gaslimit,
          contract: widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'],
          isTest: widget.coinModel.isTest,
          addLatest:addLatest,
        );
      }

      if(ethMessage.error==false){
        gas=ethMessage.data;
        if(widget.coinModel.coin['coinType']==CoinType.BOBA.name
            || widget.coinModel.coin['coinType']==CoinType.OP.name){
          gas=BigInt.from(gas.toInt()*1.5);
        }
        if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name && widget.coinModel.coin['isContract']==false){
          String note=noteTextEditingController.text.trim();
          if(note !=""){
            String noteHex=bytesToHex(note.codeUnits);
            gas=gas+BigInt.from((noteHex.length*8));
          }
        }
        totalGasPrice=gasPrice*gas;
        errorMessage="";
        return true;
      }else{
        errorMessage=ethMessage.data;
        return false;
      }
    }catch(e){
      errorMessage=e.toString();
      return false;
    }finally{
      setState(() {
        gasLimitLoad=Load.finish;
      });
    }
  }
  /// Validate amount input using Decimal for precision
  ///
  /// IMPORTANT: Uses Decimal library instead of double to avoid floating-point
  /// precision errors in financial calculations. This prevents issues like:
  /// - 0.1 + 0.2 != 0.3 in floating-point arithmetic
  /// - Rounding errors in large numbers
  void amountCheck({String value=""}) {
    if (value.isEmpty) {
      value = valueTextEditingController.text;
    }

    final int decimals = widget.coinModel.coin['decimals'] ?? 18;
    final int minValue = decimals == 0 ? 1 : 0;

    if (value.isEmpty) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    // Validate format
    bool isValidInteger = _regular.regularNums(value);
    bool isValidDecimal = _regular.regularDouble(value);

    if (decimals == 0) {
      // For zero-decimal tokens (like NFTs), only integers are valid
      if (!isValidInteger) {
        amountErrorMessage = S.of(context).g_key_134;
        setState(() {});
        return;
      }
    } else {
      if (!isValidInteger && !isValidDecimal) {
        amountErrorMessage = S.of(context).g_key_134;
        setState(() {});
        return;
      }
    }

    // Use Decimal for precise comparison instead of double
    Decimal decimalValue;
    try {
      decimalValue = Decimal.parse(value);
    } catch (e) {
      amountErrorMessage = S.of(context).g_key_134;
      setState(() {});
      return;
    }

    // Check minimum value
    if (decimalValue < Decimal.fromInt(minValue)) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    // Check if zero
    if (decimalValue == Decimal.zero) {
      amountErrorMessage = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    // Convert to wei using string to avoid floating-point errors
    // ethToWeiString handles the conversion precisely
    BigInt valueBi = ethToWeiString(value, decimals);

    if (widget.coinModel.coin['blockchainType'] == BlockchainType.Ripple.name) {
      // XRP requires minimum 10 XRP reserve
      final reserveAmount = ethToWeiString("10", decimals);
      if (valueBi + totalGasPrice > widget.coinModel.balance - reserveAmount) {
        amountErrorMessage = S.of(context).g_key_47;
        setState(() {});
        return;
      }
    } else {
      if (widget.coinModel.coin['isContract'] == false) {
        // Native token: check balance includes gas
        if (valueBi + totalGasPrice > widget.coinModel.balance) {
          amountErrorMessage = S.of(context).g_key_47;
          setState(() {});
          return;
        }
      }
      transferValue = valueBi;
    }

    amountErrorMessage = "";
    setState(() {});
  }
  /// Address validator instance
  AddressValidator? _addressValidator;
  AddressValidator get addressValidator {
    _addressValidator ??= AddressValidator(tokenViewApi: tokenViewApi);
    return _addressValidator!;
  }

  /// 用户是否已确认 ENS 解析结果
  bool _ensConfirmed = false;

  // ── ENS 实时解析状态（地址输入框下方的内联状态横幅） ──
  final EnsService _ensService = EnsServiceProvider.instance;
  EnsResolveStatus _ensStatus = EnsResolveStatus.idle;
  EnsResolutionResult? _ensResult;
  Timer? _ensDebounceTimer;

  /// 检查链是否支持 ENS 解析
  /// N42 链优先，然后是所有 EVM 兼容链
  bool _isEnsSupported(String coinType) {
    // N42 链优先支持 ENS
    if (coinType == CoinType.N.name) return true;

    // ETH 主网支持
    if (coinType == CoinType.ETH.name) return true;

    // 其他 EVM 兼容链
    const evmChains = [
      'BNB', 'MATIC', 'AVAX', 'FTM', 'OP', 'ARB',
      'CELO', 'ONE', 'CRO', 'MOVR', 'GLMR',
    ];
    return evmChains.contains(coinType);
  }

  // ── ENS 实时解析（防抖 500ms，仅在 ENS 支持链上触发） ──────────────────────

  void _onToAddressInputChanged() {
    final coinType = widget.coinModel.coin['coinType'] as String;
    if (!_isEnsSupported(coinType)) return;

    _ensDebounceTimer?.cancel();
    final text = toTextEditingController.text.trim();

    if (text.isEmpty || !EnsService.isEnsName(text)) {
      if (_ensStatus != EnsResolveStatus.idle) {
        setState(() {
          _ensStatus = EnsResolveStatus.idle;
          _ensResult = null;
        });
      }
      return;
    }

    setState(() {
      _ensStatus = EnsResolveStatus.resolving;
      _ensResult = null;
    });

    _ensDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _resolveEnsRealtime(text, coinType);
    });
  }

  Future<void> _resolveEnsRealtime(String ensName, String coinType) async {
    final result = await _ensService.resolveName(ensName, preferredChain: coinType);
    if (!mounted) return;
    setState(() {
      _ensStatus = result.success && result.address != null
          ? EnsResolveStatus.resolved
          : EnsResolveStatus.failed;
      _ensResult = result;
    });
  }

  /// 地址输入框下方的 ENS 实时状态横幅
  Widget _buildEnsStatusBanner() {
    if (_ensStatus == EnsResolveStatus.idle) return const SizedBox.shrink();

    final subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final mainTextColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    // 解析中：旋转指示器 + 文本
    if (_ensStatus == EnsResolveStatus.resolving) {
      return Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
        child: Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(20),
              height: ScreenUtil().setWidth(20),
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(blueColor),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(
              S.of(context).g_key_ens_resolving,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: subtitleColor,
              ),
            ),
          ],
        ),
      );
    }

    // 解析失败：橙色警告
    if (_ensStatus == EnsResolveStatus.failed) {
      final errMsg = _ensResult?.error ?? S.of(context).g_key_t_50;
      return Padding(
        padding: EdgeInsets.only(
          top: ScreenUtil().setWidth(6),
          left: ScreenUtil().setWidth(4),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: ScreenUtil().setWidth(20)),
            SizedBox(width: ScreenUtil().setWidth(6)),
            Expanded(
              child: Text(
                errMsg,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 解析成功：绿色卡片，显示缩短地址 + 来源链徽章，点击复制
    if (_ensStatus == EnsResolveStatus.resolved && _ensResult?.address != null) {
      final resolvedAddr = _ensResult!.address!;
      final shortAddr = AddressValidator.getAddressPreview(
        resolvedAddr,
        prefixLength: 6,
        suffixLength: 4,
      );

      return GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: resolvedAddr));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).g_key_ens_copy_address),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(12),
            vertical: ScreenUtil().setWidth(8),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: const Color(0xFF4CAF50),
                size: ScreenUtil().setWidth(20),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).g_key_ens_resolved_address,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20),
                        color: subtitleColor,
                      ),
                    ),
                    Text(
                      shortAddr,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        fontWeight: FontWeight.w600,
                        color: mainTextColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              if (_ensResult?.sourceChain != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(6),
                    vertical: ScreenUtil().setWidth(3),
                  ),
                  decoration: BoxDecoration(
                    color: blueColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(5)),
                  ),
                  child: Text(
                    _ensResult!.sourceChain!,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(18),
                      fontWeight: FontWeight.w600,
                      color: blueColor,
                    ),
                  ),
                ),
              SizedBox(width: ScreenUtil().setWidth(4)),
              Icon(
                Icons.copy_rounded,
                color: subtitleColor,
                size: ScreenUtil().setWidth(18),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Enhanced address validation with multiple security layers
  ///
  /// Security features:
  /// - Format validation
  /// - Self-transfer prevention
  /// - ENS resolution with user confirmation
  /// - Address preview display
  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }

    // 获取当前链类型
    final coinType = widget.coinModel.coin['coinType'] as String;

    // 判断是否支持 ENS (N42 优先，然后是所有 EVM 兼容链)
    final supportsEns = _isEnsSupported(coinType);

    final result = await addressValidator.validateAddress(
      coinType: coinType,
      address: addr,
      senderAddress: widget.coinModel.address.toString(),
      allowEns: supportsEns,
    );

    if (!result.isValid) {
      toErrorMessage = result.errorMessage ?? S.current.g_key_t_50;
      setState(() {});
      return null;
    }

    // Handle ENS resolution - show confirmation to user
    if (result.isEnsResolved && result.ensName != null) {
      // 如果用户尚未确认，显示确认对话框
      if (!_ensConfirmed && mounted) {
        final confirmed = await EnsConfirmDialog.show(
          context: context,
          ensName: result.ensName!,
          resolvedAddress: result.resolvedAddress ?? '',
          tokenSymbol: widget.coinModel.coin['symbol'],
        );

        if (!confirmed) {
          // 用户取消
          _ensConfirmed = false;
          return null;
        }

        // 用户确认
        _ensConfirmed = true;
      }

      debugPrint('ENS resolved: ${result.ensName} -> ${AddressValidator.getAddressPreview(result.resolvedAddress ?? "")}');
    }

    toErrorMessage = "";
    setState(() {});
    return result.resolvedAddress;
  }
  Future<void> sendTransaction()async{
    if(load==Load.loading){
      ToastUtils.show("loading");
      return;
    }
    if(amountErrorMessage !="")return;
    closeKeyboard();
    amountCheck();
    if(amountErrorMessage !=""){
      return;
    }
    setState(() {
      load=Load.loading;
    });
    String? toAddr=await toAddressCheck(toTextEditingController.text.trim());
    if(toAddr == null) {
      setState(() {
        load=Load.finish;
      });
      return;
    }
    await estimateGasEthLocal(checkAddress: false);
    if(errorMessage != ""){
      setState(() {
        load=Load.finish;
      });
      return;
    }
    BigInt uBalance=widget.coinModel.balance;
    if(widget.coinModel.coin['isContract']){
      uBalance=chainModel?.balance??BigInt.zero;
    }
    if(totalGasPrice > uBalance){
      setState(() {
        load=Load.finish;
      });
      return;
    }
    if(widget.coinModel.balance==BigInt.zero){
      setState(() {
        load=Load.finish;
      });
      return;
    }
    if (!mounted) return;
    TransationRecordModel trModel=TransationRecordModel();
    trModel.address=widget.coinModel.address.toString();
    trModel.from1=widget.coinModel.address.toString();
    trModel.to1=toAddr;//toTextEditingController.text;
    trModel.addrType=widget.coinModel.addrType;
    trModel.coin=widget.coinModel.coin;
    trModel.coinMiniName=widget.coinModel.coin['coinType'];
    trModel.walletIndex=ref.read(wapBridgeProvider).walletIndex;
    trModel.contract=widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'];
    trModel.isTest=widget.coinModel.isTest?1:0;
    trModel.gasPrice=totalGasPrice;
    trModel.gas=gas.toInt();
    trModel.gasPriceValue=gasPrice;
    trModel.price=transferValue;
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      trModel.message=noteTextEditingController.text.trim();
    }
    bool check=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletBaseSend(trModel,null,chainModel==null?widget.coinModel.coin['unit'].toString().toUpperCase():chainModel!.coin['unit'].toString().toUpperCase())));
    if (!mounted) return;
    if(check){
      signTx(trModel);
    }else{
      setState(() {
        load=Load.finish;
      });
    }
  }
  Future<void> signTx(TransationRecordModel trModel)async{
    if(signTxCheck()==false)return;
    try{
      TransferApi transferApi=TransferApi();
      MessageModel mm=await transferApi.transferWallet(
          trModel: trModel,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex,
      );
      if (!mounted) return;
      if(mm.error){
        errorMessage=mm.data;
      }else{
        trModel.txHash=mm.data;
        AppDatabase appDatabase =AppDatabase();
        trModel.trId=await appDatabase.insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel,1);
        await RecentAddressService.save(
          widget.coinModel.coin['coinType'] ?? '',
          toTextEditingController.text.trim(),
        );
        if (!mounted) return;
        ToastUtils.show(S.current.g_key_nft_41);
        Navigator.pop(context);
      }
    }catch(e){
      errorMessage=e.toString();
      ToastUtils.show(e.toString());
    }finally{
      load=Load.finish;
      setState(() {});
    }
  }
  bool signTxCheck(){
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      if(widget.coinModel.coin['isContract']){
        BigInt chainBalance=chainModel?.balance??BigInt.zero;
        if(chainBalance==BigInt.zero){
          ToastUtils.show(S.current.g_key_t_29(chainModel?.coin['coinType']??""));
          return false;
        }else if(totalGasPrice > chainBalance){
          ToastUtils.show(S.current.g_key_t_29(chainModel?.coin['coinType']??""));
          return false;
        }
      }
    }
    return true;
  }
  void scanQR() async{
    String? scanValue =await Navigator.push(context, MaterialPageRoute(builder: (context)=>ScanPage()));
    if (!mounted) return;
    if(scanValue !=null){
      toTextEditingController.text=scanValue;
      // 扫码填入普通地址时重置 ENS 状态（监听器会处理 ENS 名称）
      if (!EnsService.isEnsName(scanValue)) {
        setState(() {
          _ensStatus = EnsResolveStatus.idle;
          _ensResult = null;
        });
      }
      toAddressCheck(scanValue);
    }
    Navigator.pop(context);
  }
  Future<void> maxTag()async{
    if(gasLimitLoad==Load.loading)return;
    if(widget.coinModel.coin['isContract']){
      valueTextEditingController.text=widget.coinModel.balanceStringAll();
      transferValue=widget.coinModel.balance;
      estimateGasEthLocal();
    }else{
      if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name || widget.coinModel.coin['blockchainType']==BlockchainType.Tron.name){
        valueTextEditingController.text=widget.coinModel.balanceStringAll();
        bool? rOK=await estimateGasEthLocal();
        if(rOK != null && rOK){
          transferValue=widget.coinModel.balance-totalGasPrice;
          valueTextEditingController.text=_regular.formartNum(toEther(transferValue.toString(),widget.coinModel.coin['decimals']).toDouble(), 14,isCrop: true,isFill0: false);
        }
      }
      else{
        transferValue=widget.coinModel.balance-totalGasPrice;
        valueTextEditingController.text=toEther(transferValue.toString(),widget.coinModel.coin['decimals']).toString();
      }
    }
    amountErrorMessage="";
    setState(() {});
  }
  //关闭键盘
  void closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:"${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
        /*actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> AddressBookList(coinName: widget.coinModel.coin['coinType'],))).then((value)async{
                if(value !=null){
                  toTextEditingController.text=value;
                }
              },);
            },
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(right:ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(20.0),),
              child: Image.asset(
                'assets/wallet/addressBook.png',
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],*/
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: closeKeyboard,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: coinTypeWidget(),
                ),
              ),
              sendButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
  Widget coinTypeWidget(){
    List<Widget> cChildren=[
      /*
      WalletChainInfoTitle(
        title: Text(
          "${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(32.0),
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: null,
        rightWidget: null,
        rightImgUrl: "assets/wallet/addressBook.png",
        rightTao: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context)=> AddressBookList(coinName: widget.coinModel.coin['coinType'],))).then((value)async{
            if(value !=null){
              toTextEditingController.text=value;
            }
          },);
        },
      ),
      */
      RecentAddressBar(
        coinType: widget.coinModel.coin['coinType'] ?? '',
        onSelected: (addr) {
          toTextEditingController.text = addr;
          toAddressCheck(addr);
        },
      ),
      toWidget(),
      amountWidget(),
      noteWidget(),
      minerFeeWidget(),
      errorMessageWidget(),
      SizedBox(height: 100,),
    ];
    return Column(
      children: cChildren,
    );
  }
  Widget toWidget(){
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20.0),),
          textFieldStyle2(
            context,
            controller: toTextEditingController,
            focusNode: toNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: (){
              FocusScope.of(context).requestFocus(valueNode);
              toAddressCheck(toTextEditingController.text.trim());
            },
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            errorMessage: toErrorMessage,
            rightWidget1: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.add,
                size: ScreenUtil().setWidth(50.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            rightOnTap1: searchToAddressWidget,
            bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              /*
            rightWidget3: widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name?Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.face_outlined,
                size: ScreenUtil().setWidth(50.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ):null,
            rightOnTap3: widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name?faceMatchTypeWidget:null,
            rightWidget1: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Image.asset(
                "assets/wallet/scan.png",
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                width: ScreenUtil().setWidth(50.0),
                height: ScreenUtil().setWidth(50.0),
              ),
            ),
            rightWidget2: Container(
              //margin: EdgeInsets.only(left: scr.setWidth(10.0)),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(60.0),)),
              ),
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_key_166,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                ),
              ),
            ),
            rightOnTap1: scanQR,
            rightOnTap2: ()async{
              ClipboardData? cd = await Clipboard.getData(Clipboard.kTextPlain);
              if(cd !=null){
                if(cd.text !=null && cd.text != "null"){
                  toTextEditingController.text=cd.text??"";
                  setState(() {
                  });
                  toAddressCheck(cd.text??"");
                }
              }
            },
            */
          ),
          // ENS 实时解析状态横幅（ENS 支持链上输入 ENS 名称时自动展示）
          _buildEnsStatusBanner(),
        ],
      ),
    );
  }
  Widget noteWidget(){
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name && widget.coinModel.coin['isContract']==false) {
      return Container(
        margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_wallet_k58,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20.0),),
            textFieldStyle2(
              context,
              controller: noteTextEditingController,
              focusNode: noteNode,
              hintText: S.of(context).nicknameMessage(100),
              errorMessage: noteErrorMessage,
              suffix: Text(
                "${noteTextEditingController.text.length}/100",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(20.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(toNode);
              },
              onChanged: (String value){
                if(value.length>100){
                  noteErrorMessage=S.of(context).nicknameMessage(100);
                }else{
                  noteErrorMessage="";
                }
                setState(() {});
              },
              maxLines: 2,
              height: ScreenUtil().setWidth(108.0),
              bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }
  Widget amountWidget(){
    return containerStyle1(
      context,
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left:ScreenUtil().setWidth(30.0),
              right:ScreenUtil().setWidth(30.0),
              top: ScreenUtil().setWidth(30.0),
            ),
            child: Row(
              children: [
                Text(
                  S.of(context).g_key_44,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(20.0),),
                Expanded(flex: 1,child: amountBalanceWidget(),),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius:BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
                  offset: Offset(0, 1), //阴影位置,从什么位置开始
                  blurRadius: ScreenUtil().setWidth(4.0),  // 阴影模糊层度
                  spreadRadius: 0, )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: valueTextEditingController,
                  focusNode: valueNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(54.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textFieldHintColor.name),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value){
                    amountCheck(value: value);
                  },
                  onEditingComplete: (){
                    amountCheck();
                    FocusScope.of(context).requestFocus(toNode);
                  },
                  fontSize: ScreenUtil().setWidth(70.0),
                  height: ScreenUtil().setWidth(120.0),
                  boxShadow:BoxShadow(
                    color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
                    offset: Offset(0, 0), //阴影位置,从什么位置开始
                    blurRadius: ScreenUtil().setWidth(0),  // 阴影模糊层度
                    spreadRadius: 0, ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                  rightWidget1: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(60.0),)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_197,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                  rightOnTap1: (){
                    maxTag();
                  },
                ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(30.0),
                  endIndent: ScreenUtil().setWidth(30.0),
                ),
                ownerAddress(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget amountBalanceWidget(){
    String unit=widget.coinModel.coin['unit'].toString().toUpperCase();
    return Text(
      '${widget.coinModel.balanceStringAll()} $unit',
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        fontSize: ScreenUtil().setSp(28.0),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }
  //返回账户地址
  Widget ownerAddress(){
    String addr="";
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      addr=widget.coinModel.address.toString();
    }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Solana.name){
      addr=widget.coinModel.address.toString();
    }else{
      addr=widget.coinModel.address.toString();
    }
    addr=dataUtils.addressFarmat(addr);
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(30.0),
        left: ScreenUtil().setWidth(30.0),
      ),
      child: Text(addr,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  //旷工费
  Widget minerFeeWidget(){
    // 如果有高级 Gas 估算且是 EVM 链，显示 Gas 选择器
    if (_gasEstimate != null &&
        _useAdvancedGas &&
        widget.coinModel.coin['blockchainType'] == BlockchainType.Ethereum.name) {
      return _advancedMinerFeeWidget();
    }

    /*if(widget.coinModel.coin['blockchainType']==BlockchainType.Tezos.name){
      return minerFeeWidget_TezosXTZ();
    }*/
    String title=widget.coinModel.coin['coinType'];
    String totalGasPriceStr="";
    String gasPriceStr="";
    Color totalGasPriceColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    Widget gasLimitWidget=Container();
    int decimals=widget.coinModel.coin['decimals'];
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      String unit=widget.coinModel.coin['unit'].toString().toUpperCase();
      if(widget.coinModel.coin['isContract']){
        decimals=chainModel?.coin['decimals']??0;
        unit=(chainModel?.coin['unit']??"").toString().toUpperCase();
        BigInt chainBalance=chainModel?.balance?? BigInt.zero;
        if(totalGasPrice > chainBalance){
          totalGasPriceColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
        }
      }
      totalGasPriceStr='${Decimal.parse(toEther(totalGasPrice.toString(),decimals).toString())}$unit';
      gasPriceStr='${Decimal.parse(toGWei(gasPrice.toString()).toString()) }Gwei';
      gasLimitWidget=Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0)),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_101,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(10),),
            Expanded(flex: 1,child: Text(
              "$gas",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
              textAlign: TextAlign.right,
            ),),
          ],
        ),
      );
    }
    else if(widget.coinModel.coin['blockchainType']==BlockchainType.Tron.name){
      if(widget.coinModel.coin['isContract']){
        decimals=chainModel?.coin['decimals']??0;
        if(toEther(totalGasPrice.toString(),decimals).toDouble() > (chainModel?.balanceDoubleAll()??0)){
          totalGasPriceColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
        }
      }
      totalGasPriceStr='${toEther(totalGasPrice.toString(),decimals)} $title';
      gasPriceStr='${toEther(gasPrice.toString(),decimals) } $title';
      gasLimitWidget=Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0)),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_101,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            Expanded(flex: 1,child: Container()),
            Text(
              "$gas",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
          ],
        ),
      );
    }
    else{
      if(widget.coinModel.coin['isContract']){
        decimals=chainModel?.coin['decimals']??0;
      }
      totalGasPriceStr='${toEther(totalGasPrice.toString(),decimals)} $title';
      gasPriceStr='${toEther(gasPrice.toString(),decimals) } $title';
    }

    return containerStyle1(
      context,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          if(widget.coinModel.coin['isContract'])
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).g_key_29,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  Expanded(flex: 1,child: Text(
                    '${chainModel?.balanceDoubleAll()??0} ${(chainModel?.coin['unit']??"").toString().toUpperCase()}',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                    textAlign: TextAlign.right,
                  ),),

                ],
              ),
            ),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_t_17,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10),),
                Expanded(
                  flex: 1,
                  child: Text(
                    gasPriceStr,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                    textAlign: TextAlign.right,
                  ),),
              ],
            ),
          ),
          gasLimitWidget,
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0)),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_t_16,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10),),
                Expanded(flex: 1,child: Text(
                  totalGasPriceStr,
                  style: TextStyle(
                    color: totalGasPriceColor,
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                  textAlign: TextAlign.right,
                ),),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 高级矿工费显示组件（带 Gas 选择器）
  Widget _advancedMinerFeeWidget() {
    // 检查余额是否足够支付 gas
    bool gasExceedsBalance = false;
    if (widget.coinModel.coin['isContract']) {
      BigInt chainBalance = chainModel?.balance ?? BigInt.zero;
      gasExceedsBalance = totalGasPrice > chainBalance;
    }

    return Column(
      children: [
        // 主链余额显示（如果是代币转账）
        if (widget.coinModel.coin['isContract'])
          containerStyle1(
            context,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(20.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_29,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? "").toString().toUpperCase()}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: ScreenUtil().setWidth(20.0)),

        // Gas 选择器（紧凑版，可点击打开设置页面）
        GasSelectorCompact(
          gasEstimate: _gasEstimate!,
          onTap: _openGasSettings,
        ),

        // 如果 gas 费用超过余额，显示警告
        if (gasExceedsBalance)
          Container(
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(10.0),
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(30.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20.0),
              vertical: ScreenUtil().setWidth(10.0),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  size: ScreenUtil().setWidth(32.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                ),
                SizedBox(width: ScreenUtil().setWidth(10.0)),
                Expanded(
                  child: Text(
                    S.of(context).g_key_t_29(chainModel?.coin['coinType'] ?? ""),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget errorMessageWidget(){
    if(errorMessage==""){
      return SizedBox();
    }else{
      return Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),left: ScreenUtil().setWidth(30),right: ScreenUtil().setWidth(30)),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
        ),
        child: Text(
          errorMessage,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
          ),
        ),
      );
    }

  }
  //提交按钮
  Widget sendButtonWidget(){
    String title=S.of(context).g_key_48;
    return Positioned(
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
                sendTransaction();
              },
              load==Load.loading?'${S.of(context).g_key_106}...':title,
              AppThemeUtils.getColorByKey(
                context, load==Load.loading?
              AppThemeKeys.mainButtonBgColor3.name:
              AppThemeKeys.mainButtonBgColor.name,
              ),
              AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
              load==Load.loading,
            ),
          ),
        ],
      ),
    );
  }
  void faceMatchTypeWidget(){
    Widget child=Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(1)));
            if (!mounted) return;
            if(address !=null){
              toTextEditingController.text=address;
              toAddressCheck(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).photograph,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(2)));
            if (!mounted) return;
            if(address !=null){
              toTextEditingController.text=address;
              toAddressCheck(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).g_key_nft_16,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
    sheetBottom(context, S.of(context).g_face_match_key1, child);
  }
  void searchToAddressWidget() {
    showAddressPickerSheet(
      context,
      coinModel: widget.coinModel,
      onAddressSelected: (addr) {
        toTextEditingController.text = addr;
        toAddressCheck(addr);
      },
      isEvm: true,
    );
  }
}
