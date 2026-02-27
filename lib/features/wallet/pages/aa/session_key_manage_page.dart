// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/repository/session_key_repository.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

import 'session_key_card.dart';
import 'session_key_models.dart';
import 'session_key_sheets.dart';

// ════════════════════════════════════════════════════════════════════════════
// Main page
// ════════════════════════════════════════════════════════════════════════════

/// Session Key management page for a specific [SmartAccount].
///
/// Displays active / expired / revoked keys in a tab view. Users can:
/// - Browse existing authorisations with plain-language permission summaries
/// - Revoke an active key (optimistic UI update + local DB update)
/// - Create new keys via a guided wizard with preset permission templates
class SessionKeyManagePage extends StatefulWidget {
  final SmartAccount account;

  const SessionKeyManagePage({
    super.key,
    required this.account,
  });

  @override
  State<SessionKeyManagePage> createState() => _SessionKeyManagePageState();
}

class _SessionKeyManagePageState extends State<SessionKeyManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SessionKeyRepository _repository;
  bool _isLoading = true;
  List<SessionKeyData> _sessionKeys = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _repository = SessionKeyRepository(AppDatabase());
    _loadSessionKeys();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionKeys() async {
    setState(() => _isLoading = true);
    final keys = await _repository.loadKeys(widget.account.chainId);
    if (mounted) {
      setState(() {
        _sessionKeys = keys;
        _isLoading = false;
      });
    }
  }

  // ── Filtered lists ────────────────────────────────────────────────────────

  List<SessionKeyData> get _activeKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.active).toList();

  List<SessionKeyData> get _expiredKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.expired).toList();

  List<SessionKeyData> get _revokedKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.revoked).toList();

  // ── Actions ───────────────────────────────────────────────────────────────

  void _createNewSessionKey() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateSessionKeySheet(
        account: widget.account,
        repository: _repository,
        onCreated: (key) {
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

    // Optimistic UI update
    final idx =
        _sessionKeys.indexWhere((k) => k.keyAddress == key.keyAddress);
    if (idx >= 0 && mounted) {
      setState(() {
        _sessionKeys[idx] = key.copyWith(status: SessionKeyStatus.revoked);
      });
    }

    // Persist to SQLite
    final ok =
        await _repository.revokeKey(key.keyAddress, widget.account.chainId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? S.of(context).g_key_aa_revoked
              : S.of(context).g_key_aa_session_create_failed),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_session_keys,
      ),
      body: Column(
        children: [
          _buildInfoHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading ? _buildLoading() : _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewSessionKey,
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          S.of(context).g_key_aa_create_session,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(24)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withAlpha(25),
            const Color(0xFF8B5CF6).withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setWidth(48),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(14)),
                ),
                child: Icon(
                  Icons.key,
                  size: ScreenUtil().setWidth(28),
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).g_key_aa_session_keys,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    Text(
                      S.of(context).g_key_aa_session_keys_desc,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            children: [
              _buildStatItem(
                _activeKeys.length.toString(),
                S.of(context).g_key_aa_active,
                Colors.green,
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              _buildStatItem(
                _expiredKeys.length.toString(),
                S.of(context).g_key_aa_expired,
                Colors.orange,
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              _buildStatItem(
                _revokedKeys.length.toString(),
                S.of(context).g_key_aa_revoked_status,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(12),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemSubtitleTextColor.name,
        ),
        labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
              text:
                  '${S.of(context).g_key_aa_active} (${_activeKeys.length})'),
          Tab(
              text:
                  '${S.of(context).g_key_aa_expired} (${_expiredKeys.length})'),
          Tab(
              text:
                  '${S.of(context).g_key_aa_revoked_status} (${_revokedKeys.length})'),
        ],
      ),
    );
  }

  Widget _buildLoading() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildKeyList(_activeKeys, showActions: true),
        _buildKeyList(_expiredKeys, showActions: false),
        _buildKeyList(_revokedKeys, showActions: false),
      ],
    );
  }

  Widget _buildKeyList(List<SessionKeyData> keys,
      {required bool showActions}) {
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.key_off,
            size: ScreenUtil().setWidth(64),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_aa_no_session_keys,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
