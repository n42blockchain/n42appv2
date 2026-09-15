import 'package:flutter/material.dart';

//自定义
Future<dynamic> tipsDialog3(BuildContext context, Widget child) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: child,
        ),
      );
    },
  );
}
