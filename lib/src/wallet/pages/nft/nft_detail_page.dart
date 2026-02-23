// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/nft_model.dart';
import 'package:n42appv2/src/wallet/pages/nft/nft_send_page.dart';
import 'package:n42appv2/src/wallet/pages/wallet_receive_qr.dart';
import 'package:n42appv2/src/wallet/widgets/nft_info_board.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// NFT 详情页
///
/// 复用 [NftInfoBoard] 展示 NFT 信息及操作按钮：
/// - Send → [NftSendPage]
/// - Receive → [WalletReceiveQr]
/// - Browser → 打开 OpenSea 链接
/// - Burn → 确认弹窗 → 发送到 0x…dead（仅 EVM）
class NftDetailPage extends StatefulWidget {
  final NftModel nft;
  final CoinModel coinModel;

  const NftDetailPage(this.nft, this.coinModel, {super.key});

  @override
  State<NftDetailPage> createState() => _NftDetailPageState();
}

class _NftDetailPageState extends State<NftDetailPage> {
  bool _burning = false;

  NftModel get nft => widget.nft;
  CoinModel get coinModel => widget.coinModel;

  // ── Send ──────────────────────────────────────────────────────────────────
  void _handleSend() {
    if (nft.isSolana) {
      ToastUtils.showWarning(S.of(context).g_key_nft_send_sol_unsupported);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NftSendPage(nft, coinModel),
      ),
    );
  }

  // ── Receive ───────────────────────────────────────────────────────────────
  void _handleReceive() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletReceiveQr(coinModel),
      ),
    );
  }

  // ── Browser ───────────────────────────────────────────────────────────────
  Future<void> _handleBrowser() async {
    final url = nft.openseaUrl;
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ToastUtils.showWarning(S.of(context).g_key_nft_no_url);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ToastUtils.showWarning(S.of(context).g_key_nft_no_url);
      return;
    }
    final canLaunch = await canLaunchUrl(uri);
    if (!mounted) return;
    if (!canLaunch) {
      ToastUtils.showWarning(S.of(context).g_key_nft_no_url);
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Burn ──────────────────────────────────────────────────────────────────
  Future<void> _handleBurn() async {
    if (nft.isSolana) {
      ToastUtils.showWarning(S.of(context).g_key_nft_burn_sol_unsupported);
      return;
    }

    // 确认弹窗
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).g_key_nft_burn_title),
        content: Text(S.of(ctx).g_key_nft_burn_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).g_key_79), // Cancel
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(ctx).g_key_78, // Confirm
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _burning = true);

    try {
      final coinType = coinModel.coin['coinType'] as String? ?? 'ETH';
      final mm = await TransferApi().transferEth721(
        toAddress: '0x000000000000000000000000000000000000dEaD',
        contractAddress: nft.contractAddress,
        value: 0,
        nftNum: nft.balance,
        tokenId: nft.tokenId,
        erc721Or1155: nft.nftType,
        coinType: coinType,
        isTest: coinModel.isTest,
      );

      if (!mounted) return;

      if (mm.error == true) {
        ToastUtils.showWarning(mm.data?.toString() ?? 'Burn failed');
      } else {
        ToastUtils.showSuccess(S.of(context).g_key_nft_41); // Transaction submitted
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ToastUtils.showWarning(e.toString());
    } finally {
      if (mounted) setState(() => _burning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: nft.name),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: NftInfoBoard(
              address: coinModel.address?.toString(),
              coinType: coinModel.coin['coinType'] as String?,
              tokenName: nft.name,
              tokenId: nft.tokenId,
              contractAddress: nft.contractAddress,
              imageUrl: nft.imageUrl,
              nftType: nft.nftType,
              balance: nft.balance.toString(),
              sendTap: _handleSend,
              receiveTap: _handleReceive,
              browserTap: _handleBrowser,
              burnTap: _handleBurn,
            ),
          ),
          if (_burning)
            Container(
              color: Colors.black.withAlpha(80),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
