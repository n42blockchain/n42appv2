// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/aa/aa.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_send_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/deployment_status_indicator.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

part 'aa_account_detail_page_widgets.dart';

/// AA 账户详情页面
class AAAccountDetailPage extends ConsumerStatefulWidget {
  final SmartAccount account;
  final String walletAddress;

  const AAAccountDetailPage({
    super.key,
    required this.account,
    required this.walletAddress,
  });

  @override
  ConsumerState<AAAccountDetailPage> createState() =>
      _AAAccountDetailPageState();
}

class _AAAccountDetailPageState extends ConsumerState<AAAccountDetailPage>
    with _AAAccountDetailWidgetsMixin {
  bool _isDeploying = false;

  @override
  void copyAddress() {
    Clipboard.setData(ClipboardData(text: widget.account.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_119),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _checkAccountStatus() async {
    setState(() => _isDeploying = true);
    try {
      final wap = ref.read(wapBridgeProvider);
      final aaProvider = AAProvider(wap);
      final isDeployed = await aaProvider.checkAccountDeployment(
        widget.account,
      );
      if (!mounted) return;
      final msg = isDeployed
          ? S.of(context).g_key_aa_deployed
          : S.of(context).g_key_aa_deploy_auto_note;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isDeployed ? Colors.green : null,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).g_key_aa_retry)));
    } finally {
      if (mounted) setState(() => _isDeploying = false);
    }
  }

  void _showReceiveDialog() {
    final address = widget.account.address;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).g_key_aa_receive_address),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: address.isEmpty ? '0x0' : address,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 12),
              SelectableText(
                address,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).g_key_79),
          ),
        ],
      ),
    );
  }

  void _navigateToSend() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AASendPage(
          account: widget.account,
          walletAddress: widget.walletAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: widget.account.displayName),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildAccountCard(),
            SizedBox(height: ScreenUtil().setWidth(24)),
            buildQuickActions(
              onSend: widget.account.state.canExecute ? _navigateToSend : null,
              onReceive: _showReceiveDialog,
              onCheckStatus: _checkAccountStatus,
              isDeploying: _isDeploying,
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            buildDetailsSection(),
            SizedBox(height: ScreenUtil().setWidth(24)),
            buildTransactionHistory(),
          ],
        ),
      ),
    );
  }
}
