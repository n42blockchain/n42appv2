// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'wallet_chain_send_apt_logic.dart';
part 'wallet_chain_send_apt_widgets.dart';

class WalletChainSendApt extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendApt(this.coinModel, {super.key});

  @override
  ConsumerState<WalletChainSendApt> createState() => _WalletChainSendAptState();
}

class _WalletChainSendAptState extends ConsumerState<WalletChainSendApt>
    with _AptSendLogicMixin, _AptSendWidgetsMixin {
  @override
  void initState() {
    super.initState();
    valueTextEditingController.text = '0';
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
        minerFeeWidget(),
        errorMessageWidget(),
        const SizedBox(height: 100),
      ],
    );
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
