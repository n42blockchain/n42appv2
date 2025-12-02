import 'dart:io';

import 'package:n42appv2/src/chat/models/squad_file_type.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  ///获取文件名
  String getFileNameByPath(String filePath) {
    var name =
    filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
    return name;
  }

  ///获取文件后缀 png mp3
  String? getFileSuffixByPath(String filePath) {
    var name =
    filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
    if (name.contains(".")) {
      var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
      return suffix;
    }
    return null;
  }

  ///根据文件名 生成临时文件
  Future<String> getTempDirByName(String fileName) async {
    Directory tempDir = await getTemporaryDirectory();
    // String tempPath = tempDir.path + "/download/";
    String tempPath = tempDir.path;
    if (!await createDirectory(tempPath)) {
      return "";
    }
    return '$tempPath/$fileName';
  }

  ///根据文件名 生成临时文件
  Future<String?> getSDCardDirByName(String fileName) async {
    Directory? tempDir;
    if (Platform.isIOS) {
      ///ios平台
      tempDir = await getApplicationSupportDirectory();
    } else {
      tempDir = await getExternalStorageDirectory();
    }
    if (tempDir == null) return null;
    String tempPath = "${tempDir.path}/download/";
    String uri = tempPath + fileName;
    return Future.value(uri);
  }

  //判断文件是否存在 不存在就生成 最后返回结果
  Future<bool> createDirectory(String path) async {
    bool exists = await Directory(path).exists();
    if (!exists) {
      await Directory(path).create(recursive: true);
    }
    return await Directory(path).exists();
  }

  ///计算文件大小
  String computerFileSize(String filePath) {
    File file = File(filePath);
    int fileSize = file.lengthSync();
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      double sizeInKB = fileSize / 1024;
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      double sizeInMB = fileSize / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(2)} MB';
    } else {
      double sizeInGB = fileSize / (1024 * 1024 * 1024);
      return '${sizeInGB.toStringAsFixed(2)} GB';
    }
  }


  //获取消息类型
  static SquadFileType getType(String type) {
    switch (type) {
      case "image":
        return SquadFileType.image;
      case "video":
        return SquadFileType.video;
      case "audio":
        return SquadFileType.audio;
      case "text":
        return SquadFileType.text;
      default:
        return SquadFileType.any;
    }
  }


}