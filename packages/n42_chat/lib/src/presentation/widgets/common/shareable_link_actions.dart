import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

class ShareableLinkPresentation {
  final String entityName;
  final String linkLabel;
  final String qrCodeTitle;
  final String errorPrefix;
  final String? qrCodeSubtitle;
  final String? copySuccessMessage;
  final IconData icon;

  const ShareableLinkPresentation({
    required this.entityName,
    required this.linkLabel,
    required this.qrCodeTitle,
    required this.errorPrefix,
    this.qrCodeSubtitle,
    this.copySuccessMessage,
    this.icon = Icons.link_outlined,
  });
}

Future<void> showResolvedShareableLinkActions(
  BuildContext context, {
  required Future<String> Function() resolveLink,
  required ShareableLinkPresentation presentation,
}) async {
  final link = await _resolveShareableLink(
    context,
    resolveLink: resolveLink,
    presentation: presentation,
  );
  if (link == null || !context.mounted) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(presentation.icon),
            title: Text(presentation.linkLabel),
            subtitle: Text(link, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: Text(presentation.qrCodeTitle),
            onTap: () async {
              Navigator.pop(sheetContext);
              await _openShareableLinkQrPage(
                context,
                link: link,
                presentation: presentation,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('Copy Link'),
            onTap: () async {
              Navigator.pop(sheetContext);
              await Clipboard.setData(ClipboardData(text: link));
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    presentation.copySuccessMessage ??
                        (S.of(context)?.commonCopiedToClipboard ??
                            'Copied to clipboard'),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(S.of(context)?.commonShare ?? 'Share'),
            onTap: () async {
              Navigator.pop(sheetContext);
              await SharePlus.instance.share(
                ShareParams(text: link, subject: presentation.entityName),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showResolvedShareableLinkQrPage(
  BuildContext context, {
  required Future<String> Function() resolveLink,
  required ShareableLinkPresentation presentation,
}) async {
  final link = await _resolveShareableLink(
    context,
    resolveLink: resolveLink,
    presentation: presentation,
  );
  if (link == null || !context.mounted) {
    return;
  }

  await _openShareableLinkQrPage(
    context,
    link: link,
    presentation: presentation,
  );
}

Future<String?> _resolveShareableLink(
  BuildContext context, {
  required Future<String> Function() resolveLink,
  required ShareableLinkPresentation presentation,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final link = await resolveLink();
    return link;
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('${presentation.errorPrefix}: $e')),
      );
    }
    return null;
  }
}

Future<void> _openShareableLinkQrPage(
  BuildContext context, {
  required String link,
  required ShareableLinkPresentation presentation,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          _ShareableLinkQrPage(link: link, presentation: presentation),
    ),
  );
}

class _ShareableLinkQrPage extends StatefulWidget {
  final String link;
  final ShareableLinkPresentation presentation;

  const _ShareableLinkQrPage({required this.link, required this.presentation});

  @override
  State<_ShareableLinkQrPage> createState() => _ShareableLinkQrPageState();
}

class _ShareableLinkQrPageState extends State<_ShareableLinkQrPage> {
  final GlobalKey _qrCardKey = GlobalKey();

  Future<Uint8List?> _captureQrCard() async {
    final boundary =
        _qrCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.link));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.presentation.copySuccessMessage ??
              (S.of(context)?.commonCopiedToClipboard ?? 'Copied to clipboard'),
        ),
      ),
    );
  }

  Future<void> _shareQrCard() async {
    try {
      final bytes = await _captureQrCard();
      if (bytes == null) {
        await SharePlus.instance.share(
          ShareParams(
            text: widget.link,
            subject: widget.presentation.entityName,
          ),
        );
        return;
      }

      await SharePlus.instance.share(
        ShareParams(
          text: widget.link,
          subject: widget.presentation.entityName,
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name: 'shareable-link-qr.png',
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.commonShareFailed(e.toString()) ?? 'Share failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final backgroundColor = AppColors.bgOf(isDark);
    final cardColor = context.surfaceColor;
    final primaryText = AppColors.textPrimaryOf(isDark);
    final secondaryText = AppColors.textSecondaryOf(isDark);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          widget.presentation.qrCodeTitle,
          style: TextStyle(color: primaryText),
        ),
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  key: _qrCardKey,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 360),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            widget.presentation.icon,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.presentation.entityName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        if (widget.presentation.qrCodeSubtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.presentation.qrCodeSubtitle!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: secondaryText,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: QrImageView(
                            data: widget.link,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            widget.link,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _shareQrCard,
                    icon: const Icon(Icons.share_outlined),
                    label: Text(S.of(context)?.commonShare ?? 'Share'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _copyLink,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy Link'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
