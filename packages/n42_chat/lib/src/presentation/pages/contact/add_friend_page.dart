import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../integration/wallet_bridge.dart';
import '../../widgets/common/common_widgets.dart';
import 'phone_contacts_page.dart';

// ─── Input type detection ─────────────────────────────────────────────────────

enum _InputType {
  matrixId, // @user:server.com
  walletAddress, // 0x...
  ensName, // xxx.eth / xxx.lens / xxx.cb.id
  username, // anything else
}

final _walletAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

_InputType _detectInputType(String input) {
  final q = input.trim();
  if (q.startsWith('@') && q.contains(':')) return _InputType.matrixId;
  if (_walletAddressRegExp.hasMatch(q)) {
    return _InputType.walletAddress;
  }
  // ENS: requires at least 1 label char before the TLD dot (e.g. "a.eth")
  if ((q.endsWith('.eth') && q.length > 4) ||
      (q.endsWith('.lens') && q.length > 5) ||
      (q.endsWith('.cb.id') && q.length > 6) ||
      (q.endsWith('.bnb') && q.length > 4) ||
      (q.endsWith('.bit') && q.length > 4)) {
    return _InputType.ensName;
  }
  return _InputType.username;
}

// ─── Resolved Web3 identity ───────────────────────────────────────────────────

class _Web3Identity {
  final String address;
  final String? ensName;
  final String? avatarUrl;
  final String? matrixUserId;
  final String? displayName;
  final bool isNftAvatar;

  const _Web3Identity({
    required this.address,
    this.ensName,
    this.avatarUrl,
    this.matrixUserId,
    this.displayName,
    this.isNftAvatar = false,
  });

  bool get isN42User => matrixUserId != null;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

/// 添加好友页面
///
/// Supports three input types:
/// - Matrix ID  (@user:server) — existing search
/// - Wallet address (0x...) — resolves via IWalletBridge
/// - ENS name (xxx.eth) — resolves via IWalletBridge.resolveEnsName
class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _errorMessage;

  // Web3 identity resolved from wallet address / ENS
  _Web3Identity? _web3Identity;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─── Search ────────────────────────────────────────────────────────────

  Future<void> _searchUser() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
      _web3Identity = null;
    });

    final type = _detectInputType(query);

    switch (type) {
      case _InputType.walletAddress:
        await _resolveByWallet(query);
      case _InputType.ensName:
        await _resolveByEns(query);
      case _InputType.matrixId:
      case _InputType.username:
        await _searchByMatrixId(query);
    }
  }

  // ─── Web3 resolution: wallet address ─────────────────────────────────

  Future<void> _resolveByWallet(String address) async {
    try {
      final walletBridge = getIt<IWalletBridge>();

      // Parallel: ENS reverse lookup + N42 user lookup
      final results = await Future.wait([
        walletBridge.lookupEnsName(address).catchError((_) => null),
        walletBridge.getUserInfoByAddress(address).catchError((_) => null),
      ]);

      final ensName = results[0] as String?;
      final userInfo = results[1] as WalletUserInfo?;

      // Fetch ENS avatar if ENS name resolved
      String? avatarUrl;
      if (ensName != null) {
        avatarUrl = await walletBridge
            .getEnsAvatar(ensName)
            .catchError((_) => null);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSearching = true;
          _web3Identity = _Web3Identity(
            address: address,
            ensName: ensName,
            avatarUrl: avatarUrl,
            matrixUserId: userInfo?.matrixUserId,
            displayName: userInfo?.displayName ?? ensName,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              S.of(context)?.web3ResolveFailed ??
              'Failed to resolve wallet identity';
        });
      }
    }
  }

  // ─── Web3 resolution: ENS name ────────────────────────────────────────

  Future<void> _resolveByEns(String ensName) async {
    try {
      final walletBridge = getIt<IWalletBridge>();

      final address = await walletBridge.resolveEnsName(ensName);
      if (address == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSearching = true;
            _errorMessage =
                S.of(context)?.web3EnsNotFound(ensName) ??
                'ENS name "$ensName" not found';
          });
        }
        return;
      }

      // Parallel: ENS avatar + N42 user lookup
      final results = await Future.wait([
        walletBridge.getEnsAvatar(ensName).catchError((_) => null),
        walletBridge.getUserInfoByAddress(address).catchError((_) => null),
      ]);

      final avatarUrl = results[0] as String?;
      final userInfo = results[1] as WalletUserInfo?;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSearching = true;
          _web3Identity = _Web3Identity(
            address: address,
            ensName: ensName,
            avatarUrl: avatarUrl,
            matrixUserId: userInfo?.matrixUserId,
            displayName: userInfo?.displayName ?? ensName,
            isNftAvatar: false, // ENS avatar may or may not be NFT
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              S.of(context)?.web3ResolveFailed ?? 'Failed to resolve ENS';
        });
      }
    }
  }

  // ─── Matrix user search (existing) ───────────────────────────────────

  Future<void> _searchByMatrixId(String query) async {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client == null) {
        setState(() {
          _errorMessage =
              S.of(context)?.commonChatServiceNotConnected ??
              'Chat service not connected';
          _isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> results = [];

      // Direct Matrix ID
      if (query.startsWith('@') && query.contains(':')) {
        try {
          final profile = await client.getProfileFromUserId(query);
          final localpart = query.split(':').first.replaceFirst('@', '');
          results.add({
            'userId': query,
            'displayName': profile.displayName ?? localpart,
            'avatarUrl': profile.avatarUrl?.toString(),
          });
        } catch (_) {}
      } else {
        // Build full Matrix ID
        final homeserver = client.homeserver?.host ?? '';
        var fullUserId = query.startsWith('@') ? query : '@$query';
        if (!fullUserId.contains(':') && homeserver.isNotEmpty) {
          fullUserId = '$fullUserId:$homeserver';
        }

        if (fullUserId.contains(':')) {
          try {
            final profile = await client.getProfileFromUserId(fullUserId);
            final localpart = fullUserId.split(':').first.replaceFirst('@', '');
            results.add({
              'userId': fullUserId,
              'displayName': profile.displayName ?? localpart,
              'avatarUrl': profile.avatarUrl?.toString(),
            });
          } catch (_) {}
        }

        // Directory search
        try {
          final response = await client.searchUserDirectory(query, limit: 20);
          for (final user in response.results) {
            if (!results.any((r) => r['userId'] == user.userId)) {
              final localpart = user.userId
                  .split(':')
                  .first
                  .replaceFirst('@', '');
              results.add({
                'userId': user.userId,
                'displayName': user.displayName ?? localpart,
                'avatarUrl': user.avatarUrl?.toString(),
              });
            }
          }
        } catch (_) {}
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
        _isSearching = true;
        if (results.isEmpty) {
          _errorMessage =
              S.of(context)?.contactUserNotFoundHint(query) ??
              'User "$query" not found';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            S.of(context)?.contactSearchFailed(e.toString()) ??
            'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  // ─── DM creation ──────────────────────────────────────────────────────

  Future<void> _startDirectChat(String userId) async {
    var completedWithExit = false;
    setState(() => _isLoading = true);

    try {
      final roomId = await getIt<IContactRepository>().startDirectChat(userId);
      if (mounted) {
        completedWithExit = true;
        Navigator.of(context).pop(roomId);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(
        S.of(context)?.contactCreateChatFailed(e.toString()) ??
            'Failed to create chat: $e',
      );
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _openPhoneContacts() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const PhoneContactsPage()),
    );
    if (result != null && mounted) Navigator.of(context).pop(result);
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.commonAddFriend ?? 'Add Friend',
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar
          Container(
            color: context.surfaceColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context)?.web3SearchHint ??
                      '@matrix:id  •  0x wallet address  •  name.eth',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.backgroundDark
                              : AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText:
                                S.of(context)?.web3SearchPlaceholder ??
                                'Search by ID, wallet, or ENS...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                            ),
                            prefixIcon: Icon(
                              AppIcons.search,
                              size: 20,
                              color: context.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            color: context.textPrimary,
                          ),
                          cursorColor: AppColors.primary,
                          onSubmitted: (_) => _searchUser(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(72, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(S.of(context)?.commonSearch ?? 'Search'),
                    ),
                  ],
                ),

                // Input type hint chip
                if (_searchController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InputTypeChip(query: _searchController.text, isDark: isDark),
                ],
              ],
            ),
          ),

          // ── Phone contacts entry
          Container(
            color: context.surfaceColor,
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contacts,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: Text(
                'From Contacts',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Find friends from your phone contacts',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
              trailing: Icon(
                AppIcons.chevron,
                color: context.textSecondary,
              ),
              onTap: _openPhoneContacts,
            ),
          ),

          // ── Error
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),

          // ── Results
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return N42Loading(
        message: S.of(context)?.contactSearching ?? 'Searching...',
      );
    }

    if (!_isSearching) {
      return _SearchEmptyState(isDark: isDark);
    }

    // Web3 identity card result
    if (_web3Identity != null) {
      return SingleChildScrollView(
        child: Web3IdentityCard(
          walletAddress: _web3Identity!.address,
          ensName: _web3Identity!.ensName,
          avatarUrl: _web3Identity!.avatarUrl,
          displayName: _web3Identity!.displayName,
          isN42User: _web3Identity!.isN42User,
          isEnsVerified: _web3Identity!.ensName != null,
          isNftAvatar: _web3Identity!.isNftAvatar,
          isDark: isDark,
          onMessage: () {
            if (_web3Identity!.matrixUserId != null) {
              _startDirectChat(_web3Identity!.matrixUserId!);
            } else {
              // No N42 account: show info dialog
              _showWalletOnlyDialog();
            }
          },
        ),
      );
    }

    // Matrix user list result
    if (_searchResults.isEmpty) {
      return N42EmptyState.noSearchResult(
        description:
            S.of(context)?.contactUserNotFound(_searchController.text) ??
            'User "${_searchController.text}" not found',
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user, isDark);
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, bool isDark) {
    final displayName = user['displayName'] as String? ?? '';
    final userId = user['userId'] as String;
    final avatarUrl = user['avatarUrl'] as String?;

    return ListTile(
      leading: N42Avatar(
        imageUrl: avatarUrl,
        name: displayName.isNotEmpty ? displayName : userId,
        size: 48,
      ),
      title: Text(
        displayName.isNotEmpty
            ? displayName
            : userId.split(':').first.replaceFirst('@', ''),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: context.textPrimary,
        ),
      ),
      subtitle: Text(
        userId,
        style: TextStyle(
          fontSize: 13,
          color: context.textSecondary,
        ),
      ),
      trailing: OutlinedButton(
        onPressed: () => _startDirectChat(userId),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(S.of(context)?.commonChat ?? 'Chat'),
      ),
    );
  }

  void _showWalletOnlyDialog() {
    final l10n = S.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.web3NoN42AccountTitle ?? 'No N42 Account'),
        content: Text(
          l10n?.web3NoN42AccountDesc ??
              'This wallet address has no N42 account yet. You can share your N42 invite link with them to get started.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.web3ShareInvite ?? 'Share Invite'),
          ),
        ],
      ),
    );
  }
}

// ─── Input type hint chip ────────────────────────────────────────────────────

class _InputTypeChip extends StatelessWidget {
  final String query;
  final bool isDark;

  const _InputTypeChip({required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final type = _detectInputType(query);

    String label;
    Color color;
    IconData icon;

    switch (type) {
      case _InputType.walletAddress:
        label = 'Wallet Address';
        color = Colors.orange;
        icon = Icons.account_balance_wallet_outlined;
      case _InputType.ensName:
        label = 'ENS / Domain';
        color = const Color(0xFF5298FF);
        icon = Icons.verified_outlined;
      case _InputType.matrixId:
        label = 'Matrix ID';
        color = AppColors.primary;
        icon = Icons.person_outline;
      case _InputType.username:
        label = 'Username';
        color = Colors.teal;
        icon = Icons.alternate_email;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _SearchEmptyState extends StatelessWidget {
  final bool isDark;

  const _SearchEmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final color = context.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            32,
            32,
            32,
            32 + MediaQuery.of(context).viewInsets.bottom,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 64
                  ? constraints.maxHeight - 64
                  : 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 56, color: color),
                const SizedBox(height: 16),
                Text(
                  l10n?.contactSearchUserToChat ??
                      'Search user to start chatting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _SearchMethodRow(isDark: isDark, l10n: l10n),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchMethodRow extends StatelessWidget {
  final bool isDark;
  final S? l10n;

  const _SearchMethodRow({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MethodCard(
          icon: Icons.person_outline,
          color: AppColors.primary,
          title: 'Matrix ID',
          desc: '@user:server.com',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _MethodCard(
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.orange,
          title: l10n?.web3WalletAddress ?? 'Wallet Address',
          desc: '0x71C7...6b6e',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _MethodCard(
          icon: Icons.verified_outlined,
          color: const Color(0xFF5298FF),
          title: 'ENS / Domain',
          desc: 'vitalik.eth • alice.lens',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final bool isDark;

  const _MethodCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
