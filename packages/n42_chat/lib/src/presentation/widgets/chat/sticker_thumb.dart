import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../data/datasources/bundled_sticker_packs.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/sticker_pack_entity.dart';
import 'video_sticker_view.dart';

/// 贴纸缩略图（emoji / 内置 asset SVG·Lottie / 网络图片·视频）
///
/// 统一各处（贴纸面板「最近」分页、输入联想条等）的贴纸渲染逻辑，
/// 避免重复实现 asset/网络/视频分支。
class StickerThumb extends StatelessWidget {
  final Sticker sticker;

  /// emoji / 兜底文本字号
  final double emojiFontSize;

  /// 内边距
  final EdgeInsetsGeometry padding;

  const StickerThumb({
    super.key,
    required this.sticker,
    this.emojiFontSize = 28,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.placeholderOf(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding,
      child: Center(child: _content()),
    );
  }

  Widget _content() {
    if (sticker.url.startsWith('emoji:')) {
      return Text(sticker.url.substring(6),
          style: TextStyle(fontSize: emojiFontSize));
    }
    if (BundledStickerPacks.isAssetSticker(sticker.url)) {
      final path = BundledStickerPacks.assetPath(sticker.url);
      if (BundledStickerPacks.isLottie(sticker.url)) {
        return Lottie.asset(path, fit: BoxFit.contain, repeat: true);
      }
      return SvgPicture.asset(
        path,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Text(sticker.emoji ?? '🙂',
            style: TextStyle(fontSize: emojiFontSize)),
      );
    }
    final httpUrl = sticker.httpUrl ?? sticker.url;
    if (httpUrl.startsWith('http')) {
      final client = getIt.isRegistered<MatrixClientManager>()
          ? getIt<MatrixClientManager>().client
          : null;
      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        httpUrl,
        client: client,
      );
      if (VideoStickerView.isVideoSticker(
        mimeType: sticker.mimeType,
        url: httpUrl,
      )) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: VideoStickerView(url: httpUrl, headers: headers),
        );
      }
      return Image.network(
        httpUrl,
        fit: BoxFit.contain,
        headers: headers,
        errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
      );
    }
    return Text(sticker.emoji ?? '?', style: TextStyle(fontSize: emojiFontSize));
  }
}
