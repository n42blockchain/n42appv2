import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
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
        _tags = list.map((e) => TagData.fromJson(e as Map<String, dynamic>)).toList();
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
    await prefs.setString('tags_data', json);
  }

  void _createTag() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.contactCreateTag ?? 'Create Tag'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: S.of(context)?.contactEnterTagName ?? 'Enter tag name',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                setState(() {
                  _tags.add(TagData(
                    name: name,
                    contactIds: [],
                  ));
                });
                _saveTags();
              }
            },
            child: Text(S.of(context)?.commonConfirm ?? 'OK'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _editTag(int index) {
    final controller = TextEditingController(text: _tags[index].name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.contactEditTag ?? 'Edit Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                setState(() {
                  _tags[index] = _tags[index].copyWith(name: name);
                });
                _saveTags();
              }
            },
            child: Text(S.of(context)?.commonSave ?? 'Save'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _deleteTag(int index) {
    final tag = _tags[index];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.contactDeleteTag ?? 'Delete Tag'),
        content: Text(S.of(context)?.contactDeleteTagConfirm(tag.name) ??
            'Delete tag "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedTags.remove(tag.name);
                _tags.removeAt(index);
              });
              _saveTags();
            },
            child: Text(
              S.of(context)?.commonDelete ?? 'Delete',
              style: const TextStyle(color: Colors.red),
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
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.contactTags ?? 'Tags',
        actions: [
          if (widget.selectMode)
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedTags.toList()),
              child: Text(
                S.of(context)?.commonConfirm ?? 'OK',
                style: const TextStyle(color: AppColors.primary),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createTag,
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
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context)?.contactNoTags ?? 'No tags yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createTag,
                        icon: const Icon(Icons.add),
                        label: Text(S.of(context)?.contactCreateTag ?? 'Create Tag'),
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
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 16,
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final tag = _tags[index];
                    return Material(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      child: ListTile(
                        leading: widget.selectMode
                            ? Checkbox(
                                value: _selectedTags.contains(tag.name),
                                onChanged: (value) {
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
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${tag.contactIds.length} ${S.of(context)?.commonContacts ?? "contacts"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        trailing: widget.selectMode
                            ? null
                            : const Icon(Icons.chevron_right, size: 20),
                        onTap: widget.selectMode
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
                        onLongPress: widget.selectMode
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(S.of(context)?.commonDelete ?? 'Delete',
                  style: const TextStyle(color: Colors.red)),
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'contactIds': contactIds,
  };

  factory TagData.fromJson(Map<String, dynamic> json) => TagData(
    name: json['name'] as String,
    contactIds: List<String>.from(json['contactIds'] as List),
  );
}
