import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/contact/contact_state.dart';
import '../../blocs/bloc_message_keys.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../helpers/bloc_message_helper.dart';
import '../../widgets/common/common_widgets.dart';
import '../contact/contact_tile.dart';

/// 邀请成员页面
class InviteMembersPage extends StatefulWidget {
  final String roomId;

  const InviteMembersPage({super.key, required this.roomId});

  @override
  State<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  bool _isSearching = false;
  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    context.read<ContactBloc>().add(const LoadContacts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _inviteMembers() {
    if (_selectedUserIds.isEmpty || _isInviting) return;

    setState(() => _isInviting = true);
    context.read<GroupBloc>().add(
      InviteMembers(widget.roomId, _selectedUserIds.toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (!_isInviting) {
          return;
        }

        if (state.status == GroupStatus.success &&
            state.successMessage == BlocMessageKeys.groupMembersInvited) {
          setState(() => _isInviting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resolveBlocMessage(context, state.successMessage!)),
            ),
          );
          Navigator.pop(context);
        } else if (state.status == GroupStatus.error &&
            state.errorMessage != null) {
          setState(() => _isInviting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resolveBlocMessage(context, state.errorMessage!)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.pageBackground,
        appBar: N42AppBar(
          title: S.of(context)?.groupInviteMembers ?? 'Invite Members',
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: (_selectedUserIds.isNotEmpty && !_isInviting)
                  ? _inviteMembers
                  : null,
              child: _isInviting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      S
                              .of(context)
                              ?.groupInviteCount(_selectedUserIds.length) ??
                          'Invite(${_selectedUserIds.length})',
                      style: TextStyle(
                        color: _selectedUserIds.isNotEmpty
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 已选成员
            if (_selectedUserIds.isNotEmpty)
              Container(
                height: 80,
                color: context.surfaceColor,
                child: BlocBuilder<ContactBloc, ContactState>(
                  builder: (context, state) {
                    if (!state.isLoaded) return const SizedBox.shrink();

                    final selectedContacts = state.contacts
                        .where((c) => _selectedUserIds.contains(c.userId))
                        .toList();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: selectedContacts.length,
                      itemBuilder: (context, index) {
                        final contact = selectedContacts[index];
                        return _buildSelectedMember(contact);
                      },
                    );
                  },
                ),
              ),

            // 搜索栏
            Container(
              color: context.surfaceColor,
              padding: const EdgeInsets.all(12),
              child: N42SearchBar(
                controller: _searchController,
                hintText:
                    S.of(context)?.commonSearchContacts ?? 'Search contacts',
                onChanged: (query) {
                  setState(() {
                    _isSearching = query.isNotEmpty;
                  });
                  context.read<ContactBloc>().add(SearchContacts(query));
                },
              ),
            ),

            // 联系人列表
            Expanded(
              child: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const N42Loading();
                  }

                  if (!state.isLoaded) {
                    return N42EmptyState(
                      icon: Icons.contacts_outlined,
                      title: S.of(context)?.commonNoContacts ?? 'No contacts',
                    );
                  }

                  final contacts = _isSearching
                      ? state.filteredContacts
                      : state.contacts;

                  if (contacts.isEmpty) {
                    return N42EmptyState.noSearchResult();
                  }

                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final isSelected = _selectedUserIds.contains(
                        contact.userId,
                      );

                      return SimpleContactTile(
                        contact: contact,
                        selected: isSelected,
                        onTap: () => _toggleSelection(contact.userId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMember(ContactEntity contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GestureDetector(
        onTap: () => _toggleSelection(contact.userId),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                N42Avatar(
                  imageUrl: contact.avatarUrl,
                  name: contact.effectiveDisplayName,
                  size: 44,
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 50,
              child: Text(
                contact.effectiveDisplayName,
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
