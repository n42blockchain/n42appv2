import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n42appv2/src/widgets/esoImage_cachemanager.dart';
import 'package:validators/validators.dart';

///@author zhc 2022/3/30 10:57 上午
///@description: 图片加载框架
typedef CachedImageBuilder = Widget Function(
    BuildContext context,
    String url,
    Widget placeholderImage,
    );

///对图片框架cache network Image 进行封装 方便后期替换
class ImageNetWork extends StatelessWidget {
  final CachedImageBuilder? builder;
  final String? placeholder;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ImageNetWork(
      {Key? key,
        this.builder,
        this.placeholder,
        required this.imageUrl,
        this.width,
        this.height,
        this.fit = BoxFit.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      );
    }
    /// 如果是一个网络url
    String resultUrl = imageUrl;

    if (builder != null) {
      return builder!(
        context,
        resultUrl,
        placeholderImage,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context,String url){
          return placeholderImage;
        },
        errorWidget: (context,String url,dynamic error){
          return placeholderImage;
        },
        // cacheManager:
        //     resultUrl.contains("https") ? EsoImageCacheManager() : null,
        cacheManager: EsoImageCacheManager(),
      );
    }
  }
}
