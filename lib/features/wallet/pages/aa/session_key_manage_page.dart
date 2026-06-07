// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/repository/session_key_repository.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

import 'session_key_card.dart';
import 'session_key_models.dart';
import 'session_key_sheets.dart';

/// Session Key management page for a specific [SmartAccount].
///
/// Displays active / expired / revoked keys in a tab view. Users can:
/// - Browse existing authorisations with plain-language permission summaries
/// - Revoke an active key (optimistic UI update + local DB update)
/// - Create new keys via a guided wizard with preset permission templates
class SessionKeyManagePage extends StatefulWidget {
  final SmartAccount account;

  const SessionKeyManagePage({super.key, required this.account});

  @override
  State<SessionKeyManagePage> createState() => _SessionKeyManagePageState();
}

class _SessionKeyManagePageState extends State<SessionKeyManagePage>
    with SingleTickerProviderStateMixin {
  static const _accentColor = Color(0xFF8B5CF6);

  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );
  late final SessionKeyRepository _repository = SessionKeyRepository(
    AppDatabase(),
  );
  bool _isLoading = true;
  List<SessionKeyData> _sessionKeys = [];

  @override
  void initState() {
    super.initState();
    _loadSessionKeys();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionKeys() async {
    setState(() => _isLoading = true);
    try {
      final keys = await _repository.loadKeys(widget.account.chainId);
      if (!mounted) return;
      setState(() {
        _sessionKeys = keys;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.w('SessionKeyManage', '_loadSessionKeys error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<SessionKeyData> _keysByStatus(SessionKeyStatus status) =>
      _sessionKeys.where((k) => k.status == status).toList();

  void _createNewSessionKey() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateSessionKeySheet(
        account: widget.account,
        repository: _repository,
        onCreated: (key) {
          if (!mounted) return;
          setState(() => _sessionKeys.insert(0, key));
          _tabController.animateTo(0); // jump to Active tab
        },
      ),
    );
  }

  Future<void> _performRevoke(SessionKeyData key) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_aa_revoking),
        duration: const Duration(seconds: 2),
      ),
    );

    final idx = _sessionKeys.indexWhere((k) => k.keyAddress == key.keyAddress);
    if (idx >= 0 && mounted) {
      setState(
        () =>
            _sessionKeys[idx] = key.copyWith(status: SessionKeyStatus.revoked),
      );
    }

    final ok = await _repository.revokeKey(
      key.keyAddress,
      widget.account.chainId,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? S.of(context).g_key_aa_revoked
              : S.of(context).g_key_aa_session_create_failed,
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor);
    final activeKeys = _keysByStatus(SessionKeyStatus.active);
    final expiredKeys = _keysByStatus(SessionKeyStatus.expired);
    final revokedKeys = _keysByStatus(SessionKeyStatus.revoked);

    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_aa_session_keys),
      body: Column(
        children: [
          _buildInfoHeader(s, activeKeys, expiredKeys, revokedKeys),
          _buildTabBar(s, blueColor, activeKeys, expiredKeys, revokedKeys),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTabContent(activeKeys, expiredKeys, revokedKeys),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewSessionKey,
        backgroundColor: blueColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          s.g_key_aa_create_session,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  Widget _buildInfoHeader(
    S s,
    List<SessionKeyData> activeKeys,
    List<SessionKeyData> expiredKeys,
    List<SessionKeyData> revokedKeys,
  ) {
    final mainText = _themeColor(AppThemeKeys.mainTextColor);
    final subtitleText = _themeColor(AppThemeKeys.itemSubtitleTextColor);
    final su = ScreenUtil();

    return Container(
      margin: EdgeInsets.all(su.setWidth(24)),
      padding: EdgeInsets.all(su.setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accentColor.withAlpha(25), _accentColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(su.setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: su.setWidth(48),
                height: su.setWidth(48),
                decoration: BoxDecoration(
                  color: _accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(su.setWidth(14)),
                ),
                child: Icon(
                  Icons.key,
                  size: su.setWidth(28),
                  color: _accentColor,
                ),
              ),
              SizedBox(width: su.setWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.g_key_aa_session_keys,
                      style: TextStyle(
                        fontSize: su.setSp(28),
                        fontWeight: FontWeight.w600,
                        color: mainText,
                      ),
                    ),
                    Text(
                      s.g_key_aa_session_keys_desc,
                      style: TextStyle(
                        fontSize: su.setSp(22),
                        color: subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: su.setWidth(16)),
          Row(
            children: [
              _buildStatItem(
                activeKeys.length.toString(),
                s.g_key_aa_active,
                Colors.green,
              ),
              SizedBox(width: su.setWidth(16)),
              _buildStatItem(
                expiredKeys.length.toString(),
                s.g_key_aa_expired,
                Colors.orange,
              ),
              SizedBox(width: su.setWidth(16)),
              _buildStatItem(
                revokedKeys.length.toString(),
                s.g_key_aa_revoked_status,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    final su = ScreenUtil();
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: su.setWidth(12),
          vertical: su.setWidth(10),
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(su.setWidth(10)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: su.setSp(32),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: su.setSp(20),
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(
    S s,
    Color blueColor,
    List<SessionKeyData> activeKeys,
    List<SessionKeyData> expiredKeys,
    List<SessionKeyData> revokedKeys,
  ) {
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: su.setWidth(24)),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.circular(su.setWidth(12)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(su.setWidth(10)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: _themeColor(AppThemeKeys.itemSubtitleTextColor),
        labelStyle: TextStyle(
          fontSize: su.setSp(24),
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: '${s.g_key_aa_active} (${activeKeys.length})'),
          Tab(text: '${s.g_key_aa_expired} (${expiredKeys.length})'),
          Tab(text: '${s.g_key_aa_revoked_status} (${revokedKeys.length})'),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    List<SessionKeyData> activeKeys,
    List<SessionKeyData> expiredKeys,
    List<SessionKeyData> revokedKeys,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildKeyList(activeKeys, showActions: true),
        _buildKeyList(expiredKeys, showActions: false),
        _buildKeyList(revokedKeys, showActions: false),
      ],
    );
  }

  Widget _buildKeyList(List<SessionKeyData> keys, {required bool showActions}) {
    if (keys.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      itemCount: keys.length,
      itemBuilder: (context, index) => SessionKeyCard(
        keyData: keys[index],
        showActions: showActions,
        onRevoke: () => _performRevoke(keys[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor);
    final su = ScreenUtil();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.key_off,
            size: su.setWidth(64),
            color: subtitleColor.withAlpha(100),
          ),
          SizedBox(height: su.setWidth(16)),
          Text(
            S.of(context).g_key_aa_no_session_keys,
            style: TextStyle(fontSize: su.setSp(28), color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
