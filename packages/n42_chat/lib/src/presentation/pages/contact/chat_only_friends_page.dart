import 'package:flutter/material.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../data/datasources/matrix/contact_privacy_service.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../widgets/common/common_widgets.dart';
import 'contact_tile.dart';
import '../../../core/utils/debug_log.dart';

/// 仅聊天的朋友列表页面
class ChatOnlyFriendsPage extends StatefulWidget {
  const ChatOnlyFriendsPage({super.key});

  @override
  State<ChatOnlyFriendsPage> createState() => _ChatOnlyFriendsPageState();
}

class _ChatOnlyFriendsPageState extends State<ChatOnlyFriendsPage> {
  List<ContactEntity> _chatOnlyFriends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatOnlyFriends();
  }

  Future<void> _loadChatOnlyFriends() async {
    try {
      final privacy = ContactPrivacyService(getIt<MatrixClientManager>());
      final allContacts = await getIt<IContactRepository>().getContacts();
      if (allContacts.isNotEmpty) await privacy.load(allContacts.first.userId);
      final chatOnlyIds = allContacts
          .where((c) => privacy.forUser(c.userId)['chatOnly'] == true)
          .map((c) => c.userId)
          .toSet();

      if (mounted) {
        setState(() {
          _chatOnlyFriends = allContacts
              .where((c) => chatOnlyIds.contains(c.userId))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugLog('Failed to load chat-only friends: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.contactChatOnlyFriends ?? 'Chat-only Friends',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatOnlyFriends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.contactNoChatOnlyFriends ??
                        'No chat-only friends',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _chatOnlyFriends.length,
              separatorBuilder: (_, _) => Padding(
                padding: const EdgeInsets.only(left: 72),
                child: Divider(height: 1, color: context.dividerColor),
              ),
              itemBuilder: (context, index) {
                return ContactTile(contact: _chatOnlyFriends[index]);
              },
            ),
    );
  }
}
