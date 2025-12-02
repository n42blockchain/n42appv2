import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileImport{
  fileImport()async{
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final content = await File(result.files.single.path!).readAsString();
      return content;
    }
    return "";
  }
}