import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/services/mini_app_bridge_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/debug_log.dart';
import '../../../domain/entities/mini_app_entity.dart';
import '../../../integration/wallet_bridge.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';

/// Mini App WebView 容器页面
///
/// 加载指定 [MiniAppEntity] 的 URL，注入 N42 JS Bridge，
/// 允许 Mini App 通过 `window.n42.*` API 与钱包/聊天交互。
class MiniAppPage extends StatefulWidget {
  final MiniAppEntity app;

  /// 当前聊天室 ID（用于聊天 bridge）
  final String roomId;

  /// 可选的初始深链接 URL。若为空则回退到 app manifest URL。
  final String? initialUrl;

  const MiniAppPage({
    super.key,
    required this.app,
    required this.roomId,
    this.initialUrl,
  });

  @override
  State<MiniAppPage> createState() => _MiniAppPageState();
}

class _MiniAppPageState extends State<MiniAppPage> with WidgetsBindingObserver {
  WebViewController? _webController;
  late final MiniAppBridgeService _bridge;
  bool _isLoading = true;
  String? _errorMessage;
  int _loadProgress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 通知 Mini App 即将销毁
    unawaited(
      _runJavaScriptSafely(
        'if(window.n42&&window.n42.lifecycle.onDestroy)window.n42.lifecycle.onDestroy();',
      ),
    );
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        unawaited(
          _runJavaScriptSafely(
            'if(window.n42&&window.n42.lifecycle.onPause)window.n42.lifecycle.onPause();',
          ),
        );
      case AppLifecycleState.resumed:
        unawaited(
          _runJavaScriptSafely(
            'if(window.n42&&window.n42.lifecycle.onResume)window.n42.lifecycle.onResume();',
          ),
        );
      default:
        break;
    }
  }

  void _initWebView() {
    final initialUri = _resolveInitialUri();
    if (initialUri == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid mini app URL';
      });
      return;
    }

    _bridge = MiniAppBridgeService(
      walletBridge: getIt<IWalletBridge>(),
      roomId: widget.roomId,
      app: widget.app,
      onSendMessage: _onBridgeSendMessage,
      onClose: () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );

    final controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (_) async {
            final currentUrl = await controller.currentUrl();
            if (!isTrustedMiniAppNavigationUrl(
              appUrl: widget.app.url,
              candidateUrl: currentUrl,
            )) {
              debugLog(
                'MiniAppPage: blocked bridge injection for untrusted URL: $currentUrl',
              );
              if (!mounted) return;
              setState(() {
                _isLoading = false;
                _errorMessage = 'Blocked untrusted mini app origin';
              });
              return;
            }

            await _runJavaScriptSafely(_bridge.initScript);
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadProgress = 100;
              });
            }
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _loadProgress = progress);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = error.description;
              });
            }
          },
          onNavigationRequest: (request) {
            if (isTrustedMiniAppNavigationUrl(
              appUrl: widget.app.url,
              candidateUrl: request.url,
            )) {
              return NavigationDecision.navigate;
            }

            debugLog(
              'MiniAppPage: blocked navigation outside trusted origin: ${request.url}',
            );
            return NavigationDecision.prevent;
          },
        ),
      );
    _webController = controller;

    // 注册 JS Channel（必须在 loadRequest 之前）
    _bridge.registerChannels(controller, context);

    // 加载 Mini App URL
    unawaited(_loadInitialUrl(initialUri));
  }

  Uri? _resolveInitialUri() {
    final launchUrl = widget.initialUrl ?? widget.app.url;
    final initialUri = normalizeTrustedMiniAppUri(launchUrl);
    if (initialUri == null) {
      return null;
    }
    if (!isTrustedMiniAppNavigationUrl(
      appUrl: widget.app.url,
      candidateUrl: initialUri.toString(),
    )) {
      return null;
    }
    return initialUri;
  }

  void _onBridgeSendMessage(String text) {
    // 通过 ChatBloc 发送消息到当前聊天室
    try {
      context.read<ChatBloc>().add(SendTextMessage(text));
    } catch (_) {
      // ChatBloc 可能不在 context 中（独立打开时）
    }
  }

  Future<void> _runJavaScriptSafely(String script) async {
    final controller = _webController;
    if (controller == null) return;
    try {
      await controller.runJavaScript(script);
    } catch (_) {
      // 页面销毁或 WebView 尚未就绪时，生命周期通知允许静默失败。
    }
  }

  Future<void> _loadInitialUrl(Uri initialUri) async {
    final controller = _webController;
    if (controller == null) return;

    try {
      await controller.loadRequest(initialUri);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load mini app: $e';
      });
    }
  }

  void _retryLoad() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadProgress = 0;
    });

    final controller = _webController;
    if (controller != null) {
      controller.reload();
      return;
    }

    _initWebView();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // 应用图标
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.apps, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.app.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.app.developer ?? 'N42',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _retryLoad,
          ),
        ],
        bottom: _loadProgress < 100 && _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _loadProgress / 100,
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
      body: _buildBody(l10n, isDark),
    );
  }

  Widget _buildBody(S? l10n, bool isDark) {
    if (_errorMessage != null) {
      return _buildError(l10n, isDark);
    }

    final controller = _webController;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildError(S? l10n, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.commonLoadFailed ?? 'Failed to load',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _retryLoad,
              icon: const Icon(Icons.refresh),
              label: Text(l10n?.commonRetry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
