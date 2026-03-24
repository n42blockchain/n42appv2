import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_match.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_settings_page.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_ens.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_form.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_gas.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_logic.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/utils/validation/address_validator.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_field.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_confirm_dialog.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class WalletChainSend extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  final String? initialToAddress;

  const WalletChainSend(this.coinModel, {this.initialToAddress, super.key});

  @override
  ConsumerState<WalletChainSend> createState() => _WalletChainSendState();
}

class _WalletChainSendState extends ConsumerState<WalletChainSend>
    with EnsResolveMixin, SendLogicMixin {
  @override
  CoinModel get coinModel => widget.coinModel;

  CoinModel? _chainModel;

  @override
  CoinModel? get chainModel => _chainModel;

  @override
  set chainModel(CoinModel? v) => _chainModel = v;

  @override
  late final Regular regular = Regular();

  late final DataUtils dataUtils = DataUtils();

  @override
  late final TokenViewApi tokenViewApi = TokenViewApi();

  late final AddressValidator addressValidator = AddressValidator(
    tokenViewApi: tokenViewApi,
  );

  @override
  final TextEditingController toTextEditingController = TextEditingController();
  @override
  final TextEditingController valueTextEditingController =
      TextEditingController();
  @override
  final TextEditingController noteTextEditingController =
      TextEditingController();

  final FocusNode toNode = FocusNode();
  final FocusNode valueNode = FocusNode();
  final FocusNode noteNode = FocusNode();

  @override
  void initState() {
    super.initState();
    valueTextEditingController.text = '0';
    toTextEditingController.addListener(_onAddressInputChanged);
    if (widget.initialToAddress?.isNotEmpty == true) {
      toTextEditingController.text = widget.initialToAddress!;
    }
    initData();
  }

  @override
  void dispose() {
    toTextEditingController.removeListener(_onAddressInputChanged);
    cancelEnsTimer();
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    noteTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    noteNode.dispose();
    super.dispose();
  }

  void _onAddressInputChanged() {
    onToAddressInputChanged(
      toTextEditingController.text.trim(),
      widget.coinModel.coin['coinType'] as String,
    );
  }

  @override
  Future<String?> toAddressCheck(String addr) async {
    if (addr.isEmpty) {
      toErrorMessage = S.current.g_key_41;
      setState(() {});
      return null;
    }

    final coinType = widget.coinModel.coin['coinType'] as String;
    final result = await addressValidator.validateAddress(
      coinType: coinType,
      address: addr,
      senderAddress: widget.coinModel.address.toString(),
      allowEns: isEnsSupported(coinType),
    );

    if (!result.isValid) {
      toErrorMessage = result.errorMessage ?? S.current.g_key_t_50;
      setState(() {});
      return null;
    }

    if (result.isEnsResolved && result.ensName != null) {
      if (!ensConfirmed && mounted) {
        final confirmed = await EnsConfirmDialog.show(
          context: context,
          ensName: result.ensName!,
          resolvedAddress: result.resolvedAddress ?? '',
          tokenSymbol: widget.coinModel.coin['symbol'],
        );
        if (!confirmed) {
          ensConfirmed = false;
          return null;
        }
        ensConfirmed = true;
      }
      debugPrint(
        'ENS resolved: ${result.ensName} -> '
        '${AddressValidator.getAddressPreview(result.resolvedAddress ?? "")}',
      );
    }

    toErrorMessage = '';
    setState(() {});
    return result.resolvedAddress;
  }

  @override
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _openGasSettings() async {
    if (gasEstimate == null) return;
    final result = await Navigator.push<GasEstimateModel>(
      context,
      MaterialPageRoute(
        builder: (_) => GasSettingsPage(gasEstimate: gasEstimate!),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        gasEstimate = result;
        totalGasPrice = gasEstimate!.currentTotalFee;
        gasPrice = gasEstimate!.currentOption.effectiveGasPrice;
        gas = gasEstimate!.gasLimit;
      });
    }
  }

  @override
  Widget buildWalletBaseSend(TransationRecordModel trModel, String chainUnit) =>
      WalletBaseSend(trModel, null, chainUnit);

  void scanQR() async {
    final scanValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );
    if (!mounted) return;
    if (scanValue != null) {
      toTextEditingController.text = scanValue;
      if (!EnsService.isEnsName(scanValue)) {
        setState(() {
          ensStatus = EnsResolveStatus.idle;
          ensResult = null;
        });
      }
      toAddressCheck(scanValue);
    }
  }

  void faceMatchTypeWidget() {
    sheetBottom(
      context,
      S.of(context).g_face_match_key1,
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _faceMatchOption(context, 1, S.of(context).photograph),
          _faceMatchOption(context, 2, S.of(context).g_key_nft_16),
        ],
      ),
    );
  }

  Widget _faceMatchOption(BuildContext context, int mode, String label) {
    final sw = ScreenUtil().setWidth;
    return InkWell(
      onTap: () async {
        final nav = Navigator.of(context);
        final address = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => FaceMatch(mode)),
        );
        if (!mounted) return;
        if (address != null) {
          toTextEditingController.text = address;
          toAddressCheck(address);
        }
        nav.pop();
      },
      child: SizedBox(
        height: sw(88.0),
        width: double.infinity,
        child: Text(
          label,
          style: TextStyle(
            fontSize: sw(32.0),
            color: _themeColor(AppThemeKeys.mainTextColor),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
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

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  bool get _isEvm =>
      widget.coinModel.coin['blockchainType'] == BlockchainType.Ethereum.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: '${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}',
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: closeKeyboard,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(child: _buildScrollContent()),
              ),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollContent() {
    final isContract = widget.coinModel.coin['isContract'] as bool? ?? false;
    return Column(
      children: [
        RecentAddressBar(
          coinType: widget.coinModel.coin['coinType'] ?? '',
          onSelected: (addr) {
            toTextEditingController.text = addr;
            toAddressCheck(addr);
          },
        ),
        SendToWidget(
          controller: toTextEditingController,
          focusNode: toNode,
          nextFocusNode: valueNode,
          toErrorMessage: toErrorMessage,
          ensStatus: ensStatus,
          ensResult: ensResult,
          onAddressValidate: (addr) async => toAddressCheck(addr),
          onSearchTap: searchToAddressWidget,
        ),
        SendAmountWidget(
          coinModel: widget.coinModel,
          controller: valueTextEditingController,
          focusNode: valueNode,
          nextFocusNode: toNode,
          amountErrorMessage: amountErrorMessage,
          onChanged: (v) => amountCheck(value: v),
          onEditingComplete: amountCheck,
          onMaxTap: maxTag,
        ),
        if (_isEvm && !isContract)
          SendNoteWidget(
            controller: noteTextEditingController,
            focusNode: noteNode,
            nextFocusNode: toNode,
            noteErrorMessage: noteErrorMessage,
            onChanged: (v) {
              noteErrorMessage = v.length > 100
                  ? S.of(context).nicknameMessage(100)
                  : '';
              setState(() {});
            },
          ),
        _buildMinerFee(),
        SendErrorWidget(message: errorMessage),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMinerFee() {
    if (gasEstimate != null && useAdvancedGas && _isEvm) {
      return AdvancedMinerFeeWidget(
        coinModel: widget.coinModel,
        chainModel: _chainModel,
        gasEstimate: gasEstimate!,
        totalGasPrice: totalGasPrice,
        onGasSettingsTap: _openGasSettings,
      );
    }
    return StandardMinerFeeWidget(
      coinModel: widget.coinModel,
      chainModel: _chainModel,
      gasPrice: gasPrice,
      gas: gas,
      totalGasPrice: totalGasPrice,
    );
  }

  Widget _buildSendButton() {
    final isLoading = load == Load.loading;
    final sw = ScreenUtil().setWidth;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          Divider(height: sw(1), indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(sw(30.0)),
            height: sw(148.0),
            color: _themeColor(AppThemeKeys.backGroundColor),
            child: buttonStyle6(
              context,
              sendTransaction,
              isLoading
                  ? '${S.of(context).g_key_106}...'
                  : S.of(context).g_key_48,
              _themeColor(
                isLoading
                    ? AppThemeKeys.mainButtonBgColor3
                    : AppThemeKeys.mainButtonBgColor,
              ),
              _themeColor(AppThemeKeys.mainButtonTextColor),
              isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
