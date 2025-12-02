import 'dart:typed_data';

import 'package:dio/dio.dart';

class AppendixModel{
  String name="";
  String path="";
  Uint8List? imgMini=null;
  String url="";
  CancelToken? cancelToken;
  int upCount=0;
  int upTotal=0;
  int state=0;//0未开始上传，1正在上传，2上传成功，3上传失败
}