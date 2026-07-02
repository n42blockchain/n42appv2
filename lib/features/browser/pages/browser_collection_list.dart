import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/pages/browser_collection_info.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrowserCollectionList extends StatefulWidget {
  final int type; //0点击列表项，立刻返回上一页，并带回地址；1点击列表项，跳转收藏详情页
  const BrowserCollectionList({this.type = 0, super.key});

  @override
  State<BrowserCollectionList> createState() => _BrowserCollectionListState();
}

class _BrowserCollectionListState extends State<BrowserCollectionList> {
  late final BrowserApi browserApi = BrowserApi();

  List<BrowserCollectionModel> collectionList = [];
  int pageSize = 20;
  int pageNum = 1;
  bool lastPage = false;
  Load loading = Load.finish;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    refreshCollectionList();
  }

  Future<void> refreshCollectionList() async {
    await _loadCollectionPage(pageToLoad: 1, replace: true);
  }

  Future<void> moreCollectionList() async {
    await _loadCollectionPage(pageToLoad: pageNum + 1, replace: false);
  }

  Future<void> _loadCollectionPage({
    required int pageToLoad,
    required bool replace,
  }) async {
    if (loading == Load.loading || (!replace && lastPage)) return;
    final requestId = ++_requestId;
    loading = Load.loading;
    if (mounted) {
      setState(() {});
    }

    try {
      final cList = await browserApi.selectBrowserCollection(
        pageNum: pageToLoad,
        pageSize: pageSize,
      );
      if (requestId != _requestId) return;
      if (!mounted) return;
      if (replace) {
        collectionList.clear();
        lastPage = false;
      }
      pageNum = pageToLoad;
      lastPage = cList.length < pageSize;
      collectionList.addAll(cList);
    } catch (e) {
      AppLogger.w('BrowserCollection', 'load failed: $e');
    } finally {
      if (mounted) {
        loading = Load.finish;
        setState(() {});
      }
    }
  }

  Future<void> deleteCollection(int index) async {
    if (index < 0 || index >= collectionList.length) return;
    _requestId++;
    BrowserCollectionModel bcm = collectionList[index];
    await browserApi.deleteBrowserCollection(bcm.id!);
    if (!mounted) return;
    collectionList.removeWhere((element) => element.id == bcm.id);
    setState(() {});
    ToastUtils.show(S.of(context).g_key_address_5);
  }

  /// 导航到收藏详情页并处理返回结果
  Future<void> _navigateToInfo(BrowserCollectionModel bcm, int index) async {
    String? edit = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrowserCollectionInfo(bcm)),
    );
    if (!mounted) return;
    if (edit != null) {
      _requestId++;
      if (edit == "delete") {
        collectionList.removeWhere((element) => element.id == bcm.id);
      }
      setState(() {});
    }
  }

  TextStyle _subtitleStyle(BuildContext context) {
    return AppTypography.bodySm.copyWith(
      color: AppColorTokens.of(context).textSubtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_browser_key3),
      body: RefreshIndicator(
        onRefresh: refreshCollectionList,
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainButtonBgColor.name,
        ),
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainButtonTextColor.name,
        ),
        displacement: ScreenUtil().setWidth(72.0),
        child: collectionList.isEmpty ? noDataWidget() : listWidget(),
      ),
    );
  }

  Widget listWidget() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 50 &&
            !lastPage &&
            loading != Load.loading) {
          moreCollectionList();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        itemCount: collectionList.length + 1,
        itemBuilder: (context, int index) {
          if (index == collectionList.length) {
            final isLoadingMore =
                loading == Load.loading && collectionList.isNotEmpty;
            return Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(50.0),
              child: lastPage
                  ? Text(
                      S.of(context).g_key_105,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: _subtitleStyle(context),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoadingMore)
                          Container(
                            margin: EdgeInsets.only(
                              right: ScreenUtil().setWidth(10.0),
                            ),
                            height: ScreenUtil().setWidth(40.0),
                            width: ScreenUtil().setWidth(40.0),
                            child: const CircularProgressIndicator(),
                          ),
                        Text(
                          S.of(context).g_key_106,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: _subtitleStyle(context),
                        ),
                      ],
                    ),
            );
          }
          BrowserCollectionModel bcm = collectionList[index];
          return InkWell(
            onTap: () async {
              if (widget.type == 0) {
                Navigator.pop(context, bcm.url);
              } else {
                _navigateToInfo(bcm, index);
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: AppSpacing.space4),
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
                horizontal: AppSpacing.space8,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.brMd,
                color: AppColorTokens.of(context).bgSurface,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.space2,
                          ),
                          child: Text(
                            bcm.name ?? "",
                            style: AppTypography.body.copyWith(
                              color: AppColorTokens.of(context).textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.space2,
                          ),
                          child: Text(
                            bcm.url ?? "",
                            style: _subtitleStyle(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Visibility(
                          visible: (bcm.desc ?? "").isNotEmpty,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.space2,
                            ),
                            child: Text(
                              bcm.desc ?? "",
                              style: _subtitleStyle(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => deleteCollection(index),
                        child: SizedBox(
                          height: ScreenUtil().setWidth(40.0),
                          width: ScreenUtil().setWidth(40.0),
                          child: Icon(
                            Icons.delete,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainButtonBgColor.name,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.space2),
                      InkWell(
                        onTap: () => _navigateToInfo(bcm, index),
                        child: SizedBox(
                          height: ScreenUtil().setWidth(40.0),
                          width: ScreenUtil().setWidth(40.0),
                          child: Icon(
                            Icons.edit_note,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainButtonBgColor.name,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget noDataWidget() {
    return EmptyView(
      type: EmptyType.noData,
      canRefresh: true,
      onPressed: () => refreshCollectionList(),
    );
  }
}
