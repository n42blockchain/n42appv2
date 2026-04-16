import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/fiat_ramp_service.dart';
import '../../../domain/protocols/fiat_ramp_bridge.dart';

/// 法币出入金页面。
///
/// 根据 [type] 打开 MoonPay / Transak 的 WebView 完成买入/卖出流程。
class FiatRampPage extends StatefulWidget {
  const FiatRampPage({
    super.key,
    required this.walletAddress,
    required this.cryptoCurrency,
    this.type = FiatRampType.buy,
    this.fiatCurrency = 'USD',
    this.amount,
    this.provider,
  });

  final String walletAddress;
  final String cryptoCurrency;
  final FiatRampType type;
  final String fiatCurrency;
  final double? amount;
  final FiatRampProvider? provider;

  @override
  State<FiatRampPage> createState() => _FiatRampPageState();
}

class _FiatRampPageState extends State<FiatRampPage> {
  WebViewController? _webController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRampUrl();
  }

  Future<void> _loadRampUrl() async {
    if (!getIt.isRegistered<FiatRampService>()) {
      setState(() {
        _error = '法币出入金服务未配置';
        _loading = false;
      });
      return;
    }

    final service = getIt<FiatRampService>();
    FiatRampUrl? rampUrl;

    if (widget.type == FiatRampType.buy) {
      rampUrl = await service.startBuy(
        walletAddress: widget.walletAddress,
        cryptoCurrency: widget.cryptoCurrency,
        fiatCurrency: widget.fiatCurrency,
        fiatAmount: widget.amount,
        provider: widget.provider,
      );
    } else {
      rampUrl = await service.startSell(
        walletAddress: widget.walletAddress,
        cryptoCurrency: widget.cryptoCurrency,
        cryptoAmount: widget.amount,
        fiatCurrency: widget.fiatCurrency,
        provider: widget.provider,
      );
    }

    if (rampUrl == null) {
      setState(() {
        _error = '无法获取支付页面，请检查网络连接';
        _loading = false;
      });
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (error) {
          if (mounted) {
            setState(() {
              _error = error.description;
              _loading = false;
            });
          }
        },
      ))
      ..loadRequest(Uri.parse(rampUrl.url));

    if (mounted) {
      setState(() {
        _webController = controller;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == FiatRampType.buy ? '购买加密货币' : '卖出加密货币';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_webController != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webController!.reload(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _loading = true;
                  });
                  _loadRampUrl();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        if (_webController != null)
          WebViewWidget(controller: _webController!),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
