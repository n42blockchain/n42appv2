// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'market_page.dart';

class _NewsTab extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool loading;
  final Future<void> Function() onRefresh;

  const _NewsTab({
    required this.articles,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (articles.isEmpty) {
      return _EmptyState(
        icon: Icons.newspaper_outlined,
        message: S.of(context).g_news_empty,
        onRefresh: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (_, i) => _NewsCard(article: articles[i]),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final textColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final subColor = textColor.withAlpha(153);
    final dividerColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.dividerColor.name);

    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(article.url);
        if (uri != null &&
            (uri.isScheme('https') || uri.isScheme('http'))) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: article.imageUrl != null
                      ? ImageNetWork(
                          imageUrl: article.imageUrl!,
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 72.w,
                          height: 72.w,
                          color: dividerColor,
                          child: Icon(Icons.article_outlined,
                              color: subColor, size: 32.sp),
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              article.sourceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18.sp, color: subColor),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 6.w),
                            child: Text('·',
                                style: TextStyle(
                                    fontSize: 18.sp, color: subColor)),
                          ),
                          Text(
                            article.timeAgo(),
                            style: TextStyle(
                                fontSize: 18.sp, color: subColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios,
                    size: 16.sp, color: subColor.withAlpha(128)),
              ],
            ),
          ),
          Divider(
              height: 1,
              thickness: 0.5,
              color: dividerColor,
              indent: 16.w,
              endIndent: 0),
        ],
      ),
    );
  }
}
