
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/news/api/news_api.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:n42appv2/src/widgets/base_list.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      body: Column(
        children: [
          AppHomeTopBar(
            title: S.of(context).g_home_key2,
            onLeftImageClick: () {
              Scaffold.of(this.context).openDrawer();
            },
            onLeftImageUri: "assets/img/menu.png",
          ),
          Expanded(
            flex: 1,
            child: BaseList(
              buildItem: (BuildContext context, List<dynamic> results, int index) {
                final Map<String, dynamic> item = results[index];
                final dateStrList = (item["pubDate"] as String).split(" ");
                String dateTimeSte = '';
                if (dateStrList.length >= 5) {
                  for (int i = 1; i < 5; i++) {
                    dateTimeSte += "${dateStrList[i]} ";
                  }
                }
                return buildItem(
                  item["title"] ?? '',
                  item["description"] ?? '',
                  item["image"] ?? '',
                  dateTimeSte,
                  onTap: () async {
                    Navigator.push(context,MaterialPageRoute(
                        builder: (_) => BrowserPage( item["link"],)));
                  },
                );
              },
              getData: (int page, int pageSize) async {
                final data = await NewsApi().newsList(skip: page, limit: pageSize);
                //debugPrint("data:$data");
                if (data != null && data["code"] == 200) {
                  return data["data"];
                }
                return await Future(() => []);
              },
              firstRefresh: true,
              pageIndex: 0,
              pageSize: 20,
              mainAxisSpacing: ScreenUtil().setWidth(30.0),
            ),
          )
        ],
      ),
    );
  }
  Widget buildItem(String title, String desc, String imageUrl, String time,
      {GestureTapCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(30.0),
            horizontal: ScreenUtil().setWidth(30.0)
        ),
        margin: EdgeInsets.only(
          bottom: ScreenUtil().setWidth(30.0),
          left: ScreenUtil().setWidth(30.0),
          right: ScreenUtil().setWidth(30.0),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0))
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
                        fontWeight: FontWeight.bold),
                  ),
                  /*SizedBox(
                    height: ScreenUtil().setWidth(19),
                  ),
                  Text(
                    desc ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(25.0),
                    ),
                  ),*/
                  SizedBox(
                    height: ScreenUtil().setWidth(12.0),
                  ),
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
            SizedBox(
              width: ScreenUtil().setWidth(30.0),
            ),
            if (imageUrl.isNotEmpty)
              Container(
                height: ScreenUtil().setWidth(108.0),
                width: ScreenUtil().setWidth(160.0),
                //超出部分，可裁剪
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
                ),
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
