import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/file_import.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FilePickerPlatform originalPlatform;
  late Directory tempDirectory;

  setUp(() async {
    originalPlatform = FilePickerPlatform.instance;
    tempDirectory = await Directory.systemTemp.createTemp('file-import-test-');
  });

  tearDown(() async {
    FilePickerPlatform.instance = originalPlatform;
    await tempDirectory.delete(recursive: true);
  });

  test('returns selected file contents', () async {
    final file = File('${tempDirectory.path}/key.txt');
    await file.writeAsString('wallet import payload');
    FilePickerPlatform.instance = _FakeFilePicker([
      _TestPlatformFile(file.path),
    ]);

    expect(await FileImport().fileImport(), 'wallet import payload');
  });

  test('returns empty content when the picker is canceled', () async {
    FilePickerPlatform.instance = _FakeFilePicker(const []);

    expect(await FileImport().fileImport(), isEmpty);
  });
}

class _FakeFilePicker extends FilePickerPlatform {
  _FakeFilePicker(this.files);

  final List<PlatformFile> files;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => files;
}

final class _TestPlatformFile extends PlatformFile {
  _TestPlatformFile(this.path);

  @override
  final String path;

  @override
  String get name => 'key.txt';

  @override
  Uri get uri => Uri.file(path);

  @override
  int? lengthSync() => 21;

  @override
  Future<int?> length() async => 21;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
