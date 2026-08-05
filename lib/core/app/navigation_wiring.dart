import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/shared/utils/in_app_browser.dart';

/// 宿主导航接线（composition root）。
///
/// 跨 feature 的导航抽象在此落到具体页面，使各 feature 之间
/// 不需要为了「打开某页」互相 import。在 main() 早期调用。
void registerHostNavigation() {
  InAppBrowser.registerPageBuilder((url) => BrowserPage(url));
}
