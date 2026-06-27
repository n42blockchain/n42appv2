import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';
import '../../../core/utils/payment_request_uri.dart';
import '../../../integration/wallet_bridge.dart';
import '../../widgets/common/common_widgets.dart';

/// 商户收款二维码页
///
/// 收款方填写金额/代币/备注，生成带金额的收款二维码（[PaymentRequestUri]）。
/// 付款方扫码后即可预填转账，省去手输地址与金额（商户固定金额收款场景）。
class MerchantQrPage extends StatefulWidget {
  const MerchantQrPage({super.key});

  @override
  State<MerchantQrPage> createState() => _MerchantQrPageState();
}

class _MerchantQrPageState extends State<MerchantQrPage> {
  final GlobalKey _qrKey = GlobalKey();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  String? _walletAddress;
  List<TokenInfo> _tokens = const [];
  TokenInfo? _selectedToken;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onChanged);
    _memoController.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _load() async {
    try {
      final bridge = getIt<IWalletBridge>();
      final tokens = await bridge.getSupportedTokens();
      if (!mounted) return;
      setState(() {
        _walletAddress = bridge.walletAddress;
        _tokens = tokens;
        _selectedToken = tokens.isNotEmpty ? tokens.first : null;
        _loading = false;
      });
    } catch (e) {
      debugLog('MerchantQrPage: load failed: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String? get _qrData {
    final addr = _walletAddress;
    if (addr == null || addr.isEmpty) return null;
    return PaymentRequestUri.encode(
      PaymentRequestData(
        receiverAddress: addr,
        amount: _amountController.text.trim(),
        token: _selectedToken?.symbol ?? '',
        memo: _memoController.text.trim(),
      ),
    );
  }

  Future<void> _shareQr() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              byteData.buffer.asUint8List(),
              mimeType: 'image/png',
              name: 'payment_qr.png',
            ),
          ],
        ),
      );
    } catch (e) {
      debugLog('MerchantQrPage: share failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: 'Merchant QR',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _walletAddress == null
              ? Center(
                  child: N42EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n?.transferWalletNotConnected ??
                        'Wallet Not Connected',
                    description: l10n?.transferPleaseConnectWallet ??
                        'Please connect your wallet first',
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildQrCard(l10n),
                      const SizedBox(height: 24),
                      _buildForm(l10n),
                      const SizedBox(height: 24),
                      N42Button(
                        text: l10n?.commonShare ?? 'Share',
                        onPressed: _shareQr,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQrCard(S? l10n) {
    final data = _qrData;
    final amount = _amountController.text.trim();
    final symbol = _selectedToken?.symbol ?? '';
    return RepaintBoundary(
      key: _qrKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (data != null)
              QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                errorStateBuilder: (ctx, error) => SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      l10n?.transferQrCodeGenerateFailed ??
                          'QR code generation failed',
                    ),
                  ),
                ),
              )
            else
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            Text(
              amount.isNotEmpty
                  ? '$amount $symbol'
                  : (l10n?.transferScanQrToPayMe ?? 'Scan QR code to pay me'),
              style: TextStyle(
                fontSize: amount.isNotEmpty ? 22 : 14,
                fontWeight:
                    amount.isNotEmpty ? FontWeight.w700 : FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _shortAddress(_walletAddress!),
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(S? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<TokenInfo>(
            initialValue: _selectedToken,
            decoration: InputDecoration(
              labelText: l10n?.transferSelectToken ?? 'Select Token',
              border: const OutlineInputBorder(),
            ),
            items: _tokens
                .map((token) => DropdownMenuItem(
                      value: token,
                      child: Text('${token.symbol} - ${token.name}'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedToken = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n?.commonTransferAmount ?? 'Amount',
              hintText: 'Leave empty for open amount',
              border: const OutlineInputBorder(),
              suffixText: _selectedToken?.symbol,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _memoController,
            decoration: InputDecoration(
              labelText: l10n?.transferMemoOptional ?? 'Memo (optional)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _walletAddress!,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: context.textSecondary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _walletAddress!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.commonAddressCopied ?? 'Address copied',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortAddress(String addr) {
    if (addr.length <= 14) return addr;
    return '${addr.substring(0, 8)}...${addr.substring(addr.length - 6)}';
  }
}
