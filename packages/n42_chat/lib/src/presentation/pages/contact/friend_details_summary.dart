import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/services/friend_details_store.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';

/// Read-only preview of this account's private annotations on a friend.
class FriendDetailsSummary extends StatefulWidget {
  final String userId;
  final int revision;
  final VoidCallback onEdit;

  const FriendDetailsSummary({
    super.key,
    required this.userId,
    required this.revision,
    required this.onEdit,
  });

  @override
  State<FriendDetailsSummary> createState() => _FriendDetailsSummaryState();
}

class _FriendDetailsSummaryState extends State<FriendDetailsSummary> {
  Map<String, dynamic> _details = {};
  FriendDetailsStore? _store;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(FriendDetailsSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId ||
        widget.revision != oldWidget.revision) {
      _details = {};
      _store = null;
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final storage = SecureStorageDataSource();
      final session = await storage.getSession();
      if (session == null) return;
      final store = FriendDetailsStore(
        session['homeserver']!,
        session['userId']!,
        widget.userId,
      );
      final details = await store.load();
      final current = await storage.getSession();
      if (!mounted ||
          generation != _generation ||
          current?['userId'] != session['userId'] ||
          current?['homeserver'] != session['homeserver'])
        return;
      setState(() {
        _store = store;
        _details = details;
      });
    } catch (_) {
      // Keep the existing edit entry available if local data cannot be read.
    }
  }

  Widget _row(String label, String value) => Material(
    type: MaterialType.transparency,
    child: ListTile(
      title: Text(label),
      subtitle: Text(value),
      onTap: widget.onEdit,
      dense: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final phone = _details['phone'] as String? ?? '';
    final notes = _details['notes'] as String? ?? '';
    final tags = List<String>.from(_details['tags'] as List? ?? const []);
    final photos = List<String>.from(_details['photos'] as List? ?? const []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (phone.isNotEmpty) _row(strings?.contactPhone ?? 'Phone', phone),
        if (tags.isNotEmpty)
          _row(strings?.contactTags ?? 'Tags', tags.join(', ')),
        if (notes.isNotEmpty) _row(strings?.contactNotes ?? 'Notes', notes),
        if (photos.isNotEmpty && _store != null) ...[
          _row(
            strings?.contactPhotos ?? 'Photos',
            strings?.contactPhotoCount(photos.length) ??
                '${photos.length} photos',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final name in photos) _thumbnail(name)],
            ),
          ),
        ],
      ],
    );
  }

  Widget _thumbnail(String name) => FutureBuilder<File>(
    key: ValueKey('${_store!.key}/$name'),
    future: _store!.photo(name),
    builder: (context, snapshot) {
      final file = snapshot.data;
      return SizedBox(
        width: 64,
        height: 64,
        child: file == null
            ? const Icon(Icons.image_outlined)
            : InkWell(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: InteractiveViewer(
                            child: Image.file(
                              file,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            MaterialLocalizations.of(context).closeButtonLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
              ),
      );
    },
  );
}
