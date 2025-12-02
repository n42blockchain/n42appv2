import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactImage extends StatelessWidget {
  final String? faceUrl;
  final String? placeholder;

  const ContactImage({Key? key, this.faceUrl, this.placeholder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(80),
      height: ScreenUtil().setWidth(80),
      //超出部分，可裁剪
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(100)),
          border: Border.all(
              width: 0.5,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemLineColor.name))),
      child: ImageNetWork(
        imageUrl: faceUrl ?? "",
        width: ScreenUtil().setWidth(40),
        placeholder: placeholder ?? "assets/chat/user_def_icon.png",
        fit: BoxFit.cover,
      ),
    );
  }
}
