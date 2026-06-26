import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/username_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/username_validator.dart';

/// 设置用户名页面
class SetUsernamePage extends StatefulWidget {
  const SetUsernamePage({super.key});

  @override
  State<SetUsernamePage> createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  final _controller = TextEditingController();
  final _usernameService = getIt<UsernameService>();

  String? _currentUsername;
  String? _errorMessage;
  bool _isAvailable = false;
  bool _isChecking = false;
  bool _isSaving = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
    _controller.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUsername() async {
    final username = await _usernameService.getMyUsername();
    if (mounted) {
      setState(() {
        _currentUsername = username;
        if (username != null) {
          _controller.text = username;
        }
      });
    }
  }

  void _onUsernameChanged() {
    _debounce?.cancel();
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = null;
        _isAvailable = false;
        _isChecking = false;
      });
      return;
    }

    // 先做本地格式验证
    final validation = UsernameValidator.validate(text);
    if (!validation.isValid) {
      setState(() {
        _errorMessage = validation.errorMessage;
        _isAvailable = false;
        _isChecking = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    // 防抖检查可用性
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await _usernameService.isAvailable(text);
      if (mounted && _controller.text.trim() == text) {
        setState(() {
          _isChecking = false;
          _isAvailable = available;
          if (!available) {
            _errorMessage =
                S.of(context)?.usernameUnavailable ?? 'Username already taken';
          }
        });
      }
    });
  }

  Future<void> _saveUsername() async {
    final username = _controller.text.trim();
    if (username.isEmpty || !_isAvailable) return;

    setState(() => _isSaving = true);

    try {
      final success = await _usernameService.claimUsername(username);

      if (!mounted) return;

      setState(() => _isSaving = false);
      if (success) {
        final s = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s?.usernameSaved ?? 'Username saved')),
        );
        Navigator.of(context).pop(username);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save username')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save username: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUsername != null
              ? (s?.usernameChange ?? 'Change Username')
              : (s?.usernameSet ?? 'Set Username'),
        ),
        actions: [
          TextButton(
            onPressed: (_isAvailable && !_isSaving) ? _saveUsername : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s?.usernameTitle ?? 'Username',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixText: '@',
                hintText: s?.usernamePlaceholder ?? 'Enter username',
                border: const OutlineInputBorder(),
                suffixIcon: _isChecking
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _isAvailable && _controller.text.trim().isNotEmpty
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      )
                    : _errorMessage != null
                    ? const Icon(Icons.error_outline, color: AppColors.error)
                    : null,
                errorText: _errorMessage,
              ),
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (_isAvailable) _saveUsername();
              },
            ),
            const SizedBox(height: 8),
            Text(
              s?.usernameInvalid ??
                  '3-30 characters, lowercase letters, numbers, underscore. Must start with a letter.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (_isAvailable && _controller.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                s?.usernameAvailable ?? 'Username available',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
