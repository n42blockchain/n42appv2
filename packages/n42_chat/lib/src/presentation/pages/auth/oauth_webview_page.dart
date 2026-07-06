import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/utils/debug_log.dart';

/// 通用 WebView OAuth 授权页（Discord/GitHub OAuth2 + Telegram Login Widget 共用）。
///
/// 打开 [authorizeUrl]，监听导航；一旦跳转到以 [redirectPrefix] 开头的地址，
/// 拦截该次导航、把完整回调 [Uri]（含 query 与 fragment）通过 `Navigator.pop`
/// 返回给调用方。调用方自行解析：
/// - OAuth2 Authorization Code：读 `uri.queryParameters['code']`；
/// - Telegram Login Widget：读 fragment 里的 `tgAuthResult`（base64url(JSON)）。
///
/// 用户手动返回（未完成授权）时返回 `null`。
///
/// 零新依赖——`webview_flutter` 已在 chat 依赖中。
class OAuthWebViewPage extends StatefulWidget {
  final String authorizeUrl;
  final String redirectPrefix;
  final String title;

  const OAuthWebViewPage({
    super.key,
    required this.authorizeUrl,
    required this.redirectPrefix,
    required this.title,
  });

  /// 打开授权页并等待回调 Uri（用户取消返回 null）。
  static Future<Uri?> open(
    BuildContext context, {
    required String authorizeUrl,
    required String redirectPrefix,
    required String title,
  }) {
    return Navigator.of(context).push<Uri>(
      MaterialPageRoute<Uri>(
        builder: (_) => OAuthWebViewPage(
          authorizeUrl: authorizeUrl,
          redirectPrefix: redirectPrefix,
          title: title,
        ),
      ),
    );
  }

  @override
  State<OAuthWebViewPage> createState() => _OAuthWebViewPageState();
}

class _OAuthWebViewPageState extends State<OAuthWebViewPage> {
  late final WebViewController _controller;
  bool _completed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isRedirect(request.url)) {
              _finish(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            // 部分回调经由 fragment（如 Telegram tgAuthResult）不会触发
            // onNavigationRequest，需在 URL 变化时兜底拦截。
            if (url != null && _isRedirect(url)) {
              _finish(url);
            }
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            debugLog('OAuthWebView: resource error ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizeUrl));
  }

  bool _isRedirect(String url) {
    return url.startsWith(widget.redirectPrefix);
  }

  void _finish(String url) {
    if (_completed || !mounted) return;
    _completed = true;
    Uri? parsed;
    try {
      parsed = Uri.parse(url);
    } catch (e) {
      debugLog('OAuthWebView: failed to parse redirect $e');
      parsed = null;
    }
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
