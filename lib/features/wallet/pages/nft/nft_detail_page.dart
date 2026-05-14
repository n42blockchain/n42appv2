// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/nft_sender.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show getPathWithIndex;
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_send_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/widgets/nft_info_board.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// NFT 详情页
///
/// 复用 [NftInfoBoard] 展示 NFT 信息及操作按钮：
/// - Send → [NftSendPage]（Solana/Ordinals 不支持，显示 toast）
/// - Receive → [WalletReceiveQr]
/// - Browser → 打开 OpenSea/marketplace 链接
/// - Burn → 确认弹窗 → 发送到 0x…dead（仅 EVM）
///
/// 特殊媒体：
/// - 若 NFT 带有 animationUrl 且为视频格式，使用 Chewie 播放器展示
class NftDetailPage extends StatefulWidget {
  final NftModel nft;
  final CoinModel coinModel;

  const NftDetailPage(this.nft, this.coinModel, {super.key});

  @override
  State<NftDetailPage> createState() => _NftDetailPageState();
}

class _NftDetailPageState extends State<NftDetailPage> {
  bool _burning = false;

  // 视频播放器（仅当 nft.hasVideo == true 时初始化）
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoError = false;

  NftModel get nft => widget.nft;
  CoinModel get coinModel => widget.coinModel;

  @override
  void initState() {
    super.initState();
    if (nft.hasVideo && nft.animationUrl != null) {
      _initVideoPlayer(nft.animationUrl!);
    }
  }

  Future<void> _initVideoPlayer(String url) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      if (!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        placeholder: _buildVideoPlaceholder(),
      );
      setState(() {});
    } catch (e) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  bool _isUnsupportedChain() {
    final warning = nft.isSolana
        ? S.of(context).g_key_nft_send_sol_unsupported
        : nft.isOrdinal
        ? S.of(context).g_key_nft_ordinals_unsupported
        : null;
    if (warning != null) ToastUtils.showWarning(warning);
    return warning != null;
  }

  // ── Send ──────────────────────────────────────────────────────────────────
  void _handleSend() {
    if (_isUnsupportedChain()) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NftSendPage(nft, coinModel)),
    );
  }

  // ── Receive ───────────────────────────────────────────────────────────────
  void _handleReceive() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WalletReceiveQr(coinModel)),
    );
  }

  // ── Browser ───────────────────────────────────────────────────────────────
  Future<void> _handleBrowser() async {
    final url = nft.openseaUrl;
    final uri = (url != null && url.isNotEmpty) ? Uri.tryParse(url) : null;

    if (uri == null) {
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
    if (_isUnsupportedChain()) return;

    // 确认弹窗
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).g_key_nft_burn_title),
        content: SingleChildScrollView(child: Text(S.of(ctx).g_key_nft_burn_confirm)),
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

    bool completedWithExit = false;
    setState(() => _burning = true);

    try {
      final coinType = coinModel.coin['coinType'] as String? ?? 'ETH';
      final addrType = coinModel.addrType;
      final baseInfo = coinModel.coin['baseInfo'] as Map<String, dynamic>?;
      final pathMap = baseInfo?['path'] as Map<String, dynamic>?;
      final basePath = pathMap?[addrType]?.toString() ?? "m/44'/60'/0'/0/0";
      final path = getPathWithIndex(basePath, coinModel.pathIndex);

      final result = await NftSender().send(
        SendParams(
          coinType: coinType,
          fromAddress: coinModel.address.toString(),
          toAddress: '0x000000000000000000000000000000000000dEaD',
          amount: 0.0,
          decimals: (coinModel.coin['decimals'] as num?)?.toInt() ?? 18,
          path: path,
          isTest: coinModel.isTest,
          contractAddress: nft.contractAddress,
          nftTokenId: nft.tokenId,
          nftStandard: nft.nftType,
          nftQuantity: nft.balance,
          chainConfig: coinModel.coin,
        ),
      );

      if (!mounted) return;

      if (!result.success) {
        ToastUtils.showWarning(result.error ?? 'Burn failed');
      } else {
        ToastUtils.showSuccess(S.of(context).g_key_nft_41);
        completedWithExit = true;
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ToastUtils.showWarning(e.toString());
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _burning = false);
      }
    }
  }

  // ── 视频 placeholder ───────────────────────────────────────────────────────
  Widget _buildVideoPlaceholder() {
    return Builder(
      builder: (ctx) => Container(
        color: AppThemeUtils.getColorByKey(
          ctx,
          AppThemeKeys.backGroundColor.name,
        ).withAlpha(200),
        child: Center(
          child: CircularProgressIndicator(
            color: AppThemeUtils.getColorByKey(
              ctx,
              AppThemeKeys.mainBlueColor.name,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildMediaWidget() {
    if (!nft.hasVideo) return null;
    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }
    if (!_videoError) return _buildVideoPlaceholder();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (nft.imageUrl != null)
          Expanded(
            child: Image.network(
              nft.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => const SizedBox(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (ctx) => Text(
              S.of(ctx).g_key_nft_no_video_support,
              style: TextStyle(
                fontSize: 12,
                color: AppThemeUtils.getColorByKey(
                  ctx,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidget = _buildMediaWidget();

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
              description: nft.description,
              floorPriceDisplay: nft.floorPriceDisplay,
              inscriptionNumber: nft.inscriptionNumber,
              collectionName: nft.collectionName,
              mediaWidget: mediaWidget,
              sendTap: _handleSend,
              receiveTap: _handleReceive,
              browserTap: _handleBrowser,
              // Ordinals 不支持 burn
              burnTap: nft.isOrdinal ? null : _handleBurn,
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
