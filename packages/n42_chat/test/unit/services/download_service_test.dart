import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/download_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('download_service_test');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('forwards custom headers to protected downloads', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      expect(request.headers.value('Authorization'), 'Bearer test-token');
      request.response.statusCode = HttpStatus.ok;
      request.response.contentLength = 4;
      request.response.add(const [1, 2, 3, 4]);
      await request.response.close();
    });

    final service = DownloadService();
    final savePath = '${tempDir.path}/protected.bin';
    final taskId = await service.download(
      url: 'http://${server.address.host}:${server.port}/protected.bin',
      savePath: savePath,
      fileName: 'protected.bin',
      headers: const {'Authorization': 'Bearer test-token'},
    );

    final completedTask = await service.waitForTaskCompletion(taskId);

    expect(completedTask.status, DownloadStatus.completed);
    expect(File(savePath).readAsBytesSync(), const [1, 2, 3, 4]);
  });
}
