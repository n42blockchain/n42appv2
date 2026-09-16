import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../core/utils/debug_log.dart';

/// 标签管理页面
class TagsManagementPage extends StatefulWidget {
  /// 选择模式（从联系人详情进入时为 true）
  final bool selectMode;

  /// 已选中的标签
  final List<String>? selectedTags;

  const TagsManagementPage({
    super.key,
    this.selectMode = false,
    this.selectedTags,
  });

  @override
  State<TagsManagementPage> createState() => _TagsManagementPageState();
}

class _TagsManagementPageState extends State<TagsManagementPage> {
  List<TagData> _tags = [];
  Set<String> _selectedTags = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedTags = Set.from(widget.selectedTags ?? []);
    _loadTags();
  }

  Future<void> _loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    final tagsJson = prefs.getString('tags_data');
    if (tagsJson != null) {
      try {
        final List<dynamic> list = jsonDecode(tagsJson) as List<dynamic>;
        _tags = list
            .map((e) => TagData.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugLog('Failed to load tags: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTags() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_tags.map((t) => t.toJson()).toList());
    if (!await prefs.setString('tags_data', json)) {
      throw StateError('Unable to save tags');
    }
  }

  List<TagData> _cloneTags(List<TagData> tags) {
    return tags
        .map(
          (tag) => tag.copyWith(contactIds: List<String>.from(tag.contactIds)),
        )
        .toList();
  }

  Future<void> _applyTagMutation(VoidCallback update) async {
    if (_isSaving) {
      return;
    }

    final previousTags = _cloneTags(_tags);
    final previousSelectedTags = Set<String>.from(_selectedTags);
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      update();
    });

    try {
      await _saveTags();
    } catch (e) {
      debugLog('TagsManagementPage: Failed to save tags: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _tags = previousTags;
        _selectedTags = previousSelectedTags;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _createTag() async {
    if (_isLoading || _isSaving) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _TagNameDialog(),
    );
    if (!mounted || name == null) return;
    await _applyTagMutation(() {
      final existing = _tags.where(
        (tag) => tag.name.trim().toLowerCase() == name.toLowerCase(),
      );
      final selectedName = existing.isEmpty ? name : existing.first.name;
      if (existing.isEmpty) {
        _tags.add(TagData(name: name, contactIds: []));
      }
      if (widget.selectMode) _selectedTags.add(selectedName);
    });
  }

  Future<void> _editTag(int index) async {
    final oldName = _tags[index].name;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _TagNameDialog(initialName: oldName),
    );
    if (!mounted || name == null) return;
    await _applyTagMutation(() {
      _tags[index] = _tags[index].copyWith(name: name);
      if (_selectedTags.remove(oldName)) _selectedTags.add(name);
    });
  }

  void _deleteTag(int index) {
    final tag = _tags[index];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.contactDeleteTag ?? 'Delete Tag'),
        content: Text(
          S.of(context)?.contactDeleteTagConfirm(tag.name) ??
              'Delete tag "${tag.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _applyTagMutation(() {
                _selectedTags.remove(tag.name);
                _tags.removeAt(index);
              });
            },
            child: Text(
              S.of(context)?.commonDelete ?? 'Delete',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.contactTags ?? 'Tags',
        actions: [
          IconButton(
            tooltip: S.of(context)?.contactCreateTag ?? 'Create Tag',
            icon: const Icon(Icons.add),
            onPressed: _isLoading || _isSaving ? null : _createTag,
          ),
          if (widget.selectMode)
            TextButton(
              onPressed: _isLoading || _isSaving
                  ? null
                  : () => Navigator.pop(context, _selectedTags.toList()),
              child: Text(
                S.of(context)?.commonConfirm ?? 'OK',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tags.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 64,
                    color: AppColors.textTertiaryOf(isDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.contactNoTags ?? 'No tags yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _createTag,
                    icon: const Icon(Icons.add),
                    label: Text(
                      S.of(context)?.contactCreateTag ?? 'Create Tag',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _tags.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, indent: 16, color: context.dividerColor),
              itemBuilder: (context, index) {
                final tag = _tags[index];
                return Material(
                  color: context.surfaceColor,
                  child: ListTile(
                    leading: widget.selectMode
                        ? Checkbox(
                            value: _selectedTags.contains(tag.name),
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedTags.add(tag.name);
                                      } else {
                                        _selectedTags.remove(tag.name);
                                      }
                                    });
                                  },
                            activeColor: AppColors.primary,
                          )
                        : const Icon(Icons.label_outline),
                    title: Text(
                      tag.name,
                      style: TextStyle(color: context.textPrimary),
                    ),
                    subtitle: Text(
                      '${tag.contactIds.length} ${S.of(context)?.commonContacts ?? "contacts"}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                    ),
                    trailing: widget.selectMode
                        ? null
                        : const Icon(AppIcons.chevron, size: 20),
                    onTap: widget.selectMode && !_isSaving
                        ? () {
                            setState(() {
                              if (_selectedTags.contains(tag.name)) {
                                _selectedTags.remove(tag.name);
                              } else {
                                _selectedTags.add(tag.name);
                              }
                            });
                          }
                        : null,
                    onLongPress: widget.selectMode || _isSaving
                        ? null
                        : () => _showTagOptions(index),
                  ),
                );
              },
            ),
    );
  }

  void _showTagOptions(int index) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(S.of(context)?.commonEdit ?? 'Edit'),
              onTap: () {
                Navigator.pop(ctx);
                _editTag(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: Text(
                S.of(context)?.commonDelete ?? 'Delete',
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deleteTag(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 标签数据模型
class TagData {
  final String name;
  final List<String> contactIds;

  TagData({required this.name, required this.contactIds});

  TagData copyWith({String? name, List<String>? contactIds}) {
    return TagData(
      name: name ?? this.name,
      contactIds: contactIds ?? this.contactIds,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'contactIds': contactIds};

  factory TagData.fromJson(Map<String, dynamic> json) => TagData(
    name: json['name'] as String,
    contactIds: List<String>.from(json['contactIds'] as List),
  );
}

/// Own the controller until the dialog route has finished its exit animation.
class _TagNameDialog extends StatefulWidget {
  final String? initialName;
  const _TagNameDialog({this.initialName});

  @override
  State<_TagNameDialog> createState() => _TagNameDialogState();
}

class _TagNameDialogState extends State<_TagNameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final editing = widget.initialName != null;
    return AlertDialog(
      title: Text(
        editing
            ? strings?.contactEditTag ?? 'Edit Tag'
            : strings?.contactCreateTag ?? 'Create Tag',
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: strings?.contactEnterTagName ?? 'Enter tag name',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings?.commonCancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            editing
                ? strings?.commonSave ?? 'Save'
                : strings?.commonConfirm ?? 'OK',
          ),
        ),
      ],
    );
  }
}
