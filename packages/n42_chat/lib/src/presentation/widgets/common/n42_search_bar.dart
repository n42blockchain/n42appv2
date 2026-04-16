import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// 微信风格搜索框
///
/// 特点：
/// - 圆角背景
/// - 搜索图标
/// - 取消按钮
/// - 清除按钮
class N42SearchBar extends StatefulWidget {
  /// 占位文字
  final String? hintText;

  /// 初始值
  final String? initialValue;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 清除回调
  final VoidCallback? onClear;

  /// 点击回调（用于跳转到搜索页）
  final VoidCallback? onTap;

  /// 是否自动聚焦
  final bool autofocus;

  /// 是否启用
  final bool enabled;

  /// 是否显示取消按钮
  final bool showCancelButton;

  /// 背景色
  final Color? backgroundColor;

  /// 文本控制器
  final TextEditingController? controller;

  /// 焦点节点
  final FocusNode? focusNode;

  const N42SearchBar({
    super.key,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onCancel,
    this.onClear,
    this.onTap,
    this.autofocus = false,
    this.enabled = true,
    this.showCancelButton = true,
    this.backgroundColor,
    this.controller,
    this.focusNode,
  });

  @override
  State<N42SearchBar> createState() => _N42SearchBarState();
}

class _N42SearchBarState extends State<N42SearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClear = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _showClear = _controller.text.isNotEmpty;

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  void _onCancel() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.searchBackground);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: widget.onTap != null
                  ? _buildReadOnlySearch(isDark)
                  : _buildEditableSearch(isDark),
            ),
          ),
        ),
        if (widget.showCancelButton && _isFocused) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onCancel,
            child: Text(
              S.of(context)?.commonCancel ?? 'Cancel',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadOnlySearch(bool isDark) {
    final hint = widget.hintText ?? S.of(context)?.commonSearch ?? 'Search';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.search,
          size: 18,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          hint,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableSearch(bool isDark) {
    final hint = widget.hintText ?? S.of(context)?.commonSearch ?? 'Search';
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.textTertiary,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        suffixIcon: _showClear
            ? GestureDetector(
                onTap: _onClear,
                child: const Icon(
                  Icons.cancel,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}

/// 搜索栏容器（带背景）
class N42SearchBarContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const N42SearchBarContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      color: isDark ? AppColors.navBarDark : AppColors.navBar,
      padding: padding,
      child: child,
    );
  }
}

