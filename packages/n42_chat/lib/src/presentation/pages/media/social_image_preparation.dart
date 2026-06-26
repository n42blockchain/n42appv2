import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'media_editor_page.dart';

typedef SocialImageEditorLauncher =
    Future<Uint8List?> Function(
      BuildContext context, {
      required Uint8List imageBytes,
      String? filename,
    });

class PreparedSocialImage {
  final Uint8List bytes;
  final String filename;
  final String mimeType;

  const PreparedSocialImage({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });
}

Future<PreparedSocialImage?> prepareSocialImage(
  BuildContext context, {
  required XFile image,
  bool openEditor = true,
  SocialImageEditorLauncher editorLauncher = MediaEditorPage.open,
}) async {
  final originalBytes = await image.readAsBytes();
  if (!context.mounted) return null;

  Uint8List finalBytes = originalBytes;
  if (openEditor) {
    try {
      final editedBytes = await editorLauncher(
        context,
        imageBytes: originalBytes,
        filename: image.name,
      );
      if (editedBytes == null) return null;
      finalBytes = editedBytes;
    } catch (_) {
      // Keep the original selection if the editor fails.
      finalBytes = originalBytes;
    }
  }

  final originalFilename = _resolveOriginalFilename(image);
  final mimeType =
      lookupMimeType(originalFilename, headerBytes: finalBytes) ??
      image.mimeType ??
      'image/jpeg';

  return PreparedSocialImage(
    bytes: finalBytes,
    filename: _ensureFilenameMatchesMimeType(originalFilename, mimeType),
    mimeType: mimeType,
  );
}

final _slashRegex = RegExp(r'[\\/]');

String _resolveOriginalFilename(XFile image) {
  final explicitName = image.name.trim();
  if (explicitName.isNotEmpty) {
    return explicitName;
  }

  final path = image.path.trim();
  if (path.isNotEmpty) {
    final slashIndex = path.lastIndexOf(_slashRegex);
    if (slashIndex >= 0 && slashIndex < path.length - 1) {
      return path.substring(slashIndex + 1);
    }
    return path;
  }

  return 'image.jpg';
}

String _ensureFilenameMatchesMimeType(String filename, String mimeType) {
  final expectedExtension = switch (mimeType) {
    'image/png' => '.png',
    'image/webp' => '.webp',
    'image/gif' => '.gif',
    _ => '.jpg',
  };

  final lower = filename.toLowerCase();
  if (lower.endsWith(expectedExtension)) {
    return filename;
  }

  final dotIndex = filename.lastIndexOf('.');
  final basename = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
  return '$basename$expectedExtension';
}
