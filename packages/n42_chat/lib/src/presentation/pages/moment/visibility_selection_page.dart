import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../widgets/common/n42_avatar.dart';
import '../contact/tags_management_page.dart';
import '../../../core/utils/debug_log.dart';

/// 可见性好友选择页面
///
/// 用于发布朋友圈时选择"部分可见"或"不给谁看"的好友列表。
class VisibilitySelectionPage extends StatefulWidget {
  /// 已选择的用户 ID 列表（编辑时回传）
  final List<String> initialSelectedIds;

  /// 标题描述（如 "选择可见好友" 或 "选择不可见好友"）
  final String? title;

  const VisibilitySelectionPage({
    super.key,
    this.initialSelectedIds = const [],
    this.title,
  });

  @override
  State<VisibilitySelectionPage> createState() => _VisibilitySelectionPageState();
}

class _VisibilitySelectionPageState extends State<VisibilitySelectionPage> {
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  List<TagData> _tags = [];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.initialSelectedIds);
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsJson = prefs.getString('contact_tags');
      if (tagsJson != null) {
        final list = jsonDecode(tagsJson) as List;
        if (mounted) {
          setState(() {
            _tags = list.map((e) => TagData.fromJson(e as Map<String, dynamic>)).toList();
          });
        }
      }
    } catch (e) {
      debugLog('Failed to load tags: $e');
    }
  }

  List<ContactEntity> _getContacts() {
    try {
      final state = context.read<ContactBloc>().state;
      if (state.isLoaded) {
        return state.contacts;
      }
    } catch (e) {
      debugLog('Error: $e');
    }
    return [];
  }

  List<ContactEntity> get _filteredContacts {
    final contacts = _getContacts();
    if (_searchQuery.isEmpty) return contacts;
    final query = _searchQuery.toLowerCase();
    return contacts.where((c) {
      return c.effectiveDisplayName.toLowerCase().contains(query) ||
          c.userId.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleTag(TagData tag) {
    setState(() {
      final allSelected = tag.contactIds.every((id) => _selectedIds.contains(id));
      if (allSelected) {
        _selectedIds.removeAll(tag.contactIds);
      } else {
        _selectedIds.addAll(tag.contactIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final s = S.of(context);
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white70 : Colors.black54;

    final contacts = _filteredContacts;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text(
          widget.title ?? (s?.momentSelectFriends ?? 'Select Friends'),
          style: TextStyle(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            color: cardColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: s?.momentSelectFriends ?? 'Search',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          // 标签分组区
          if (_tags.isNotEmpty && _searchQuery.isEmpty) ...[
            Container(
              width: double.infinity,
              color: cardColor,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s?.momentSelectTags ?? 'Select by Tags',
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      final allSelected = tag.contactIds.isNotEmpty &&
                          tag.contactIds.every((id) => _selectedIds.contains(id));
                      return FilterChip(
                        label: Text(
                          '${tag.name} (${tag.contactIds.length})',
                          style: TextStyle(
                            color: allSelected ? Colors.white : textColor,
                            fontSize: 13,
                          ),
                        ),
                        selected: allSelected,
                        onSelected: (_) => _toggleTag(tag),
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 联系人列表
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isSelected = _selectedIds.contains(contact.userId);

                return Container(
                  color: cardColor,
                  child: ListTile(
                    leading: N42Avatar(
                      name: contact.effectiveDisplayName,
                      imageUrl: contact.avatarUrl,
                      size: 40,
                    ),
                    title: Text(
                      contact.effectiveDisplayName,
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(contact.userId);
                          } else {
                            _selectedIds.remove(contact.userId);
                          }
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(contact.userId);
                        } else {
                          _selectedIds.add(contact.userId);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // 底部确认栏
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  s?.momentSelectedCount(_selectedIds.length) ??
                      'Selected (${_selectedIds.length})',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_selectedIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(s?.contactDoneButton ?? 'Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
