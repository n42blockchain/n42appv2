import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import '../providers/prediction_providers.dart';

/// 主播"开预测"弹窗：填问题、结果项（≥2）、可选截止时长。
class CreatePredictionSheet extends ConsumerStatefulWidget {
  const CreatePredictionSheet({super.key, required this.roomId});

  final String roomId;

  static Future<void> show(BuildContext context, {required String roomId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorTokens.of(context).bgElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brSheetTop),
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
    final c = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.space8,
        right: AppSpacing.space8,
        top: AppSpacing.space8,
        bottom: AppSpacing.space8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '开启预测',
              style: AppTypography.title.copyWith(color: c.textPrimary),
            ),
            SizedBox(height: AppSpacing.space6),
            _field(_question, '预测问题，如：本局谁赢？'),
            SizedBox(height: AppSpacing.space6),
            Text(
              '结果选项',
              style: AppTypography.body.copyWith(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.space2),
            for (var i = 0; i < _outcomes.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.space4),
                child: Row(
                  children: [
                    Expanded(child: _field(_outcomes[i], '结果 ${i + 1}')),
                    if (_outcomes.length > 2)
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: c.textTertiary,
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
            SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                Text(
                  '截止',
                  style: AppTypography.body.copyWith(color: c.textSecondary),
                ),
                SizedBox(width: AppSpacing.space6),
                DropdownButton<int>(
                  value: _durationMin,
                  dropdownColor: c.bgElevated,
                  style: AppTypography.body.copyWith(color: c.textPrimary),
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
              SizedBox(height: AppSpacing.space4),
              Text(
                _error!,
                style: AppTypography.bodySm.copyWith(color: c.danger),
              ),
            ],
            SizedBox(height: AppSpacing.space6),
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

  Widget _field(TextEditingController controller, String hint) {
    final t = AppColorTokens.of(context);
    return TextField(
      controller: controller,
      style: AppTypography.body.copyWith(color: t.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(color: t.textTertiary),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: t.brand),
        ),
      ),
    );
  }
}
