// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_campaign.dart';
import 'package:n42_wallet/features/airdrop/services/airdrop_service.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_select_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class AirdropHomePage extends StatefulWidget {
  const AirdropHomePage({super.key, required this.walletAddress, this.service});

  final String walletAddress;
  final AirdropService? service;

  @override
  State<AirdropHomePage> createState() => _AirdropHomePageState();
}

class _AirdropHomePageState extends State<AirdropHomePage> {
  late final AirdropService _service = widget.service ?? AirdropService();
  late final bool _ownsService = widget.service == null;
  List<AirdropCampaign> _campaigns = const [];
  bool _loading = true;
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final campaigns = await _service.getCampaigns(
        walletAddress: widget.walletAddress,
      );
      if (!mounted) return;
      setState(() => _campaigns = campaigns);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Uri url) async {
    if (PhishingDetector.instance.checkUrl(url.toString()) ==
        PhishingCheckResult.phishing) {
      final proceed = await showPhishingWarningDialog(context, url.toString());
      if (proceed != true || !mounted) return;
      PhishingDetector.instance.allowForSession(url.toString());
    }
    // 无 URL 处理器的设备上 launchUrl 会抛 PlatformException，未捕获会直接
    // 崩掉整页；失败与「打不开」走同一条提示。
    bool opened;
    try {
      opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).g_key_error_4)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).g_key_airdrop_title),
          actions: [
            IconButton(
              tooltip: MaterialLocalizations.of(
                context,
              ).refreshIndicatorSemanticLabel,
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.explore_outlined),
                text: S.of(context).g_key_airdrop_discover,
              ),
              Tab(
                icon: const Icon(Icons.public_rounded),
                text: S.of(context).g_key_airdrop_sources,
              ),
              Tab(
                icon: const Icon(Icons.send_rounded),
                text: S.of(context).g_key_airdrop_distribute,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDiscover(colors),
            _buildSources(colors),
            _buildDistribute(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscover(AppColorTokens colors) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _campaigns.isEmpty) {
      return _StatusView(
        icon: Icons.cloud_off_rounded,
        title: S.of(context).g_key_airdrop_no_airdrops,
        detail: _error!,
        actionLabel: S.of(context).g_key_retry,
        onAction: _load,
      );
    }
    if (_campaigns.isEmpty) {
      return _StatusView(
        icon: Icons.inbox_outlined,
        title: S.of(context).g_key_airdrop_no_airdrops,
        detail: S.of(context).g_key_airdrop_sources_hint,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.space12),
        itemCount: _campaigns.length + (_error == null ? 0 : 1),
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.space8),
        itemBuilder: (context, index) {
          if (_error != null && index == 0) {
            return _InlineWarning(message: _error!);
          }
          final campaign = _campaigns[index - (_error == null ? 0 : 1)];
          return _CampaignTile(campaign: campaign, onOpen: _open);
        },
      ),
    );
  }

  Widget _buildSources(AppColorTokens colors) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.space12),
      itemCount: AirdropService.sources.length + 1,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.space8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _InlineWarning(
            message: S.of(context).g_key_airdrop_thirdparty_warning,
          );
        }
        final source = AirdropService.sources[index - 1];
        return ListTile(
          tileColor: colors.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          leading: const Icon(Icons.open_in_new_rounded),
          title: Text(source.name),
          subtitle: Text(source.description),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _open(source.url),
        );
      },
    );
  }

  Widget _buildDistribute(AppColorTokens colors) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_to_mobile_rounded, size: 56, color: colors.brand),
            SizedBox(height: AppSpacing.space12),
            Text(
              S.of(context).g_key_batch_title,
              style: AppTypography.headline.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.space6),
            Text(
              S.of(context).g_key_batch_send_multiple,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: colors.textSubtitle),
            ),
            SizedBox(height: AppSpacing.space16),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(S.of(context).g_key_batch_select_token),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BatchTransferSelectPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignTile extends StatelessWidget {
  const _CampaignTile({required this.campaign, required this.onOpen});

  final AirdropCampaign campaign;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final status = switch (campaign.status) {
      AirdropCampaignStatus.active => S.of(context).g_key_airdrop_active,
      AirdropCampaignStatus.upcoming => S.of(context).g_key_airdrop_upcoming,
      AirdropCampaignStatus.ended => S.of(context).g_key_airdrop_expired,
      AirdropCampaignStatus.unknown => S.of(context).g_key_airdrop_pending,
    };
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.brMd,
      child: InkWell(
        borderRadius: AppRadius.brMd,
        onTap: campaign.claimUrl == null
            ? null
            : () => onOpen(campaign.claimUrl!),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.name,
                      style: AppTypography.bodyStrong.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    status,
                    style: AppTypography.caption.copyWith(color: colors.brand),
                  ),
                ],
              ),
              if (campaign.description.isNotEmpty) ...[
                SizedBox(height: AppSpacing.space4),
                Text(
                  campaign.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: colors.textSubtitle,
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.space8),
              Row(
                children: [
                  Icon(
                    Icons.source_outlined,
                    size: 16,
                    color: colors.textSubtitle,
                  ),
                  SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: Text(
                      campaign.sourceName,
                      style: AppTypography.caption.copyWith(
                        color: colors.textSubtitle,
                      ),
                    ),
                  ),
                  if (campaign.symbol != null)
                    Text(campaign.symbol!, style: AppTypography.caption),
                  if (campaign.canOpenClaim) ...[
                    SizedBox(width: AppSpacing.space6),
                    const Icon(Icons.open_in_new_rounded, size: 16),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.12),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: colors.warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning),
          SizedBox(width: AppSpacing.space8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.textSubtitle),
            SizedBox(height: AppSpacing.space8),
            Text(
              title,
              style: AppTypography.headline.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(color: colors.textSubtitle),
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: AppSpacing.space12),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
