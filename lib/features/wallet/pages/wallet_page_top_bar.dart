import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// 钱包页顶部导航栏
///
/// 包含：钱包名称标题（可点击切换钱包）、二维码菜单、WalletConnect 按钮、面部识别按钮。
class WalletTopBar extends ConsumerWidget {
  const WalletTopBar({
    super.key,
    required this.walletName,
    required this.isWatchOnly,
    required this.onTitleTap,
    required this.onMenuTap,
    required this.onWalletConnectTap,
    required this.onScanTap,
    required this.onReceiveTap,
    required this.onAssistantTap,
  });

  final String walletName;
  final bool isWatchOnly;
  final VoidCallback onTitleTap;
  final VoidCallback onMenuTap;
  final VoidCallback onWalletConnectTap;
  final VoidCallback onScanTap;
  final VoidCallback onReceiveTap;
  final VoidCallback onAssistantTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppHomeTopBar(
      leftActionKey: const ValueKey<String>('wallet_open_drawer'),
      titleChild: _WalletTitleButton(
        walletName: walletName,
        isWatchOnly: isWatchOnly,
        onTap: onTitleTap,
      ),
      onLeftImageClick: onMenuTap,
      onLeftImageUri: "assets/img/menu.png",
      actions: [
        _WalletAssistantButton(onTap: onAssistantTap),
        _QrCodeMenu(onScanTap: onScanTap, onReceiveTap: onReceiveTap),
        _WalletConnectButton(onTap: onWalletConnectTap),
      ],
    );
  }
}

// ── 钱包名称标题按钮 ─────────────────────────────────────────────────────────

class _WalletTitleButton extends StatelessWidget {
  const _WalletTitleButton({
    required this.walletName,
    required this.isWatchOnly,
    required this.onTap,
  });

  final String walletName;
  final bool isWatchOnly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    final su = ScreenUtil();
    return InkWell(
      key: const ValueKey<String>('wallet_select_account'),
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: SizedBox(
        // ≥88.w（44dp 触控红线）；Row 内容居中，视觉高度不变。
        height: su.setWidth(88),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWatchOnly)
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.space2),
                child: Icon(
                  Icons.visibility_outlined,
                  color: blueColor,
                  size: su.setWidth(28),
                ),
              ),
            Flexible(
              child: Text(
                walletName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headline.copyWith(color: blueColor),
              ),
            ),
            SizedBox(
              height: su.setWidth(40),
              width: su.setWidth(40),
              child: Icon(
                Icons.arrow_drop_down,
                color: blueColor,
                size: su.setWidth(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 二维码下拉菜单 ──────────────────────────────────────────────────────────

class _QrCodeMenu extends StatelessWidget {
  const _QrCodeMenu({required this.onScanTap, required this.onReceiveTap});

  final VoidCallback onScanTap;
  final VoidCallback onReceiveTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return PopupMenuButton<int>(
      key: const ValueKey<String>('wallet_qr_menu'),
      icon: Icon(
        Icons.qr_code_rounded,
        size: su.setWidth(52.0),
        color: AppColorTokens.of(context).brand,
      ),
      offset: Offset(0, su.setWidth(80)),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      color: AppColorTokens.of(context).bgSurface,
      onSelected: (value) => switch (value) {
        0 => onScanTap(),
        1 => onReceiveTap(),
        _ => null,
      },
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          value: 0,
          icon: Icons.qr_code_scanner,
          label: S.of(context).g_key_4,
        ),
        _buildMenuItem(
          context,
          value: 1,
          icon: Icons.qr_code,
          label: S.of(context).g_key_33,
        ),
      ],
    );
  }

  PopupMenuItem<int> _buildMenuItem(
    BuildContext context, {
    required int value,
    required IconData icon,
    required String label,
  }) {
    final textColor = AppColorTokens.of(context).textPrimary;
    return PopupMenuItem<int>(
      key: ValueKey<String>('wallet_qr_menu_item_$value'),
      value: value,
      child: Row(
        children: [
          Icon(icon, size: ScreenUtil().setWidth(40), color: textColor),
          SizedBox(width: AppSpacing.space4),
          Text(label, style: AppTypography.body.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

// ── 钱包 AI 助手按钮 ────────────────────────────────────────────────────────

class _WalletAssistantButton extends StatelessWidget {
  const _WalletAssistantButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    // 触控 ≥88.w(44dp 红线):外层命中区扩大,图标视觉 44.w 不变
    // (与兄弟 _WalletConnectButton 一致,接线复审第二轮 P2)。
    return Tooltip(
      message: S.of(context).g_ui_wallet_ai,
      child: InkWell(
        key: const ValueKey<String>('wallet_assistant'),
        onTap: onTap,
        borderRadius: AppRadius.brPill,
        child: SizedBox(
          width: su.setWidth(88.0),
          height: su.setWidth(88.0),
          child: Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              size: su.setWidth(44.0),
              color: AppColorTokens.of(context).brand,
            ),
          ),
        ),
      ),
    );
  }
}

// ── WalletConnect 按钮（含会话数 badge）────────────────────────────────────

class _WalletConnectButton extends ConsumerWidget {
  const _WalletConnectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wc = ref.watch(wcpBridgeProvider);
    final sessionCount = wc.getActiveSessions().length;
    final isConnected =
        wc.walletConnectState != WalletConnectState.disconnect &&
        wc.dAppTopic != null &&
        wc.metadata != null;
    final iconUrl = wc.metadata?.icons.firstOrNull ?? "";

    // 触控 ≥88.w（44dp 红线）：外层命中区扩大，图标视觉 60.w 不变。
    return InkWell(
      key: const ValueKey<String>('wallet_connect'),
      onTap: onTap,
      borderRadius: AppRadius.brPill,
      child: SizedBox(
        width: ScreenUtil().setWidth(88.0),
        height: ScreenUtil().setWidth(88.0),
        child: Center(
          child: SizedBox(
            width: ScreenUtil().setWidth(60.0),
            height: ScreenUtil().setWidth(60.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: isConnected
                      ? ImageNetWork(
                          imageUrl: iconUrl,
                          placeholder: "assets/img/list_default.png",
                        )
                      : Image.asset(
                          "assets/wallet/WalletConnect.png",
                          color: AppColorTokens.of(context).brand,
                        ),
                ),
                if (sessionCount > 0)
                  Positioned(
                    right: -ScreenUtil().setWidth(8),
                    top: -ScreenUtil().setWidth(8),
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.space2),
                      decoration: BoxDecoration(
                        color: AppColorTokens.of(context).brand,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: ScreenUtil().setWidth(28),
                        minHeight: ScreenUtil().setWidth(28),
                      ),
                      child: Text(
                        '$sessionCount',
                        // 品牌色底上反白（叠层 on-color，§2.7 边界允许固定色）
                        style: AppTypography.captionSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
