// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:dio/dio.dart';

class FaceApi {
  late String url;
  late Map<String, String> header;

  FaceApi() {
    url = AppConfig.apiUrl['face'];
    header = {'content-type': 'application/x-www-form-urlencoded'};
  }

  // ── 内部工具：统一解析响应 ────────────────────────────────────────────────
  //
  // 后端响应有两种格式：
  //   A. 带 code 包装：{"code": 200, "data": {...}}  （标准格式）
  //   B. 直接返回对象：{"match": true, "address": "..."} （旧格式）
  //
  // 优先识别格式 A；若无 "code" 字段则按格式 B 处理（向后兼容）。
  MessageModel _parseResponse(dynamic data) {
    final mm = MessageModel();
    if (data == null) {
      mm.error = true;
      mm.data = 'Empty response from server';
      return mm;
    }
    if (data is Map && data.containsKey('code')) {
      // 格式 A：带 code 包装
      if (data['code'] == 200) {
        mm.data = data['data'];
      } else {
        mm.error = true;
        mm.data = data['err'] ?? data['message'] ?? 'Error ${data['code']}';
      }
    } else {
      // 格式 B：直接数据（向后兼容）
      mm.data = data;
    }
    return mm;
  }

  // ── 绑定人脸到钱包地址 ────────────────────────────────────────────────────
  //
  // POST /address_upload_face
  // 响应 data 字段: {"match": bool, "address": String}
  //   match=true  → 该人脸已绑定到 address，需提示用户已绑定
  //   match=false → 绑定成功，address 为本次绑定的地址
  Future<MessageModel> binding(
    String address,
    dynamic file,
    String filename, {
    int type = 0,
  }) async {
    try {
      final MultipartFile f = type == 0
          ? await MultipartFile.fromFile(file, filename: filename)
          : MultipartFile.fromBytes(file as List<int>, filename: filename);
      final fd = FormData.fromMap({"face": f, "address": address});
      final data = await BaseApi.requestEmptyH.post(
        '$url/address_upload_face',
        params: {},
        data: fd,
        header: header,
        addUserInfo: true,
      );
      return _parseResponse(data);
    } on DioException catch (e) {
      final mm = MessageModel.error();
      mm.data = e.message ?? e.toString();
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  // ── 人脸检测与匹配 ────────────────────────────────────────────────────────
  //
  // POST /detect_face
  // 响应 data 字段: {"match": bool, "address": String}
  //   match=true  → 人脸匹配到 address
  //   match=false → 无匹配
  Future<MessageModel> match(
    dynamic file,
    String filename, {
    int type = 0,
  }) async {
    try {
      final MultipartFile f = type == 0
          ? await MultipartFile.fromFile(file, filename: filename)
          : MultipartFile.fromBytes(file as List<int>, filename: filename);
      final fd = FormData.fromMap({"face": f});
      final data = await BaseApi.requestEmptyH.post(
        '$url/detect_face',
        params: {},
        data: fd,
        header: header,
        addUserInfo: true,
      );
      return _parseResponse(data);
    } on DioException catch (e) {
      final mm = MessageModel.error();
      mm.data = e.message ?? e.toString();
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  // ── 解绑人脸 ──────────────────────────────────────────────────────────────
  //
  // DELETE /delete_face
  Future<MessageModel> deleteBinding(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.delete(
        '$url/delete_face',
        params: {"address": address},
        data: {"address": address},
        header: header,
        addUserInfo: true,
      );
      return _parseResponse(data);
    } on DioException catch (e) {
      final mm = MessageModel.error();
      mm.data = e.message ?? e.toString();
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
