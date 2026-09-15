// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:get_it/get_it.dart';
import 'package:n42_chat/n42_chat.dart' show AiService, AiMessage, AiRole;
import 'package:n42_wallet/features/ai_assistant/domain/wallet_ai_channel.dart';

/// 复用 n42_chat 已注册的 `AiService`（云端 LLM）作为钱包 AI 助手的通道。
///
/// chat 把 `AiService` 注册到全局 `GetIt.instance`（见 chat `injection.dart`），宿主
/// 钱包同进程可取。未注册（chat 未初始化 / 未配置 AI key）或调用失败时返回 null，
/// 引擎自动降级到规则回答。**只读用途**：仅做问答，不触碰签名。
class ChatAiChannel implements WalletAiChannel {
  const ChatAiChannel();

  @override
  Future<String?> ask(String systemPrompt, String userPrompt) async {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<AiService>()) return null;
    try {
      final ai = getIt<AiService>();
      final res = await ai.completion([
        AiMessage(role: AiRole.user, content: userPrompt),
      ], systemPrompt: systemPrompt);
      final text = res.text.trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      // AI key 未配 / 网络失败 / 类型不匹配——静默降级。
      return null;
    }
  }
}
