import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/a11y_l10n.dart';
import 'slash_command_picker.dart';
import 'scheduled_send_picker.dart';
import '../../../core/utils/debug_log.dart';

/// 语音录音结果回调
typedef VoiceRecordCallback = void Function(String path, Duration duration);

/// 录音状态回调
typedef RecordingStateCallback =
    void Function(bool isRecording, bool isCancelled, Duration duration);

class _MarkdownFormatAction {
  final String prefix;
  final String suffix;
  final IconData? icon;
  final String? label;
  final String tooltip;
  final bool bold;
  final bool italic;
  final bool strikethrough;

  const _MarkdownFormatAction({
    required this.prefix,
    this.suffix = '',
    required this.tooltip,
    this.icon,
    this.label,
    this.bold = false,
    this.italic = false,
    this.strikethrough = false,
  });
}

const List<_MarkdownFormatAction> _formatActions = [
  _MarkdownFormatAction(
    prefix: '**',
    suffix: '**',
    tooltip: 'Bold',
    label: 'B',
    bold: true,
  ),
  _MarkdownFormatAction(
    prefix: '*',
    suffix: '*',
    tooltip: 'Italic',
    label: 'I',
    italic: true,
  ),
  _MarkdownFormatAction(
    prefix: '~~',
    suffix: '~~',
    tooltip: 'Strikethrough',
    label: 'S',
    strikethrough: true,
  ),
  _MarkdownFormatAction(
    prefix: '`',
    suffix: '`',
    tooltip: 'Inline code',
    label: '<>',
  ),
  _MarkdownFormatAction(
    prefix: '```dart\n',
    suffix: '\n```',
    tooltip: 'Code block',
    label: '{}',
  ),
  _MarkdownFormatAction(
    prefix: '\n> ',
    tooltip: 'Quote',
    icon: Icons.format_quote,
  ),
  _MarkdownFormatAction(
    prefix: '\n- [ ] ',
    tooltip: 'Checklist item',
    icon: Icons.check_box_outlined,
  ),
  _MarkdownFormatAction(
    prefix: '\n- ',
    tooltip: 'Bullet list',
    icon: Icons.format_list_bulleted,
  ),
  _MarkdownFormatAction(
    prefix: '\n1. ',
    tooltip: 'Numbered list',
    icon: Icons.format_list_numbered,
  ),
  _MarkdownFormatAction(
    prefix: '[',
    suffix: '](https://)',
    tooltip: 'Link',
    icon: Icons.link,
  ),
  _MarkdownFormatAction(
    prefix: '\n| Column | Value |\n| --- | --- |\n| Item | Detail |\n',
    tooltip: 'Table',
    label: '| |',
  ),
  _MarkdownFormatAction(
    prefix:
        '\n### Meeting Notes\n- Date: \n- Attendees: \n- Agenda:\n  - \n- Notes:\n- Action Items:\n  - [ ] \n',
    tooltip: 'Meeting template',
    icon: Icons.calendar_today_outlined,
  ),
];

/// 聊天输入栏
///
/// 特点：
/// - 语音/键盘切换
/// - 按住录音，松开发送
/// - 表情按钮
/// - 更多功能按钮
/// - 发送按钮（有内容时显示）
/// - 自动增高
class ChatInputBar extends StatefulWidget {
  /// 发送文本回调
  final ValueChanged<String>? onSendText;

  /// 发送语音回调
  final VoiceRecordCallback? onSendVoice;

  /// 录音状态变化回调（用于显示全屏录音浮层）
  final RecordingStateCallback? onRecordingStateChanged;

  /// 语音按钮点击回调（用于切换模式）
  final VoidCallback? onVoicePressed;

  /// 表情按钮点击回调
  final VoidCallback? onEmojiPressed;

  /// 更多按钮点击回调
  final VoidCallback? onMorePressed;

  /// 输入框为空时显示的相机快捷入口
  final VoidCallback? onCameraPressed;

  /// 快捷回复按钮点击回调
  final VoidCallback? onQuickReplyPressed;

  /// 定时发送回调（长按发送按钮触发）
  final void Function(DateTime scheduledAt)? onScheduledSend;

  /// 输入变化回调
  final ValueChanged<String>? onChanged;

  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChanged;

  /// 占位文字
  final String? hintText;

  /// 是否显示语音按钮
  final bool showVoiceButton;

  /// 是否显示表情按钮
  final bool showEmojiButton;

  /// 是否显示更多按钮
  final bool showMoreButton;

  /// 附件扩展面板是否已打开；打开时附件按钮切换为键盘入口。
  final bool isMorePanelOpen;

  /// 是否显示快捷回复按钮
  final bool showQuickReplyButton;

  /// 是否禁用
  final bool enabled;

  /// 最大行数
  final int maxLines;

  /// 文本控制器
  final TextEditingController? controller;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 斜杠命令 /poll 回调（由 UI 层打开投票对话框）
  final VoidCallback? onCommandPoll;

  /// 语音服务（测试或宿主注入）
  final VoiceService? voiceService;

  const ChatInputBar({
    super.key,
    this.onSendText,
    this.onSendVoice,
    this.onRecordingStateChanged,
    this.onVoicePressed,
    this.onEmojiPressed,
    this.onMorePressed,
    this.onCameraPressed,
    this.onQuickReplyPressed,
    this.onScheduledSend,
    this.onChanged,
    this.onFocusChanged,
    this.hintText,
    this.showVoiceButton = true,
    this.showEmojiButton = true,
    this.showMoreButton = true,
    this.isMorePanelOpen = false,
    this.showQuickReplyButton = true,
    this.enabled = true,
    this.maxLines = 5,
    this.controller,
    this.focusNode,
    this.onCommandPoll,
    this.voiceService,
  });

  @override
  State<ChatInputBar> createState() => ChatInputBarState();
}

class ChatInputBarState extends State<ChatInputBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isVoiceMode = false;
  bool _hasText = false;
  final bool _showFormattingBar = false;
  bool _showCommandPicker = false;
  String _commandQuery = '';

  // 录音状态
  bool _isRecording = false;
  bool _cancelRecording = false;
  Duration _recordingDuration = Duration.zero;
  StreamSubscription<RecordingState>? _recordingSubscription;

  late final VoiceService _voiceService;
  late final bool _ownsVoiceService;

  @override
  void initState() {
    super.initState();
    _voiceService =
        widget.voiceService ??
        (getIt.isRegistered<VoiceService>()
            ? getIt<VoiceService>()
            : VoiceService());
    _ownsVoiceService =
        widget.voiceService == null && !getIt.isRegistered<VoiceService>();
    unawaited(_voiceService.initialize());

    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = _controller.text.isNotEmpty;

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    // 监听录音状态
    _recordingSubscription = _voiceService.recordingStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _recordingDuration = state.duration;
        });
        // 通知父组件录音状态变化
        widget.onRecordingStateChanged?.call(
          _isRecording,
          _cancelRecording,
          state.duration,
        );
      }
    });
  }

  @override
  void dispose() {
    _recordingSubscription?.cancel();
    if (_ownsVoiceService) {
      unawaited(_voiceService.dispose());
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);

    // 斜杠命令检测：以 "/" 开头且无空格时显示选择器
    final text = _controller.text;
    final showPicker = text.startsWith('/') && !text.contains(' ');
    final newQuery = showPicker ? text.substring(1) : '';
    if (_showCommandPicker != showPicker || _commandQuery != newQuery) {
      setState(() {
        _showCommandPicker = showPicker;
        _commandQuery = newQuery;
      });
    }
  }

  void _handleCommandSelect(SlashCommandItem item) {
    setState(() => _showCommandPicker = false);
    if (item.command == 'poll') {
      _controller.clear();
      widget.onCommandPoll?.call();
    } else if (item.command == 'announce') {
      const prefix = '/announce ';
      _controller.value = const TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    } else if (item.command == 'welcome') {
      const prefix = '/welcome ';
      _controller.value = const TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    } else if (item.command == 'price') {
      // /price 需要参数，填入前缀让用户继续输入 token 符号
      const prefix = '/price ';
      _controller.value = const TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
      _focusNode.requestFocus();
    } else {
      // /help, /balance, /chains 等无参数命令：直接填入并提交
      final cmd = '/${item.command}';
      _controller.value = TextEditingValue(
        text: cmd,
        selection: TextSelection.collapsed(offset: cmd.length),
      );
      // 延迟一帧后触发发送，让 UI 更新先行
      Future<void>.microtask(() {
        widget.onSendText?.call(cmd);
        _controller.clear();
      });
    }
  }

  void _onFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _toggleVoiceMode() {
    final switchingToVoice = !_isVoiceMode;
    setState(() {
      _isVoiceMode = switchingToVoice;
    });
    if (switchingToVoice) {
      _focusNode.unfocus();
      // 切换到语音模式时预请求麦克风权限（微信方案）
      _preRequestMicrophonePermission();
    }
    widget.onVoicePressed?.call();
  }

  /// 预请求麦克风权限
  ///
  /// 在切换到语音模式时调用，避免用户按住录音时才弹出权限对话框打断手势。
  /// 如果权限被永久拒绝，弹出引导对话框让用户去系统设置开启。
  Future<void> _preRequestMicrophonePermission() async {
    final status = await _voiceService.checkPermissionStatus();
    if (status.isGranted) return;

    if (status.isPermanentlyDenied) {
      if (mounted) _showMicrophonePermissionDeniedDialog();
      return;
    }

    // 首次或之前拒绝过（非永久），直接请求
    final granted = await _voiceService.requestPermission();
    if (!granted && mounted) {
      // 请求后仍被拒绝，再次检查是否变为永久拒绝
      final newStatus = await _voiceService.checkPermissionStatus();
      if (newStatus.isPermanentlyDenied) {
        _showMicrophonePermissionDeniedDialog();
      }
    }
  }

  /// 显示麦克风权限被永久拒绝时的引导对话框
  void _showMicrophonePermissionDeniedDialog() {
    final l10n = S.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n?.commonMicrophonePermissionRequired ??
              'Microphone Permission Required',
        ),
        content: Text(
          l10n?.chatMicrophonePermissionDeniedPermanent ??
              'Microphone permission has been denied. Please enable it in system settings to use voice messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n?.chatGoToSettings ?? 'Go to Settings'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final rawText = _controller.text;
    if (rawText.trim().isNotEmpty) {
      widget.onSendText?.call(rawText);
      _controller.clear();
    }
  }

  Future<void> _startRecording() async {
    try {
      final started = await _voiceService.startRecording();
      if (!mounted) return;
      if (started) {
        setState(() {
          _isRecording = true;
          _cancelRecording = false;
          _recordingDuration = Duration.zero;
        });
        // 通知父组件
        widget.onRecordingStateChanged?.call(true, false, Duration.zero);
      } else {
        // 显示权限提示
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.commonMicrophonePermissionRequired ??
                    'Please allow microphone permission',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        }
      }
    } catch (e) {
      debugLog('Start recording error: $e');
      _forceResetRecordingState();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)?.commonStartRecordingFailed ?? 'Start recording failed'}: $e',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      // 确保状态被重置
      _forceResetRecordingState();
      return;
    }

    final wasCancelled = _cancelRecording;

    try {
      if (wasCancelled) {
        await _voiceService.cancelRecording();
        _forceResetRecordingState();
        return;
      }

      final result = await _voiceService.stopRecording();

      // 先重置状态
      _forceResetRecordingState();

      if (result != null && result.duration.inSeconds >= 1) {
        widget.onSendVoice?.call(result.path, result.duration);
      } else if (result != null) {
        // 录音时间太短
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.commonRecordingTooShort ?? 'Recording too short',
              ),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        }
      }
    } catch (e) {
      debugLog('Stop recording error: $e');
      _forceResetRecordingState();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)?.commonStopRecordingFailed ?? 'Stop recording failed'}: $e',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    }
  }

  /// 强制重置录音状态
  void _forceResetRecordingState() {
    setState(() {
      _isRecording = false;
      _cancelRecording = false;
      _recordingDuration = Duration.zero;
    });
    // 通知父组件录音结束
    widget.onRecordingStateChanged?.call(false, false, Duration.zero);
  }

  /// 公共方法：从外部取消录音
  ///
  /// 当用户点击外部的取消按钮时调用此方法
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _voiceService.cancelRecording();
    } catch (e) {
      debugLog('Cancel recording error: $e');
    } finally {
      _forceResetRecordingState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: context.inputBarColor,
        border: Border(
          top: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 斜杠命令选择器
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: _showCommandPicker
                  ? SlashCommandPicker(
                      query: _commandQuery,
                      onSelect: _handleCommandSelect,
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: _showFormattingBar
                  ? _buildFormattingBar()
                  : const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 语音/键盘切换
                  if (widget.showVoiceButton)
                    _buildIconButton(
                      icon: _isVoiceMode ? Icons.keyboard : Icons.mic,
                      onPressed: _toggleVoiceMode,
                      semanticLabel: _isVoiceMode
                          ? A11yL10n.of(context).switchToKeyboard
                          : A11yL10n.of(context).voice,
                    ),

                  // 输入区域
                  Expanded(
                    child: _isVoiceMode
                        ? _buildVoiceButton()
                        : _buildTextField(isDark),
                  ),

                  // 快捷回复
                  if (widget.showQuickReplyButton)
                    _buildIconButton(
                      icon: Icons.flash_on_outlined,
                      onPressed: widget.onQuickReplyPressed,
                      semanticLabel: A11yL10n.of(context).quickReply,
                    ),

                  // 表情
                  if (widget.showEmojiButton)
                    _buildIconButton(
                      icon: Icons.emoji_emotions_outlined,
                      onPressed: widget.onEmojiPressed,
                      semanticLabel: A11yL10n.of(context).emoji,
                    ),

                  // 与主流聊天应用一致：无文本时保留相机快捷入口。
                  if (!_hasText && widget.onCameraPressed != null)
                    _buildIconButton(
                      icon: Icons.camera_alt_outlined,
                      onPressed: widget.onCameraPressed,
                      semanticLabel: S.of(context)?.commonTakePhoto ?? 'Camera',
                    ),

                  // 附件/更多 或 发送
                  _hasText
                      ? _buildSendButton()
                      : (widget.showMoreButton
                            ? _buildIconButton(
                                icon: widget.isMorePanelOpen
                                    ? Icons.keyboard_alt_outlined
                                    : Icons.attach_file,
                                onPressed: widget.onMorePressed,
                                semanticLabel: widget.isMorePanelOpen
                                    ? A11yL10n.of(context).switchToKeyboard
                                    : A11yL10n.of(context).attachments,
                              )
                            : const SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattingBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _formatActions.length,
        itemBuilder: (context, index) {
          return _buildFormatButton(_formatActions[index]);
        },
      ),
    );
  }

  Widget _buildFormatButton(_MarkdownFormatAction action) {
    return Tooltip(
      message: action.tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _applyMarkdownFormat(action.prefix, action.suffix),
        child: Container(
          width: 40,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          alignment: Alignment.center,
          child: action.icon != null
              ? Icon(action.icon, size: 18)
              : Text(
                  action.label ?? '',
                  style: TextStyle(
                    fontWeight: action.bold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontStyle: action.italic
                        ? FontStyle.italic
                        : FontStyle.normal,
                    decoration: action.strikethrough
                        ? TextDecoration.lineThrough
                        : null,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }

  void _applyMarkdownFormat(String prefix, String suffix) {
    final ctrl = _controller;
    final sel = ctrl.selection;
    final text = ctrl.text;

    if (sel.isValid && !sel.isCollapsed) {
      // 有选中文本 → 包裹
      final selected = text.substring(sel.start, sel.end);
      final newText = text.replaceRange(
        sel.start,
        sel.end,
        '$prefix$selected$suffix',
      );
      ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: sel.end + prefix.length + suffix.length,
        ),
      );
    } else {
      // 无选中 → 插入模板，光标停在 prefix 之后（中间）
      final pos = sel.isValid ? sel.baseOffset : text.length;
      final newText = text.replaceRange(pos, pos, '$prefix$suffix');
      ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: pos + prefix.length),
      );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? semanticLabel,
  }) {
    final color = context.textSecondary;
    final effectiveCallback = widget.enabled ? onPressed : null;
    return Semantics(
      button: true,
      enabled: effectiveCallback != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: effectiveCallback,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
          child: Icon(
            icon,
            size: 22,
            color: effectiveCallback != null
                ? color
                : color.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _sendMessage(),
        style: TextStyle(fontSize: 16, color: context.textPrimary),
        decoration: InputDecoration(
          hintText:
              widget.hintText ??
              S.of(context)?.commonSendMessage ??
              'Send message',
          hintStyle: const TextStyle(
            fontSize: 16,
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    // 使用 Listener 直接处理 pointer events，比 GestureDetector 更可靠
    return Semantics(
      button: true,
      label: A11yL10n.of(context).holdToTalk,
      child: _buildVoiceListener(),
    );
  }

  Widget _buildVoiceListener() {
    return Listener(
      onPointerDown: (_) => _startRecording(),
      onPointerUp: (_) => _stopRecording(),
      onPointerCancel: (_) {
        // 取消录音（例如来电打断）
        if (_isRecording) {
          _cancelRecording = true;
          _stopRecording();
        }
      },
      onPointerMove: (event) {
        if (_isRecording) {
          // 计算相对于按钮的偏移，向上滑动超过 50 像素取消
          final dy = event.localPosition.dy;
          final shouldCancel = dy < -50;
          if (_cancelRecording != shouldCancel) {
            setState(() {
              _cancelRecording = shouldCancel;
            });
            widget.onRecordingStateChanged?.call(
              _isRecording,
              shouldCancel,
              _recordingDuration,
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 40,
        decoration: BoxDecoration(
          color: _isRecording
              ? (_cancelRecording
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1))
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(4),
          border: _isRecording
              ? Border.all(
                  color: _cancelRecording ? AppColors.error : AppColors.primary,
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: Text(
            _isRecording
                ? (_cancelRecording
                      ? (S.of(context)?.chatReleaseToCancel ??
                            'Release to cancel')
                      : (S.of(context)?.chatReleaseToSend ??
                            'Release to send, swipe up to cancel'))
                : (S.of(context)?.commonHoldToTalk ?? 'Hold to talk'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _isRecording
                  ? (_cancelRecording ? AppColors.error : AppColors.primary)
                  : context.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: A11yL10n.of(context).send,
      excludeSemantics: true,
      child: GestureDetector(
        onLongPress: widget.enabled && widget.onScheduledSend != null
            ? () async {
                if (_controller.text.trim().isEmpty) return;
                final scheduledAt = await showScheduledSendPicker(context);
                if (!mounted || scheduledAt == null) return;
                widget.onScheduledSend?.call(scheduledAt);
                if (!mounted) return;
                _controller.clear();
              }
            : null,
        child: InkWell(
          onTap: widget.enabled ? _sendMessage : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Icon(
              Icons.send,
              size: 22,
              color: widget.enabled
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
