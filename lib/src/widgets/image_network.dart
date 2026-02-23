import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n42_wallet/src/widgets/eso_image_cachemanager.dart';

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
      {super.key,
        this.builder,
        this.placeholder,
        required this.imageUrl,
        this.width,
        this.height,
        this.fit = BoxFit.cover});

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
    if (builder != null) {
      return builder!(
        context,
        imageUrl,
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
        //
        cacheManager: EsoImageCacheManager(),
      );
    }
  }
}
