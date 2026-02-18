// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/models/message_model.dart';

/// 将 Result 转为 MessageModel，在迁移期保持 UI 层调用方不变。
///
/// 待 UI 层迁移完成后删除此文件。
MessageModel resultToMessageModel<T>(Result<T, AppError> result) {
  return result.when(
    success: (value) => MessageModel()..data = value,
    failure: (error) => MessageModel.error()..data = error.message,
  );
}
