import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';

part 'wallet_chain_send_sol_logic.dart';
part 'wallet_chain_send_sol_widgets.dart';

class WalletChainSendSol extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  final String? initialToAddress;
  const WalletChainSendSol(this.coinModel, {this.initialToAddress, super.key});

  @override
  ConsumerState<WalletChainSendSol> createState() => _WalletChainSendSolState();
}

class _WalletChainSendSolState extends ConsumerState<WalletChainSendSol>
    with _SolSendLogicMixin, _SolSendWidgetsMixin {
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
    final List<Widget> cChildren = [
      RecentAddressBar(
        coinType: widget.coinModel.coin['coinType'] ?? '',
        onSelected: (addr) {
          toTextEditingController.text = addr;
          toAddressCheck(addr);
        },
      ),
      toWidget(),
      amountWidget(),
      minerFeeWidget(),
      errorMessageWidget(),
      const SizedBox(height: 100),
    ];
    return Column(children: cChildren);
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
