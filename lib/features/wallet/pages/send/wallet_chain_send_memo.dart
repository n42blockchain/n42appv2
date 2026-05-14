import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';

part 'wallet_chain_send_memo_logic.dart';
part 'wallet_chain_send_memo_widgets.dart';

/// 通用 Memo 发送页，覆盖所有无专属发送页的非 EVM 链。
///
/// 支持：收款地址、金额、可选备注（Memo/Note）。
/// 实际交易由 [SenderFactory] 路由到对应链的 [ChainSender]；若链暂不支持，
/// 则捕获异常并友好提示。
class WalletChainSendMemo extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendMemo(this.coinModel, {super.key});

  @override
  ConsumerState<WalletChainSendMemo> createState() =>
      _WalletChainSendMemoState();
}

class _WalletChainSendMemoState extends ConsumerState<WalletChainSendMemo>
    with _MemoSendLogicMixin, _MemoSendWidgetsMixin {
  @override
  void initState() {
    super.initState();
    valueCtrl.text = '0';
    initData();
  }

  @override
  void dispose() {
    toCtrl.dispose();
    valueCtrl.dispose();
    memoCtrl.dispose();
    toNode.dispose();
    valueNode.dispose();
    memoNode.dispose();
    super.dispose();
  }

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
          onTap: closeKeyboard,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: buildForm(),
                ),
              ),
              buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }
}
