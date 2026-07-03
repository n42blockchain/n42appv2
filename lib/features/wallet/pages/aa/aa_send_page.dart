// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/aa/aa.dart' hide PaymasterType;
import 'package:n42_wallet/features/wallet/api/sender/aa_transfer_handler.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/pages/aa/paymaster_select_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/aa_transaction_preview.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/gas_sponsorship_badge.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'aa_send_page_logic.dart';
part 'aa_send_page_widgets.dart';

/// AA 转账页面
class AASendPage extends StatefulWidget {
  final SmartAccount account;
  final String walletAddress;

  const AASendPage({
    super.key,
    required this.account,
    required this.walletAddress,
  });

  @override
  State<AASendPage> createState() => _AASendPageState();
}

class _AASendPageState extends State<AASendPage>
    with _AASendLogicMixin, _AASendWidgetsMixin {
  @override
  void initState() {
    super.initState();
    loadBalance();
  }

  @override
  void dispose() {
    disposeLogic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_48),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.space6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 发送方信息
                buildFromSection(),
                SizedBox(height: AppSpacing.space6),

                // 接收方地址
                buildToSection(),
                SizedBox(height: AppSpacing.space6),

                // 金额输入
                buildAmountSection(),
                SizedBox(height: AppSpacing.space6),

                // Paymaster 选择
                buildPaymasterSection(),
                SizedBox(height: AppSpacing.space6),

                // Gas 估算
                buildGasSection(),
                SizedBox(height: AppSpacing.space8),

                // 发送按钮
                buildSendButton(),
              ],
            ),
          ),
          if (isSending)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
