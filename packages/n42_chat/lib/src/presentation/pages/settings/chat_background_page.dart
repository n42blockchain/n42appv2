import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/a11y_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/chat_background_presets.dart';
import '../../../core/utils/debug_log.dart';
import '../../../data/datasources/local/preferences_datasource.dart';

/// 聊天背景设置页
class ChatBackgroundPage extends StatefulWidget {
  final String? roomId;

  const ChatBackgroundPage({super.key, this.roomId});

  @override
  State<ChatBackgroundPage> createState() => _ChatBackgroundPageState();
}

class _ChatBackgroundPageState extends State<ChatBackgroundPage> {
  final PreferencesDataSource _storage =
      GetIt.instance<PreferencesDataSource>();
  String? _selectedBackground;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBackground();
  }

  Future<void> _loadCurrentBackground() async {
    final bg = widget.roomId != null
        ? await _storage.getChatBackground(widget.roomId!)
        : await _storage.getDefaultChatBackground();
    if (mounted) {
      setState(() => _selectedBackground = bg);
    }
  }

  Future<void> _selectBackground(String value) async {
    final isDefaultSelection =
        value == 'default' &&
        (_selectedBackground == null || _selectedBackground == 'default');
    if (_isSaving || isDefaultSelection || value == _selectedBackground) {
      return;
    }

    final previousBackground = _selectedBackground;
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      _selectedBackground = value;
    });

    try {
      if (widget.roomId != null) {
        await _storage.setChatBackground(widget.roomId!, value);
      } else {
        await _storage.setDefaultChatBackground(value);
      }
    } catch (e) {
      debugLog('ChatBackgroundPage: Failed to save background: $e');
      if (!mounted) {
        return;
      }
      setState(() => _selectedBackground = previousBackground);
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          S.of(context)?.chatBackground ?? 'Chat Background',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: context.textPrimary,
            size: 20,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSaving,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 默认（无背景）
                _buildDefaultOption(),

                const SizedBox(height: 24),

                // 纯色背景
                Text(
                  S.of(context)?.solidColors ?? 'Solid Colors',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildColorGrid(),

                const SizedBox(height: 24),

                // 渐变背景
                Text(
                  S.of(context)?.gradients ?? 'Gradients',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGradientGrid(),
              ],
            ),
          ),
          if (_isSaving)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultOption() {
    final isSelected =
        _selectedBackground == null || _selectedBackground == 'default';

    return GestureDetector(
      onTap: _isSaving ? null : () => _selectBackground('default'),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : context.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            S.of(context)?.defaultBackground ?? 'Default',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ChatBackgroundPresets.solidColors.asMap().entries.map((entry) {
        final colorKey = 'solid_${entry.key}';
        final isSelected = _selectedBackground == colorKey;

        return Semantics(
          button: true,
          selected: isSelected,
          label: A11yL10n.of(context).solidColor,
          excludeSemantics: true,
          child: GestureDetector(
          onTap: _isSaving ? null : () => _selectBackground(colorKey),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: entry.value,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 24),
                  )
                : null,
          ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGradientGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ChatBackgroundPresets.gradients.asMap().entries.map((entry) {
        final gradientKey = 'gradient_${entry.key}';
        final isSelected = _selectedBackground == gradientKey;

        return Semantics(
          button: true,
          selected: isSelected,
          label: A11yL10n.of(context).gradient,
          excludeSemantics: true,
          child: GestureDetector(
          onTap: _isSaving ? null : () => _selectBackground(gradientKey),
          child: Container(
            width: 80,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: entry.value,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 24),
                  )
                : null,
          ),
          ),
        );
      }).toList(),
    );
  }
}
