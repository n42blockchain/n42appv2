import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/media_lifecycle_service.dart';
import 'package:n42_chat/src/core/services/storage_cleanup_service.dart';
import 'package:n42_chat/src/core/services/storage_manager_service.dart';
import 'package:n42_chat/src/data/datasources/local/media_metadata_database.dart';

class _Lifecycle extends Mock implements MediaLifecycleService {
  List<MediaFile> files = const [];
  int cleanableQueries = 0;
  List<String>? cleanedPaths;

  @override
  Future<List<MediaFile>> getCleanableFiles({
    int? olderThanDays,
    String? roomId,
    String? fileCategory,
    int? minFileSizeBytes,
    bool preserveThumbnails = true,
  }) async {
    cleanableQueries++;
    return files;
  }

  @override
  Future<CleanupResult> cleanupFiles(List<String> filePaths) async {
    cleanedPaths = List.of(filePaths);
    final bytes = files
        .where((file) => filePaths.contains(file.filePath))
        .fold<int>(0, (total, file) => total + file.fileSize);
    return CleanupResult(filesDeleted: filePaths.length, bytesFreed: bytes);
  }
}

class _StorageManager extends Mock implements StorageManagerService {}

MediaFile _file(String path, DateTime accessedAt, int size) => MediaFile(
  filePath: path,
  mxcUrl: 'mxc://example/$path',
  roomId: '!room:example.org',
  fileCategory: 'image',
  fileSize: size,
  isThumbnail: false,
  downloadedAt: accessedAt,
  lastAccessedAt: accessedAt,
  isCleaned: false,
  isPinned: false,
);

void main() {
  late _Lifecycle lifecycle;
  late _StorageManager storageManager;
  late StorageCleanupService service;

  setUp(() {
    lifecycle = _Lifecycle();
    storageManager = _StorageManager();
    service = StorageCleanupService(
      lifecycleService: lifecycle,
      storageManager: storageManager,
    );
  });

  test(
    'date-range cleanup keeps inclusive boundaries and excludes outside files',
    () async {
      final start = DateTime(2024, 5, 10);
      final end = DateTime(2024, 5, 12);
      lifecycle.files = [
        _file('before.jpg', start.subtract(const Duration(seconds: 1)), 1),
        _file('start.jpg', start, 10),
        _file('inside.jpg', DateTime(2024, 5, 11), 20),
        _file('end.jpg', end, 30),
        _file('after.jpg', end.add(const Duration(seconds: 1)), 2),
      ];

      final result = await service.cleanupByDateRange(
        startDate: start,
        endDate: end,
      );

      expect(lifecycle.cleanedPaths, ['start.jpg', 'inside.jpg', 'end.jpg']);
      expect(result.filesDeleted, 3);
      expect(result.bytesFreed, 60);
      verify(() => storageManager.invalidateCache()).called(1);
    },
  );

  test(
    'reversed date range returns without querying or deleting files',
    () async {
      final result = await service.cleanupByDateRange(
        startDate: DateTime(2024, 5, 13),
        endDate: DateTime(2024, 5, 12),
      );

      expect(result.filesDeleted, 0);
      expect(result.bytesFreed, 0);
      expect(lifecycle.cleanableQueries, 0);
      expect(lifecycle.cleanedPaths, isNull);
      verifyNever(() => storageManager.invalidateCache());
    },
  );
}
