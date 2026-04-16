import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/contact/contact_state.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../helpers/bloc_message_helper.dart';
import '../../widgets/common/common_widgets.dart';
import '../contact/contact_tile.dart';

/// 创建群聊页面
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  Uint8List? _avatarBytes;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // ContactBloc 已经在导航时提供并加载了联系人
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() {
          _avatarBytes = bytes;
        });
      }
    }
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

  void _createGroup() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.commonEnterGroupName ?? 'Enter group name')),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.groupSelectAtLeastOne ?? 'Please select at least one member')),
      );
      return;
    }

    context.read<GroupBloc>().add(CreateGroup(
          name: name,
          inviteUserIds: _selectedUserIds.toList(),
          avatar: _avatarBytes,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state.status == GroupStatus.created) {
          Navigator.of(context).pop(state.createdRoomId!);
        } else if (state.status == GroupStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resolveBlocMessage(context, state.errorMessage!))),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: N42AppBar(
          title: S.of(context)?.commonCreateGroup ?? 'Create Group',
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: _selectedUserIds.isNotEmpty ? _createGroup : null,
              child: Text(
                S.of(context)?.groupDone(_selectedUserIds.length) ?? 'Done(${_selectedUserIds.length})',
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
            // 群信息输入
            Container(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 群头像
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        image: _avatarBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_avatarBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _avatarBytes == null
                          ? const Icon(Icons.camera_alt, color: AppColors.textSecondary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 群名称输入
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: S.of(context)?.commonEnterGroupName ?? 'Enter group name',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 已选成员
            if (_selectedUserIds.isNotEmpty)
              Container(
                height: 80,
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
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
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              padding: const EdgeInsets.all(12),
              child: N42SearchBar(
                controller: _searchController,
                hintText: S.of(context)?.commonSearchContacts ?? 'Search contacts',
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
                      final isSelected = _selectedUserIds.contains(contact.userId);

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
                      color: Colors.red,
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

