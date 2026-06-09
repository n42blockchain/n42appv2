# 裸语义色 → 令牌 SOP

import `package:n42_wallet/core/design_system/design_system.dart`
颜色访问：`AppColorTokens.of(context).X`

映射：
- Colors.red → danger（错误/失败/删除/到期）
- Colors.green → success（成功/有效）
- Colors.orange / Colors.amber → warning（警示/将到期）
- Colors.blue → CTA/链接用 brand，中性提示用 info
- Colors.grey / Colors.grey[n] → 禁用/占位/次要文字用 textTertiary，分隔线/描边用 border

规则：
- 保留 .withAlpha(n)/.withValues(alpha:) 链式，只换颜色基。
- SnackBar(backgroundColor:)、_showSnack(bg:)、ElevatedButton.styleFrom(backgroundColor:)、元组返回色、Icon color 同样替换。
- const Icon/Container 含被替换色 → 去掉 const。
- 只在能拿到 BuildContext 的地方用 of(context)；纯 static/无 context 工具方法的裸色跳过并记录。
- 不动 Colors.transparent / white / black。
- 只改颜色，不动业务逻辑/条件/文案。
- 文件缺 design_system import 则补；part of 文件补到父文件。

验收：改完跑 `flutter analyze <目录>`，必须 0 error，自己引入的 warning 也修。
