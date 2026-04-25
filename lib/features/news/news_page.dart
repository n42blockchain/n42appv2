
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/news/api/news_api.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/features/widgets/base_list.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsApi _newsApi = NewsApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHomeTopBar(
            title: S.of(context).g_home_key2,
            onLeftImageClick: () {
              Scaffold.of(context).openDrawer();
            },
            onLeftImageUri: "assets/img/menu.png",
          ),
          Expanded(
            child: BaseList(
              buildItem: (BuildContext context, List<dynamic> results, int index) {
                final Map<String, dynamic> item = results[index];
                final dateTimeSte = _parsePubDate(item["pubDate"]);
                final link = item["link"] as String? ?? '';
                return _buildItem(
                  item["title"] as String? ?? '',
                  item["image"] as String? ?? '',
                  dateTimeSte,
                  onTap: link.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrowserPage(link),
                            ),
                          );
                        }
                      : null,
                );
              },
              getData: (int page, int pageSize) async {
                final data = await _newsApi.newsList(skip: page, limit: pageSize);
                if (data["code"] == 200) {
                  return data["data"];
                }
                return [];
              },
              firstRefresh: true,
              pageIndex: 0,
              pageSize: 20,
              mainAxisSpacing: ScreenUtil().setWidth(30.0),
            ),
          ),
        ],
      ),
    );
  }

  /// 解析 pubDate 字符串，提取日期时间部分
  String _parsePubDate(dynamic pubDate) {
    if (pubDate == null || pubDate is! String) return '';
    final dateStrList = pubDate.split(" ");
    if (dateStrList.length < 5) return pubDate;
    return dateStrList.sublist(1, 5).join(" ");
  }

  Widget _buildItem(
    String title,
    String imageUrl,
    String time, {
    GestureTapCallback? onTap,
  }) {
    final gap = ScreenUtil().setWidth(30.0);
    final radius = BorderRadius.circular(ScreenUtil().setWidth(16.0));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(gap),
        margin: EdgeInsets.only(bottom: gap, left: gap, right: gap),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: radius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemTextColor.name),
                      fontSize: ScreenUtil().setSp(30.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(12.0)),
                  Text(
                    time,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(20.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: gap),
            if (imageUrl.isNotEmpty)
              Container(
                height: ScreenUtil().setWidth(108.0),
                width: ScreenUtil().setWidth(160.0),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: radius),
                child: ImageNetWork(
                  key: ValueKey(imageUrl),
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: "assets/img/default_img.png",
                ),
              ),
          ],
        ),
      ),
    );
  }
}
