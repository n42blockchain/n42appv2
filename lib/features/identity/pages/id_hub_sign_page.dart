import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/identity/api/id_hub_api.dart';
import 'package:n42_wallet/features/identity/models/id_hub_models.dart';
import 'package:n42_wallet/features/identity/services/id_hub_bind_signer.dart';
import 'package:n42_wallet/features/wallet/n42_wallet_bridge.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

enum _Stage { loading, ready, signing, success, error }

/// Confirmation + signing page for a scanned `n42id://bind|auth` QR.
///
/// Security model (mirrors [IdHubBindSigner]): the hub host is re-checked
/// against the allowlist here, and the message to sign is fetched from the hub
/// (`prepare`) - never taken from the QR. The user sees the decoded request
/// (action, address, hub domain) before the wallet signs.
class IdHubSignPage extends StatefulWidget {
  final String sessionId;
  final String hubUrl;
  final bool isLogin;

  const IdHubSignPage({
    super.key,
    required this.sessionId,
    required this.hubUrl,
    this.isLogin = false,
  });

  @override
  State<IdHubSignPage> createState() => _IdHubSignPageState();
}

class _IdHubSignPageState extends State<IdHubSignPage> {
  final _bridge = N42WalletBridge();
  IdHubApi? _api;
  IdHubChallenge? _challenge;
  String? _address;
  String _message = '';
  String _error = '';
  _Stage _stage = _Stage.loading;

  String get _hubHost => Uri.tryParse(widget.hubUrl)?.host ?? widget.hubUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Anti-phishing: refuse a hub that is not on the allowlist.
    if (!IdHubBindSigner.isHubAllowed(widget.hubUrl)) {
      _fail('This request points to an untrusted server and was blocked.');
      return;
    }
    final address = _bridge.walletAddress;
    if (address == null || address.isEmpty) {
      _fail('Unlock your wallet, then reopen this request.');
      return;
    }
    try {
      final api = IdHubApi(baseUrl: widget.hubUrl);
      final session = await api.getBindSession(widget.sessionId);
      if (session.status != 'pending') {
        _fail('This request has expired. Ask the other device to retry.');
        return;
      }
      // Fetch the exact message to sign from the hub (never from the QR).
      final challenge = await api.prepareBindSession(
        sessionId: widget.sessionId,
        address: address,
      );
      if (!mounted) return;
      setState(() {
        _api = api;
        _address = address;
        _challenge = challenge;
        _message = challenge.message;
        _stage = _Stage.ready;
      });
    } on IdHubException catch (e) {
      _fail(e.message);
    } catch (e) {
      AppLogger.w('IdHubSignPage', 'load error: $e');
      _fail('Could not load this request.');
    }
  }

  Future<void> _confirm() async {
    final api = _api;
    final challenge = _challenge;
    if (api == null || challenge == null) return;
    setState(() => _stage = _Stage.signing);
    try {
      // Runs through the wallet's existing unlock/biometric gate.
      final signature = await _bridge.signMessage(challenge.message);
      if (signature == null || signature.isEmpty) {
        setState(() => _stage = _Stage.ready);
        return;
      }
      await api.completeBindSession(
        sessionId: widget.sessionId,
        challengeId: challenge.challengeId,
        signature: signature,
      );
      if (!mounted) return;
      setState(() => _stage = _Stage.success);
    } on IdHubException catch (e) {
      _fail(e.code == 'binding-conflict'
          ? 'This wallet is already linked to another identity.'
          : e.message);
    } catch (e) {
      AppLogger.w('IdHubSignPage', 'sign error: $e');
      _fail('Signing failed. Please try again.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _stage = _Stage.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.isLogin ? 'Login Request' : 'Bind Wallet',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBody(colors),
        ),
      ),
    );
  }

  Widget _buildBody(AppColorTokens colors) {
    switch (_stage) {
      case _Stage.loading:
        return Center(child: CircularProgressIndicator(color: colors.brand));
      case _Stage.error:
        return _centered(
          Icons.error_outline,
          colors.danger,
          _error,
          colors,
        );
      case _Stage.success:
        return _centered(
          Icons.check_circle_outline,
          colors.success,
          widget.isLogin
              ? 'Approved. Return to the other device.'
              : 'Wallet bound. Return to the other device.',
          colors,
        );
      case _Stage.ready:
      case _Stage.signing:
        return _buildConfirm(colors);
    }
  }

  Widget _buildConfirm(AppColorTokens colors) {
    final signing = _stage == _Stage.signing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.isLogin
              ? 'Approve sign-in with your N42 identity?'
              : 'Bind this wallet to your N42 identity?',
          style: AppTypography.headline.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 24),
        _row('Request', widget.isLogin ? 'Sign in' : 'Bind wallet', colors),
        _row('Wallet', _short(_address ?? ''), colors),
        _row('Server', _hubHost, colors),
        const SizedBox(height: 16),
        Text('Message', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _message,
            style: AppTypography.body.copyWith(color: colors.textPrimary),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: signing ? null : _confirm,
          child: signing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isLogin ? 'Approve' : 'Bind'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: signing ? null : () => Navigator.of(context).maybePop(),
          child: Text('Cancel',
              style: AppTypography.body.copyWith(color: colors.textSecondary)),
        ),
      ],
    );
  }

  Widget _row(String label, String value, AppColorTokens colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.body.copyWith(color: colors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _centered(
    IconData icon,
    Color color,
    String text,
    AppColorTokens colors,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  String _short(String addr) {
    if (addr.length <= 14) return addr;
    return '${addr.substring(0, 8)}...${addr.substring(addr.length - 6)}';
  }
}
