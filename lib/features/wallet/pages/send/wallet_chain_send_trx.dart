import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_match.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';

part 'wallet_chain_send_trx_logic.dart';
part 'wallet_chain_send_trx_widgets.dart';

class WalletChainSendTrx extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendTrx(this.coinModel, {super.key});

  @override
  ConsumerState<WalletChainSendTrx> createState() => _WalletChainSendTrxState();
}

class _WalletChainSendTrxState extends ConsumerState<WalletChainSendTrx>
    with _TrxSendLogicMixin, _TrxSendWidgetsMixin {
  @override
  void initState() {
    super.initState();
    valueTextEditingController.text = "0";
    initData();
  }

  @override
  void dispose() {
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    noteTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    noteNode.dispose();
    super.dispose();
  }

  Widget coinTypeWidget() {
    return Column(
      children: [
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
        const SizedBox(height: 100),
      ],
    );
  }

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    final sw = ScreenUtil().setWidth;
    return Container(
      margin: EdgeInsets.only(top: sw(20.0), left: sw(30), right: sw(30)),
      padding: EdgeInsets.symmetric(horizontal: sw(30.0), vertical: sw(30.0)),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(sw(16.0))),
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorBgColor2.name,
        ),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.errorTextColor.name,
          ),
        ),
      ),
    );
  }

  Widget sendButtonWidget() {
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
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.backGroundColor.name,
            ),
            child: buttonStyle6(
              context,
              sendTransaction,
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
                context,
                AppThemeKeys.mainButtonTextColor.name,
              ),
              isLoading,
            ),
          ),
        ],
      ),
    );
  }

  void faceMatchTypeWidget() {
    sheetBottom(
      context,
      S.of(context).g_face_match_key1,
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _faceMatchOption(1, S.of(context).photograph),
          _faceMatchOption(2, S.of(context).g_key_nft_16),
        ],
      ),
    );
  }

  Widget _faceMatchOption(int mode, String label) {
    return InkWell(
      onTap: () async {
        final address = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => FaceMatch(mode)),
        );
        if (!mounted) return;
        if (address != null) {
          toTextEditingController.text = address;
          toAddressCheck(address);
        }
        Navigator.pop(context);
      },
      child: SizedBox(
        height: ScreenUtil().setWidth(88.0),
        width: double.infinity,
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setWidth(32.0),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: "${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: closeKeyboard,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(child: coinTypeWidget()),
              ),
              sendButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
