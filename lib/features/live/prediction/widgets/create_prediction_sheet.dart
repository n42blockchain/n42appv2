import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/prediction_providers.dart';

/// 主播"开预测"弹窗：填问题、结果项（≥2）、可选截止时长。
class CreatePredictionSheet extends ConsumerStatefulWidget {
  const CreatePredictionSheet({super.key, required this.roomId});

  final String roomId;

  static Future<void> show(BuildContext context, {required String roomId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CreatePredictionSheet(roomId: roomId),
    );
  }

  @override
  ConsumerState<CreatePredictionSheet> createState() =>
      _CreatePredictionSheetState();
}

class _CreatePredictionSheetState extends ConsumerState<CreatePredictionSheet> {
  final TextEditingController _question = TextEditingController();
  final List<TextEditingController> _outcomes = [
    TextEditingController(text: '是'),
    TextEditingController(text: '否'),
  ];
  int _durationMin = 0; // 0 = 不限
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _question.dispose();
    for (final c in _outcomes) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOutcome() {
    if (_outcomes.length >= 6) return;
    setState(() => _outcomes.add(TextEditingController()));
  }

  void _removeOutcome(int i) {
    if (_outcomes.length <= 2) return;
    setState(() {
      _outcomes.removeAt(i).dispose();
    });
  }

  Future<void> _create() async {
    final question = _question.text.trim();
    final labels = _outcomes
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (question.isEmpty) {
      setState(() => _error = '请填写预测问题');
      return;
    }
    if (labels.length < 2) {
      setState(() => _error = '至少两个有效结果');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final closesAt = _durationMin > 0
          ? DateTime.now().add(Duration(minutes: _durationMin))
          : null;
      await ref
          .read(predictionRepositoryProvider)
          .createMarket(
            roomId: widget.roomId,
            question: question,
            outcomeLabels: labels,
            closesAt: closesAt,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '开启预测',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _field(_question, '预测问题，如：本局谁赢？'),
            const SizedBox(height: 12),
            const Text('结果选项', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            for (var i = 0; i < _outcomes.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: _field(_outcomes[i], '结果 ${i + 1}')),
                    if (_outcomes.length > 2)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.white38,
                        ),
                        onPressed: () => _removeOutcome(i),
                      ),
                  ],
                ),
              ),
            if (_outcomes.length < 6)
              TextButton.icon(
                onPressed: _addOutcome,
                icon: const Icon(Icons.add),
                label: const Text('添加结果'),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('截止', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _durationMin,
                  dropdownColor: const Color(0xFF2A2A33),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('不限（手动停盘）')),
                    DropdownMenuItem(value: 1, child: Text('1 分钟')),
                    DropdownMenuItem(value: 3, child: Text('3 分钟')),
                    DropdownMenuItem(value: 5, child: Text('5 分钟')),
                  ],
                  onChanged: (v) => setState(() => _durationMin = v ?? 0),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _create,
                child: Text(_busy ? '创建中…' : '发布预测'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        isDense: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
      ),
    );
  }
}
