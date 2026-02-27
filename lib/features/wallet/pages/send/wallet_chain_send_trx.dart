import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/models/message_model.dart';
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
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
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
  ConsumerState<WalletChainSendTrx> createState() =>
      _WalletChainSendTrxState();
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
        /*
        WalletChainInfoTitle(
          title: Text(
            "${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
            ...
          ),
          ...
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
        const SizedBox(height: 100),
      ],
    );
  }

  Widget errorMessageWidget() {
    if (errorMessage == "") return const SizedBox();
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
        errorMessage,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
        ),
      ),
    );
  }

  // 提交按钮
  Widget sendButtonWidget() {
    final String title = S.of(context).g_key_48;
    final bool isLoading = load == Load.loading;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            height: ScreenUtil().setWidth(148.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            child: buttonStyle6(
              context,
              () async {
                sendTransaction();
              },
              isLoading ? '${S.of(context).g_key_106}...' : title,
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

  void faceMatchTypeWidget() {
    final Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            final String? address = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FaceMatch(1)),
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
              S.of(context).photograph,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final String? address = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FaceMatch(2)),
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
              S.of(context).g_key_nft_16,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
    sheetBottom(context, S.of(context).g_face_match_key1, child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:
            "${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
        /*actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddressBookList(
                    coinName: widget.coinModel.coin['coinType']),
              )).then((value) async {
                if (value != null) {
                  toTextEditingController.text = value;
                }
              });
            },
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(30.0),
                left: ScreenUtil().setWidth(20.0),
              ),
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
}
