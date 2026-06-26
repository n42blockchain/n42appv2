// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/utils/validation/address_validator.dart';

/// ENS 解析状态
enum EnsResolveStatus {
  /// 空闲状态
  idle,

  /// 正在解析
  resolving,

  /// 解析成功
  resolved,

  /// 解析失败
  failed,
}

/// ENS 地址输入框
///
/// 提供实时 ENS 解析反馈，对标 MetaMask、Rainbow 等主流钱包。
/// 解析成功后显示缩短地址（6+4 格式）、来源链徽章、头像，
/// 并支持点击复制已解析地址。
class EnsAddressField extends StatefulWidget {
  /// 文本控制器
  final TextEditingController controller;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 当前链类型
  final String coinType;

  /// 发送者地址（用于自转检测）
  final String senderAddress;

  /// 标签文本
  final String? labelText;

  /// 提示文本
  final String? hintText;

  /// 错误信息
  final String? errorText;

  /// 后缀图标按钮
  final List<Widget>? suffixIcons;

  /// 地址验证回调
  final void Function(String? validAddress, bool isEns)? onAddressValidated;

  /// ENS 解析状态变化回调
  final void Function(EnsResolveStatus status, EnsResolutionResult? result)?
  onEnsStatusChanged;

  const EnsAddressField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.coinType,
    required this.senderAddress,
    this.labelText,
    this.hintText,
    this.errorText,
    this.suffixIcons,
    this.onAddressValidated,
    this.onEnsStatusChanged,
  });

  @override
  State<EnsAddressField> createState() => _EnsAddressFieldState();
}

class _EnsAddressFieldState extends State<EnsAddressField> {
  final EnsService _ensService = EnsServiceProvider.instance;

  EnsResolveStatus _status = EnsResolveStatus.idle;
  EnsResolutionResult? _resolveResult;
  String? _avatarUrl;
  Timer? _debounceTimer;
  int _resolveRequestId = 0;

  /// 防抖延迟时间
  static const _debounceDelay = Duration(milliseconds: 500);

  /// ENS 解析成功颜色
  Color get _successColor => AppColorTokens.of(context).success;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant EnsAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _onTextChanged();
      return;
    }

    if (oldWidget.coinType != widget.coinType ||
        oldWidget.senderAddress != widget.senderAddress) {
      _onTextChanged();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();

    final text = widget.controller.text.trim();
    final requestId = ++_resolveRequestId;

    if (text.isEmpty) {
      _updateStatus(EnsResolveStatus.idle, null);
      return;
    }

    // 检查是否是 ENS 名称
    if (EnsService.isEnsName(text)) {
      _updateStatus(EnsResolveStatus.resolving, null);
      _debounceTimer = Timer(
        _debounceDelay,
        () => _resolveEns(text, requestId),
      );
    } else {
      _updateStatus(EnsResolveStatus.idle, null);
      // 验证普通地址
      _validateAddress(text);
    }
  }

  Future<void> _resolveEns(String ensName, int requestId) async {
    if (!mounted || requestId != _resolveRequestId) return;

    EnsResolutionResult result;
    try {
      result = await _ensService.resolveName(
        ensName,
        preferredChain: widget.coinType,
      );
    } catch (e) {
      AppLogger.w('EnsAddressField', 'failed to resolve ENS: $e');
      if (!mounted ||
          requestId != _resolveRequestId ||
          widget.controller.text.trim() != ensName) {
        return;
      }
      _updateStatus(
        EnsResolveStatus.failed,
        EnsResolutionResult.failure(e.toString()),
      );
      widget.onAddressValidated?.call(null, true);
      return;
    }

    if (!mounted ||
        requestId != _resolveRequestId ||
        widget.controller.text.trim() != ensName) {
      return;
    }

    if (result.success && result.address != null) {
      // 检查是否自转
      if (result.address!.toLowerCase() == widget.senderAddress.toLowerCase()) {
        _updateStatus(
          EnsResolveStatus.failed,
          EnsResolutionResult.failure(S.current.g_key_ens_self_transfer),
        );
        widget.onAddressValidated?.call(null, true);
        return;
      }

      _updateStatus(EnsResolveStatus.resolved, result);
      widget.onAddressValidated?.call(result.address, true);

      // 异步加载头像（不阻塞主流程）
      _loadAvatar(result, ensName, requestId);
    } else {
      _updateStatus(EnsResolveStatus.failed, result);
      widget.onAddressValidated?.call(null, true);
    }
  }

  /// 异步加载 ENS 头像：优先使用已内联在解析结果中的 avatar URL，
  /// 否则单独请求 getAvatar。
  Future<void> _loadAvatar(
    EnsResolutionResult result,
    String ensName,
    int requestId,
  ) async {
    var url = result.avatar;
    if (url?.isNotEmpty != true) {
      try {
        url = await _ensService.getAvatar(ensName);
      } catch (_) {
        url = null;
      }
    }
    if (!mounted ||
        requestId != _resolveRequestId ||
        widget.controller.text.trim() != ensName ||
        url?.isNotEmpty != true) {
      return;
    }
    setState(() => _avatarUrl = url);
  }

  static final RegExp _evmAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

  void _validateAddress(String address) {
    final isValid = _evmAddressRegExp.hasMatch(address);
    widget.onAddressValidated?.call(isValid ? address : null, false);
  }

  void _updateStatus(EnsResolveStatus status, EnsResolutionResult? result) {
    setState(() {
      _status = status;
      _resolveResult = result;
      if (status != EnsResolveStatus.resolved) _avatarUrl = null;
    });
    widget.onEnsStatusChanged?.call(status, result);
  }

  Color _themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

  @override
  Widget build(BuildContext context) {
    final mainTextColor = _themeColor(AppThemeKeys.mainTextColor.name);
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor.name);
    final bgColor = _themeColor(AppThemeKeys.itemBgColor.name);
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor.name);
    final su = ScreenUtil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 输入框
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(su.setWidth(12)),
            border: Border.all(
              color: _getBorderColor(subtitleColor, blueColor),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            style: AppTypography.body.copyWith(color: mainTextColor),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText ?? 'Address or ENS name',
              hintStyle: AppTypography.bodySm.copyWith(
                color: subtitleColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: su.setWidth(16),
                vertical: su.setWidth(14),
              ),
              border: InputBorder.none,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusIndicator(blueColor, subtitleColor),
                  ...?widget.suffixIcons,
                ],
              ),
            ),
          ),
        ),

        // ENS 解析结果显示（解析成功时展示）
        if (_status == EnsResolveStatus.resolved && _resolveResult != null)
          _buildResolvedCard(blueColor, subtitleColor, mainTextColor),

        // 外部错误信息（父组件传入）
        if (widget.errorText?.isNotEmpty == true)
          _buildHintText(widget.errorText!, AppColorTokens.of(context).danger),

        // ENS 解析失败信息
        if (_status == EnsResolveStatus.failed && _resolveResult?.error != null)
          _buildHintText(
            _resolveResult!.error!,
            AppColorTokens.of(context).warning,
          ),
      ],
    );
  }

  Color _getBorderColor(Color defaultColor, Color activeColor) {
    switch (_status) {
      case EnsResolveStatus.resolving:
        return activeColor.withValues(alpha: 0.5);
      case EnsResolveStatus.resolved:
        return _successColor;
      case EnsResolveStatus.failed:
        return AppColorTokens.of(context).warning;
      case EnsResolveStatus.idle:
        return defaultColor.withValues(alpha: 0.3);
    }
  }

  Widget _buildHintText(String text, Color color) {
    final su = ScreenUtil();
    return Padding(
      padding: EdgeInsets.only(top: su.setWidth(8), left: su.setWidth(4)),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }

  Widget _buildStatusIndicator(Color blueColor, Color subtitleColor) {
    if (_status == EnsResolveStatus.idle) return const SizedBox.shrink();

    final su = ScreenUtil();
    final iconSize = su.setWidth(28);
    final Widget indicator = switch (_status) {
      EnsResolveStatus.resolving => SizedBox(
        width: su.setWidth(24),
        height: su.setWidth(24),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(blueColor),
        ),
      ),
      EnsResolveStatus.resolved => Icon(
        Icons.check_circle,
        color: _successColor,
        size: iconSize,
      ),
      EnsResolveStatus.failed => Icon(
        Icons.warning_amber_rounded,
        color: AppColorTokens.of(context).warning,
        size: iconSize,
      ),
      EnsResolveStatus.idle => const SizedBox.shrink(),
    };

    return Padding(
      padding: EdgeInsets.only(right: su.setWidth(12)),
      child: indicator,
    );
  }

  /// 解析成功卡片：显示头像（若有）、ENS名称→缩短地址、来源链徽章。
  /// 点击整个卡片可复制完整地址。
  Widget _buildResolvedCard(
    Color blueColor,
    Color subtitleColor,
    Color mainTextColor,
  ) {
    final su = ScreenUtil();
    final resolvedAddr = _resolveResult!.address!;
    final shortAddr = AddressValidator.getAddressPreview(
      resolvedAddr,
      prefixLength: 6,
      suffixLength: 4,
    );

    return GestureDetector(
      onTap: () => _copyAddress(resolvedAddr),
      child: Container(
        margin: EdgeInsets.only(top: su.setWidth(8)),
        padding: EdgeInsets.symmetric(
          horizontal: su.setWidth(12),
          vertical: su.setWidth(10),
        ),
        decoration: BoxDecoration(
          color: _successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(su.setWidth(8)),
          border: Border.all(color: _successColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // 头像（有时才显示）或默认的 verified 图标
            _buildAvatarWidget(),
            SizedBox(width: su.setWidth(8)),

            // 地址信息列
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).g_key_ens_resolved_address,
                    style: AppTypography.captionSm.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: su.setWidth(2)),
                  Text(
                    shortAddr,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: mainTextColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            // 来源链徽章（若有）
            if (_resolveResult?.sourceChain != null)
              Container(
                margin: EdgeInsets.only(left: su.setWidth(4)),
                padding: EdgeInsets.symmetric(
                  horizontal: su.setWidth(8),
                  vertical: su.setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: blueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(su.setWidth(6)),
                ),
                child: Text(
                  _resolveResult!.sourceChain!,
                  style: AppTypography.captionSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: blueColor,
                  ),
                ),
              ),

            SizedBox(width: su.setWidth(6)),
            Icon(
              Icons.copy_rounded,
              color: subtitleColor,
              size: su.setWidth(20),
            ),
          ],
        ),
      ),
    );
  }

  /// 头像组件：如有 URL 则显示网络图片，否则显示 verified 图标
  Widget _buildAvatarWidget() {
    final avatarUrl = _avatarUrl;
    if (avatarUrl == null) return _verifiedIcon();
    final size = ScreenUtil().setWidth(32);
    return ClipOval(
      child: Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _verifiedIcon(),
      ),
    );
  }

  Widget _verifiedIcon() => Icon(
    Icons.verified,
    color: _successColor,
    size: ScreenUtil().setWidth(24),
  );

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_ens_copy_address),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
