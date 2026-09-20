import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contact_entity.dart';
import '../common/n42_search_bar.dart';

class ContactSelectDialog extends StatefulWidget {
  final List<ContactEntity> contacts;
  final String title;

  const ContactSelectDialog({
    super.key,
    required this.contacts,
    required this.title,
  });

  @override
  State<ContactSelectDialog> createState() => _ContactSelectDialogState();
}

class _ContactSelectDialogState extends State<ContactSelectDialog> {
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  List<ContactEntity> get _filteredContacts {
    if (_searchQuery.isEmpty) return widget.contacts;
    final query = _searchQuery.toLowerCase();
    return widget.contacts.where((c) {
      return c.effectiveDisplayName.toLowerCase().contains(query) ||
          c.userId.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = AppColors.surfaceOf(isDark);
    final textColor = AppColors.textPrimaryOf(isDark);

    final filteredContacts = _filteredContacts;

    return AlertDialog(
      scrollable: true,
      backgroundColor: bgColor,
      title: Text(widget.title, style: TextStyle(color: textColor)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // 搜索框
            N42SearchBar(
              hintText:
                  S.of(context)?.chatSearchContactHint ?? 'Search contacts',
              showCancelButton: false,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 8),
            // 联系人列表
            Expanded(
              child: filteredContacts.isEmpty
                  ? Semantics(
                      liveRegion: true,
                      child: Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? S.of(context)?.commonNoContacts ?? 'No contacts'
                              : S.of(context)?.searchNoResults ?? 'No Results',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.textSupporting),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        final isSelected = _selectedIds.contains(
                          contact.userId,
                        );
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedIds.add(contact.userId);
                              } else {
                                _selectedIds.remove(contact.userId);
                              }
                            });
                          },
                          title: Text(
                            contact.effectiveDisplayName,
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                            contact.userId,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondary: CircleAvatar(
                            backgroundColor: _getColorFromName(
                              contact.effectiveDisplayName,
                            ),
                            child: Text(
                              contact.effectiveDisplayName.isNotEmpty
                                  ? contact.effectiveDisplayName[0]
                                        .toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: _selectedIds.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedIds.toList()),
          child: Text(
            S.of(context)?.chatConfirmWithCount(_selectedIds.length) ??
                'Confirm (${_selectedIds.length})',
          ),
        ),
      ],
    );
  }

  Color _getColorFromName(String name) {
    return AppColorPalettes.getAvatarColor(name);
  }
}
