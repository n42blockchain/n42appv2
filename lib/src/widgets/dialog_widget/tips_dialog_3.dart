import 'package:flutter/material.dart';
//自定义
Future tipsDialog3(BuildContext context,child)async{
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        content: child,
      );
    },
  );
}