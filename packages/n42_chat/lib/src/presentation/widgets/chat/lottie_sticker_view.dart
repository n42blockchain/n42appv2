import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

import '../../../core/services/lottie_cache_service.dart';

/// Lottie 贴纸渲染组件：优先使用内嵌 JSON，其次走本地缓存；下载完成前显示 fallback。
///
/// - [autoPlay] 选择器 tile 中为 true；消息气泡中建议 true 并 [repeatCount]=1 播放一次。
/// - [repeatCount] 0 表示无限循环，默认 1。
class LottieStickerView extends StatefulWidget {
  const LottieStickerView({
    super.key,
    required this.url,
    this.inlineJson,
    this.fallbackHttpUrl,
    this.size = 96,
    this.autoPlay = true,
    this.repeatCount = 1,
  });

  /// Lottie 资源 URL（https）。
  final String url;

  /// 直接内嵌的 Lottie JSON（可选），有值则跳过下载。
  final String? inlineJson;

  /// 弱网/错误时的静态回退缩略图 URL。
  final String? fallbackHttpUrl;

  final double size;
  final bool autoPlay;
  final int repeatCount; // 0 = 无限

  @override
  State<LottieStickerView> createState() => _LottieStickerViewState();
}

class _LottieStickerViewState extends State<LottieStickerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  LottieComposition? _composition;
  Object? _error;

  LottieCacheService? get _cache {
    if (GetIt.I.isRegistered<LottieCacheService>()) {
      return GetIt.I<LottieCacheService>();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _load();
  }

  @override
  void didUpdateWidget(covariant LottieStickerView old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url || old.inlineJson != widget.inlineJson) {
      _composition = null;
      _error = null;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final LottieComposition composition;
      final inline = widget.inlineJson;
      if (inline != null && inline.isNotEmpty) {
        final bytes = const Utf8Encoder().convert(inline);
        composition = await LottieComposition.fromBytes(
          Uint8List.fromList(bytes),
        );
      } else {
        final cache = _cache ?? LottieCacheService();
        final file = await cache.resolve(widget.url);
        final raw = await file.readAsBytes();
        composition = await LottieComposition.fromBytes(raw);
      }
      if (!mounted) return;
      setState(() {
        _composition = composition;
        _error = null;
      });
      _controller.duration = composition.duration;
      if (widget.autoPlay) {
        if (widget.repeatCount == 0) {
          _controller.repeat();
        } else {
          _controller.forward(from: 0);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    if (_composition != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Lottie(
          composition: _composition!,
          controller: _controller,
          fit: BoxFit.contain,
        ),
      );
    }
    if (_error != null) {
      return _buildFallback(size);
    }
    // Loading
    return _buildFallback(size, showProgress: true);
  }

  Widget _buildFallback(double size, {bool showProgress = false}) {
    final fallback = widget.fallbackHttpUrl;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (fallback != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                fallback,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(Icons.emoji_emotions_outlined),
              ),
            )
          else
            const Icon(Icons.emoji_emotions_outlined),
          if (showProgress)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

