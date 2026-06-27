import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../core/utils/debug_log.dart';

class ContactCardSelectSheet extends StatefulWidget {
  final bool isDark;
  final String selectContactText;
  final String searchContactHintText;
  final String noContactsFoundText;
  final String? excludeUserId;

  const ContactCardSelectSheet({
    super.key,
    required this.isDark,
    required this.selectContactText,
    required this.searchContactHintText,
    required this.noContactsFoundText,
    this.excludeUserId,
  });

  @override
  State<ContactCardSelectSheet> createState() => _ContactCardSelectSheetState();
}

class _ContactCardSelectSheetState extends State<ContactCardSelectSheet> {
  String _searchQuery = '';
  List<ContactEntity> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contactRepository = getIt<IContactRepository>();
      final contacts = await contactRepository.getContacts();
      final filteredContacts = widget.excludeUserId == null
          ? contacts
          : contacts.where((c) => c.userId != widget.excludeUserId).toList();
      if (mounted) {
        setState(() {
          _contacts = filteredContacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugLog('Failed to load contacts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ContactEntity> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts
        .where(
          (c) =>
              c.effectiveDisplayName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              c.userId.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(widget.isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 顶部标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.dividerOf(widget.isDark),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.selectContactText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryOf(widget.isDark),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textPrimaryOf(widget.isDark),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.searchContactHintText,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.inputBgOf(widget.isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // 联系人列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      widget.noContactsFoundText,
                      style: TextStyle(
                        color: AppColors.textTertiaryOf(widget.isDark),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return ListTile(
                        leading: contact.avatarUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  contact.avatarUrl!,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  contact.effectiveDisplayName.isNotEmpty
                                      ? contact.effectiveDisplayName[0]
                                            .toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                        title: Text(
                          contact.effectiveDisplayName,
                          style: TextStyle(
                            color: AppColors.textPrimaryOf(widget.isDark),
                          ),
                        ),
                        subtitle: Text(
                          contact.userId,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiaryOf(widget.isDark),
                          ),
                        ),
                        onTap: () => Navigator.pop(context, {
                          'id': contact.userId,
                          'name': contact.effectiveDisplayName,
                          'avatar': contact.avatarUrl,
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 音乐选择底部弹窗
