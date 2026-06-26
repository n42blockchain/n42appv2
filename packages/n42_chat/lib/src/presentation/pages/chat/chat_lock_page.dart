import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/chat_lock_service.dart';
import '../../../core/theme/app_colors.dart';

/// 聊天锁验证页面
///
/// 进入已锁定的聊天前弹出此页面，用户需要通过生物识别或 PIN 码验证
class ChatLockPage extends StatefulWidget {
  final String roomId;
  final String chatName;

  const ChatLockPage({super.key, required this.roomId, required this.chatName});

  @override
  State<ChatLockPage> createState() => _ChatLockPageState();
}

class _ChatLockPageState extends State<ChatLockPage> {
  final ChatLockService _lockService = ChatLockService();
  final TextEditingController _pinController = TextEditingController();
  bool _showPinInput = false;
  bool _isBiometricAvailable = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final biometricAvailable = await _lockService.isBiometricAvailable();
    if (mounted) {
      setState(() => _isBiometricAvailable = biometricAvailable);
    }
    // Auto-trigger biometric if available
    if (biometricAvailable) {
      unawaited(_verifyBiometric());
    } else {
      if (mounted) setState(() => _showPinInput = true);
    }
  }

  Future<void> _verifyBiometric() async {
    final l10n = S.of(context);
    final success = await _lockService.verifyWithBiometric(
      reason: l10n?.chatLockVerifySubtitle ?? 'Verify to access this chat',
    );
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      // Biometric failed, show PIN input as fallback
      final hasPin = await _lockService.hasPinSet(widget.roomId);
      if (!mounted) return;
      if (hasPin) {
        setState(() {
          _showPinInput = true;
          _errorMessage = l10n?.chatLockVerifyFailed ?? 'Verification failed';
        });
      }
    }
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text;
    if (pin.isEmpty) return;

    final success = await _lockService.verifyPin(widget.roomId, pin);
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      setState(() {
        _errorMessage =
            S.of(context)?.chatLockVerifyFailed ?? 'Verification failed';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: context.textPrimary,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n?.chatLockVerifyTitle ?? 'Chat locked',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.chatName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.chatLockVerifySubtitle ?? 'Verify to access this chat',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (_showPinInput) ...[
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: l10n?.chatLockPinTitle ?? 'Enter PIN',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _verifyPin(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _verifyPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n?.commonConfirm ?? 'Confirm'),
                    ),
                  ),
                ],
                if (_isBiometricAvailable && _showPinInput) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _verifyBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n?.chatLockUseBiometric ?? 'Use biometric'),
                  ),
                ],
                if (_isBiometricAvailable && !_showPinInput) ...[
                  ElevatedButton.icon(
                    onPressed: _verifyBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n?.chatLockUseBiometric ?? 'Use biometric'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
