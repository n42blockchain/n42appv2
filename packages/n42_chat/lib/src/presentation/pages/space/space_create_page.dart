import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/room_metadata_utils.dart';
import '../../../domain/entities/space_entity.dart';
import '../../blocs/space/space_bloc.dart';
import '../../blocs/space/space_event.dart';
import '../../blocs/space/space_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 创建 Space 页面
class SpaceCreatePage extends StatefulWidget {
  const SpaceCreatePage({super.key});

  @override
  State<SpaceCreatePage> createState() => _SpaceCreatePageState();
}

class _SpaceCreatePageState extends State<SpaceCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  SpaceType _type = SpaceType.public;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocListener<SpaceBloc, SpaceState>(
      listenWhen: (prev, curr) =>
          curr.operationSuccess != null &&
          prev.operationSuccess != curr.operationSuccess,
      listener: (context, state) {
        if (state.operationSuccess != null) {
          Navigator.pop(context); // 创建成功后返回
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        appBar: N42AppBar(
          title: S.of(context)?.spacesCreate ?? 'Create Community',
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 社区名称
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: S.of(context)?.spacesName ?? 'Community Name',
                  hintText:
                      S.of(context)?.spacesNameHint ?? 'e.g. Crypto Traders',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return S.of(context)?.spacesNameRequired ??
                        'Name is required';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // 描述
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: S.of(context)?.spacesDescription ?? 'Description',
                  hintText:
                      S.of(context)?.spacesDescriptionHint ??
                      'What is this community about?',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: '#defi #trading #n42',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 类型选择
              Text(
                S.of(context)?.spacesType ?? 'Community Type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _TypeSelector(
                value: _type,
                onChanged: (t) => setState(() => _type = t),
              ),

              const SizedBox(height: 32),

              // 提交按钮
              BlocBuilder<SpaceBloc, SpaceState>(
                buildWhen: (p, c) => p.isOperating != c.isOperating,
                builder: (context, state) => FilledButton(
                  onPressed: state.isOperating ? null : _submit,
                  child: state.isOperating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(S.of(context)?.spacesCreate ?? 'Create Community'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SpaceBloc>().add(
      CreateSpace(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        type: _type,
        topics: normalizeTopicLabels(_tagsCtrl.text),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final SpaceType value;
  final ValueChanged<SpaceType> onChanged;

  const _TypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            selected: value == SpaceType.public,
            icon: Icons.public,
            title: S.of(context)?.spacesPublic ?? 'Public',
            subtitle:
                S.of(context)?.spacesPublicDesc ??
                'Anyone can discover and join',
            onTap: () => onChanged(SpaceType.public),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeCard(
            selected: value == SpaceType.private,
            icon: Icons.lock_outlined,
            title: S.of(context)?.spacesPrivate ?? 'Private',
            subtitle:
                S.of(context)?.spacesPrivateDesc ??
                'Only invited members can join',
            onTap: () => onChanged(SpaceType.private),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _TypeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.primary
                  : (isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected
                    ? AppColors.primary
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
