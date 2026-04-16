import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';

enum PollComposerAction { sendNow, schedule }

class PollComposerResult {
  final String question;
  final List<String> options;
  final int maxSelections;
  final bool isAnonymous;
  final PollComposerAction action;

  const PollComposerResult({
    required this.question,
    required this.options,
    required this.maxSelections,
    required this.isAnonymous,
    required this.action,
  });
}

class PollCreateSheet extends StatefulWidget {
  final bool allowScheduling;

  const PollCreateSheet({super.key, this.allowScheduling = true});

  @override
  State<PollCreateSheet> createState() => _PollCreateSheetState();
}

class _PollCreateSheetState extends State<PollCreateSheet> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _maxSelections = 1; // 1 = 单选, 0 = 多选（不限）
  bool _isAnonymous = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _submit(PollComposerAction action) {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.chatPleaseEnterQuestion ?? 'Please enter poll question')),
      );
      return;
    }

    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((o) => o.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.chatAtLeastTwoOptions ?? 'At least 2 options required')),
      );
      return;
    }

    Navigator.pop(
      context,
      PollComposerResult(
        question: question,
        options: options,
        maxSelections: _maxSelections,
        isAnonymous: _isAnonymous,
        action: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    S.of(context)?.commonCancel ?? 'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    S.of(context)?.chatCreatePollTitle ?? 'Create Poll',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.allowScheduling)
                      TextButton(
                        onPressed: () => _submit(PollComposerAction.schedule),
                        child: const Text(
                          'Schedule',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: () => _submit(PollComposerAction.sendNow),
                      child: Text(
                        S.of(context)?.chatSubmitPoll ?? 'Submit',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomPadding + 16,
              ),
              children: [
                // 问题输入
                Text(
                  S.of(context)?.chatPollQuestionLabel ?? 'Poll Question',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _questionController,
                  maxLines: 2,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: S.of(context)?.chatEnterPollQuestionHint ?? 'Please enter poll question',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                  ),
                ),

                const SizedBox(height: 24),

                // 选项输入
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context)?.chatPollOptionsLabel ?? 'Poll Options',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      '${_optionControllers.length}/10',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...List.generate(_optionControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _optionControllers[index],
                            maxLength: 50,
                            decoration: InputDecoration(
                              hintText: S.of(context)?.chatOptionHintWithIndex(index + 1) ?? 'Option ${index + 1}',
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        if (_optionControllers.length > 2)
                          IconButton(
                            onPressed: () => _removeOption(index),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                            iconSize: 20,
                          ),
                      ],
                    ),
                  );
                }),

                if (_optionControllers.length < 10)
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(S.of(context)?.chatAddOptionButton ?? 'Add Option'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),

                const SizedBox(height: 24),

                // 投票类型
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context)?.chatPollSettingsLabel ?? 'Poll Settings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 单选/多选
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              S.of(context)?.chatSelectionType ?? 'Selection Type',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: SegmentedButton<int>(
                              segments: [
                                ButtonSegment(value: 1, label: Text(S.of(context)?.chatSingleChoiceLabel ?? 'Single', overflow: TextOverflow.ellipsis)),
                                ButtonSegment(value: 0, label: Text(S.of(context)?.chatMultiChoiceLabel ?? 'Multi', overflow: TextOverflow.ellipsis)),
                              ],
                              selected: {_maxSelections},
                              onSelectionChanged: (value) {
                                setState(() {
                                  _maxSelections = value.first;
                                });
                              },
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // 匿名投票
                      Row(
                        children: [
                          Text(S.of(context)?.chatAnonymousPollSwitch ?? 'Anonymous Poll'),
                          const Spacer(),
                          Switch(
                            value: _isAnonymous,
                            onChanged: (value) {
                              setState(() {
                                _isAnonymous = value;
                              });
                            },
                            activeTrackColor: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 提示信息
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          S.of(context)?.chatPollHint ?? 'Poll will be displayed in chat. Group members can vote.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 联系人选择对话框
