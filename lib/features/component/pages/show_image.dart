//查看图片
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowImage extends StatelessWidget{
  final String title;
  final dynamic img;
  final String type;//图片来源类型 network,file,memory
  final String watermark;
  const ShowImage(this.title, this.img, {this.watermark="AstraWallet",this.type="network",super.key});

  GestureConfig _gestureConfig(ExtendedImageState state) {
    return GestureConfig(
      minScale: 0.9,
      animationMinScale: 0.7,
      maxScale: 3.0,
      animationMaxScale: 3.5,
      speed: 1.0,
      inertialSpeed: 100.0,
      initialScale: 1.0,
      inPageView: false,
      initialAlignment: InitialAlignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget extendedImage;
    if(type == "network"){
      extendedImage=ExtendedImage.network(
        img,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: _gestureConfig,
      );
    }else if(type == "file"){
      extendedImage=ExtendedImage.file(
        img,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: _gestureConfig,
      );
    }else{
      extendedImage=ExtendedImage.memory(
        img,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: _gestureConfig,
      );
    }
    return Scaffold(
      backgroundColor: Color(0xff000000),
      appBar: AppBar(
        centerTitle: false,
        title: Text(title,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(40),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
                child: extendedImage
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      alignment: Alignment.center,
                      height: ScreenUtil().setWidth(240),
                      color: Colors.transparent,
                      child: Text(
                        watermark,
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.6 * 255).round()),
                          fontSize: ScreenUtil().setSp(40),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
