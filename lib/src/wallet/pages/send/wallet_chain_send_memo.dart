import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';
import 'package:n42_wallet/src/utils/data_utils.dart';
import 'package:n42_wallet/src/utils/regular.dart';
import 'package:n42_wallet/src/wallet/api/transfer_api.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/src/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/src/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/src/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/src/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/text_field_widget.dart';

/// 通用 Memo 发送页，覆盖所有无专属发送页的非 EVM 链。
///
/// 支持：收款地址、金额、可选备注（Memo/Note）。
/// 实际交易由 [TransferApi.transferWallet] 处理；若链暂不支持，
/// 则捕获异常并友好提示。
class WalletChainSendMemo extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendMemo(this.coinModel, {super.key});

  @override
  ConsumerState<WalletChainSendMemo> createState() =>
      _WalletChainSendMemoState();
}

class _WalletChainSendMemoState extends ConsumerState<WalletChainSendMemo> {
  CoinModel? chainModel; // 代币场景下的主链 model（提供 gas 余额）

  Regular? _regular;
  Regular get _reg {
    _regular ??= Regular();
    return _regular!;
  }

  DataUtils? _dataUtils;
  DataUtils get dataUtils {
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }

  final TextEditingController _toCtrl = TextEditingController();
  final TextEditingController _valueCtrl = TextEditingController();
  final TextEditingController _memoCtrl = TextEditingController();

  final FocusNode _toNode = FocusNode();
  final FocusNode _valueNode = FocusNode();
  final FocusNode _memoNode = FocusNode();

  String _toError = '';
  String _amountError = '';
  String _errorMessage = '';

  BigInt _totalGasPrice = BigInt.zero;
  BigInt _gasPrice = BigInt.zero;
  BigInt _gas = BigInt.zero;
  BigInt _transferValue = BigInt.zero;

  Load _load = Load.loading;

  @override
  void initState() {
    super.initState();
    _valueCtrl.text = '0';
    _initData();
  }

  @override
  void dispose() {
    _toCtrl.dispose();
    _valueCtrl.dispose();
    _memoCtrl.dispose();
    _toNode.dispose();
    _valueNode.dispose();
    _memoNode.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    if (widget.coinModel.coin['isContract'] == true) {
      final wap = ref.read(wapBridgeProvider);
      final coinType = widget.coinModel.coin['coinType'];
      final idx = wap.coinModels.indexWhere((m) {
        if (m.coin['coinType'] != coinType) return false;
        final pk = widget.coinModel.privateKey;
        return pk == null || m.privateKey == pk;
      });
      if (idx >= 0) {
        chainModel = wap.coinModels[idx];
        await chainModel!.getBalance();
        if (!mounted) return;
        setState(() {});
      }
    }

    _gas = BigInt.from(getCoinGas(
      widget.coinModel.coin['coinType'] as String? ?? '',
      contract: widget.coinModel.coin['isContract'] == true,
    ));
    // 非 EVM 链 gas 固定为 gas 单位（无需 gasPrice rpc 查询）
    _totalGasPrice = _gas;

    await _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() => _load = Load.loading);
    final ok = await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if (!ok) {
      _errorMessage = S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() => _load = Load.finish);
  }

  void _amountCheck({String value = ''}) {
    if (value.isEmpty) value = _valueCtrl.text;
    final int minValue = widget.coinModel.coin['decimals'] == 0 ? 1 : 0;

    if (value.isEmpty) {
      _amountError = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }
    final bool isInt = _reg.regularNums(value);
    final bool isDouble = _reg.regularDouble(value);
    if (!isInt && !isDouble) {
      _amountError = S.of(context).g_key_134;
      setState(() {});
      return;
    }
    final double dv = double.tryParse(value) ?? 0;
    if (dv <= 0 || dv < minValue) {
      _amountError = S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }

    final BigInt valueBi =
        ethToWeiString(value, widget.coinModel.coin['decimals'] as int);
    if (widget.coinModel.coin['isContract'] != true) {
      if (valueBi + _totalGasPrice > widget.coinModel.balance) {
        _amountError = S.of(context).g_key_47;
        setState(() {});
        return;
      }
    }
    _transferValue = valueBi;
    _amountError = '';
    setState(() {});
  }

  Future<String?> _toAddressCheck(String addr) async {
    addr = addr.trim();
    if (addr.isEmpty) {
      _toError = S.current.g_key_41;
      setState(() {});
      return null;
    }
    // 剥离 "chainName:address" 格式
    final parts = addr.split(':');
    if (parts.length == 2) addr = parts[1];

    final coinType = widget.coinModel.coin['coinType'] as String? ?? '';
    final bool ok = await Trustdart().validateAddress(coinType, addr);
    if (!mounted) return null;
    if (!ok) {
      _toError = S.current.g_key_t_50;
      setState(() {});
      return null;
    }
    if (addr.toUpperCase() ==
        widget.coinModel.address.toString().toUpperCase()) {
      _toError = S.current.g_key_t_50;
      setState(() {});
      return null;
    }
    _toError = '';
    setState(() {});
    return addr;
  }

  Future<void> _sendTransaction() async {
    if (_load == Load.loading) {
      ToastUtils.show('loading');
      return;
    }
    _closeKeyboard();
    _amountCheck();
    if (_amountError.isNotEmpty) return;

    setState(() => _load = Load.loading);

    final String? toAddr = await _toAddressCheck(_toCtrl.text);
    if (toAddr == null) {
      setState(() => _load = Load.finish);
      return;
    }

    final BigInt uBalance = widget.coinModel.coin['isContract'] == true
        ? (chainModel?.balance ?? BigInt.zero)
        : widget.coinModel.balance;

    if (_totalGasPrice > uBalance) {
      ToastUtils.show(S.current.g_key_47);
      setState(() => _load = Load.finish);
      return;
    }
    if (widget.coinModel.balance == BigInt.zero) {
      ToastUtils.show(S.current.g_key_47);
      setState(() => _load = Load.finish);
      return;
    }

    final trModel = TransationRecordModel()
      ..address = widget.coinModel.address.toString()
      ..from1 = widget.coinModel.address.toString()
      ..to1 = toAddr
      ..addrType = widget.coinModel.addrType
      ..coin = widget.coinModel.coin
      ..coinMiniName = widget.coinModel.coin['coinType'] as String? ?? ''
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = widget.coinModel.isTest
          ? (widget.coinModel.coin['contract_test'] as String? ?? '')
          : (widget.coinModel.coin['contract'] as String? ?? '')
      ..isTest = widget.coinModel.isTest ? 1 : 0
      ..gasPrice = _totalGasPrice
      ..gas = _gas.toInt()
      ..gasPriceValue = _gasPrice
      ..price = _transferValue
      ..message = _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim();

    final String unitLabel = chainModel != null
        ? (chainModel!.coin['unit'] as String? ?? '').toUpperCase()
        : (widget.coinModel.coin['unit'] as String? ?? '').toUpperCase();

    final bool confirmed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => WalletBaseSend(trModel, null, unitLabel),
          ),
        ) ??
        false;

    if (!mounted) return;
    if (confirmed) {
      await _signTx(trModel);
    } else {
      setState(() => _load = Load.finish);
    }
  }

  Future<void> _signTx(TransationRecordModel trModel) async {
    try {
      final MessageModel mm = await TransferApi().transferWallet(
        trModel: trModel,
        privateKey: widget.coinModel.privateKey,
        pathIndex: widget.coinModel.pathIndex,
      );
      if (!mounted) return;
      if (mm.error) {
        _errorMessage = mm.data?.toString() ?? '';
        ToastUtils.show(_errorMessage);
      } else {
        trModel.txHash = mm.data?.toString() ?? '';
        final db = AppDatabase();
        trModel.trId = await db.insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          widget.coinModel.coin['coinType'] as String? ?? '',
          _toCtrl.text.trim(),
        );
        ToastUtils.show(S.current.g_key_nft_41);
        Navigator.pop(context);
      }
    } catch (e) {
      _errorMessage = e.toString();
      // 对于该链暂不支持的情况，展示友好提示
      final friendly = _isFriendlyError(e.toString())
          ? S.current.g_key_chain_transfer_not_supported
          : e.toString();
      ToastUtils.show(friendly);
    } finally {
      _load = Load.finish;
      if (mounted) setState(() {});
    }
  }

  /// 判断是否为"链未实现"类型的错误（区别于网络错误）
  bool _isFriendlyError(String msg) {
    const keywords = ['not supported', 'not implemented', 'unsupported'];
    final lower = msg.toLowerCase();
    return keywords.any(lower.contains);
  }

  void _maxTag() {
    if (widget.coinModel.coin['isContract'] == true) {
      _valueCtrl.text = widget.coinModel.balanceStringAll();
      _transferValue = widget.coinModel.balance;
    } else {
      _transferValue = widget.coinModel.balance - _totalGasPrice;
      if (_transferValue < BigInt.zero) _transferValue = BigInt.zero;
      _valueCtrl.text = toEther(
        _transferValue.toString(),
        widget.coinModel.coin['decimals'] as int,
      ).toString();
    }
    _amountError = '';
    setState(() {});
  }

  void _closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _scanQR() => performScanQR(context,
      controller: _toCtrl, onAddress: _toAddressCheck);

  void _pasteAddress() => performPasteAddress(context,
      controller: _toCtrl, onAddress: _toAddressCheck);

  // ────────────────────────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final miniName =
        (widget.coinModel.coin['miniName'] as String? ?? '').toUpperCase();
    return Scaffold(
      appBar: AppBarWidget(
        text: '${S.of(context).g_key_37} $miniName',
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: _closeKeyboard,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: _buildForm(),
                ),
              ),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        RecentAddressBar(
          coinType: widget.coinModel.coin['coinType'] as String? ?? '',
          onSelected: (addr) {
            _toCtrl.text = addr;
            _toAddressCheck(addr);
          },
        ),
        _buildToField(),
        _buildAmountField(),
        _buildMemoField(),
        _buildFeeRow(),
        _buildErrorMessage(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildToField() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20.0)),
          textFieldStyle2(
            context,
            controller: _toCtrl,
            focusNode: _toNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(_valueNode);
              _toAddressCheck(_toCtrl.text.trim());
            },
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            errorMessage: _toError,
            bgColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
            rightWidget3: buildSendIconBtn(context, Icons.qr_code_scanner),
            rightOnTap3: _scanQR,
            rightWidget1: buildSendIconBtn(context, Icons.paste_outlined),
            rightOnTap1: _pasteAddress,
            rightWidget2: buildSendIconBtn(context, Icons.menu_book_outlined),
            rightOnTap2: _showAddressPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    final unit =
        (widget.coinModel.coin['unit'] as String? ?? '').toUpperCase();
    final balance = '${widget.coinModel.balanceStringAll()} $unit';

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                S.of(context).g_key_44,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              Expanded(
                child: Text(
                  balance,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff101828).withAlpha((0.05 * 255).round()),
                  offset: const Offset(0, 1),
                  blurRadius: ScreenUtil().setWidth(4.0),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: _valueCtrl,
                  focusNode: _valueNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(54.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.textFieldHintColor.name),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => _amountCheck(value: v),
                  onEditingComplete: () {
                    _amountCheck();
                    FocusScope.of(context).requestFocus(_toNode);
                  },
                  fontSize: ScreenUtil().setWidth(70.0),
                  height: ScreenUtil().setWidth(120.0),
                  boxShadow: BoxShadow(
                    color: const Color(0xff101828).withAlpha(0),
                    offset: Offset.zero,
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  bgColor: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                  errorMessage: _amountError,
                  messageMargin: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(30.0)),
                  rightWidget1: Container(
                    margin:
                        EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(
                          Radius.circular(ScreenUtil().setWidth(60.0))),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_197,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                  rightOnTap1: _maxTag,
                ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(20.0),
                  endIndent: ScreenUtil().setWidth(20.0),
                ),
                _buildOwnerAddress(),
                buildUsdEquivalent(
                    context, _valueCtrl.text, widget.coinModel.coinPrice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerAddress() {
    final addr =
        dataUtils.addressFarmat(widget.coinModel.address.toString());
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(30.0),
        left: ScreenUtil().setWidth(30.0),
      ),
      child: Text(
        addr,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMemoField() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_send_memo_label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20.0)),
          textFieldStyle2(
            context,
            controller: _memoCtrl,
            focusNode: _memoNode,
            hintText: S.of(context).g_key_send_memo_hint,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(FocusNode()),
            maxLines: 2,
            height: ScreenUtil().setWidth(120.0),
            bgColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow() {
    final coinType =
        widget.coinModel.coin['coinType']?.toString() ?? '';
    final isContract = widget.coinModel.coin['isContract'] == true;
    final int decimals = isContract
        ? (chainModel?.coin['decimals'] as int? ?? 0)
        : (widget.coinModel.coin['decimals'] as int? ?? 0);
    final feeText =
        '${toEther(_totalGasPrice.toString(), decimals)} $coinType';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isContract)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30.0),
              vertical: ScreenUtil().setWidth(8.0),
            ),
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
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} '
                  '${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
        NonEvmFeeCompact(
          feeText: feeText,
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isEmpty) return const SizedBox();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor2.name),
      ),
      child: Text(
        _errorMessage,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final isLoading = _load == Load.loading;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          const Divider(height: 1, indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            height: ScreenUtil().setWidth(148.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            child: buttonStyle6(
              context,
              isLoading ? () {} : () { _sendTransaction(); },
              isLoading
                  ? '${S.of(context).g_key_106}...'
                  : S.of(context).g_key_48,
              AppThemeUtils.getColorByKey(
                context,
                isLoading
                    ? AppThemeKeys.mainButtonBgColor3.name
                    : AppThemeKeys.mainButtonBgColor.name,
              ),
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonTextColor.name),
              isLoading,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressPicker() {
    showAddressPickerSheet(
      context,
      coinModel: widget.coinModel,
      onAddressSelected: (addr) {
        _toCtrl.text = addr;
        _toAddressCheck(addr);
      },
    );
  }
}
