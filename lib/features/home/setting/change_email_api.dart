// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

class ChangeEmailApi {
  ChangeEmailApi()
    : _http = BaseHttp(
        AppConfig.getApiUrlOnline('userInfoHost'),
        AppConfig.getApiUrlOnline('userInfoHost'),
        {},
      );

  final BaseHttp _http;

  Future<dynamic> sendUpdateEmailCode(String newEmail) {
    return _post(
      '/v1/l/user/send/update/email/code',
      _authBody(newEmail: newEmail),
      'send code',
    );
  }

  Future<dynamic> verifyUpdateEmailCode(String code) {
    return _post(
      '/v1/l/user/verify/update/email/code',
      _authBody(code: code),
      'verify code',
    );
  }

  Future<dynamic> updateEmail({
    required String newEmail,
    required String code,
  }) {
    return _post(
      '/v1/l/user/update/email',
      _authBody(newEmail: newEmail, code: code),
      'update email',
    );
  }

  Map<String, dynamic> _authBody({String? newEmail, String? code}) {
    final user = AppGlobals.userInfo;
    final source = user?.source;
    final body = <String, dynamic>{
      'uuid': user?.uuid ?? '',
      'token': user?.token ?? '',
      'source': source == null || source.isEmpty ? 'app' : source,
    };
    if (newEmail != null) {
      body['new_email'] = newEmail;
    }
    if (code != null) {
      body['code'] = code;
    }
    return body;
  }

  Future<dynamic> _post(
    String path,
    Map<String, dynamic> body,
    String action,
  ) async {
    AppLogger.i('ChangeEmailApi', '$action request started: $path');
    try {
      final response = await _http.post<dynamic>(
        path,
        params: const {},
        data: body,
        timeout: const Duration(seconds: 20),
      );
      AppLogger.i('ChangeEmailApi', '$action request succeeded');
      return response;
    } catch (error) {
      AppLogger.w('ChangeEmailApi', '$action request failed: $error');
      rethrow;
    }
  }
}
