import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileImport {
  Future<String> fileImport() async {
    final result = await FilePicker.pickFile();
    final path = result?.path;
    if (path != null) {
      final content = await File(path).readAsString();
      return content;
    }
    return "";
  }
}
