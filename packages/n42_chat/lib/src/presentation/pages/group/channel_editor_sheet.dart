import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

class ChannelEditorDraft {
  final String name;
  final String? topic;
  final String? category;

  const ChannelEditorDraft({required this.name, this.topic, this.category});
}

Future<ChannelEditorDraft?> showChannelEditorSheet(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? initialName,
  String? initialTopic,
  String? initialCategory,
}) {
  return showModalBottomSheet<ChannelEditorDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _ChannelEditorSheet(
        title: title,
        confirmLabel: confirmLabel,
        initialName: initialName,
        initialTopic: initialTopic,
        initialCategory: initialCategory,
      );
    },
  );
}

class _ChannelEditorSheet extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String? initialName;
  final String? initialTopic;
  final String? initialCategory;

  const _ChannelEditorSheet({
    required this.title,
    required this.confirmLabel,
    this.initialName,
    this.initialTopic,
    this.initialCategory,
  });

  @override
  State<_ChannelEditorSheet> createState() => _ChannelEditorSheetState();
}

class _ChannelEditorSheetState extends State<_ChannelEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _topicController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _topicController = TextEditingController(text: widget.initialTopic ?? '');
    _categoryController = TextEditingController(
      text: widget.initialCategory ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _topicController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Channel Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    hintText: 'Announcements / Product / Support',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _submit,
                    child: Text(
                      widget.confirmLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final topic = _topicController.text.trim();
    final category = _categoryController.text.trim();

    Navigator.of(context).pop(
      ChannelEditorDraft(
        name: name,
        topic: topic.isEmpty ? null : topic,
        category: category.isEmpty ? null : category,
      ),
    );
  }
}
