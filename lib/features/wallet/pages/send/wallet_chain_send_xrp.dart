import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/address_book_list.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';

part 'wallet_chain_send_xrp_logic.dart';
part 'wallet_chain_send_xrp_widgets.dart';

class WalletChainSendXrp extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  final String? initialToAddress;
  const WalletChainSendXrp(this.coinModel, {this.initialToAddress, super.key});

  @override
  ConsumerState<WalletChainSendXrp> createState() => _WalletChainSendXrpState();
}

class _WalletChainSendXrpState extends ConsumerState<WalletChainSendXrp>
    with _XrpSendLogicMixin, _XrpSendWidgetsMixin {
  @override
  void initState() {
    super.initState();
    valueTextEditingController.text = "0";
    if (widget.initialToAddress?.isNotEmpty == true) {
      toTextEditingController.text = widget.initialToAddress!;
    }
    initData();
  }

  @override
  void dispose() {
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    destTagCtrl.dispose();
    toNode.dispose();
    valueNode.dispose();
    destTagNode.dispose();
    super.dispose();
  }

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space8,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorBgColor2.name,
        ),
      ),
      child: Text(
        errorMessage,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).danger,
        ),
      ),
    );
  }

  Widget coinTypeWidget() {
    return Column(
      children: [
        RecentAddressBar(
          coinType: widget.coinModel.config.coinType,
          onSelected: (addr) {
            toTextEditingController.text = addr;
            toAddressCheck(addr);
          },
        ),
        toWidget(),
        destinationTagWidget(),
        amountWidget(),
        minerFeeWidgetRippleXRP(),
        toAddressAccount(),
        errorMessageWidget(),
        const SizedBox(height: 100),
      ],
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
            color: AppColorTokens.of(context).bgBase,
            child: AppButton(
              label: S.of(context).g_key_48,
              onPressed: sendTransaction,
              loading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: "${S.of(context).g_key_37} ${widget.coinModel.config.miniName}",
        actions: [
          InkWell(
            onTap: () async {
              final value = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddressBookList(
                    coinName: widget.coinModel.config.coinType,
                  ),
                ),
              );
              if (!mounted) return;
              if (value != null) {
                toTextEditingController.text = value;
              }
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
                color: AppColorTokens.of(context).brand,
              ),
            ),
          ),
        ],
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
