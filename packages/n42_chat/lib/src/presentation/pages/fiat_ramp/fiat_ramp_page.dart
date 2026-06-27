import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/fiat_ramp_service.dart';
import '../../../core/theme/app_colors.dart';

/// 法币出入金页（MoonPay/Transak WebView）
///
/// 顶部切换 买入/卖出，下方 WebView 加载对应通道 widget。未配置 key 时显示提示。
class FiatRampPage extends StatefulWidget {
  /// 收款钱包地址（买入时传入，省去用户手填；可空）
  final String? walletAddress;

  const FiatRampPage({super.key, this.walletAddress});

  @override
  State<FiatRampPage> createState() => _FiatRampPageState();
}

class _FiatRampPageState extends State<FiatRampPage> {
  late final FiatRampService? _service =
      getIt.isRegistered<FiatRampService>() ? getIt<FiatRampService>() : null;
  WebViewController? _controller;
  bool _isBuy = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  void _loadUrl() {
    final svc = _service;
    if (svc == null || !svc.isAvailable) return;
    final url = _isBuy
        ? svc.buildBuyUrl(walletAddress: widget.walletAddress)
        : svc.buildSellUrl();
    if (url == null) return;
    setState(() => _loading = true);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final available = _service?.isAvailable ?? false;
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Buy / Sell crypto'),
        bottom: available
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Buy')),
                      ButtonSegment(value: false, label: Text('Sell')),
                    ],
                    selected: {_isBuy},
                    onSelectionChanged: (s) {
                      setState(() => _isBuy = s.first);
                      _loadUrl();
                    },
                  ),
                ),
              )
            : null,
      ),
      body: !available
          ? _buildNotConfigured()
          : Stack(
              children: [
                if (_controller != null)
                  WebViewWidget(controller: _controller!),
                if (_loading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }

  Widget _buildNotConfigured() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_outlined,
                size: 56, color: context.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Fiat on/off-ramp not configured',
              style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Host app needs to provide a MoonPay/Transak publishable key '
              'via N42ChatConfig.fiatRampApiKey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
