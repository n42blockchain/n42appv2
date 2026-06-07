// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/utils/validation/address_validator.dart';

part 'ens_address_text.dart';

/// ENS 地址显示样式
enum EnsDisplayStyle {
  /// 紧凑模式 - 单行显示，ENS 名称优先
  compact,

  /// 完整模式 - 显示 ENS 名称 + 地址预览
  full,

  /// 详细模式 - 显示 ENS 名称 + 完整地址 + 头像
  detailed,

  /// 仅地址 - 只显示地址（带复制功能）
  addressOnly,
}

/// ENS 地址显示组件
///
/// 统一的地址显示组件，支持：
/// - 自动解析 ENS 名称
/// - 显示 ENS 头像
/// - 多种显示样式
/// - 复制功能
/// - 缓存解析结果
class EnsAddressDisplay extends StatefulWidget {
  /// 钱包地址
  final String address;

  /// 链类型 (ETH, N, BNB 等)
  final String coinType;

  /// 显示样式
  final EnsDisplayStyle style;

  /// 是否显示头像
  final bool showAvatar;

  /// 是否显示复制按钮
  final bool showCopy;

  /// 自定义头像大小
  final double? avatarSize;

  /// 文字颜色
  final Color? textColor;

  /// 副标题颜色
  final Color? subtitleColor;

  /// 文字大小
  final double? fontSize;

  /// 最大行数
  final int maxLines;

  /// 点击回调
  final VoidCallback? onTap;

  /// 已知的 ENS 名称（避免重复解析）
  final String? knownEnsName;

  const EnsAddressDisplay({
    super.key,
    required this.address,
    this.coinType = 'ETH',
    this.style = EnsDisplayStyle.compact,
    this.showAvatar = true,
    this.showCopy = true,
    this.avatarSize,
    this.textColor,
    this.subtitleColor,
    this.fontSize,
    this.maxLines = 1,
    this.onTap,
    this.knownEnsName,
  });

  @override
  State<EnsAddressDisplay> createState() => _EnsAddressDisplayState();
}

class _EnsAddressDisplayState extends State<EnsAddressDisplay> {
  final EnsService _ensService = EnsServiceProvider.instance;

  String? _ensName;
  String? _avatarUrl;
  bool _isLoading = true;
  bool _hasResolved = false;
  int _resolveRequestId = 0;

  @override
  void initState() {
    super.initState();
    _resolveEns();
  }

  @override
  void didUpdateWidget(EnsAddressDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address ||
        oldWidget.coinType != widget.coinType ||
        oldWidget.knownEnsName != widget.knownEnsName) {
      _hasResolved = false;
      _ensName = null;
      _avatarUrl = null;
      _isLoading = true;
      _resolveEns();
    }
  }

  void _markResolved({String? ensName}) {
    if (!mounted) return;
    setState(() {
      _ensName = ensName;
      _isLoading = false;
      _hasResolved = true;
    });
  }

  Future<void> _resolveEns() async {
    if (_hasResolved) return;
    final requestId = ++_resolveRequestId;
    final address = widget.address;
    final coinType = widget.coinType;
    if (widget.address.isEmpty) {
      if (!mounted || requestId != _resolveRequestId) return;
      setState(() => _isLoading = false);
      return;
    }

    // 如果已知 ENS 名称，直接使用
    final knownName = widget.knownEnsName;
    if (knownName != null && knownName.isNotEmpty) {
      if (!mounted ||
          requestId != _resolveRequestId ||
          widget.address != address ||
          widget.coinType != coinType) {
        return;
      }
      _markResolved(ensName: knownName);
      if (widget.showAvatar)
        _fetchAvatar(knownName, requestId, address, coinType);
      return;
    }

    // 检查链是否支持 ENS
    if (!EnsService.chainSupportsEns(widget.coinType)) {
      if (!mounted ||
          requestId != _resolveRequestId ||
          widget.address != address ||
          widget.coinType != coinType) {
        return;
      }
      _markResolved();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ensName = await _ensService.resolveAddress(
        widget.address,
        coinType: widget.coinType,
      );
      if (!mounted ||
          requestId != _resolveRequestId ||
          widget.address != address ||
          widget.coinType != coinType) {
        return;
      }
      _markResolved(ensName: ensName);
      if (ensName != null && widget.showAvatar) {
        _fetchAvatar(ensName, requestId, address, coinType);
      }
    } catch (e) {
      if (!mounted ||
          requestId != _resolveRequestId ||
          widget.address != address ||
          widget.coinType != coinType) {
        return;
      }
      _markResolved();
    }
  }

  Future<void> _fetchAvatar(
    String ensName,
    int requestId,
    String address,
    String coinType,
  ) async {
    try {
      final avatarUrl = await _ensService.getAvatar(ensName);
      if (mounted &&
          requestId == _resolveRequestId &&
          widget.address == address &&
          widget.coinType == coinType &&
          avatarUrl != null) {
        setState(() => _avatarUrl = avatarUrl);
      }
    } catch (e) {
      // 头像获取失败，忽略
    }
  }

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: widget.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_119), // "Copy"
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainTextColor =
        widget.textColor ?? AppColorTokens.of(context).textPrimary;
    final subtitleColor =
        widget.subtitleColor ?? AppColorTokens.of(context).textSubtitle;
    final fontSize = widget.fontSize ?? ScreenUtil().setSp(26);
    final avatarSize = widget.avatarSize ?? ScreenUtil().setWidth(36);

    switch (widget.style) {
      case EnsDisplayStyle.compact:
        return _buildCompact(
          mainTextColor,
          subtitleColor,
          fontSize,
          avatarSize,
        );
      case EnsDisplayStyle.full:
        return _buildFull(mainTextColor, subtitleColor, fontSize, avatarSize);
      case EnsDisplayStyle.detailed:
        return _buildDetailed(
          mainTextColor,
          subtitleColor,
          fontSize,
          avatarSize,
        );
      case EnsDisplayStyle.addressOnly:
        return _buildAddressOnly(mainTextColor, fontSize);
    }
  }

  /// 小型复制图标（compact / full / addressOnly 共用）
  Widget _buildCopyIcon(double size, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
      child: Icon(Icons.copy_rounded, size: size, color: color),
    );
  }

  /// 紧凑模式 - ENS 名称优先，没有则显示地址预览
  Widget _buildCompact(
    Color textColor,
    Color subtitleColor,
    double fontSize,
    double avatarSize,
  ) {
    final displayText =
        _ensName ?? AddressValidator.getAddressPreview(widget.address);

    return GestureDetector(
      onTap: widget.onTap ?? (widget.showCopy ? _copyAddress : null),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showAvatar && _ensName != null) ...[
            _buildAvatar(avatarSize),
            SizedBox(width: ScreenUtil().setWidth(8)),
          ],
          Flexible(
            child: _isLoading
                ? _buildLoadingIndicator(fontSize)
                : Text(
                    displayText,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: _ensName != null ? textColor : subtitleColor,
                      fontWeight: _ensName != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (widget.showCopy) _buildCopyIcon(fontSize, subtitleColor),
        ],
      ),
    );
  }

  /// 完整模式 - 显示 ENS 名称 + 地址预览
  Widget _buildFull(
    Color textColor,
    Color subtitleColor,
    double fontSize,
    double avatarSize,
  ) {
    return GestureDetector(
      onTap: widget.onTap ?? (widget.showCopy ? _copyAddress : null),
      child: Row(
        children: [
          if (widget.showAvatar) ...[
            _buildAvatar(avatarSize),
            SizedBox(width: ScreenUtil().setWidth(12)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  _buildLoadingIndicator(fontSize)
                else if (_ensName != null) ...[
                  Text(
                    _ensName!,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ScreenUtil().setWidth(2)),
                  Text(
                    AddressValidator.getAddressPreview(widget.address),
                    style: TextStyle(
                      fontSize: fontSize * 0.85,
                      color: subtitleColor,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else
                  Text(
                    AddressValidator.getAddressPreview(
                      widget.address,
                      prefixLength: 10,
                      suffixLength: 8,
                    ),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                      fontFamily: 'monospace',
                    ),
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (widget.showCopy) _buildCopyIcon(fontSize, subtitleColor),
        ],
      ),
    );
  }

  /// 详细模式 - 完整显示
  Widget _buildDetailed(
    Color textColor,
    Color subtitleColor,
    double fontSize,
    double avatarSize,
  ) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface.withValues(alpha: 0.5),
          borderRadius: AppRadius.brMd,
          border: Border.all(color: subtitleColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            _buildAvatar(avatarSize * 1.2),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    _buildLoadingIndicator(fontSize)
                  else if (_ensName != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: fontSize,
                          color: const Color(0xFF4CAF50),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(4)),
                        Expanded(
                          child: Text(
                            _ensName!,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                  ],
                  SelectableText(
                    widget.address,
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      color: subtitleColor,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            if (widget.showCopy)
              IconButton(
                onPressed: _copyAddress,
                icon: Icon(
                  Icons.copy_rounded,
                  color: subtitleColor,
                  size: fontSize * 1.2,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  /// 仅地址模式
  Widget _buildAddressOnly(Color textColor, double fontSize) {
    return GestureDetector(
      onTap: widget.showCopy ? _copyAddress : widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.address,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
                fontFamily: 'monospace',
              ),
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.showCopy)
            _buildCopyIcon(fontSize, textColor.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _buildAvatar(double size) {
    final blueColor = AppColorTokens.of(context).brand;
    final initial = _ensName?.isNotEmpty == true
        ? _ensName![0].toUpperCase()
        : (widget.address.length > 2 ? widget.address[2].toUpperCase() : '?');
    final radius = BorderRadius.circular(size / 2);

    Widget defaultAvatar() => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: blueColor.withValues(alpha: 0.2),
        borderRadius: radius,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: blueColor,
          ),
        ),
      ),
    );

    if (_avatarUrl == null) return defaultAvatar();

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        _avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => defaultAvatar(),
      ),
    );
  }

  Widget _buildLoadingIndicator(double fontSize) {
    return SizedBox(
      width: fontSize,
      height: fontSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColorTokens.of(context).brand,
        ),
      ),
    );
  }
}
