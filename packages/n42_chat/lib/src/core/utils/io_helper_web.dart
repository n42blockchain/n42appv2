/// 确保目录存在（Web 平台无操作）
Future<void> ensureDirectoryExists(String path) async {
  // No-op on web
}

/// 检查目录是否存在（Web 平台始终返回 false）
bool directoryExists(String path) {
  return false;
}

/// 检查文件是否存在（Web 平台始终返回 false）
bool fileExists(String path) {
  return false;
}

/// 删除文件（Web 平台无操作）
Future<void> deleteFile(String path) async {
  // No-op on web
}

/// 读取文件内容（Web 平台返回空列表）
Future<List<int>> readFileBytes(String path) async {
  return [];
}

/// 写入文件内容（Web 平台无操作）
Future<void> writeFileBytes(String path, List<int> bytes) async {
  // No-op on web
}
