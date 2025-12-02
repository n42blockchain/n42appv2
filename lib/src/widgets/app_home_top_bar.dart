import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

///@description: 主页面顶部统一appbar
class AppHomeTopBar extends StatefulWidget {
  final GestureTapCallback? onLeftImageClick;
  final String? onLeftImageUri;
  final bool isText;
  final String? title;
  final List<Widget>? actions;
  final Widget? titleChild;

  const AppHomeTopBar(
      {Key? key,
        this.onLeftImageClick,
        this.onLeftImageUri,
        this.isText = true,
        this.title,
        this.actions,
        this.titleChild,
      })
      : super(key: key);

  @override
  State<AppHomeTopBar> createState() => _AppHomeTopBarState();
}

class _AppHomeTopBarState extends State<AppHomeTopBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0) ,),
      height: ScreenUtil().setWidth(110.0) ,// 375 * MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Row(
                children: [
                  //左侧都显示头像
                  Consumer<PublicProvider>(builder: (
                      BuildContext context,
                      value,
                      Widget? child,
                      ) {
                    Widget child;
                    if(widget.onLeftImageUri ==null){
                      child=GestureDetector(
                        onTap: widget.onLeftImageClick,
                        child: Container(
                          width: ScreenUtil().setWidth(64.0) ,// 375 * MediaQuery.of(context).size.width,
                          height: ScreenUtil().setWidth(64.0) ,// 375 * MediaQuery.of(context).size.width,
                          //超出部分，可裁剪
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(32.0) ,// 375 * MediaQuery.of(context).size.width),
                            ),
                          ),
                          child: ImageNetWork(
                            imageUrl: value.userInfo?.image ?? '',
                            placeholder: "assets/img/person_def_1.png",
                          ),
                        ),
                      );
                    }else{
                      child=GestureDetector(
                        onTap: widget.onLeftImageClick,
                        child: Container(
                          margin: EdgeInsets.all(ScreenUtil().setWidth(12)),
                          width: ScreenUtil().setWidth(40.0) ,
                          height: ScreenUtil().setWidth(40.0) ,
                          alignment: Alignment.center,
                          child: Image.asset(
                            widget.onLeftImageUri??"",
                            width: ScreenUtil().setWidth(40),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: ScreenUtil().setWidth(64.0),
                      height: ScreenUtil().setWidth(64.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: child,
                          ),
                          if (value.messageNotReadCount != 0)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: ScreenUtil().setWidth(30),
                                height: ScreenUtil().setWidth(30),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(30)),
                                  color: AppThemeUtils.getColorByKey(
                                      context,
                                      AppThemeKeys.errorTextColor.name),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${value.messageNotReadCount > 99 ? 99 : value.messageNotReadCount}",
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context,
                                        AppThemeKeys.mainWhiteColor.name),
                                    fontSize: ScreenUtil().setSp(14),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              )),
          if(widget.titleChild ==null)
            Center(
              child: widget.isText
                  ? Text(
                widget.title ?? '',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              )
                  : Image.asset(
                'assets/images/ast_nft.png',
                width: ScreenUtil().setWidth(64.0) ,// 375 * MediaQuery.of(context).size.width,
                height: ScreenUtil().setWidth(64.0) ,// 375 * MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          if(widget.titleChild !=null)
            Center(
              child: widget.titleChild,
            ),
          Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.actions != null && widget.actions!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.actions!,
                    )
                ],
              ))
        ],
      ),
    );
  }
}