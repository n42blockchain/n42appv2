part of 'browser_page.dart';

/// Tab grid view builders for BrowserPage.
extension _BrowserPageTabs on _BrowserPageState {
  Widget _buildTabGridView(BrowserProvider bValue) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(16.0),
      ),
      itemCount: bValue.wvcList.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: ScreenUtil().setWidth(30),
        mainAxisSpacing: ScreenUtil().setWidth(30),
      ),
      itemBuilder: (context, int index) {
        return _buildTabCard(bValue, index);
      },
    );
  }

  Widget _buildTabCard(BrowserProvider bValue, int index) {
    final isActive = index == bValue.wListIndex;
    final title = bValue.wInfoList[index]['title'] as String? ?? '';
    final openUrl = bValue.wInfoList[index]['openUrl'] as String? ?? '';
    final host = Uri.tryParse(openUrl)?.host ?? '';
    final letter = host.isNotEmpty
        ? host.replaceFirst('www.', '')[0].toUpperCase()
        : '?';

    return Dismissible(
      key: ValueKey('tab_${bValue.wvcList[index].hashCode}'),
      direction: DismissDirection.up,
      onDismissed: (_) { bValue.wListDelete(index); },
      background: Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.close,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
          size: ScreenUtil().setWidth(50),
        ),
      ),
      child: GestureDetector(
        onTap: () { bValue.wListShow(index); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24.0)),
            border: Border.all(
              width: isActive
                  ? ScreenUtil().setWidth(3.0)
                  : ScreenUtil().setWidth(1.5),
              color: AppThemeUtils.getColorByKey(
                  context,
                  isActive
                      ? AppThemeKeys.mainBlueColor.name
                      : AppThemeKeys.itemLineColor.name),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildTabPreview(bValue, index),
              ),
              Positioned.fill(
                child: Container(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.transparentBgColor.name),
                ),
              ),
              _buildTabCardHeader(bValue, index, isActive, title, host, letter),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPreview(BrowserProvider bValue, int index) {
    final openUrl = bValue.wInfoList[index]['openUrl'] as String? ?? '';
    final title = bValue.wInfoList[index]['title'] as String? ?? '';
    final host = Uri.tryParse(openUrl)?.host ?? '';
    final progress = (bValue.wInfoList[index]['progress'] as num?)?.toDouble() ?? 0;
    final isLoading = bValue.wInfoList[index]['load'] == true;
    final subtitleColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );
    final accentColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainBlueColor.name,
    );

    return Container(
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.itemBgColor.name,
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenUtil().setWidth(48)),
          Container(
            height: ScreenUtil().setWidth(90),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withAlpha(28),
                  accentColor.withAlpha(10),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.language,
              size: ScreenUtil().setWidth(40),
              color: accentColor,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            title.isNotEmpty ? title : host,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
              fontSize: ScreenUtil().setSp(22),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            openUrl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subtitleColor,
              fontSize: ScreenUtil().setSp(18),
            ),
          ),
          const Spacer(),
          if (isLoading)
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(999)),
              child: LinearProgressIndicator(
                minHeight: ScreenUtil().setWidth(6),
                value: progress > 0 ? progress : null,
                backgroundColor: accentColor.withAlpha(20),
                color: accentColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabCardHeader(
    BrowserProvider bValue,
    int index,
    bool isActive,
    String title,
    String host,
    String letter,
  ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(8.0),
          horizontal: ScreenUtil().setWidth(12.0),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(32),
              height: ScreenUtil().setWidth(32),
              decoration: BoxDecoration(
                color: isActive
                    ? AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name)
                    : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.isNotEmpty ? title : host,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(20.0),
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (title.isNotEmpty && host.isNotEmpty)
                    Text(
                      host,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context,
                            AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(16.0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () { bValue.wListDelete(index); },
              child: Container(
                width: ScreenUtil().setWidth(36.0),
                height: ScreenUtil().setWidth(36.0),
                padding: EdgeInsets.all(ScreenUtil().setWidth(4.0)),
                child: Image.asset(
                  "assets/browser/close.png",
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  width: ScreenUtil().setWidth(28.0),
                  height: ScreenUtil().setWidth(28.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
