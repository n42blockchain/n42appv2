import 'package:flutter/material.dart';

import '../app_color_tokens.dart';
import '../app_radius.dart';

/// 统一 BottomSheet：`bgElevated` 底 + `radiusSheet` 顶角 + 默认可滚动。
///
/// 替代各处裸 `showModalBottomSheet` 的样式重复（见 `docs/DESIGN_SYSTEM.md` §2.4）。
/// 业务内容由 [builder] 提供（内部自行加内距，建议 `AppSpacing.space8`）。
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColorTokens.of(context).bgElevated,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.brSheetTop),
    builder: builder,
  );
}
