import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../core/utils/debug_log.dart';

class MemberPickerSheet extends StatefulWidget {
  final String roomId;
  final bool isDark;
  final void Function(String memberName, String memberId) onMemberSelected;

  const MemberPickerSheet({
    super.key,
    required this.roomId,
    required this.isDark,
    required this.onMemberSelected,
  });

  @override
  State<MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<MemberPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _members = [];
  List<Map<String, String>> _filteredMembers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final groupRepository = getIt<IGroupRepository>();
      final members = await groupRepository.getGroupMembers(widget.roomId);
      if (!mounted) return;
      setState(() {
        _members = members
            .map(
              (m) => {
                'id': m.userId,
                'name': m.displayName.isNotEmpty ? m.displayName : m.userId,
                'avatarUrl': m.avatarUrl ?? '',
              },
            )
            .toList();
        _filteredMembers = _members;
        _isLoading = false;
      });
    } catch (e) {
      debugLog('Error loading members: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterMembers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMembers = _members;
      } else {
        _filteredMembers = _members.where((m) {
          final name = m['name']?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.surfaceOf(widget.isDark);
    final textColor = AppColors.textPrimaryOf(widget.isDark);
    final subtextColor = AppColors.textSecondaryOf(widget.isDark);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: Icon(Icons.close, color: textColor),
                ),
                Expanded(
                  child: Text(
                    S.of(context)?.chatSelectMember ?? 'Select Member',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // 平衡布局
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMembers,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText:
                    S.of(context)?.chatSearchMemberHint ?? 'Search members',
                hintStyle: TextStyle(color: subtextColor),
                prefixIcon: Icon(Icons.search, color: subtextColor),
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // 成员列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMembers.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? (S.of(context)?.chatNoMembers ?? 'No members')
                          : (S.of(context)?.chatNoMatchingMembers ??
                                'No matching members'),
                      style: TextStyle(color: subtextColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = _filteredMembers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorFromName(
                            member['name'] ?? '',
                          ),
                          child: Text(
                            (member['name'] ?? '?')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          member['name'] ??
                              (S.of(context)?.commonUnknownMember ?? 'Unknown'),
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          member['id'] ?? '',
                          style: TextStyle(fontSize: 12, color: subtextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => widget.onMemberSelected(
                          member['name'] ??
                              (S.of(context)?.commonUnknownMember ?? 'Unknown'),
                          member['id'] ?? '',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    return AppColorPalettes.getAvatarColor(name);
  }
}

/// 批量转发选择器底部弹窗
