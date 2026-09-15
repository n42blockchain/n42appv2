import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';

part 'wallet_chain_send_algo_logic.dart';
part 'wallet_chain_send_algo_widgets.dart';

class WalletChainSendAlgo extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  final String? initialToAddress;
  const WalletChainSendAlgo(this.coinModel, {this.initialToAddress, super.key});

  @override
  ConsumerState<WalletChainSendAlgo> createState() =>
      _WalletChainSendAlgoState();
}

class _WalletChainSendAlgoState extends ConsumerState<WalletChainSendAlgo>
    with _AlgoSendLogicMixin, _AlgoSendWidgetsMixin {
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
    toNode.dispose();
    valueNode.dispose();
    super.dispose();
  }

  Widget coinTypeWidget() {
    final isAlgoCoin = widget.coinModel.config.coinType == CoinType.ALGO.name;
    return Column(
      children: [
        if (isAlgoCoin && !algoTokenAdd)
          algoAddToken()
        else ...[
          if (isAlgoCoin)
            RecentAddressBar(
              coinType: widget.coinModel.config.coinType,
              onSelected: (addr) {
                toTextEditingController.text = addr;
                toAddressCheck(addr);
              },
            ),
          toWidget(),
          amountWidget(),
        ],
        minerFeeWidget(),
        errorMessageWidget(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.all(AppSpacing.space8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.brSm,
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

  Widget sendButtonWidget() {
    final title = algoTokenAdd
        ? S.of(context).g_key_48
        : S.of(context).g_key_159;
    final isLoading = load == Load.loading;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(AppSpacing.space8),
            height: ScreenUtil().setWidth(148.0),
            color: AppColorTokens.of(context).bgBase,
            child: AppButton(
              label: title,
              onPressed: () => algoTokenAdd
                  ? sendTransaction()
                  : sendTransactionAlgoTokenEdit(true),
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
