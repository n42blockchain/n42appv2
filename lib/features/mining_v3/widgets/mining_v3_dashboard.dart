import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_activity.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/generated/l10n.dart';

String miningV3Number(BuildContext context, num value) {
  final locale = Localizations.localeOf(context).toString();
  return NumberFormat.decimalPattern(
    NumberFormat.localeExists(locale) ? locale : 'en',
  ).format(value);
}

String miningV3Duration(Duration? value) {
  if (value == null) return '—';
  final hours = value.inHours.toString().padLeft(2, '0');
  final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String miningV3BlockLabel(S s, MiningV3BlockState state) => switch (state) {
  MiningV3BlockState.pending => s.miningV3Pending,
  MiningV3BlockState.certified => s.miningV3CertifiedStatus,
  MiningV3BlockState.uncertified => s.miningV3Uncertified,
  MiningV3BlockState.failed => s.miningV3Failed,
};

AppBadgeTone miningV3BlockTone(MiningV3BlockState state) => switch (state) {
  MiningV3BlockState.pending => AppBadgeTone.brand,
  MiningV3BlockState.certified => AppBadgeTone.success,
  MiningV3BlockState.uncertified => AppBadgeTone.warning,
  MiningV3BlockState.failed => AppBadgeTone.danger,
};

enum _BlockFilter { all, certified, pending, attention }

/// The product surface; networking and private-key handling stay in the engine.
class MiningV3Dashboard extends StatefulWidget {
  const MiningV3Dashboard({
    super.key,
    required this.engine,
    required this.endpoint,
    required this.onToggle,
    required this.onSettings,
    required this.onBlock,
    this.onMenu,
    this.loading = false,
    this.bottomInset = 0,
  });

  final MiningV3Engine engine;
  final String endpoint;
  final VoidCallback? onToggle;
  final VoidCallback onSettings;
  final ValueChanged<MiningV3Block> onBlock;
  final VoidCallback? onMenu;
  final bool loading;
  final double bottomInset;

  @override
  State<MiningV3Dashboard> createState() => _MiningV3DashboardState();
}

class _MiningV3DashboardState extends State<MiningV3Dashboard> {
  _BlockFilter _filter = _BlockFilter.all;
  int _visible = 10;
  DateTime? _session;

  @override
  void initState() {
    super.initState();
    _session = widget.engine.sessionStartedAt;
  }

  @override
  void didUpdateWidget(MiningV3Dashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_session != widget.engine.sessionStartedAt) {
      _session = widget.engine.sessionStartedAt;
      _visible = 10;
    }
  }

  String _phase(S s) => widget.engine.pausedForBackground
      ? s.miningV3BackgroundPaused
      : switch (widget.engine.phase) {
          MiningV3Phase.idle =>
            widget.engine.sessionStartedAt == null
                ? s.miningV3Ready
                : s.miningV3Paused,
          MiningV3Phase.connecting => s.miningV3Connecting,
          MiningV3Phase.registering => s.miningV3Registering,
          MiningV3Phase.mining => s.miningV3Active,
          MiningV3Phase.retrying => s.miningV3Retrying,
        };

  bool _matches(MiningV3Block block) => switch (_filter) {
    _BlockFilter.all => true,
    _BlockFilter.certified => block.state == MiningV3BlockState.certified,
    _BlockFilter.pending => block.state == MiningV3BlockState.pending,
    _BlockFilter.attention =>
      block.state == MiningV3BlockState.failed ||
          block.state == MiningV3BlockState.uncertified,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    final engine = widget.engine;
    final blocks = engine.blocks.where(_matches).toList();
    final visible = blocks.take(_visible).toList();
    return Scaffold(
      backgroundColor: c.bgBase,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: c.bgBase,
        leading: widget.onMenu == null
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                onPressed: widget.onMenu,
                icon: Icon(Icons.menu_rounded, color: c.brand),
              ),
        title: Wrap(
          spacing: AppSpacing.space4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              s.miningV3Title,
              style: AppTypography.title.copyWith(color: c.textPrimary),
            ),
            const AppBadge(label: 'V3', tone: AppBadgeTone.brand),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('mining_v3_settings'),
            tooltip: s.miningV3Settings,
            onPressed: widget.onSettings,
            icon: Icon(Icons.tune_rounded, color: c.brand),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: engine.refresh,
        child: CustomScrollView(
          key: const PageStorageKey('mining_v3_dashboard'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: AppSpacing.pageHorizontal,
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSpacing.space4),
                    _hero(context),
                    SizedBox(height: AppSpacing.space8),
                    _statistics(context),
                    SizedBox(height: AppSpacing.space8),
                    _rewards(context),
                    SizedBox(height: AppSpacing.space8),
                    _connection(context),
                    if (engine.phase == MiningV3Phase.retrying ||
                        (!engine.running &&
                            !engine.pausedForBackground &&
                            engine.lastError != null)) ...[
                      SizedBox(height: AppSpacing.space8),
                      _connectionIssue(context),
                    ],
                    SizedBox(height: AppSpacing.space12),
                    Text(
                      s.miningV3RecentBlocks,
                      style: AppTypography.headline.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.space2),
                    Text(
                      s.miningV3RecentHint,
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.space4),
                    Wrap(
                      spacing: AppSpacing.space4,
                      runSpacing: AppSpacing.space2,
                      children: [
                        for (final entry in {
                          _BlockFilter.all: s.miningV3All,
                          _BlockFilter.certified: s.miningV3CertifiedStatus,
                          _BlockFilter.pending: s.miningV3Pending,
                          _BlockFilter.attention: s.miningV3Attention,
                        }.entries)
                          ChoiceChip(
                            key: ValueKey('mining_v3_filter_${entry.key.name}'),
                            label: Text(entry.value),
                            selected: _filter == entry.key,
                            onSelected: (_) => setState(() {
                              _filter = entry.key;
                              _visible = 10;
                            }),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.space8),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              SliverPadding(
                padding: AppSpacing.pageHorizontal,
                sliver: SliverToBoxAdapter(child: _empty(context)),
              )
            else
              SliverPadding(
                padding: AppSpacing.pageHorizontal,
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: AppSpacing.space4),
                  itemBuilder: (context, index) =>
                      _block(context, visible[index]),
                ),
              ),
            if (blocks.length > visible.length)
              SliverPadding(
                padding: AppSpacing.cardInset,
                sliver: SliverToBoxAdapter(
                  child: AppButton(
                    label: s.miningV3LoadMore,
                    variant: AppButtonVariant.text,
                    onPressed: () => setState(() => _visible += 20),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space16 + widget.bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    Color shade(Color color) => Color.alphaBlend(
      AppColorTokens.overlay.withValues(
        alpha: color.computeLuminance() > .25 ? .6 : .2,
      ),
      color,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shade(c.brand), shade(AppColorTokens.brandOnOverlay)],
        ),
        borderRadius: AppRadius.brXl,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.space4,
              runSpacing: AppSpacing.space4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.engine.running
                          ? Icons.shield_outlined
                          : Icons.pause_circle_outline,
                      size: AppSpacing.space12,
                      color: AppColorTokens.onOverlayPrimary,
                    ),
                    SizedBox(width: AppSpacing.space4),
                    Flexible(
                      child: Text(
                        _phase(s),
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColorTokens.onOverlayPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.engine.deviceIndex case final int index)
                  Text(
                    s.miningV3Device(miningV3Number(context, index)),
                    style: AppTypography.caption.copyWith(
                      color: AppColorTokens.onOverlaySecondary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.space12),
            Text(
              s.miningV3Duration,
              style: AppTypography.footnote.copyWith(
                color: AppColorTokens.onOverlaySecondary,
              ),
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              miningV3Duration(widget.engine.sessionDuration),
              key: const ValueKey('mining_v3_duration'),
              style: AppTypography.displayXl.copyWith(
                color: AppColorTokens.onOverlayPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.space12),
            AppButton(
              key: const ValueKey('mining_v3_toggle'),
              label: widget.engine.running || widget.engine.pausedForBackground
                  ? s.miningV3Pause
                  : widget.endpoint.isEmpty
                  ? s.miningV3Setup
                  : s.miningV3Start,
              icon: widget.engine.running
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              loading: widget.loading || widget.engine.busy,
              onPressed: widget.onToggle,
            ),
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                s.miningV3IOSForegroundHint,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.onOverlaySecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statistics(BuildContext context) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    final e = widget.engine;
    final samples = e.blocks
        .where(
          (b) => b.elapsedMs != null && b.state != MiningV3BlockState.failed,
        )
        .toList();
    final average = samples.isEmpty
        ? null
        : (samples.fold<int>(0, (sum, b) => sum + b.elapsedMs!) /
                  samples.length)
              .round();
    final attempts = e.verified + e.failed;
    final success = attempts == 0
        ? '—'
        : '${(100 * e.verified / attempts).round()}%';
    final cards = [
      _stat(
        context,
        s.miningV3Verified,
        miningV3Number(context, e.verified),
        Icons.layers_outlined,
        c.brand,
      ),
      _stat(
        context,
        s.miningV3Certified,
        miningV3Number(context, e.certified),
        Icons.verified_outlined,
        c.success,
      ),
      _stat(
        context,
        s.miningV3SuccessRate,
        success,
        Icons.task_alt_rounded,
        c.brand,
      ),
      _stat(
        context,
        s.miningV3AverageTime,
        average == null
            ? '—'
            : s.miningV3Milliseconds(miningV3Number(context, average)),
        Icons.timer_outlined,
        c.info,
      ),
    ];
    final single = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    return Column(
      children: [
        for (var i = 0; i < cards.length; i += single ? 1 : 2) ...[
          if (i > 0) SizedBox(height: AppSpacing.space4),
          if (single)
            cards[i]
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[i]),
                  SizedBox(width: AppSpacing.space4),
                  Expanded(child: cards[i + 1]),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _stat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final c = AppColorTokens.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSpacing.space12),
          SizedBox(height: AppSpacing.space4),
          Text(
            value,
            style: AppTypography.titleLg.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _rewards(BuildContext context) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: c.brand,
                size: AppSpacing.space12,
              ),
              SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Text(
                  s.miningV3Rewards,
                  style: AppTypography.bodyStrong.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: s.miningV3Rewards,
                onPressed: () => showAppSheet<void>(
                  context,
                  builder: (context) => Padding(
                    padding: EdgeInsets.all(AppSpacing.space8),
                    child: Text(
                      s.miningV3RewardsInfo,
                      style: AppTypography.body.copyWith(color: c.textPrimary),
                    ),
                  ),
                ),
                icon: Icon(Icons.info_outline_rounded, color: c.textTertiary),
              ),
            ],
          ),
          Text(
            s.miningV3RewardsUnavailable,
            style: AppTypography.title.copyWith(color: c.textPrimary),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            s.miningV3RewardsHint,
            style: AppTypography.caption.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _connection(BuildContext context) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    final url = widget.engine.running || widget.engine.pausedForBackground
        ? widget.engine.endpoint ?? widget.endpoint
        : widget.endpoint;
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    final title = host.isEmpty
        ? s.miningV3Configure
        : uri!.hasPort
        ? '$host:${uri.port}'
        : host;
    return AppCard(
      onTap: widget.onSettings,
      child: Row(
        children: [
          Icon(Icons.dns_outlined, color: c.brand, size: AppSpacing.space12),
          SizedBox(width: AppSpacing.space6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(color: c.textPrimary),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  url == miningV3LocalTestnetEndpoint
                      ? s.miningV3LocalTestnet
                      : s.miningV3Node,
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textTertiary),
        ],
      ),
    );
  }

  Widget _connectionIssue(BuildContext context) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: c.warning,
            size: AppSpacing.space12,
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.miningV3ConnectionIssue,
                  style: AppTypography.bodyStrong.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  widget.engine.running
                      ? s.miningV3RetryHint
                      : s.miningV3StartIssueHint,
                  style: AppTypography.footnote.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    final noActivity = widget.engine.blocks.isEmpty;
    return AppCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space12),
        child: Column(
          children: [
            Icon(
              Icons.layers_outlined,
              size: AppSpacing.space16,
              color: c.brand,
            ),
            SizedBox(height: AppSpacing.space6),
            Text(
              noActivity ? s.miningV3EmptyTitle : s.miningV3FilterEmpty,
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
            ),
            if (noActivity) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                s.miningV3EmptyBody,
                textAlign: TextAlign.center,
                style: AppTypography.footnote.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _block(BuildContext context, MiningV3Block block) {
    final s = S.of(context);
    final c = AppColorTokens.of(context);
    final details = [
      if (block.time != null) block.time!,
      if (block.transactions != null)
        s.miningV3Transactions(miningV3Number(context, block.transactions!)),
      if (block.elapsedMs != null)
        s.miningV3Milliseconds(miningV3Number(context, block.elapsedMs!)),
    ].join(' · ');
    final compact = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final badge = AppBadge(
      label: miningV3BlockLabel(s, block.state),
      tone: miningV3BlockTone(block.state),
    );
    return AppCard(
      key: ValueKey('mining_v3_block_${block.number}'),
      onTap: () => widget.onBlock(block),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact) ...[
            Text(
              s.miningV3Block(miningV3Number(context, block.number)),
              style: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
            ),
            SizedBox(height: AppSpacing.space4),
            badge,
          ] else
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.miningV3Block(miningV3Number(context, block.number)),
                    style: AppTypography.bodyStrong.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                badge,
              ],
            ),
          if (details.isNotEmpty) ...[
            SizedBox(height: AppSpacing.space4),
            Text(
              details,
              style: AppTypography.caption.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
