// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/home/setting/setting_share.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_models.dart';
import 'package:n42_wallet/features/loyalty/services/loyalty_service.dart';
import 'package:n42_wallet/generated/l10n.dart';

class LoyaltyHomePage extends StatefulWidget {
  const LoyaltyHomePage({super.key, required this.walletAddress, this.service});

  final String walletAddress;
  final LoyaltyService? service;

  @override
  State<LoyaltyHomePage> createState() => _LoyaltyHomePageState();
}

class _LoyaltyHomePageState extends State<LoyaltyHomePage> {
  late final LoyaltyService _service = widget.service ?? LoyaltyService();
  late final bool _ownsService = widget.service == null;
  LoyaltySnapshot? _snapshot;
  bool _loading = true;
  bool _checkingIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    if (_ownsService) _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.walletAddress.trim().isEmpty) {
      setState(() {
        _loading = false;
        // _load 由 initState 调起，此处不能用 S.of(context)（会触发
        // dependOnInheritedWidgetOfExactType 断言）。
        _error = S.current.g_key_loyalty_no_wallet;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await _service.load(widget.walletAddress);
      if (mounted) setState(() => _snapshot = snapshot);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkIn() async {
    if (_checkingIn || _snapshot?.checkedInToday == true) return;
    setState(() => _checkingIn = true);
    try {
      final result = await _service.checkIn(widget.walletAddress);
      if (!mounted) return;
      final tx = result.transactionHash;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context).g_key_loyalty_checkin_success} +${result.points}'
            '${tx == null ? '' : '\n$tx'}',
          ),
          action: tx == null
              ? null
              : SnackBarAction(
                  label: S.of(context).g_key_loyalty_copy,
                  onPressed: () => Clipboard.setData(ClipboardData(text: tx)),
                ),
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context).g_key_loyalty_checkin_failed}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).g_key_loyalty_title),
          actions: [
            IconButton(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_snapshot == null) {
      return _LoyaltyStatusView(
        message: _error ?? S.of(context).g_key_loyalty_unavailable,
        onRetry: _load,
      );
    }
    final snapshot = _snapshot!;
    final dailyPoints = snapshot.tasks
        .where((task) => task.id == 'daily-checkin')
        .map((task) => task.points)
        .firstOrNull;
    return Column(
      children: [
        if (_error != null) _ServiceBanner(message: _error!),
        _PointsHeader(account: snapshot.account),
        _CheckInRow(
          checkedIn: snapshot.checkedInToday,
          points: dailyPoints,
          loading: _checkingIn,
          onPressed: _checkIn,
        ),
        TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: S.of(context).g_key_loyalty_tasks),
            Tab(text: S.of(context).g_key_loyalty_referral),
            Tab(text: S.of(context).g_key_loyalty_history),
            Tab(text: S.of(context).g_key_loyalty_leaderboard),
            Tab(text: S.of(context).g_key_loyalty_rewards),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _TasksList(tasks: snapshot.tasks),
              _ReferralsList(referrals: snapshot.referrals),
              _HistoryList(history: snapshot.history),
              _LeaderboardList(entries: snapshot.leaderboard),
              _RewardsList(rewards: snapshot.rewards),
            ],
          ),
        ),
      ],
    );
  }
}

class _PointsHeader extends StatelessWidget {
  const _PointsHeader({required this.account});

  final LoyaltyAccount account;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space12,
        AppSpacing.space8,
        AppSpacing.space12,
        AppSpacing.space6,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.space12),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: colors.border.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).g_key_loyalty_available_points,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSubtitle,
                    ),
                  ),
                  Text(
                    '${account.availablePoints}',
                    style: AppTypography.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            _PointStat(
              label: S.of(context).g_key_loyalty_total_earned,
              value: account.totalPoints,
            ),
            SizedBox(width: AppSpacing.space12),
            _PointStat(
              label: S.of(context).g_key_loyalty_used,
              value: account.usedPoints,
            ),
          ],
        ),
      ),
    );
  }
}

class _PointStat extends StatelessWidget {
  const _PointStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: AppTypography.bodyStrong.copyWith(color: colors.textPrimary),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: colors.textSubtitle),
        ),
      ],
    );
  }
}

class _CheckInRow extends StatelessWidget {
  const _CheckInRow({
    required this.checkedIn,
    required this.points,
    required this.loading,
    required this.onPressed,
  });

  final bool checkedIn;
  final int? points;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return ListTile(
      leading: Icon(
        checkedIn ? Icons.check_circle_rounded : Icons.calendar_today_rounded,
        color: checkedIn ? colors.success : colors.brand,
      ),
      title: Text(S.of(context).g_key_loyalty_daily_checkin),
      subtitle: Text(
        checkedIn
            ? S.of(context).g_key_loyalty_checked_today
            : points == null
            ? S.of(context).g_key_loyalty_daily_checkin
            : S.of(context).g_key_loyalty_earn_points(points!),
      ),
      trailing: FilledButton(
        onPressed: checkedIn || loading ? null : onPressed,
        child: loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                checkedIn
                    ? S.of(context).g_key_loyalty_checkin_done
                    : S.of(context).g_key_loyalty_checkin_btn,
              ),
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({required this.tasks});
  final List<LoyaltyTask> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return _EmptyText(S.of(context).g_key_loyalty_no_tasks);
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space8),
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        return ListTile(
          leading: Icon(
            task.status == LoyaltyTaskStatus.completed
                ? Icons.check_circle
                : Icons.task_alt,
          ),
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Text('+${task.points}'),
        );
      },
    );
  }
}

class _ReferralsList extends StatelessWidget {
  const _ReferralsList({required this.referrals});
  final List<LoyaltyReferral> referrals;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space8),
      itemCount: referrals.length + 1,
      itemBuilder: (_, index) {
        if (index == 0) {
          return ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: Text(S.of(context).g_key_loyalty_invite_friends),
            subtitle: Text(
              referrals.isEmpty
                  ? S.of(context).g_key_loyalty_no_referrals
                  : S.of(context).g_key_loyalty_invite_description,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingShare()),
            ),
          );
        }
        final referral = referrals[index - 1];
        return ListTile(
          leading: const Icon(Icons.person_add_alt_1_rounded),
          title: Text(_shortAddress(referral.address)),
          trailing: Text('+${referral.pointsEarned}'),
        );
      },
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});
  final List<LoyaltyHistoryItem> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _EmptyText(S.of(context).g_key_loyalty_no_history);
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space8),
      itemCount: history.length,
      itemBuilder: (_, index) {
        final item = history[index];
        final positive = item.points >= 0;
        return ListTile(
          leading: Icon(
            positive ? Icons.add_circle_outline : Icons.remove_circle_outline,
          ),
          title: Text(item.description),
          subtitle: item.createdAt == null
              ? null
              : Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(item.createdAt!),
                ),
          trailing: Text('${positive ? '+' : ''}${item.points}'),
        );
      },
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.entries});
  final List<LoyaltyLeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _EmptyText(S.of(context).g_key_loyalty_empty_leaderboard);
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space8),
      itemCount: entries.length,
      itemBuilder: (_, index) {
        final entry = entries[index];
        return ListTile(
          leading: SizedBox(width: 32, child: Text('#${entry.rank}')),
          title: Text(_shortAddress(entry.address)),
          trailing: Text('${entry.points} pts'),
        );
      },
    );
  }
}

class _RewardsList extends StatelessWidget {
  const _RewardsList({required this.rewards});
  final List<LoyaltyReward> rewards;

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      return _EmptyText(S.of(context).g_key_loyalty_no_rewards);
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space8),
      itemCount: rewards.length,
      itemBuilder: (_, index) {
        final reward = rewards[index];
        return ListTile(
          leading: const Icon(Icons.card_giftcard_rounded),
          title: Text(reward.name),
          subtitle: Text(reward.description),
          trailing: Text('${reward.pointsCost} pts'),
        );
      },
    );
  }
}

class _ServiceBanner extends StatelessWidget {
  const _ServiceBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Container(
      width: double.infinity,
      color: colors.warning.withValues(alpha: 0.12),
      padding: EdgeInsets.all(AppSpacing.space8),
      child: Text(message, textAlign: TextAlign.center),
    );
  }
}

class _LoyaltyStatusView extends StatelessWidget {
  const _LoyaltyStatusView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56),
            SizedBox(height: AppSpacing.space8),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.space12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(S.of(context).g_key_retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, textAlign: TextAlign.center));
  }
}

String _shortAddress(String value) {
  if (value.length <= 14) return value;
  return '${value.substring(0, 8)}...${value.substring(value.length - 6)}';
}
