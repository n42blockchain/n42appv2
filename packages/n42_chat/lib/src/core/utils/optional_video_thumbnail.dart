import 'dart:typed_data';

/// A gallery preview is optional. Returning null lets the video sender try its
/// file-based thumbnail extractor and still send when no preview is available.
Future<Uint8List?> loadOptionalVideoThumbnail(
  Future<Uint8List?> Function() load,
) async {
  try {
    final bytes = await load();
    return bytes == null || bytes.isEmpty ? null : bytes;
  } catch (_) {
    return null;
  }
}
