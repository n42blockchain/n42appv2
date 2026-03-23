import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/pages/browser_collection_info.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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

  @override
  void initState() {
    super.initState();
    refreshCollectionList();
  }

  Future<void> refreshCollectionList() async {
    if (loading == Load.loading) return;
    loading = Load.loading;
    pageNum = 1;
    lastPage = false;
    collectionList.clear();
    await getCollectionList();
    loading = Load.finish;
    setState(() {});
  }

  Future<void> moreCollectionList() async {
    loading = Load.loading;
    pageNum++;
    await getCollectionList();
    loading = Load.finish;
    setState(() {});
  }

  Future<void> getCollectionList() async {
    List<BrowserCollectionModel> cList = await browserApi
        .selectBrowserCollection(pageNum: pageNum, pageSize: pageSize);
    if (cList.length < pageSize) {
      lastPage = true;
    }
    collectionList.addAll(cList);
  }

  Future<void> deleteCollection(int index) async {
    BrowserCollectionModel bcm = collectionList[index];
    await browserApi.deleteBrowserCollection(bcm.id!);
    collectionList.remove(bcm);
    if (!mounted) return;
    setState(() {});
    ToastUtils.show(S.of(context).g_key_address_5);
  }

  /// 导航到收藏详情页并处理返回结果
  Future<void> _navigateToInfo(BrowserCollectionModel bcm, int index) async {
    String? edit = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrowserCollectionInfo(bcm)),
    );
    if (edit != null) {
      if (edit == "delete") {
        collectionList.removeAt(index);
      }
      setState(() {});
    }
  }

  TextStyle _subtitleStyle(BuildContext context) {
    return TextStyle(
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.itemSubtitleTextColor.name,
      ),
      fontSize: ScreenUtil().setSp(26.0),
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
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      itemCount: collectionList.length + 1,
      itemBuilder: (context, int index) {
        if (index == collectionList.length) {
          return Container(
            alignment: Alignment.center,
            height: ScreenUtil().setWidth(50.0),
            child: lastPage
                ? Text(S.of(context).g_key_105, style: _subtitleStyle(context))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(20.0),
              horizontal: ScreenUtil().setWidth(30.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(20.0)),
              ),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemBgColor.name,
              ),
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
                          vertical: ScreenUtil().setWidth(6.0),
                        ),
                        child: Text(
                          bcm.name ?? "",
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(28.0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(6.0),
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
                            vertical: ScreenUtil().setWidth(6.0),
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
                    SizedBox(height: ScreenUtil().setWidth(10.0)),
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
