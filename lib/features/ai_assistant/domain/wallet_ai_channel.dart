// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 钱包 AI 助手的 LLM 通道（座）。
///
/// 规则引擎处理结构化意图；自然语言/未识别意图回退到此通道（如复用 chat 的
/// `AiService`，见 `data/chat_ai_channel.dart`）。不可用时返回 null，引擎据此降级。
abstract class WalletAiChannel {
  /// 询问 LLM；返回回复文本，**不可用/失败返回 null**（绝不抛）。
  Future<String?> ask(String systemPrompt, String userPrompt);
}
