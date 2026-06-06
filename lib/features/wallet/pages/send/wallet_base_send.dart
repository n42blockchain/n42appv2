import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/goplus_security_result.dart';
import 'package:n42_wallet/core/security/goplus_security_service.dart';
import 'package:n42_wallet/core/security/tx_simulation_result.dart';
import 'package:n42_wallet/core/security/tx_simulation_service.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:n42_wallet/features/widgets/contract_security_card.dart';
import 'package:n42_wallet/features/widgets/tx_simulation_card.dart';
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
    this.mainCoinUnit, {
    this.isNft = false,
    super.key,
  });

  @override
  State<WalletBaseSend> createState() => _WalletBaseSendState();
}

class _WalletBaseSendState extends State<WalletBaseSend> {
  Map<String, dynamic> coinInfo = {};
  String gasPrice = "";
  TxSimulationResult _simResult = TxSimulationResult.simulating();

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  GoplusSecurityResult? _goplResult;
  bool _goplLoading = false;

  Map<String, dynamic> securityMap = {"email": false, "face": false};
  @override
  void initState() {
    super.initState();
    coinInfo =
        widget.transationRecordModel?.coin ??
        widget.btcTransactionRecodeModel?.coin ??
        {};
    init();
    initSecurity();
    _runSimulation();
    _runGoplusCheck();
  }

  static const Map<BlockchainType, int?> _gasDecimals = {
    BlockchainType.Bitcoin: 8,
    BlockchainType.Ethereum: 18,
    BlockchainType.Solana: 9,
    BlockchainType.Tron: 6,
    BlockchainType.Ripple: 6,
    BlockchainType.Algorand: 6,
    BlockchainType.Tezos: 6,
    BlockchainType.Cosmos: 6,
    BlockchainType.Filecoin: 18,
    BlockchainType.Polkadot: null,
    BlockchainType.Aptos: null,
    BlockchainType.Sui: null,
    BlockchainType.TheOpenNetwork: null,
    BlockchainType.Stellar: 7,
    BlockchainType.VeChain: 18,
    BlockchainType.Harmony: 18,
    BlockchainType.IoTeX: 18,
    BlockchainType.Near: 24,
    BlockchainType.Zilliqa: 12,
    BlockchainType.Theta: 18,
    BlockchainType.Cardano: 6,
    BlockchainType.MultiversX: 18,
    BlockchainType.Starknet: 18,
    BlockchainType.EOSIO: null, // EOS uses resource model
    BlockchainType.Waves: 8,
    BlockchainType.Neo: 8,
    BlockchainType.Ontology: 9,
    BlockchainType.NEM: 6,
    BlockchainType.Nano: null, // Nano is feeless
    BlockchainType.Decred: 8,
    BlockchainType.ICON: 18,
    BlockchainType.IOST: 8,
    BlockchainType.Ark: 8,
    BlockchainType.Qtum: 8,
    BlockchainType.Hive: null, // Hive uses resource credits
  };

  void init() {
    final bt = BlockchainType.values.firstWhere(
      (e) => e.name == coinInfo['blockchainType'],
    );
    final int? decimals = _gasDecimals[bt];
    if (decimals == null) {
      gasPrice = '0';
      return;
    }
    final rawGas = bt == BlockchainType.Bitcoin
        ? widget.btcTransactionRecodeModel!.gasPrice.toString()
        : widget.transationRecordModel!.gasPrice.toString();
    gasPrice = '${toEther(rawGas, decimals)} ${widget.mainCoinUnit}';
  }

  Future<void> initSecurity() async {
    final s = await SPUtil().getSecurity();
    if (s == null) return;
    final userSecurityMap = s[AppGlobals.userInfo?.uuid ?? ""];
    if (!mounted) return;
    if (userSecurityMap != null) {
      setState(() => securityMap = userSecurityMap);
    }
  }

  Future<void> _runSimulation() async {
    final bt = coinInfo['blockchainType'] as String? ?? '';
    final m = widget.transationRecordModel;
    // Only EVM chains with a valid model support eth_call simulation
    if (bt != 'Ethereum' || m == null) {
      if (mounted)
        setState(() => _simResult = TxSimulationResult.unavailable());
      return;
    }

    final coinType = coinInfo['coinType'] as String? ?? '';
    final isTest = m.isTest == 1;
    final data = _buildCalldata(m);
    // Native transfer: forward value (m.price is already BigInt).
    // Token transfer: value stays null — amount is encoded in calldata.
    final BigInt? value = (m.contract.isEmpty && m.price > BigInt.zero)
        ? m.price
        : null;

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

  Future<void> _runGoplusCheck() async {
    final bt = coinInfo['blockchainType'] as String? ?? '';
    if (bt != 'Ethereum') return;

    final m = widget.transationRecordModel;
    if (m == null || m.contract.isEmpty) return;

    final coinType = coinInfo['coinType'] as String? ?? '';
    if (!GoplusSecurityService.supportsChain(coinType)) return;

    if (mounted) setState(() => _goplLoading = true);

    final result = await GoplusSecurityService.checkToken(coinType, m.contract);
    if (mounted) {
      setState(() {
        _goplResult = result;
        _goplLoading = false;
      });
    }
  }

  String _buildCalldata(TransationRecordModel m) {
    if (m.contract.isEmpty || widget.isNft) return '0x';

    final raw = m.to1.toLowerCase();
    final toAddress = (raw.startsWith('0x') ? raw.substring(2) : raw).padLeft(
      64,
      '0',
    );
    final paddedAmount = m.price.toRadixString(16).padLeft(64, '0');
    return '0xa9059cbb$toAddress$paddedAmount';
  }

  void closeKeyboard() => FocusScope.of(context).unfocus();

  Future<bool> _pageBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    } else {
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final String from;
    final String to;
    final String price;
    final unit = coinInfo['unit'] ?? '';

    if (widget.transationRecordModel case final m?) {
      from = m.from1;
      to = m.to1;
      price = widget.isNft
          ? '${int.parse(m.priceDouble().toString())}'
          : '${m.priceDouble()} $unit';
    } else if (widget.btcTransactionRecodeModel case final btc?) {
      from = btc.address;
      to = btc.to1;
      price = '${btc.priceDouble()} $unit';
    } else {
      from = '';
      to = '';
      price = '';
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        appBar: AppBarWidget(text: S.of(context).s_key_3),
        body: SafeArea(
          child: GestureDetector(
            onTap: closeKeyboard,
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
                              color: _themeColor(AppThemeKeys.mainTextColor),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(16.0),
                            horizontal: ScreenUtil().setWidth(30.0),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(ScreenUtil().setWidth(20.0)),
                            ),
                            color: _themeColor(AppThemeKeys.itemBgColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAddressLabel(S.of(context).g_key_75, from),
                              _buildAddressLabel(S.of(context).g_key_38, to),
                              tapLabelWidget(S.of(context).g_key_44, price),
                              tapLabelWidget(
                                S.of(context).g_key_t_16,
                                gasPrice,
                              ),
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
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                        color: _themeColor(AppThemeKeys.backGroundColor),
                        height: ScreenUtil().setWidth(148),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                height: ScreenUtil().setWidth(88.0),
                                child: AppButton(
                                  label: S.of(context).g_key_79,
                                  variant: AppButtonVariant.secondary,
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(30.0)),
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                height: ScreenUtil().setWidth(88.0),
                                child: AppButton(
                                  label: S.of(context).g_key_t_31,
                                  onPressed: () async {
                                    final r = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            WalletSecurityVerification(),
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    if (r == true) Navigator.pop(context, true);
                                  },
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
      ),
    );
  }

  Widget _buildAddressLabel(String title, String address) {
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.symmetric(vertical: su.setWidth(16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
              fontSize: su.setSp(28.0),
            ),
          ),
          SizedBox(height: su.setWidth(10.0)),
          EnsAddressDisplay(
            address: address,
            coinType: coinInfo['coinType'] ?? 'ETH',
            style: EnsDisplayStyle.full,
            showAvatar: true,
            showCopy: true,
            fontSize: su.setSp(28.0),
          ),
        ],
      ),
    );
  }

  Widget tapLabelWidget(String title, String value, {bool copy = false}) {
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.symmetric(vertical: su.setWidth(16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
              fontSize: su.setSp(28.0),
            ),
          ),
          SizedBox(height: su.setWidth(10.0)),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: _themeColor(AppThemeKeys.mainTextColor),
                    fontSize: su.setSp(30.0),
                  ),
                ),
              ),
              if (copy)
                InkWell(
                  onTap: () {
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: value));
                    ToastUtils.showFtToast(
                      child: successViewV1(S.of(context).copy),
                      duration: 3,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: su.setWidth(20.0)),
                    width: su.setWidth(40.0),
                    height: su.setWidth(40.0),
                    child: Icon(
                      Icons.copy,
                      size: su.setWidth(40.0),
                      color: _themeColor(AppThemeKeys.mainBlueColor),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: su.setWidth(10.0)),
          Divider(height: su.setWidth(1.0), indent: 0, endIndent: 0),
        ],
      ),
    );
  }
}
