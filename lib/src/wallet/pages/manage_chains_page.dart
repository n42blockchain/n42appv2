import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/widgets/image_network.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 链管理页面 — 支持拖拽重排链顺序 & 切换链显示/隐藏
class ManageChainsPage extends ConsumerWidget {
  const ManageChainsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wap = ref.watch(wapBridgeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).g_key_manage_chains,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ReorderableListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(12),
        ),
        itemCount: wap.coinModels.length,
        onReorder: (oldIndex, newIndex) {
          wap.reorderChain(oldIndex, newIndex);
        },
        itemBuilder: (context, i) {
          final cm = wap.coinModels[i];
          final coinType = cm.coin['coinType'] as String? ?? '';
          final name = cm.coin['name'] as String? ?? coinType;
          final icon = cm.coin['icon'] as String? ?? '';

          Widget image;
          if (coinType == 'N') {
            image = Image.asset(
              'assets/img/ast.png',
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
            );
          } else if (icon.isEmpty) {
            image = Image.asset(
              'assets/img/list_default.png',
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
            );
          } else {
            image = ImageNetWork(
              imageUrl: icon,
              placeholder: 'assets/img/list_default.png',
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
            );
          }

          return ListTile(
            key: ValueKey(coinType),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(24),
              vertical: ScreenUtil().setWidth(4),
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReorderableDragStartListener(
                  index: i,
                  child: Padding(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      size: ScreenUtil().setWidth(36),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                  child: image,
                ),
              ],
            ),
            title: Text(
              coinType,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            subtitle: Text(
              name,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
            trailing: Switch(
              value: cm.showList,
              activeThumbColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              onChanged: (_) => wap.toggleChainVisibility(cm),
            ),
          );
        },
      ),
    );
  }
}
