import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileImport {
  Future<String> fileImport() async {
    final files = await FilePicker.pickFiles();
    if (files.isNotEmpty) {
      final content = await File(files.first.path!).readAsString();
      return content;
    }
    return "";
  }
}
