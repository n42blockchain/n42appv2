// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Base class for Token API functionality
///
/// Provides common configuration and utility methods
/// used by all token-related API classes.
abstract class TokenApiBase {
  /// API base URL
  late final String url;

  /// Default headers
  late final Map<String, String> header;

  TokenApiBase() {
    url = AppConfig.getApiUrlOnline('tokenViewUri');
    header = {'content-type': 'application/json'};
  }

  /// HTTP client for making requests
  BaseHttp get httpClient => BaseApi.requestEmptyH;

  /// Create error MessageModel
  MessageModel createError(dynamic data) {
    final mm = MessageModel.error();
    mm.data = data;
    return mm;
  }

  /// Create success MessageModel
  MessageModel createSuccess(dynamic data) {
    final mm = MessageModel();
    mm.data = data;
    return mm;
  }

  /// Convert API error code to message
  String errorMessage(int code) {
    switch (code) {
      case 400:
        return S.current.g_key_error_11;
      case 401:
        return S.current.g_key_error_12;
      case 403:
        return S.current.g_key_error_13;
      case 404:
        return S.current.g_key_error_14;
      case 500:
        return S.current.g_key_error_16;
      default:
        return '${S.current.g_key_error_22}$code';
    }
  }
}
