import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n42_wallet/features/widgets/eso_image_cachemanager.dart';

///@author zhc 2022/3/30 10:57 上午
///@description: 图片加载框架
typedef CachedImageBuilder =
    Widget Function(BuildContext context, String url, Widget placeholderImage);

///对图片框架cache network Image 进行封装 方便后期替换
class ImageNetWork extends StatelessWidget {
  /// 已经失败过的 URL。errorWidget 每次触发都 removeFile 的话，永久失效的图
  /// （404、已下架的 logo）会在每次重建时重新下载，还可能并发删同一个文件。
  static final Set<String> _failedUrls = <String>{};
  static const _maxFailedUrls = 256;

  final CachedImageBuilder? builder;
  final String? placeholder;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ImageNetWork({
    super.key,
    this.builder,
    this.placeholder,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, width: width, height: height, fit: fit);
    }

    Widget placeholderImage;
    if (placeholder != null) {
      placeholderImage = Image.asset(
        placeholder!,
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    } else {
      placeholderImage = Container(
        width: width,
        height: height,
        color: AppColorTokens.of(context).bgSurface,
      );
    }
    if (builder != null) {
      return builder!(context, imageUrl, placeholderImage);
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, String url) {
          return placeholderImage;
        },
        errorWidget: (context, String url, dynamic error) {
          if (_failedUrls.add(url)) {
            if (_failedUrls.length > _maxFailedUrls) _failedUrls.clear();
            unawaited(EsoImageCacheManager().removeFile(url));
          }
          return placeholderImage;
        },
        //
        cacheManager: EsoImageCacheManager(),
      );
    }
  }
}
