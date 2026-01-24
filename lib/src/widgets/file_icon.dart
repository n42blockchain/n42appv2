import 'package:flutter/material.dart';
import 'package:file_icon/file_icon.dart' show iconSetMap;

class FileIcon extends StatelessWidget {
  final String fileName;
  final double? size;
  final Color? iconColor;

  FileIcon(String fileName, {super.key, this.size, this.iconColor})
      : fileName = fileName.toLowerCase();

  @override
  Widget build(BuildContext context) {
    String? key;

    if (iconSetMap.containsKey(fileName)) {
      key = fileName;
    } else {
      var chunks = fileName.split('.').sublist(1);
      while (chunks.isNotEmpty) {
        var k = '.${chunks.join()}';
        if (iconSetMap.containsKey(k)) {
          key = k;
          break;
        }
        chunks = chunks.sublist(1);
      }
    }
    key ??= '.txt';
    return Icon(
      IconData(
        iconSetMap[key]!.codePoint,
        fontFamily: 'Seti',
        fontPackage: 'file_icon',
      ),
      // color: Color(iconSetMap[key]!.color),
      color: iconColor,
      size: size,
    );
  }
}