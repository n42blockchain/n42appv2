import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemContact extends StatefulWidget {
  final String? faceUrl;
  final String? name;
  final String? email;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final bool showLine;

  const ItemContact(
      {Key? key,
        this.faceUrl,
        this.name,
        this.email,
        this.onTap,
        this.onLongPress,
        this.showLine = false})
      : super(key: key);

  @override
  State<ItemContact> createState() => _ItemContactState();
}

class _ItemContactState extends State<ItemContact> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setWidth(80),
                //超出部分，可裁剪
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(48)),
                    border: Border.all(
                        width: 0.5,
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemLineColor.name))),
                child: ImageNetWork(
                  imageUrl: widget.faceUrl ?? "",
                  width: ScreenUtil().setWidth(40),
                  placeholder: "assets/chat/user_def_icon.png",
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(24),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: ScreenUtil().setWidth(14),),
                    // name
                    Text(
                      widget.name ?? '',
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          // fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(32)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(12),
                    ),
                    Row(
                      children: [
                        Text(
                          'E-mail: ',
                          style:
                          TextStyle(color: Color(0xFFC1C0C9), fontSize: ScreenUtil().setSp(24)),
                        ),
                        Expanded(
                          child: Text(
                            widget.email ?? '',
                            style: TextStyle(
                                color: Color(0xFFC1C0C9), fontSize: ScreenUtil().setSp(24)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(24),
                    ),
                    if (widget.showLine)
                      Divider(
                        height: 0.5,
                        indent: 1,
                        endIndent: 1,
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemLineColor.name),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}