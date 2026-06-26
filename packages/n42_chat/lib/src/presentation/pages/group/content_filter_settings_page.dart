import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/content_filter_entity.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../blocs/bloc_message_keys.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 关键词过滤设置页面
class ContentFilterSettingsPage extends StatefulWidget {
  final String roomId;

  const ContentFilterSettingsPage({super.key, required this.roomId});

  @override
  State<ContentFilterSettingsPage> createState() =>
      _ContentFilterSettingsPageState();
}

class _ContentFilterSettingsPageState extends State<ContentFilterSettingsPage> {
  bool _enabled = false;
  FilterAction _action = FilterAction.replace;
  final List<String> _forbiddenWords = [];
  final Set<SensitiveDataType> _sensitiveDataTypes = {};
  final TextEditingController _wordController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    try {
      final repository = getIt<IGroupRepository>();
      final config = await repository.getContentFilter(widget.roomId);
      if (!mounted) {
        return;
      }
      setState(() {
        _enabled = config?.enabled ?? false;
        _action = config?.action ?? FilterAction.replace;
        _forbiddenWords
          ..clear()
          ..addAll(config?.forbiddenWords ?? const []);
        _sensitiveDataTypes
          ..clear()
          ..addAll(config?.sensitiveDataTypes ?? const []);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (!_isSaving) {
          return;
        }
        if (state.status == GroupStatus.success &&
            state.successMessage == BlocMessageKeys.groupContentFilterUpdated) {
          if (mounted) {
            setState(() => _isSaving = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.groupContentFilterUpdated ?? 'Content filter updated',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.status == GroupStatus.error) {
          if (mounted) {
            setState(() => _isSaving = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Failed to update content filter',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: N42AppBar(
          title: l10n?.groupContentFilter ?? 'Content Filter',
          actions: [
            TextButton(
              onPressed: _isLoading || _isSaving ? null : _save,
              child: Text(
                l10n?.commonConfirm ?? 'Save',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        backgroundColor: context.pageBackground,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    color: context.surfaceColor,
                    child: SwitchListTile(
                      title: Text(
                        l10n?.groupContentFilterEnabled ??
                            'Enable Keyword Filter',
                      ),
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ),
                  if (_enabled) ...[
                    const SizedBox(height: 10),
                    Container(
                      color: context.surfaceColor,
                      child: RadioGroup<FilterAction>(
                        groupValue: _action,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _action = value);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Text(
                                l10n?.groupContentFilterReplace ?? 'Action',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            RadioListTile<FilterAction>(
                              title: Text(
                                l10n?.groupContentFilterReplace ??
                                    'Replace with ***',
                              ),
                              value: FilterAction.replace,
                            ),
                            RadioListTile<FilterAction>(
                              title: Text(
                                l10n?.groupContentFilterHide ?? 'Hide Message',
                              ),
                              value: FilterAction.hide,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: context.surfaceColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Text(
                              l10n?.groupContentFilterAddWord ?? 'Keywords',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _wordController,
                                    decoration: InputDecoration(
                                      hintText:
                                          l10n?.groupContentFilterAddWord ??
                                          'Add Keyword',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _addWord(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: _addWord,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_forbiddenWords.isEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                '—',
                                style: TextStyle(
                                  color: context.textSecondary,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _forbiddenWords.map((word) {
                                  return Chip(
                                    label: Text(word),
                                    onDeleted: () => setState(
                                      () => _forbiddenWords.remove(word),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: context.surfaceColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Text(
                              'Sensitive Data Detection',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          ...SensitiveDataType.values.map((type) {
                            return CheckboxListTile(
                              value: _sensitiveDataTypes.contains(type),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected ?? false) {
                                    _sensitiveDataTypes.add(type);
                                  } else {
                                    _sensitiveDataTypes.remove(type);
                                  }
                                });
                              },
                              title: Text(_labelForSensitiveDataType(type)),
                              subtitle: Text(
                                _descriptionForSensitiveDataType(type),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  void _addWord() {
    final word = _wordController.text.trim();
    if (word.isEmpty || _forbiddenWords.contains(word)) return;
    setState(() {
      _forbiddenWords.add(word);
      _wordController.clear();
    });
  }

  void _save() {
    setState(() => _isSaving = true);
    context.read<GroupBloc>().add(
      SetContentFilter(
        widget.roomId,
        ContentFilterConfig(
          enabled: _enabled,
          forbiddenWords: List.from(_forbiddenWords),
          action: _action,
          sensitiveDataTypes: _sensitiveDataTypes.toList(),
        ),
      ),
    );
  }

  String _labelForSensitiveDataType(SensitiveDataType type) {
    switch (type) {
      case SensitiveDataType.email:
        return 'Email';
      case SensitiveDataType.phoneNumber:
        return 'Phone Number';
      case SensitiveDataType.creditCard:
        return 'Credit Card';
      case SensitiveDataType.walletAddress:
        return 'Wallet Address';
    }
  }

  String _descriptionForSensitiveDataType(SensitiveDataType type) {
    switch (type) {
      case SensitiveDataType.email:
        return 'Detect email addresses in text messages';
      case SensitiveDataType.phoneNumber:
        return 'Detect phone numbers and international numbers';
      case SensitiveDataType.creditCard:
        return 'Detect likely bank and card numbers';
      case SensitiveDataType.walletAddress:
        return 'Detect Ethereum-style wallet addresses';
    }
  }
}
