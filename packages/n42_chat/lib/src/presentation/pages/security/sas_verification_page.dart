import 'package:flutter/material.dart';
import 'package:matrix/encryption/utils/key_verification.dart' as kv;

import '../../../core/encryption/e2ee_manager.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import 'emoji_verification_widget.dart';
import '../../../core/utils/debug_log.dart';

/// SAS 验证状态
enum SasVerificationStep {
  /// 等待对方接受
  waitingForAccept,

  /// 显示 emoji/数字，等待用户确认
  showingSas,

  /// 等待对方确认
  waitingForPartner,

  /// 验证成功
  verified,

  /// 验证失败/取消
  failed,
}

/// SAS 安全码验证页面
///
/// 支持两种验证方式：
/// 1. Emoji 对比 - 显示 7 个 emoji 符号
/// 2. 数字对比 - 显示 3 组数字（当 emoji 不可用时）
class SasVerificationPage extends StatefulWidget {
  final E2EEManager e2eeManager;

  /// 验证目标用户 ID
  final String userId;

  /// 验证目标设备 ID（为 null 时验证整个用户）
  final String? deviceId;

  /// 设备显示名称
  final String? deviceName;

  /// 已有的验证对象（用于处理传入的验证请求）
  final kv.KeyVerification? incomingVerification;

  const SasVerificationPage({
    super.key,
    required this.e2eeManager,
    required this.userId,
    this.deviceId,
    this.deviceName,
    this.incomingVerification,
  });

  @override
  State<SasVerificationPage> createState() => _SasVerificationPageState();
}

class _SasVerificationPageState extends State<SasVerificationPage> {
  SasVerificationStep _step = SasVerificationStep.waitingForAccept;
  kv.KeyVerification? _verification;

  List<kv.KeyVerificationEmoji>? _emojis;
  List<int>? _numbers;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.incomingVerification != null) {
      _verification = widget.incomingVerification;
      _acceptIncomingVerification();
    } else {
      _startVerification();
    }
  }

  @override
  void dispose() {
    _verification?.onUpdate = null;
    super.dispose();
  }

  /// 发起验证请求
  Future<void> _startVerification() async {
    try {
      final deviceId = widget.deviceId;
      if (deviceId == null) {
        setState(() {
          _step = SasVerificationStep.failed;
          _errorMessage =
              S.of(context)?.securityDeviceIdRequired ??
              'Device ID is required';
        });
        return;
      }

      _verification = await widget.e2eeManager.startSasVerification(
        widget.userId,
        deviceId,
      );

      if (_verification == null) {
        setState(() {
          _step = SasVerificationStep.failed;
          _errorMessage =
              S.of(context)?.securityVerificationFailed ??
              'Failed to start verification';
        });
        return;
      }

      _listenToVerification();
    } catch (e) {
      setState(() {
        _step = SasVerificationStep.failed;
        _errorMessage = e.toString();
      });
    }
  }

  /// 接受传入的验证请求
  Future<void> _acceptIncomingVerification() async {
    if (_verification == null) return;
    try {
      _listenToVerification();
      await widget.e2eeManager.acceptSasVerification(_verification!);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = SasVerificationStep.failed;
        _errorMessage = e.toString();
      });
    }
  }

  /// 监听验证状态变化
  void _listenToVerification() {
    if (_verification == null) return;

    _verification!.onUpdate = () {
      _handleVerificationUpdate();
    };

    // 处理当前状态
    _handleVerificationUpdate();
  }

  void _handleVerificationUpdate() {
    if (_verification == null || !mounted) return;

    final state = _verification!.state;

    switch (state) {
      case kv.KeyVerificationState.waitingAccept:
        setState(() => _step = SasVerificationStep.waitingForAccept);
        break;

      case kv.KeyVerificationState.askSas:
        // SAS 数据已就绪，可以展示
        final sasData = _verification!.sasEmojis;
        final sasNumbers = _verification!.sasNumbers;

        setState(() {
          _step = SasVerificationStep.showingSas;
          _emojis = sasData;
          _numbers = sasNumbers;
        });
        break;

      case kv.KeyVerificationState.waitingSas:
        setState(() => _step = SasVerificationStep.waitingForPartner);
        break;

      case kv.KeyVerificationState.done:
        setState(() => _step = SasVerificationStep.verified);
        break;

      case kv.KeyVerificationState.error:
        setState(() {
          _step = SasVerificationStep.failed;
          _errorMessage =
              _verification!.canceledCode ??
              (S.of(context)?.securityVerificationFailed ??
                  'Verification failed');
        });
        break;

      default:
        break;
    }
  }

  /// 用户确认 SAS 匹配
  Future<void> _onConfirm() async {
    if (_verification == null) return;

    setState(() => _step = SasVerificationStep.waitingForPartner);

    try {
      await widget.e2eeManager.confirmSas(_verification!);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = SasVerificationStep.failed;
        _errorMessage = e.toString();
      });
    }
  }

  /// 用户拒绝 SAS（不匹配）
  Future<void> _onReject() async {
    if (_verification == null) return;

    try {
      await widget.e2eeManager.rejectSas(_verification!);
    } catch (e) {
      // ignore
      debugLog('Error: $e');
    }

    setState(() {
      _step = SasVerificationStep.failed;
      _errorMessage =
          S.of(context)?.securityEmojiMismatchRejected ??
          'Verification rejected - emoji did not match';
    });
  }

  /// 取消验证
  Future<void> _onCancel() async {
    if (_verification != null) {
      try {
        await widget.e2eeManager.cancelVerification(_verification!);
      } catch (e) {
        // ignore
        debugLog('Error: $e');
      }
    }
    if (mounted) Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.securityVerifyDevice ?? 'Verify Device',
        showBackButton: true,
        onBackPressed: _onCancel,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(isDark),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    switch (_step) {
      case SasVerificationStep.waitingForAccept:
        return _buildWaitingForAccept(isDark);
      case SasVerificationStep.showingSas:
        return _buildShowingSas(isDark);
      case SasVerificationStep.waitingForPartner:
        return _buildWaitingForPartner(isDark);
      case SasVerificationStep.verified:
        return _buildVerified(isDark);
      case SasVerificationStep.failed:
        return _buildFailed(isDark);
    }
  }

  Widget _buildWaitingForAccept(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context)?.securityWaitingForDeviceAccept ??
              'Waiting for the other device to accept...',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.deviceName ?? widget.deviceId ?? '',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: _onCancel,
          child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
        ),
      ],
    );
  }

  Widget _buildShowingSas(bool isDark) {
    return Column(
      children: [
        const Spacer(),

        // 标题
        const Icon(Icons.security, size: 48, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          S.of(context)?.securityVerifyDevice ?? 'Verify this device',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context)?.securityConfirmEmojiMatch ??
              'Confirm the emoji below are displayed on both devices, in the same order',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Emoji 或数字展示
        if (_emojis != null && _emojis!.isNotEmpty)
          EmojiVerificationWidget(emojis: _emojis!)
        else if (_numbers != null && _numbers!.isNotEmpty)
          NumberVerificationWidget(numbers: _numbers!),

        const Spacer(),

        // 操作按钮
        Row(
          children: [
            // 不匹配按钮
            Expanded(
              child: OutlinedButton(
                onPressed: _onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  S.of(context)?.securityEmojiDontMatch ?? 'They don\'t match',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 匹配按钮
            Expanded(
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  S.of(context)?.securityEmojiMatch ?? 'They match',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWaitingForPartner(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context)?.securityWaitingForDeviceConfirm ??
              'Waiting for the other device to confirm...',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerified(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified, color: Colors.green, size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context)?.securityVerificationSuccess ??
              'Verification successful!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context)?.securityDeviceVerifiedTrusted ??
              'This device is now verified and trusted.',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(S.of(context)?.commonDone ?? 'Done'),
        ),
      ],
    );
  }

  Widget _buildFailed(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context)?.securityVerificationFailed ?? 'Verification failed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.of(context)?.commonClose ?? 'Close'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _step = SasVerificationStep.waitingForAccept;
                  _errorMessage = null;
                  _emojis = null;
                  _numbers = null;
                });
                _verification?.onUpdate = null;
                _startVerification();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(S.of(context)?.commonTryAgain ?? 'Try Again'),
            ),
          ],
        ),
      ],
    );
  }
}
