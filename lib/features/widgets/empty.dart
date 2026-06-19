//@author zhc 2022/3/17 11:29 上午
//@description:Loading组件
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum EmptyType { noData, netError }

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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.canRefresh)
            IconButton(
              onPressed: widget.onPressed,
              icon: Icon(
                Icons.wifi_protected_setup_outlined,
                size: ScreenUtil().setSp(40),
                color: AppColorTokens.of(context).brand,
              ),
            ),
          SizedBox(height: AppSpacing.space6),
          // 替换资源
          Image.asset(
            widget.type == EmptyType.noData
                ? 'assets/img/noData.png' //'assets/common/message_empty.png'
                : "assets/img/network_err.png",
            width: 77,
            fit: BoxFit.cover,
            color: widget.type == EmptyType.noData
                ? null
                : AppColorTokens.of(context).textPrimary,
          ),
          SizedBox(height: AppSpacing.space8),
          Text(
            widget.title ?? S.of(context).g_key_132,
            style: AppTypography.titleLg.copyWith(color: AppColorTokens.of(context).textPrimary),
          ),
        ],
      ),
    );
  }
}
