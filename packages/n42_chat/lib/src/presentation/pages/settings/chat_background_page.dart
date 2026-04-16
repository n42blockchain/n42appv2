import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/chat_background_presets.dart';
import '../../../data/datasources/local/preferences_datasource.dart';

/// 聊天背景设置页
class ChatBackgroundPage extends StatefulWidget {
  final String? roomId;

  const ChatBackgroundPage({super.key, this.roomId});

  @override
  State<ChatBackgroundPage> createState() => _ChatBackgroundPageState();
}

class _ChatBackgroundPageState extends State<ChatBackgroundPage> {
  final PreferencesDataSource _storage = GetIt.instance<PreferencesDataSource>();
  String? _selectedBackground;

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
    setState(() => _selectedBackground = value);
    if (widget.roomId != null) {
      await _storage.setChatBackground(widget.roomId!, value);
    } else {
      await _storage.setDefaultChatBackground(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          S.of(context)?.chatBackground ?? 'Chat Background',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 默认（无背景）
          _buildDefaultOption(isDark),

          const SizedBox(height: 24),

          // 纯色背景
          Text(
            S.of(context)?.solidColors ?? 'Solid Colors',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildGradientGrid(),
        ],
      ),
    );
  }

  Widget _buildDefaultOption(bool isDark) {
    final isSelected = _selectedBackground == null || _selectedBackground == 'default';

    return GestureDetector(
      onTap: () => _selectBackground('default'),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.dividerDark : AppColors.divider),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            S.of(context)?.defaultBackground ?? 'Default',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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

        return GestureDetector(
          onTap: () => _selectBackground(colorKey),
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
                    child: Icon(Icons.check, color: Colors.white, size: 24),
                  )
                : null,
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

        return GestureDetector(
          onTap: () => _selectBackground(gradientKey),
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
                    child: Icon(Icons.check, color: Colors.white, size: 24),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
