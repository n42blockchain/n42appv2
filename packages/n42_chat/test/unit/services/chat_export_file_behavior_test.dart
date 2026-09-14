import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/chat_export_service.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getTemporaryPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dev.fluttercommunity.plus/share');
  late Directory directory;
  late PathProviderPlatform originalPaths;
  late List<MethodCall> shares;
  final service = ChatExportService.instance;
  MessageEntity message(String id, int day, {int? lifetime}) => MessageEntity(
    id: id,
    roomId: 'fixture-room',
    senderId: 'fixture-sender',
    senderName: '<Alice>',
    content: id,
    type: MessageType.text,
    timestamp: DateTime(2026, 9, day),
    selfDestructAfter: lifetime,
  );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('n42-export-files-');
    originalPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(directory.path);
    shares = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          shares.add(call);
          return 'fixture-share-result';
        });
  });
  tearDown(() async {
    PathProviderPlatform.instance = originalPaths;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await directory.delete(recursive: true);
  });

  for (final format in ExportFormat.values) {
    test(
      '${format.name} file export filters ephemeral content and sorts without changing input',
      () async {
        final input = [
          message('newer-message', 12),
          message('ephemeral-fixture', 11, lifetime: 10),
          message('older-message', 10),
        ];
        final file = await service.exportChat(
          messages: input,
          roomName: 'Room/../../Name',
          format: format,
        );
        expect(file.path, startsWith('${directory.path}/'));
        expect(file.path, endsWith('.${format.name}'));
        expect(file.path, isNot(contains('/../')));
        final text = await file.readAsString();
        expect(text, isNot(contains('ephemeral-fixture')));
        expect(
          text.indexOf('older-message'),
          lessThan(text.indexOf('newer-message')),
        );
        expect(input.map((m) => m.id), [
          'newer-message',
          'ephemeral-fixture',
          'older-message',
        ]);
        if (format == ExportFormat.json) {
          expect(jsonDecode(text)['messageCount'], 2);
        } else if (format == ExportFormat.html) {
          expect(text, contains('&lt;Alice&gt;'));
          expect(text, isNot(contains('<Alice>')));
        }
      },
    );
    test(
      '${format.name} consecutive exports retain the earlier file contents',
      () async {
        final first = await service.exportChat(
          messages: [message('first-content', 10)],
          roomName: 'Same room',
          format: format,
        );
        final firstText = await first.readAsString();
        final second = await service.exportChat(
          messages: [message('second-content', 10)],
          roomName: 'Same room',
          format: format,
        );
        expect(second.path, isNot(first.path));
        expect(await first.readAsString(), firstText);
        expect(await second.readAsString(), contains('second-content'));
      },
    );
    test(
      '${format.name} share hands the OS only the filtered completed file',
      () async {
        await service.exportAndShare(
          messages: [
            message('outside-range', 1),
            message('included', 10),
            message('ephemeral-fixture', 10, lifetime: 1),
          ],
          roomName: 'Fixture room',
          format: format,
          dateRange: ExportDateRange.custom,
          customStart: DateTime(2026, 9, 10),
          customEnd: DateTime(2026, 9, 10),
        );
        expect(shares, hasLength(1));
        final args = Map<Object?, Object?>.from(shares.single.arguments as Map);
        expect(args['subject'], 'Chat export - Fixture room');
        final files = args['paths'] as List;
        expect(files, hasLength(1));
        final text = await File(files.single as String).readAsString();
        expect(text, contains('included'));
        expect(text, isNot(contains('outside-range')));
        expect(text, isNot(contains('ephemeral-fixture')));
      },
    );
  }
  test('share rejection is propagated after file generation', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
          throw PlatformException(code: 'unavailable');
        });
    await expectLater(
      service.exportAndShare(
        messages: [message('content', 10)],
        roomName: 'Fixture',
        format: ExportFormat.txt,
      ),
      throwsA(isA<PlatformException>()),
    );
    expect(
      await directory.list(recursive: true).where((e) => e is File).toList(),
      hasLength(1),
    );
  });
  test('export write failure never invokes the share sheet', () async {
    final blockedPath = File('${directory.path}/not-a-directory');
    await blockedPath.writeAsString('fixture');
    PathProviderPlatform.instance = _Paths(blockedPath.path);
    await expectLater(
      service.exportAndShare(
        messages: [],
        roomName: 'Fixture',
        format: ExportFormat.json,
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(shares, isEmpty);
  });
  test(
    'empty exports produce a usable file without any message records',
    () async {
      final file = await service.exportChat(
        messages: [],
        roomName: 'Empty',
        format: ExportFormat.json,
      );
      final data = jsonDecode(await file.readAsString());
      expect(data['messageCount'], 0);
      expect(data['messages'], isEmpty);
    },
  );
}
