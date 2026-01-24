//@author zhc 2022/3/17 11:29 上午
//@description:Loading组件
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum EmptyType {
  noData,
  netError,
}

/// 暂无信息组件 no Data
/// 默认不带刷新功能 显示no data
/// type = netError时显示网路错误 可以重新点击刷新
class EmptyView extends StatefulWidget {
  final String? title;
  final bool canRefresh;
  final EmptyType? type;
  final VoidCallback? onPressed;

  const EmptyView({
    this.title,
    super.key,
    this.canRefresh = false,
    this.type = EmptyType.noData,
    this.onPressed,
  });

  @override
  State<EmptyView> createState() => _EmptyViewState();
}

class _EmptyViewState extends State<EmptyView> {
  bool? isCanRefresh;

  @override
  void initState() {
    super.initState();
    isCanRefresh = widget.canRefresh;
    // //如果时网络类型的 可以刷新
    // if(widget.type == EmptyType.netError){
    //   isCanRefresh = true;
    // }

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCanRefresh == true) //是否需要刷新
              IconButton(
                  onPressed: widget.onPressed,
                  icon:  Icon(Icons.wifi_protected_setup_outlined,
                      size: ScreenUtil().setSp(40), 
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name))),
            SizedBox(height: ScreenUtil().setWidth(24),),
            // 替换资源
            Image.asset(
              widget.type == EmptyType.noData
                  ? 'assets/img/noData.png'//'assets/common/message_empty.png'
                  : "assets/img/network_err.png",
              width: 77,
              fit: BoxFit.cover,
              color: widget.type == EmptyType.noData?null:AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
            SizedBox(height: ScreenUtil().setWidth(28),),
            Text(
              widget.title ?? S.of(context).g_key_132,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
