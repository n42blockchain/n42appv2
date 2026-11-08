import 'package:flutter/material.dart';
import 'package:n42_wallet/features/browser/models/watch_asset_metadata.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Lists an asset only after an explicit choice and an acknowledged write.
/// This sheet never requests a key, signature or transaction.
class DAppAssetSuggestionSheet extends StatefulWidget {
  final String origin;
  final String chainName;
  final WatchAssetMetadata asset;
  final Future<void> Function() onApprove;

  const DAppAssetSuggestionSheet({
    required this.origin,
    required this.chainName,
    required this.asset,
    required this.onApprove,
    super.key,
  });

  @override
  State<DAppAssetSuggestionSheet> createState() =>
      _DAppAssetSuggestionSheetState();
}

class _DAppAssetSuggestionSheetState extends State<DAppAssetSuggestionSheet> {
  bool _saving = false;
  bool _failed = false;

  Future<void> _approve() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onApprove();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final asset = widget.asset;
    Widget detail(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
    return PopScope(
      canPop: !_saving,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .85,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.g_token_m_key_20,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        detail(s.g_key_m_9, widget.origin),
                        detail(
                          s.g_token_m_key_13,
                          '${widget.chainName} (${asset.request.chainId})',
                        ),
                        detail(
                          s.g_token_m_key_6,
                          asset.request.address.eip55With0x,
                        ),
                        detail(s.g_token_m_key_7, asset.symbol),
                        detail(s.g_token_m_key_8, '${asset.decimals}'),
                      ],
                    ),
                  ),
                ),
                if (_failed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      s.g_key_3,
                      key: const ValueKey('asset-save-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(s.g_key_79),
                    ),
                    FilledButton(
                      onPressed: _saving ? null : _approve,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(s.g_key_159),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
