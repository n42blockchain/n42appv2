import 'package:n42appv2/src/browser/api/browser_api.dart';
import 'package:n42appv2/src/browser/models/browser_history_model.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrowserHistoryPage extends StatefulWidget {
  const BrowserHistoryPage({super.key});

  @override
  State<BrowserHistoryPage> createState() => _BrowserHistoryPageState();
}

class _BrowserHistoryPageState extends State<BrowserHistoryPage> {
  BrowserApi? _browserApi;
  BrowserApi get browserApi {
    _browserApi ??= BrowserApi();
    return _browserApi!;
  }

  List<BrowserHistoryModel> historyList = [];
  int pageSize = 20;
  int pageNum = 1;
  bool lastPage = false;
  Load loading = Load.finish;

  @override
  void initState() {
    super.initState();
    refreshHistoryList();
  }

  Future<void> refreshHistoryList() async {
    if (loading == Load.loading) return;
    loading = Load.loading;
    pageNum = 1;
    lastPage = false;
    historyList.clear();
    await getHistoryList();
    loading = Load.finish;
    setState(() {});
  }

  Future<void> moreHistoryList() async {
    loading = Load.loading;
    pageNum++;
    await getHistoryList();
    loading = Load.finish;
    setState(() {});
  }

  Future<void> getHistoryList() async {
    List<BrowserHistoryModel> list = await browserApi.selectBrowserHistory(
        pageNum: pageNum, pageSize: pageSize);
    if (list.length < pageSize) {
      lastPage = true;
    }
    historyList.addAll(list);
  }

  Future<void> deleteHistory(int index) async {
    BrowserHistoryModel bhm = historyList[index];
    if (bhm.id != null) {
      await browserApi.deleteBrowserHistoryById(bhm.id!);
    }
    historyList.removeAt(index);
    setState(() {});
  }

  Future<void> clearAllHistory() async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.g_browser_key19),
        content: Text(s.g_browser_key20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.g_key_79),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.g_key_78),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await browserApi.clearBrowserHistory();
      historyList.clear();
      setState(() {});
      if (!mounted) return;
      ToastUtils.show(s.g_browser_key21);
    }
  }

  /// Group label for a history entry based on its timestamp
  String _dateLabel(BrowserHistoryModel item) {
    final s = S.of(context);
    if (item.time == null) return '';
    final ts = int.tryParse(item.time!);
    if (ts == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDay = DateTime(date.year, date.month, date.day);
    if (itemDay == today) return s.g_browser_key22;
    if (itemDay == yesterday) return s.g_browser_key23;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _timeLabel(BrowserHistoryModel item) {
    if (item.time == null) return '';
    final ts = int.tryParse(item.time!);
    if (ts == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(
        text: s.g_browser_key18,
        actions: [
          if (historyList.isNotEmpty)
            IconButton(
              onPressed: clearAllHistory,
              icon: Icon(
                Icons.delete_sweep,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await refreshHistoryList();
        },
        backgroundColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonBgColor.name),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonTextColor.name),
        displacement: ScreenUtil().setWidth(72.0),
        child: historyList.isEmpty ? noDataWidget() : listWidget(),
      ),
    );
  }

  Widget listWidget() {
    final s = S.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 50 &&
            !lastPage &&
            loading != Load.loading) {
          moreHistoryList();
        }
        return false;
      },
      child: ListView.builder(
        padding:
            EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        itemCount: historyList.length + 1,
        itemBuilder: (context, int index) {
          if (index == historyList.length) {
            Widget child;
            if (lastPage) {
              child = Text(
                s.g_key_105,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(26.0),
                ),
              );
            } else {
              child = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        right: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(40.0),
                    width: ScreenUtil().setWidth(40.0),
                    child: const CircularProgressIndicator(),
                  ),
                  Text(
                    s.g_key_106,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                  ),
                ],
              );
            }
            return Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(50.0),
              child: child,
            );
          }

          final item = historyList[index];
          // Show date group header if first item or date changed
          final showHeader = index == 0 ||
              _dateLabel(item) != _dateLabel(historyList[index - 1]);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: EdgeInsets.only(
                    top: ScreenUtil().setWidth(20.0),
                    bottom: ScreenUtil().setWidth(10.0),
                  ),
                  child: Text(
                    _dateLabel(item),
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Dismissible(
                key: Key('history_${item.id ?? index}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding:
                      EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  deleteHistory(index);
                },
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, item.url);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(6.0)),
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(16.0),
                        horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(ScreenUtil().setWidth(16.0))),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (item.title != null && item.title!.isNotEmpty)
                                    ? item.title!
                                    : (item.url ?? ''),
                                style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(context,
                                      AppThemeKeys.mainTextColor.name),
                                  fontSize: ScreenUtil().setSp(28.0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                  height: ScreenUtil().setWidth(6.0)),
                              Text(
                                item.url ?? '',
                                style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context,
                                      AppThemeKeys
                                          .itemSubtitleTextColor.name),
                                  fontSize: ScreenUtil().setSp(24.0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(10.0)),
                        Text(
                          _timeLabel(item),
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(24.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget noDataWidget() {
    return EmptyView(
      type: EmptyType.noData,
      canRefresh: true,
      onPressed: () {
        refreshHistoryList();
      },
    );
  }
}
