// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/device_scan_page.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/hardware_wallet_accounts_page.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/keystone_sign_page.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/trezor_connect_page.dart';
import 'package:n42_wallet/features/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42_wallet/features/hardware_wallet/service/keystone_service.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'hardware_wallet_page_widgets.dart';
part 'hardware_wallet_page_logic.dart';

/// 硬件钱包管理页面
///
/// 支持三种设备类型：
/// - **Ledger**（蓝牙连接）: 扫描 BLE 设备
/// - **Trezor**（USB 连接）: USB-OTG / HID 平台通道
/// - **Keystone**（气隙 QR）: 扫描设备 xpub QR 完成配对，交易用 QR 签名
class HardwareWalletPage extends StatefulWidget {
  const HardwareWalletPage({super.key});

  @override
  State<HardwareWalletPage> createState() => _HardwareWalletPageState();
}

class _HardwareWalletPageState extends State<HardwareWalletPage> {
  late HardwareWalletProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = HardwareWalletProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_audit_hardware),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _provider,
          builder: (context, _) {
            final provider = _provider;
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 连接状态卡片
                  _buildConnectionStatusCard(context, s, provider),

                  SizedBox(height: AppSpacing.space6),

                  // 已保存的设备
                  if (provider.savedDevices.isNotEmpty) ...[
                    _buildSectionTitle(context, s.g_key_hw_saved_devices),
                    SizedBox(height: AppSpacing.space4),
                    ...provider.savedDevices.map(
                      (device) =>
                          _buildSavedDeviceCard(context, s, provider, device),
                    ),
                    SizedBox(height: AppSpacing.space6),
                  ],

                  // 添加新设备按钮
                  _buildAddDeviceSection(context, s),

                  SizedBox(height: AppSpacing.space6),

                  // 支持的设备说明
                  _buildSupportedDevicesInfo(context, s),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== Helpers ====================

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTypography.body.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColorTokens.of(context).textPrimary,
      ),
    );
  }

  String _formatDate(BuildContext context, S s, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return s.g_key_hw_today;
    if (diff.inDays == 1) return s.g_key_hw_yesterday;
    if (diff.inDays < 7) return s.g_key_hw_days_ago(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}
