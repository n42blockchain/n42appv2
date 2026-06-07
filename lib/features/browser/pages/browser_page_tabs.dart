part of 'browser_page.dart';

/// Tab grid view builders for BrowserPage.
extension _BrowserPageTabs on _BrowserPageState {
  Widget _buildTabGridView(BrowserProvider bValue) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
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
      onDismissed: (_) {
        bValue.wListDelete(index);
      },
      background: Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.close,
          color: AppColorTokens.of(context).textSubtitle,
          size: ScreenUtil().setWidth(50),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          bValue.wListShow(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: AppRadius.brLg,
            border: Border.all(
              width: isActive
                  ? ScreenUtil().setWidth(3.0)
                  : ScreenUtil().setWidth(1.5),
              color: AppThemeUtils.getColorByKey(
                context,
                isActive
                    ? AppThemeKeys.mainBlueColor.name
                    : AppThemeKeys.itemLineColor.name,
              ),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(child: _buildTabPreview(bValue, index)),
              Positioned.fill(
                child: Container(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.transparentBgColor.name,
                  ),
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
    final info = bValue.wInfoList[index];
    final openUrl = info['openUrl'] as String? ?? '';
    final title = info['title'] as String? ?? '';
    final host = Uri.tryParse(openUrl)?.host ?? '';
    final progress = (info['progress'] as num?)?.toDouble() ?? 0;
    final isLoading = info['load'] == true;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final accentColor = AppColorTokens.of(context).brand;

    return Container(
      color: AppColorTokens.of(context).bgSurface,
      padding: EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.space12),
          Container(
            height: ScreenUtil().setWidth(90),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brMd,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentColor.withAlpha(28), accentColor.withAlpha(10)],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.language,
              size: ScreenUtil().setWidth(40),
              color: accentColor,
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            title.isNotEmpty ? title : host,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColorTokens.of(context).textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            openUrl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionSm.copyWith(color: subtitleColor),
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
        color: AppColorTokens.of(context).bgBase,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.space2,
          horizontal: AppSpacing.space4,
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(32),
              height: ScreenUtil().setWidth(32),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColorTokens.of(context).brand
                    : AppColorTokens.of(context).textSubtitle,
                borderRadius: AppRadius.brSm,
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: AppTypography.captionSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.isNotEmpty ? title : host,
                    style: AppTypography.captionSm.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (title.isNotEmpty && host.isNotEmpty)
                    Text(
                      host,
                      style: AppTypography.captionSm.copyWith(
                        color: AppColorTokens.of(context).textSubtitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                bValue.wListDelete(index);
              },
              child: Container(
                width: ScreenUtil().setWidth(36.0),
                height: ScreenUtil().setWidth(36.0),
                padding: EdgeInsets.all(AppSpacing.space2),
                child: Image.asset(
                  "assets/browser/close.png",
                  color: AppColorTokens.of(context).textPrimary,
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
