// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:dio/dio.dart';

class FaceApi {
  final String _url;
  final Map<String, String> _header;

  FaceApi()
      : _url = AppConfig.apiUrl['face'],
        _header = const {'content-type': 'application/x-www-form-urlencoded'};

  // ── 内部工具：统一解析响应 ────────────────────────────────────────────────
  //
  // 后端响应有两种格式：
  //   A. 带 code 包装：{"code": 200, "data": {...}}  （标准格式）
  //   B. 直接返回对象：{"match": true, "address": "..."} （旧格式）
  //
  // 优先识别格式 A；若无 "code" 字段则按格式 B 处理（向后兼容）。
  MessageModel _parseResponse(dynamic data) {
    if (data == null) {
      return MessageModel.error()..data = 'Empty response from server';
    }
    if (data is Map && data.containsKey('code')) {
      // 格式 A：带 code 包装
      if (data['code'] == 200) {
        return MessageModel()..data = data['data'];
      }
      return MessageModel.error()
        ..data = data['err'] ?? data['message'] ?? 'Error ${data['code']}';
    }
    // 格式 B：直接数据（向后兼容）
    return MessageModel()..data = data;
  }

  // ── 构建 MultipartFile ────────────────────────────────────────────────────
  Future<MultipartFile> _buildMultipart(
      dynamic file, String filename, int type) async {
    if (type == 0) return MultipartFile.fromFile(file, filename: filename);
    return MultipartFile.fromBytes(file as List<int>, filename: filename);
  }

  // ── 统一执行 POST 并解析响应 ──────────────────────────────────────────────
  Future<MessageModel> _postFace(String path, FormData fd) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '$_url/$path',
        params: {},
        data: fd,
        header: _header,
        addUserInfo: true,
      );
      return _parseResponse(data);
    } on DioException catch (e) {
      return MessageModel.error()..data = e.message ?? e.toString();
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
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
    final f = await _buildMultipart(file, filename, type);
    final fd = FormData.fromMap({'face': f, 'address': address});
    return _postFace('address_upload_face', fd);
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
    final f = await _buildMultipart(file, filename, type);
    final fd = FormData.fromMap({'face': f});
    return _postFace('detect_face', fd);
  }

  // ── 解绑人脸 ──────────────────────────────────────────────────────────────
  //
  // DELETE /delete_face
  Future<MessageModel> deleteBinding(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.delete(
        '$_url/delete_face',
        params: {'address': address},
        data: {'address': address},
        header: _header,
        addUserInfo: true,
      );
      return _parseResponse(data);
    } on DioException catch (e) {
      return MessageModel.error()..data = e.message ?? e.toString();
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
