import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/services/friend_details_store.dart';

class FriendPhotosPage extends StatefulWidget {
  final FriendDetailsStore store;
  final List<String> photos;
  final Future<bool> Function(List<String>) onSave;

  const FriendPhotosPage({
    super.key,
    required this.store,
    required this.photos,
    required this.onSave,
  });

  @override
  State<FriendPhotosPage> createState() => _FriendPhotosPageState();
}

class _FriendPhotosPageState extends State<FriendPhotosPage> {
  late List<String> _photos = List.of(widget.photos);
  bool _busy = false;

  Future<void> _addPhotos() async {
    if (_busy) return;
    setState(() => _busy = true);
    final imported = <String>[];
    var saved = false;
    try {
      final images = await ImagePicker().pickMultiImage(
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (!mounted || images.isEmpty) return;
      for (final image in images) {
        imported.add(await widget.store.importPhoto(image));
      }
      final next = [..._photos, ...imported];
      saved = await widget.onSave(next);
      if (saved && mounted) setState(() => _photos = next);
    } catch (_) {
      if (mounted) _showError();
    } finally {
      if (!saved) {
        for (final name in imported) {
          try {
            await widget.store.deletePhoto(name);
          } catch (_) {
            /* Best-effort cleanup. */
          }
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError() => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(S.of(context)?.commonSaveFailed ?? 'Save failed')),
  );

  Future<void> _delete(String name) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final next = _photos.where((photo) => photo != name).toList();
      if (await widget.onSave(next)) {
        if (mounted) setState(() => _photos = next);
        try {
          await widget.store.deletePhoto(name);
        } catch (_) {
          /* Best-effort cleanup. */
        }
      }
    } catch (_) {
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: Text(S.of(context)?.contactPhotos ?? 'Photos')),
      body: Column(
        children: [
          if (_busy) const LinearProgressIndicator(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .8,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final name = _photos[index];
                return Column(
                  children: [
                    Expanded(
                      child: FutureBuilder<File>(
                        future: widget.store.photo(name),
                        builder: (context, snapshot) {
                          final file = snapshot.data;
                          if (file == null)
                            return const Icon(Icons.image_outlined);
                          return InkWell(
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
                                        MaterialLocalizations.of(
                                          context,
                                        ).closeButtonLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: S.of(context)?.commonDelete ?? 'Delete',
                      onPressed: _busy ? null : () => _delete(name),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _busy ? null : _addPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(S.of(context)?.commonAdd ?? 'Add'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
