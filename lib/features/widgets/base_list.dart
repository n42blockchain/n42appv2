import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

///@author zhc 2022/3/17 5:01 下午
///@description: 通用列表组件（可刷新 加载更多）

/// 列表item布局
typedef BuildItem =
    Function(BuildContext context, List<dynamic> results, int index);

/// 列表数据源
typedef GetData = Future<List<dynamic>?> Function(int page, int pageSize);

/// 封装上拉加载 下拉刷新
class BaseList extends StatefulWidget {
  final BuildItem buildItem;
  final GetData getData;
  final EasyRefreshController? refreshController;

  //请求网络开始
  final void Function()? requestBegin;

  //请求完成回调
  final void Function(bool success)? requestCompleted;

  //是否可以加载更多
  final bool canLoadMore;

  // 首次进入 是否自动调用下拉刷新
  final bool? firstRefresh;

  //默认是ListView
  final bool isGridview;

  // GridView 宽高比例
  final double childAspectRatio;

  // GridView 横轴元素个数
  final int crossAxisCount;

  //GridView mainAxisSpacing
  final double mainAxisSpacing;

  //GridView 横轴间距
  final double crossAxisSpacing;

  //数据为空时 显示的空view
  final Widget? emptyView;

  ///分页处理
  /// 可以传入起始 index 和 pageSize
  final int pageIndex;
  final int pageSize;

  const BaseList({
    super.key,
    required this.buildItem,
    required this.getData,
    this.refreshController,
    this.requestBegin,
    this.requestCompleted,
    this.canLoadMore = true,
    this.firstRefresh = false,
    this.isGridview = false,
    this.childAspectRatio = 1,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
    this.pageIndex = 1,
    this.pageSize = 10,
    this.emptyView,
  });

  @override
  State<BaseList> createState() => BaseListState();
}

class BaseListState extends State<BaseList> {
  List<dynamic> listData = [];
  bool loading = false;
  bool isFirst = true;
  bool animationFirst = true;
  EasyRefreshController? _refreshController;

  ///分页处理
  int pageIndex = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.pageIndex;
    pageSize = widget.pageSize;

    _refreshController =
        widget.refreshController ??
        EasyRefreshController(
          controlFinishRefresh: true,
          controlFinishLoad: true,
        );
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Header header = MaterialHeader(
      backgroundColor: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.refreshBGColor.name,
      ),
      valueColor: AlwaysStoppedAnimation(
        AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.refreshValueColor.name,
        ),
      ),
    );

    final Footer footer = MaterialFooter(
      backgroundColor: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.refreshBGColor.name,
      ),
      valueColor: AlwaysStoppedAnimation(
        AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.refreshValueColor.name,
        ),
      ),
    );

    return EasyRefresh(
      header: header,
      footer: footer,
      controller: _refreshController,
      refreshOnStart: widget.firstRefresh ?? true,
      onRefresh: () async {
        handlerRefresh();
      },
      onLoad: widget.canLoadMore && pageIndex != widget.pageIndex
          ? () async => loadMore()
          : null,
      child: _buildListOrGridView(),
    );
  }

  Widget _buildListOrGridView() {
    if (widget.isGridview) {
      return GridView.builder(
        itemCount: listData.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
          crossAxisCount: widget.crossAxisCount,
          //纵轴间距
          mainAxisSpacing: widget.mainAxisSpacing,
          //横轴间距
          crossAxisSpacing: widget.crossAxisSpacing,
          //子组件宽高长度比例
          childAspectRatio: widget.childAspectRatio,
        ),
        itemBuilder: (BuildContext context, int index) {
          return widget.buildItem(context, listData, index);
        },
      );
    }

    return ListView.builder(
      itemCount: listData.length,
      padding: EdgeInsets.only(bottom: widget.canLoadMore ? 0 : 30),
      itemBuilder: (BuildContext context, int index) {
        return widget.buildItem(context, listData, index);
      },
    );
  }

  int resLength = 0;

  void requestListDataAndRefresh(bool reset) async {
    loading = true;
    try {
      if (reset) {
        pageIndex = widget.pageIndex;
      }
      widget.requestBegin?.call();
      final res = await widget.getData(pageIndex, pageSize) ?? [];
      pageIndex++;
      resLength = res.length;
      if (!mounted) return;

      if (reset) {
        listData = res;
      } else {
        listData.addAll(res);
      }
      widget.requestCompleted?.call(true);
      setState(() {});
    } catch (err) {
      AppLogger.w('BaseList', 'err: $err');
      if (!mounted) return;
      if (reset) listData = [];
      widget.requestCompleted?.call(false);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          isFirst = false;
          if (_refreshController == null) return;
          if (reset) _refreshController?.finishRefresh();
          final loadResult = _isNoMore()
              ? IndicatorResult.noMore
              : IndicatorResult.success;
          _refreshController?.finishLoad(loadResult);
        });
      }
    }
  }

  bool _isNoMore() {
    return resLength < pageSize;
  }

  /// 刷新操作
  void handlerRefresh() {
    requestListDataAndRefresh(true);
  }

  /// 加载更多
  void loadMore() {
    requestListDataAndRefresh(false);
  }
}
