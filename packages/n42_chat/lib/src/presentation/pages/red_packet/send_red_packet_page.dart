import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';

class SendRedPacketPage extends StatefulWidget {
  /// 接收者名称
  final String receiverName;
  
  /// 是否是群聊
  final bool isGroup;
  
  /// 群成员数量
  final int memberCount;
  
  /// 发送回调
  final Future<bool> Function(String amount, String token, String greeting, int count, bool isLucky) onSend;
  
  const SendRedPacketPage({
    super.key,
    required this.receiverName,
    this.isGroup = false,
    this.memberCount = 1,
    required this.onSend,
  });
  
  @override
  State<SendRedPacketPage> createState() => _SendRedPacketPageState();
}

class _SendRedPacketPageState extends State<SendRedPacketPage> {
  final _amountController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  late final TextEditingController _greetingController;
  
  String _selectedToken = 'CNY';
  bool _isLucky = false;
  var _isSending = false;
  int _selectedCoverIndex = 0;
  RegExp? _cachedAmountRegex;
  String? _cachedAmountPattern;

  final List<String> _tokens = ['CNY', 'ETH', 'USDT', 'BTC'];

  /// 可用的红包封面
  static const List<_RedPacketCover> _covers = [
    _RedPacketCover(
      id: 'default',
      colors: [Color(0xFFE64340), Color(0xFFD63030)],
      name: 'Classic Red',
    ),
    _RedPacketCover(
      id: 'gold',
      colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
      name: 'Golden',
    ),
    _RedPacketCover(
      id: 'purple',
      colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      name: 'Purple',
    ),
    _RedPacketCover(
      id: 'blue',
      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
      name: 'Ocean Blue',
    ),
    _RedPacketCover(
      id: 'green',
      colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      name: 'Nature Green',
    ),
    _RedPacketCover(
      id: 'pink',
      colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
      name: 'Rose Pink',
    ),
  ];

  /// 常用表情列表
  static const List<String> _emojis = [
    '🎉', '🎊', '💰', '🧧', '💵', '💴', '💶', '💷',
    '🤑', '💸', '🏆', '🎁', '🎈', '🎀', '✨', '⭐',
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
    '😊', '😄', '🥳', '😎', '🤩', '😍', '🙏', '👍',
    '🐉', '🐅', '🐇', '🐕', '🐖', '🐂', '🐏', '🐔',
  ];
  
  double get _amount {
    final text = _amountController.text.trim();
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }
  
  /// 获取当前币种的小数位数限制
  int get _decimalPlaces {
    switch (_selectedToken) {
      case 'BTC':
        return 8;  // BTC 最多 8 位小数
      case 'ETH':
        return 18; // ETH 最多 18 位小数
      case 'CNY':
      case 'USDT':
      default:
        return 2;  // CNY/USDT 最多 2 位小数
    }
  }
  
  /// 获取金额输入的正则表达式
  String get _amountPattern => r'^\d*\.?\d{0,' + _decimalPlaces.toString() + r'}';

  RegExp get _amountRegex {
    final pattern = _amountPattern;
    if (_cachedAmountPattern == pattern && _cachedAmountRegex != null) {
      return _cachedAmountRegex!;
    }
    _cachedAmountPattern = pattern;
    _cachedAmountRegex = RegExp(pattern);
    return _cachedAmountRegex!;
  }

  String get _currencySymbol {
    switch (_selectedToken) {
      case 'CNY':
        return '¥';
      case 'ETH':
        return 'Ξ';
      case 'BTC':
        return '₿';
      default:
        return '\$';
    }
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
  void initState() {
    super.initState();
    _greetingController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_greetingController.text.isEmpty) {
      _greetingController.text = S.of(context)?.commonRedPacketDefaultGreeting ?? 'Best wishes';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _countController.dispose();
    _greetingController.dispose();
    super.dispose();
  }
  
  Future<void> _send() async {
    if (_isSending) return;

    final amount = _amountController.text.trim();
    if (amount.isEmpty || _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.commonEnterAmount ?? 'Enter amount')),
      );
      return;
    }

    final count = int.tryParse(_countController.text) ?? 1;
    if (widget.isGroup && _isLucky && count < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.commonRedPacketCountMin ?? 'At least 1 red packet required')),
      );
      return;
    }

    setState(() => _isSending = true);

    final success = await widget.onSend(
      amount,
      _selectedToken,
      _greetingController.text.trim(),
      count,
      _isLucky,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSending = false);
  }
  
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = context.isDarkMode;
    final bgColor = context.pageBackground;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: textColor, size: 20),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context)?.commonSendRedPacket ?? 'Send Red Packet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 48),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       MediaQuery.of(context).padding.top - 
                       kToolbarHeight - 
                       (bottomInset > 0 ? bottomInset : 48),
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // 金额输入
                _buildMenuItem(
                  context: context,
                  label: S.of(context)?.commonTransferAmount ?? 'Amount',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 代币选择
                      GestureDetector(
                        onTap: _showTokenPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.dividerThinDark : AppColors.dividerThin.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedToken,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: secondaryTextColor, fontSize: 14, height: 1.3),
                              ),
                              Icon(Icons.arrow_drop_down, color: secondaryTextColor, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(_amountRegex),
                          ],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: _decimalPlaces > 2 ? '0.0' : (S.of(context)?.transferAmountHintZero ?? '0.00'),
                            hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 祝福语输入
                _buildMenuItem(
                  context: context,
                  child: TextField(
                    controller: _greetingController,
                    maxLength: 30,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: S.of(context)?.commonRedPacketDefaultGreeting ?? 'Best wishes',
                      hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined, color: secondaryTextColor),
                        onPressed: _showEmojiPicker,
                      ),
                    ),
                  ),
                ),
                
                // 红包封面
                _buildMenuItem(
                  context: context,
                  onTap: _showCoverPicker,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context)?.commonRedPacketCover ?? 'Red Packet Cover',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _covers[_selectedCoverIndex].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: secondaryTextColor, fontSize: 13, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      // 封面预览
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: _covers[_selectedCoverIndex].colors,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: _buildRedPacketIcon(28, Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(AppIcons.chevron, color: secondaryTextColor),
                    ],
                  ),
                ),
                
                // 群聊选项
                if (widget.isGroup) ...[
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context: context,
                    label: S.of(context)?.commonRedPacketType ?? 'Red Packet Type',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypeChip(context, S.of(context)?.commonNormalRedPacket ?? 'Normal', !_isLucky, () {
                          setState(() => _isLucky = false);
                        }),
                        const SizedBox(width: 8),
                        _buildTypeChip(context, S.of(context)?.commonLuckyRedPacket ?? 'Lucky', _isLucky, () {
                          setState(() => _isLucky = true);
                        }),
                      ],
                    ),
                  ),
                  if (_isLucky)
                    _buildMenuItem(
                      context: context,
                      label: S.of(context)?.commonRedPacketCount ?? 'Red Packet Count',
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _countController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.right,
                          style: TextStyle(color: textColor, fontSize: 16),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            suffixText: S.of(context)?.commonPieces ?? 'pcs',
                            suffixStyle: TextStyle(color: secondaryTextColor, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                ],
                
                const Spacer(),
                
                const SizedBox(height: 24),

                // 金额显示
                Text(
                  '$_currencySymbol ${_amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 24),

                // 发送按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _amount > 0 && !_isSending
                          ? () {
                              unawaited(_send());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85D04),
                        disabledBackgroundColor: isDark ? const Color(0xFF4A3020) : const Color(0xFFE8D0C0),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: isDark ? Colors.white38 : Colors.white60,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              S.of(context)?.commonPutMoneyInRedPacket ?? 'Put money in',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 底部提示
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    S.of(context)?.commonRedPacketRefundNotice ?? 'Unclaimed red packets will be refunded after 24 hours',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryTextColor.withValues(alpha: 0.6),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 红包图标（红色方形背景，金色¥符号）
  Widget _buildRedPacketIcon(double size, Color symbolColor) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 金色圆形背景
          Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
          ),
          // ¥符号
          Text(
            '¥',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4380D),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required BuildContext context,
    String? label,
    Widget? trailing,
    Widget? child,
    VoidCallback? onTap,
  }) {
    final surfaceColor = context.surfaceColor;
    final textColor = context.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: child ?? Row(
          children: [
            if (label != null)
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
                ),
              ),
            const SizedBox(width: 8),
            ?trailing,
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeChip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final isDark = context.isDarkMode;
    final secondaryTextColor = context.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE85D04)
              : (isDark ? AppColors.dividerThinDark : AppColors.dividerThin.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : secondaryTextColor,
            fontSize: 13,
            height: 1.3,
          ),
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
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ..._tokens.map((token) => ListTile(
              title: Text(token, style: TextStyle(color: textColor)),
              trailing: _selectedToken == token
                  ? const Icon(Icons.check, color: Color(0xFFE85D04))
                  : null,
              onTap: () {
                setState(() {
                  _selectedToken = token;
                  // 切换币种时验证金额小数位
                  _validateAmountDecimals();
                });
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 显示表情选择器
  void _showEmojiPicker() {
    final isDark = context.isDarkMode;
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(ctx)?.chatSelectEmoji ?? 'Select Emoji',
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // 在当前光标位置插入表情
                      final text = _greetingController.text;
                      final selection = _greetingController.selection;
                      final newText = text.replaceRange(
                        selection.start,
                        selection.end,
                        _emojis[index],
                      );
                      _greetingController.text = newText;
                      _greetingController.selection = TextSelection.fromPosition(
                        TextPosition(offset: selection.start + _emojis[index].length),
                      );
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.dividerThinDark : AppColors.dividerThin.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _emojis[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 显示红包封面选择器
  void _showCoverPicker() {
    final surfaceColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // 标题
              Text(
                S.of(ctx)?.chatSelectRedPacketCover ?? 'Select Cover',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              // 封面网格
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _covers.length,
                    itemBuilder: (context, index) {
                      final cover = _covers[index];
                      final isSelected = _selectedCoverIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCoverIndex = index;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: cover.colors,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? Border.all(color: const Color(0xFFE85D04), width: 3)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // 红包图标
                                    Center(
                                      child: _buildRedPacketIcon(36, Colors.white70),
                                    ),
                                    // 选中标记
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE85D04),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cover.name,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFE85D04) : secondaryTextColor,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// 红包封面数据
class _RedPacketCover {
  final String id;
  final List<Color> colors;
  final String name;

  const _RedPacketCover({
    required this.id,
    required this.colors,
    required this.name,
  });
}

/// 发红包弹窗（保留兼容性）
