import 'package:decimal/decimal.dart' as dec;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart' as flustars;
import 'package:intl/intl.dart';
import 'package:validators/validators.dart';

import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/gas_tracker_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/non_evm_fee_model.dart';
import 'package:n42_wallet/features/wallet/pages/gas/non_evm_gas_settings_page.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

part 'wallet_chain_send_btc_logic.dart';
part 'wallet_chain_send_btc_tx.dart';
part 'wallet_chain_send_btc_widgets.dart';

class WalletChainSendBtc extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  final String? toAmount;
  final String? toAddress;

  const WalletChainSendBtc(
    this.coinModel, {
    this.toAddress,
    this.toAmount,
    super.key,
  });

  @override
  ConsumerState<WalletChainSendBtc> createState() => _WalletChainSendBtcState();
}

class _WalletChainSendBtcState extends ConsumerState<WalletChainSendBtc>
    with _BtcSendLogicMixin, _BtcSendTxMixin, _BtcSendWidgetsMixin {
  // All state fields are declared in _BtcSendLogicMixin.
  // All widget methods are declared in _BtcSendWidgetsMixin.

  // NumberFormat instance used for display formatting.
  final oCcy = NumberFormat('#,##0.00########', 'en_US');

  @override
  void initState() {
    super.initState();
    valueTextEditingController.text = '0';
    if (widget.toAddress != null) {
      toTextEditingController.text = widget.toAddress!;
      valueTextEditingController.text = widget.toAmount!;
      toTextFieldEnabel = false;
    }
    initData();
  }

  @override
  void dispose() {
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    byteFeeTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    byteFeeNode.dispose();
    super.dispose();
  }

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
                child: SingleChildScrollView(
                  child: Column(
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
                      buildBtcFeeCompact(),
                      totalPriceWidgegt(),
                      errorMessageWidget(),
                      SizedBox(height: ScreenUtil().setWidth(100.0)),
                    ],
                  ),
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
