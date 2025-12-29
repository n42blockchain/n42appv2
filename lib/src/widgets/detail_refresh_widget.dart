
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

typedef GetData = Future<void> Function();
class DetailRefreshWidget extends StatefulWidget {
  final EasyRefreshController? refreshController;
  final GetData callback;
  final Widget childWidget;
  const DetailRefreshWidget({this.refreshController,
    required this.callback,
    required this.childWidget,
    super.key});

  @override
  State<DetailRefreshWidget> createState() => _DetailRefreshWidgetState();
}

class _DetailRefreshWidgetState extends State<DetailRefreshWidget> {
  EasyRefreshController? _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = widget.refreshController ?? EasyRefreshController(controlFinishLoad: true,controlFinishRefresh: true);
  }

  @override
  void dispose() {
    super.dispose();
    if (_refreshController != null) {
      _refreshController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
        //firstRefresh: false,
        refreshOnStart:true,
        controller: _refreshController,
        //canRefreshAfterNoMore:true,
        //canLoadAfterNoMore:true,
        //enableControlFinishLoad: true,
        //enableControlFinishRefresh: true,
        header: MaterialHeader(
            backgroundColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor.name),
            valueColor:  AlwaysStoppedAnimation(AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonTextColor.name))),
        onRefresh: () async {
          handRefresh();
        },
        child: widget.childWidget);
  }

  void handRefresh() async {
    try {
      await widget.callback();
    } finally {
      _refreshController?.finishRefresh();
      //_refreshController?.finishRefresh(success: true, noMore: false);
      //_refreshController?.resetLoadState();
      if (mounted) setState(() {});
    }
  }
}
