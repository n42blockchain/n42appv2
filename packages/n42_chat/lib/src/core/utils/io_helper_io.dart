import 'dart:io' as io;

/// 确保目录存在
Future<void> ensureDirectoryExists(String path) async {
  final dir = io.Directory(path);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
}

/// 检查目录是否存在
bool directoryExists(String path) {
  return io.Directory(path).existsSync();
}

/// 检查文件是否存在
bool fileExists(String path) {
  return io.File(path).existsSync();
}

/// 删除文件
Future<void> deleteFile(String path) async {
  final file = io.File(path);
  if (file.existsSync()) {
    await file.delete();
  }
}

/// 读取文件内容
Future<List<int>> readFileBytes(String path) async {
  return io.File(path).readAsBytes();
}

/// 写入文件内容
Future<void> writeFileBytes(String path, List<int> bytes) async {
  await io.File(path).writeAsBytes(bytes);
}
