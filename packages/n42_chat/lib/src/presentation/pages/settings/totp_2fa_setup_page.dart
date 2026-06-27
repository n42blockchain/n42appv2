import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/totp_2fa_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/totp.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../widgets/common/common_widgets.dart';

/// App 级 TOTP 二步验证设置页
///
/// 启用：生成 Base32 密钥 → 用认证器 App 扫码/手输 → 回填一次验证码确认 → 存密钥。
/// 关闭：删除密钥。验证码现算（[Totp]），不落盘。
class Totp2faSetupPage extends StatefulWidget {
  const Totp2faSetupPage({super.key});

  @override
  State<Totp2faSetupPage> createState() => _Totp2faSetupPageState();
}

class _Totp2faSetupPageState extends State<Totp2faSetupPage> {
  final Totp2faStore _store = Totp2faStore();
  final TextEditingController _codeController = TextEditingController();

  bool _loading = true;
  bool _enabled = false;
  String _secret = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final enabled = await _store.isEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      if (!enabled) _secret = Totp.randomSecret();
      _loading = false;
    });
  }

  String get _accountName {
    if (getIt.isRegistered<MatrixClientManager>()) {
      final id = getIt<MatrixClientManager>().client?.userID;
      if (id != null && id.isNotEmpty) return id;
    }
    return 'account';
  }

  int get _nowSeconds => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> _enable() async {
    final code = _codeController.text.trim();
    if (!Totp.verify(_secret, code, unixSeconds: _nowSeconds)) {
      setState(() => _error = 'Incorrect code, try again');
      return;
    }
    await _store.enable(_secret);
    if (!mounted) return;
    setState(() {
      _enabled = true;
      _error = null;
      _codeController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication enabled')),
    );
  }

  Future<void> _disable() async {
    await _store.disable();
    if (!mounted) return;
    setState(() {
      _enabled = false;
      _secret = Totp.randomSecret();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication disabled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: 'Two-Factor (TOTP)',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _enabled
              ? _buildEnabled()
              : _buildSetup(),
    );
  }

  Widget _buildEnabled() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user,
                size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            Text(
              'Two-factor authentication is on',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A code from your authenticator app is required.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 32),
            N42Button(
              text: 'Turn off',
              type: N42ButtonType.secondary,
              onPressed: _disable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetup() {
    final uri = Totp.provisioningUri(
      secret: _secret,
      accountName: _accountName,
      issuer: 'N42 Chat',
    );
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '1. Scan this QR with an authenticator app (Google Authenticator, '
          'Authy, 1Password…), or enter the key manually.',
          style: TextStyle(color: context.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: uri,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: _secret));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Key copied')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _secret,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Icon(Icons.copy, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '2. Enter the 6-digit code to confirm.',
          style: TextStyle(color: context.textSecondary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(fontSize: 22, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            border: const OutlineInputBorder(),
            errorText: _error,
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: 24),
        N42Button(text: 'Enable', onPressed: _enable),
      ],
    );
  }
}
