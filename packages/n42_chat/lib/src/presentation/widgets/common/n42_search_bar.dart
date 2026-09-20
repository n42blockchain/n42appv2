import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

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
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _showClear = _controller.text.isNotEmpty;

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant N42SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onTextChanged);
      final value = _controller.value;
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? TextEditingController.fromValue(value);
      _controller.addListener(_onTextChanged);
      _showClear = _controller.text.isNotEmpty;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
      _isFocused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
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
    final bgColor = widget.backgroundColor ?? AppColors.inputBgOf(isDark);
    final tertiary = context.textSupporting;

    final radius = BorderRadius.circular(AppDimensions.radiusXL);
    return Row(
      children: [
        Expanded(
          child: Material(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: _isFocused
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppDimensions.buttonHeight,
              ),
              child: widget.onTap != null
                  ? Semantics(
                      button: true,
                      enabled: widget.enabled,
                      child: InkWell(
                        onTap: widget.enabled ? widget.onTap : null,
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.spacingM),
                          child: _buildReadOnlySearch(tertiary),
                        ),
                      ),
                    )
                  : _buildEditableSearch(tertiary),
            ),
          ),
        ),
        if (widget.showCancelButton && _isFocused) ...[
          const SizedBox(width: AppDimensions.spacingXS),
          TextButton(
            onPressed: widget.enabled ? _onCancel : null,
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppDimensions.buttonHeight,
                AppDimensions.buttonHeight,
              ),
            ),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
        ],
      ],
    );
  }

  Widget _buildReadOnlySearch(Color iconColor) {
    final hint = widget.hintText ?? S.of(context)?.commonSearch ?? 'Search';
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          AppIcons.search,
          size: AppDimensions.iconSizeSmall,
          color: iconColor,
        ),
        const SizedBox(width: AppDimensions.spacingS),
        // Flexible 防止超长 hintText 撑破搜索栏
        Flexible(
          child: Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(color: iconColor),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableSearch(Color iconColor) {
    final hint = widget.hintText ?? S.of(context)?.commonSearch ?? 'Search';
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: iconColor),
        prefixIcon: Icon(
          AppIcons.search,
          size: AppDimensions.iconSizeSmall,
          color: iconColor,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: AppDimensions.buttonHeight,
          minHeight: AppDimensions.buttonHeight,
        ),
        suffixIcon: _showClear
            ? IconButton(
                tooltip: S.of(context)?.commonClear ?? 'Clear',
                onPressed: widget.enabled ? _onClear : null,
                icon: Icon(
                  Icons.cancel,
                  size: AppDimensions.iconSizeSmall,
                  color: iconColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppDimensions.buttonHeight,
                  minHeight: AppDimensions.buttonHeight,
                ),
                splashRadius: 18,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: AppDimensions.buttonHeight,
          minHeight: AppDimensions.buttonHeight,
        ),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingM,
        ),
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
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.listItemPadding,
      vertical: AppDimensions.spacingS,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.navBarColor,
      padding: padding,
      child: child,
    );
  }
}
