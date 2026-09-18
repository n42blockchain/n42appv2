import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// A short-lived local source for authenticated media. Native players may lose
/// headers or require range support that the homeserver does not provide.
class AuthenticatedVideoSource {
  final http.Client _client;
  final Future<Directory> Function() _temporaryDirectory;
  Directory? _directory;
  bool _disposed = false;

  AuthenticatedVideoSource({
    http.Client? client,
    Future<Directory> Function()? temporaryDirectory,
  }) : _client = client ?? http.Client(),
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  Future<File> load(Uri uri, Map<String, String> headers) async {
    const limit = 100 * 1024 * 1024;
    final origin = uri.origin;
    var target = uri;
    try {
      final base = await _temporaryDirectory();
      if (_disposed) throw StateError('Video loading cancelled');
      final directory = await base.createTemp('n42-video-');
      _directory = directory;
      if (_disposed) throw StateError('Video loading cancelled');
      for (var redirects = 0; redirects <= 3; redirects++) {
        final request = http.Request('GET', target)..followRedirects = false;
        if (target.origin == origin) request.headers.addAll(headers);
        final response = await _client
            .send(request)
            .timeout(const Duration(seconds: 30));
        if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
          final location = response.headers['location'];
          await response.stream.drain<void>().timeout(
            const Duration(seconds: 30),
          );
          if (location == null) throw StateError('Invalid media redirect');
          target = target.resolve(location);
          if (target.scheme != 'https' &&
              !(uri.scheme == 'http' && target.origin == origin)) {
            throw StateError('Unsafe media redirect');
          }
          continue;
        }
        if (response.statusCode != 200 ||
            (response.contentLength ?? 0) > limit) {
          throw StateError('Video download failed');
        }
        final file = File('${directory.path}/video.mp4');
        final sink = file.openWrite();
        var size = 0;
        try {
          await for (final chunk in response.stream.timeout(
            const Duration(seconds: 30),
          )) {
            if (_disposed) throw StateError('Video loading cancelled');
            size += chunk.length;
            if (size > limit) throw StateError('Video exceeds download limit');
            sink.add(chunk);
          }
          await sink.flush();
        } finally {
          await sink.close();
        }
        if (size == 0 || _disposed)
          throw StateError('Empty or cancelled video');
        return file;
      }
      throw StateError('Too many media redirects');
    } catch (_) {
      await dispose();
      rethrow;
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _client.close();
    final directory = _directory;
    if (directory != null && await directory.exists()) {
      try {
        await directory.delete(recursive: true);
      } on FileSystemException {
        /* A pending reader may finish cleanup. */
      }
    }
  }
}
