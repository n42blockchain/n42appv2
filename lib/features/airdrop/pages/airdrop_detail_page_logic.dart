// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'airdrop_detail_page.dart';

/// Logic mixin: state accessors, date formatting, URL launching, social icons.
mixin AirdropDetailLogicMixin on State<AirdropDetailPage> {
  /// Retrieve the latest model from provider (falls back to the constructor snapshot).
  AirdropModel get currentAirdrop {
    final found = widget.provider.airdrops
        .where((a) => a.id == widget.airdrop.id)
        .firstOrNull;
    return found ?? widget.airdrop;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> subscribeAlert(BuildContext context, AirdropModel airdrop) async {
    final success = await widget.provider.subscribeAlert(airdrop.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Reminder set! We\'ll notify you when ${airdrop.name} is live.'
              : 'Failed to set reminder. Please try again.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> launchExternalUrl(BuildContext context, String url) async {
    // Phishing check before opening in the external browser
    final result = PhishingDetector.instance.checkUrl(url);
    if (result == PhishingCheckResult.phishing) {
      if (!context.mounted) return;
      final proceed = await showPhishingWarningDialog(context, url);
      if (proceed != true) return;
      // User accepted the risk -- whitelist for this session
      PhishingDetector.instance.allowForSession(url);
    }

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to launch URL: $url, error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  IconData getSocialIcon(String platform) => switch (platform.toLowerCase()) {
        'twitter' => Icons.alternate_email,
        'discord' => Icons.discord,
        'telegram' => Icons.telegram,
        'github' => Icons.code,
        _ => Icons.link,
      };
}
