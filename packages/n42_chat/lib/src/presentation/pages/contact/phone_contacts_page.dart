import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/contact_sync_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../widgets/common/common_widgets.dart';

/// 手机通讯录匹配页面
///
/// 从手机通讯录中查找已注册的 Matrix 用户
class PhoneContactsPage extends StatefulWidget {
  const PhoneContactsPage({super.key});

  @override
  State<PhoneContactsPage> createState() => _PhoneContactsPageState();
}

class _PhoneContactsPageState extends State<PhoneContactsPage> {
  late final ContactSyncService _syncService;

  bool _isLoading = true;
  bool _hasPermission = false;
  String? _errorMessage;
  List<MatchedContact> _matchedContacts = [];
  List<PhoneContact> _allPhoneContacts = [];

  @override
  void initState() {
    super.initState();
    _syncService = ContactSyncService(getIt<MatrixClientManager>());
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _syncService.syncContacts(
        onProgress: (current, total) {
          // 可以用于显示进度
        },
      );
      if (!mounted) return;

      if (!result.success) {
        setState(() {
          _hasPermission = false;
          _errorMessage = result.error;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _hasPermission = true;
        _allPhoneContacts = result.phoneContacts;
        _matchedContacts = result.matchedContacts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startDirectChat(String userId) async {
    try {
      final roomId = await getIt<IContactRepository>().startDirectChat(userId);
      if (!mounted) return;
      Navigator.of(context).pop(roomId);
    } catch (e) {
      _showError('Failed to create chat: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: const N42AppBar(title: 'From Contacts'),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const N42Loading(message: 'Loading contacts...');
    }

    if (!_hasPermission) {
      return _buildPermissionRequest(isDark);
    }

    if (_errorMessage != null) {
      return _buildError(isDark);
    }

    if (_matchedContacts.isEmpty) {
      return _buildNoMatches(isDark);
    }

    return _buildMatchedList();
  }

  Widget _buildPermissionRequest(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.contacts,
              size: 72,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Contacts Permission Required',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'To find friends from your contacts, please allow access to your contacts.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Allow Access'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.4,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: _loadContacts, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatches(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search,
              size: 72,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Matches Found',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'None of your contacts are using this app yet. Invite them to join!',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scanned ${_allPhoneContacts.length} contacts',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchedList() {
    return Column(
      children: [
        // 统计信息
        Container(
          padding: const EdgeInsets.all(16),
          color: context.surfaceColor,
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Found ${_matchedContacts.length} matches from your contacts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 匹配列表
        Expanded(
          child: ListView.builder(
            itemCount: _matchedContacts.length,
            itemBuilder: (context, index) {
              final match = _matchedContacts[index];
              return _buildMatchTile(match);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchTile(MatchedContact match) {
    final phoneContact = match.phoneContact;
    final displayName = match.matrixDisplayName ?? phoneContact.displayName;

    return ListTile(
      leading: Stack(
        children: [
          N42Avatar(
            imageUrl: match.matrixAvatarUrl,
            name: displayName,
            size: 48,
          ),
          // 手机通讯录标识
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.surfaceColor,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.contacts, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          height: 1.3,
          color: context.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match.matrixUserId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: context.textSecondary,
            ),
          ),
          if (phoneContact.displayName != displayName)
            Text(
              'In Contacts: ${phoneContact.displayName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
        ],
      ),
      isThreeLine: phoneContact.displayName != displayName,
      trailing: OutlinedButton(
        onPressed: () => _startDirectChat(match.matrixUserId),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Chat'),
      ),
    );
  }
}
