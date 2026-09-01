import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowImage extends StatelessWidget {
  final String title;
  final dynamic img;
  final String type;
  final String watermark;
  const ShowImage(
    this.title,
    this.img, {
    this.watermark = "AstraWallet",
    this.type = "network",
    super.key,
  });

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

  Widget _buildImage() {
    if (type == "network") {
      return ExtendedImage.network(
        img,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: _gestureConfig,
      );
    } else if (type == "file") {
      return ExtendedImage.file(
        img,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: _gestureConfig,
      );
    }
    return ExtendedImage.memory(
      img,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: _gestureConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    final watermarkStyle = AppTypography.titleLg.copyWith(color: Colors.white.withAlpha(153));
    final watermarkHeight = ScreenUtil().setWidth(240);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          title,
          style: AppTypography.titleLg.copyWith(color: AppColorTokens.of(context).textPrimary),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Center(child: _buildImage())),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (_) => Container(
                    alignment: Alignment.center,
                    height: watermarkHeight,
                    color: Colors.transparent,
                    child: Text(watermark, style: watermarkStyle),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
