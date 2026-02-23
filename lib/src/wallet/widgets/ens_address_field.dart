// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/services/ens_service.dart';
import 'package:n42_wallet/src/wallet/utils/address_validator.dart';

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

  /// 防抖延迟时间
  static const _debounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
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

    if (text.isEmpty) {
      _updateStatus(EnsResolveStatus.idle, null);
      return;
    }

    // 检查是否是 ENS 名称
    if (EnsService.isEnsName(text)) {
      _updateStatus(EnsResolveStatus.resolving, null);

      _debounceTimer = Timer(_debounceDelay, () {
        _resolveEns(text);
      });
    } else {
      _updateStatus(EnsResolveStatus.idle, null);
      // 验证普通地址
      _validateAddress(text);
    }
  }

  Future<void> _resolveEns(String ensName) async {
    if (!mounted) return;

    final result = await _ensService.resolveName(
      ensName,
      preferredChain: widget.coinType,
    );

    if (!mounted) return;

    if (result.success && result.address != null) {
      // 检查是否自转
      if (result.address!.toLowerCase() ==
          widget.senderAddress.toLowerCase()) {
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
      _loadAvatar(result, ensName);
    } else {
      _updateStatus(EnsResolveStatus.failed, result);
      widget.onAddressValidated?.call(null, true);
    }
  }

  /// 异步加载 ENS 头像：优先使用已内联在解析结果中的 avatar URL，
  /// 否则单独请求 getAvatar。
  Future<void> _loadAvatar(EnsResolutionResult result, String ensName) async {
    String? url = result.avatar;
    if (url == null || url.isEmpty) {
      try {
        url = await _ensService.getAvatar(ensName);
      } catch (_) {
        url = null;
      }
    }
    if (!mounted) return;
    if (url != null && url.isNotEmpty) {
      setState(() => _avatarUrl = url);
    }
  }

  Future<void> _validateAddress(String address) async {
    // 简单的地址格式检查（0x + 40 hex）
    final isValidFormat =
        address.startsWith('0x') && address.length == 42 &&
        RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address);
    widget.onAddressValidated?.call(isValidFormat ? address : null, false);
  }

  void _updateStatus(EnsResolveStatus status, EnsResolutionResult? result) {
    setState(() {
      _status = status;
      _resolveResult = result;
      if (status != EnsResolveStatus.resolved) _avatarUrl = null;
    });
    widget.onEnsStatusChanged?.call(status, result);
  }

  @override
  Widget build(BuildContext context) {
    final mainTextColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 输入框
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            border: Border.all(
              color: _getBorderColor(subtitleColor, blueColor),
              width: 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: mainTextColor,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText ?? 'Address or ENS name',
              hintStyle: TextStyle(
                color: subtitleColor,
                fontSize: ScreenUtil().setSp(26),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(14),
              ),
              border: InputBorder.none,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ENS 解析状态指示器
                  _buildStatusIndicator(blueColor, subtitleColor),
                  // 自定义后缀图标
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
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: ScreenUtil().setWidth(8),
              left: ScreenUtil().setWidth(4),
            ),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.red,
              ),
            ),
          ),

        // ENS 解析失败信息
        if (_status == EnsResolveStatus.failed && _resolveResult?.error != null)
          Padding(
            padding: EdgeInsets.only(
              top: ScreenUtil().setWidth(8),
              left: ScreenUtil().setWidth(4),
            ),
            child: Text(
              _resolveResult!.error!,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  Color _getBorderColor(Color defaultColor, Color activeColor) {
    switch (_status) {
      case EnsResolveStatus.resolving:
        return activeColor.withValues(alpha: 0.5);
      case EnsResolveStatus.resolved:
        return const Color(0xFF4CAF50);
      case EnsResolveStatus.failed:
        return Colors.orange;
      default:
        return defaultColor.withValues(alpha: 0.3);
    }
  }

  Widget _buildStatusIndicator(Color blueColor, Color subtitleColor) {
    switch (_status) {
      case EnsResolveStatus.resolving:
        return Padding(
          padding: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
          child: SizedBox(
            width: ScreenUtil().setWidth(24),
            height: ScreenUtil().setWidth(24),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(blueColor),
            ),
          ),
        );

      case EnsResolveStatus.resolved:
        return Padding(
          padding: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
          child: Icon(
            Icons.check_circle,
            color: const Color(0xFF4CAF50),
            size: ScreenUtil().setWidth(28),
          ),
        );

      case EnsResolveStatus.failed:
        return Padding(
          padding: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
          child: Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: ScreenUtil().setWidth(28),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// 解析成功卡片：显示头像（若有）、ENS名称→缩短地址、来源链徽章。
  /// 点击整个卡片可复制完整地址。
  Widget _buildResolvedCard(
    Color blueColor,
    Color subtitleColor,
    Color mainTextColor,
  ) {
    final resolvedAddr = _resolveResult!.address!;
    final shortAddr = AddressValidator.getAddressPreview(
      resolvedAddr,
      prefixLength: 6,
      suffixLength: 4,
    );

    return GestureDetector(
      onTap: () => _copyAddress(resolvedAddr),
      child: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(12),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // 头像（有时才显示）或默认的 verified 图标
            _buildAvatarWidget(),
            SizedBox(width: ScreenUtil().setWidth(8)),

            // 地址信息列
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 副标题：Resolved Address
                  Text(
                    S.of(context).g_key_ens_resolved_address,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(2)),
                  // 主体：缩短地址（6+4）
                  Text(
                    shortAddr,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
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
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(4)),
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(8),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: blueColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Text(
                  _resolveResult!.sourceChain!,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.w600,
                    color: blueColor,
                  ),
                ),
              ),

            // 复制图标提示
            SizedBox(width: ScreenUtil().setWidth(6)),
            Icon(
              Icons.copy_rounded,
              color: subtitleColor,
              size: ScreenUtil().setWidth(20),
            ),
          ],
        ),
      ),
    );
  }

  /// 头像组件：如有 URL 则显示网络图片，否则显示 verified 图标
  Widget _buildAvatarWidget() {
    if (_avatarUrl != null) {
      return ClipOval(
        child: Image.network(
          _avatarUrl!,
          width: ScreenUtil().setWidth(32),
          height: ScreenUtil().setWidth(32),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) => _verifiedIcon(),
        ),
      );
    }
    return _verifiedIcon();
  }

  Widget _verifiedIcon() => Icon(
        Icons.verified,
        color: const Color(0xFF4CAF50),
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
