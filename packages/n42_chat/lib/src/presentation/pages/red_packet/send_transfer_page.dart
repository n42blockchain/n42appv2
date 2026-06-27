import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../widgets/common/slide_to_pay_button.dart';

class SendTransferPage extends StatefulWidget {
  final String receiverName;
  final String? receiverAvatar;
  final Future<bool> Function(String amount, String token, String? memo) onSend;

  const SendTransferPage({
    super.key,
    required this.receiverName,
    this.receiverAvatar,
    required this.onSend,
  });

  @override
  State<SendTransferPage> createState() => _SendTransferPageState();
}

class _SendTransferPageState extends State<SendTransferPage> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  String _selectedToken = 'CNY';
  var _isSending = false;
  var _submitAttempt = 0;
  RegExp? _cachedAmountRegex;
  String? _cachedAmountPattern;
  final List<String> _tokens = ['CNY', 'ETH', 'USDT', 'BTC'];

  /// 获取当前币种的小数位数限制
  int get _decimalPlaces {
    switch (_selectedToken) {
      case 'BTC':
        return 8; // BTC 最多 8 位小数
      case 'ETH':
        return 18; // ETH 最多 18 位小数
      case 'CNY':
      case 'USDT':
      default:
        return 2; // CNY/USDT 最多 2 位小数
    }
  }

  /// 获取金额输入的正则表达式
  String get _amountPattern =>
      r'^\d*\.?\d{0,' + _decimalPlaces.toString() + r'}';

  RegExp get _amountRegex {
    final pattern = _amountPattern;
    if (_cachedAmountPattern == pattern && _cachedAmountRegex != null) {
      return _cachedAmountRegex!;
    }
    _cachedAmountPattern = pattern;
    _cachedAmountRegex = RegExp(pattern);
    return _cachedAmountRegex!;
  }

  /// 切换币种时验证并截断金额小数位
  void _validateAmountDecimals() {
    final text = _amountController.text;
    if (text.isEmpty) return;

    final dotIndex = text.indexOf('.');
    if (dotIndex == -1) return; // 没有小数点，不需要处理

    final decimals = text.length - dotIndex - 1;
    if (decimals > _decimalPlaces) {
      // 截断多余的小数位
      _amountController.text = text.substring(0, dotIndex + 1 + _decimalPlaces);
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_isSending) return;

    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.commonEnterTransferAmount ??
                'Please enter transfer amount',
          ),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final success = await widget.onSend(
      amount,
      _selectedToken,
      _memoController.text.trim().isNotEmpty
          ? _memoController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSending = false;
      _submitAttempt += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = AppColors.bgOf(isDark);
    final surfaceColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = AppColors.textSecondaryOf(isDark);
    final chipBgColor = AppColors.inputBgOf(isDark);
    final dividerColor = context.dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9A825),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.close, color: Colors.white, size: 22),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context)?.commonTransfer ?? 'Transfer',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 接收者信息
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark
                        ? Colors.grey[700]
                        : Colors.grey[200],
                    backgroundImage: widget.receiverAvatar != null
                        ? NetworkImage(widget.receiverAvatar!)
                        : null,
                    child: widget.receiverAvatar == null
                        ? Text(
                            widget.receiverName.isNotEmpty
                                ? widget.receiverName[0]
                                : '?',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context)?.commonTransferTo ?? 'Transfer to',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.receiverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 金额输入卡片
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)?.commonTransferAmount ?? 'Transfer Amount',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, height: 1.3, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 币种选择
                      GestureDetector(
                        onTap: _showTokenPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: chipBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedToken,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.3,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                                color: textColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 金额输入
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(_amountRegex),
                          ],
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                S.of(context)?.transferAmountHintZero ?? '0.00',
                            hintStyle: TextStyle(color: secondaryTextColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(height: 1, color: dividerColor),
                  const SizedBox(height: 16),

                  // 转账说明
                  TextField(
                    controller: _memoController,
                    maxLength: 50,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText:
                          S.of(context)?.commonAddTransferNote ??
                          'Add transfer note',
                      hintStyle: TextStyle(
                        color: secondaryTextColor.withAlpha(153),
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 滑动确认转账（微信支付风格 — 防止误触）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SlideToPayButton(
                key: ValueKey('send_transfer_submit_$_submitAttempt'),
                label:
                    S.of(context)?.slideToPayLabel ?? '→→→  Slide to confirm',
                confirmingLabel:
                    S.of(context)?.slideToPayConfirming ?? 'Confirming...',
                trackColor: const Color(0xFFF9A825),
                onConfirmed: () {
                  unawaited(_send());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTokenPicker() {
    final surfaceColor = context.surfaceColor;
    final textColor = context.textPrimary;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                S.of(ctx)?.chatSelectCurrency ?? 'Select currency',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            ..._tokens.map(
              (token) => ListTile(
                title: Text(token, style: TextStyle(color: textColor)),
                trailing: _selectedToken == token
                    ? const Icon(Icons.check, color: Color(0xFFF9A825))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedToken = token;
                    // 切换币种时验证金额小数位
                    _validateAmountDecimals();
                  });
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 发转账弹窗（兼容性包装，自动跳转到全屏页面）
class SendTransferDialog extends StatefulWidget {
  final String receiverName;
  final String? receiverAvatar;
  final Future<bool> Function(String amount, String token, String? memo) onSend;

  const SendTransferDialog({
    super.key,
    required this.receiverName,
    this.receiverAvatar,
    required this.onSend,
  });

  @override
  State<SendTransferDialog> createState() => _SendTransferDialogState();
}

class _SendTransferDialogState extends State<SendTransferDialog> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigated || !mounted) return;
      _navigated = true;
      final navigator = Navigator.of(context);
      navigator.pop();
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => SendTransferPage(
            receiverName: widget.receiverName,
            receiverAvatar: widget.receiverAvatar,
            onSend: widget.onSend,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// 红包详情页面（仿微信）
